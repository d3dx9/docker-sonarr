# syntax=docker/dockerfile:1

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# Install git and other build dependencies
RUN apk add --no-cache git

WORKDIR /src

# Clone only what we need
RUN git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git . && \
    echo "Building from commit: $(git rev-parse HEAD)" && \
    cd src

# Set working directory to src
WORKDIR /src/src

# Restore packages with optimizations
RUN dotnet restore Sonarr.sln \
    --verbosity minimal \
    --runtime linux-musl-x64

# Build and publish
RUN dotnet publish Sonarr.sln \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained false \
    --no-restore \
    --verbosity minimal \
    -p:PublishReadyToRun=false \
    -p:PublishSingleFile=false \
    -o /app/sonarr/bin

# Runtime stage  
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

LABEL maintainer="d3dx9"
ARG VERSION="1337"
ARG BUILD_DATE="2025-08-03"

# Install runtime dependencies
RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet

# Copy built application
COPY --from=builder /app/sonarr/bin /app/sonarr/bin

# Create package info
RUN echo -e "UpdateMethod=docker\nBranch=v5-develop\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
    printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
    rm -rf /app/sonarr/bin/Sonarr.Update

# Set working directory
WORKDIR /app/sonarr

# Expose port
EXPOSE 8989

# Run Sonarr
CMD ["./bin/Sonarr", "-nobrowser", "-data=/config"]

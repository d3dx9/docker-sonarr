# syntax=docker/dockerfile:1

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# Install git and other build dependencies
RUN apk add --no-cache git

# Set memory limits for .NET
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

WORKDIR /src

# Clone only what we need
RUN git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git . && \
    echo "Building from commit: $(git rev-parse HEAD)"

# Set working directory to src
WORKDIR /src/src

# Clean up unnecessary files to save memory (but keep NuGet.Config)
RUN find . -name "*.md" -delete && \
    find . -name "*.yml" -delete && \
    find . -name "*.yaml" -delete

# Restore packages with memory optimizations and warning suppression
RUN dotnet restore Sonarr.sln \
    --disable-parallel \
    --verbosity minimal \
    --runtime linux-musl-x64 \
    --configfile NuGet.Config \
    -p:NoWarn=NETSDK1188

# Build the solution first
RUN dotnet build Sonarr.sln \
    -c Release \
    -f net8.0 \
    --no-restore \
    --verbosity minimal \
    --disable-parallel \
    -p:DebugType=None \
    -p:DebugSymbols=false \
    -p:EmbedUntrackedSources=false \
    -p:NoWarn=NETSDK1188

# Publish the main Sonarr project instead of the solution
RUN dotnet publish NzbDrone.Host/Sonarr.Host.csproj \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained false \
    --no-restore \
    --no-build \
    --verbosity minimal \
    -p:PublishReadyToRun=false \
    -p:PublishSingleFile=false \
    -p:DebugType=None \
    -p:DebugSymbols=false \
    -p:EmbedUntrackedSources=false \
    -p:NoWarn=NETSDK1188 \
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

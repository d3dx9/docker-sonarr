# syntax=docker/dockerfile:1

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

WORKDIR /src

# Install git
RUN apk add --no-cache git

# Clone repository
RUN git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git . && \
    echo "Building from commit: $(git rev-parse HEAD)"

# Copy only project files first for better caching
WORKDIR /src/src
RUN find . -name "*.csproj" -o -name "*.sln" | head -20

# Restore packages (this will be cached if project files don't change)
RUN dotnet restore Sonarr.sln --disable-parallel --verbosity minimal

# Build and publish
RUN dotnet publish Sonarr.sln \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained false \
    --no-restore \
    --verbosity minimal \
    -o /app/sonarr/bin

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

LABEL maintainer="d3dx9"
ARG VERSION="1337"
ARG BUILD_DATE

RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet

COPY --from=builder /app/sonarr/bin /app/sonarr/bin

RUN echo -e "UpdateMethod=docker\nBranch=v5-develop\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
    printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
    rm -rf /app/sonarr/bin/Sonarr.Update

CMD ["/app/sonarr/bin/Sonarr"]

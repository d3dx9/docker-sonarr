# syntax=docker/dockerfile:1

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

WORKDIR /src

# Copy solution and project files first (for better caching)
COPY src/*.sln ./
COPY src/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ${file%.*}/ && mv $file ${file%.*}/; done

# Restore packages (this layer will be cached if project files don't change)
RUN dotnet restore --disable-parallel

# Copy source code
COPY src/ ./

# Build and publish
RUN dotnet publish Sonarr.sln \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained false \
    --no-restore \
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
    printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version

CMD ["/app/sonarr/bin/Sonarr"]

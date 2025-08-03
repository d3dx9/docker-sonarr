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

# Create a Directory.Build.props to override project settings globally
RUN echo '<Project>' > Directory.Build.props && \
    echo '  <PropertyGroup>' >> Directory.Build.props && \
    echo '    <NoWarn>$(NoWarn);NETSDK1188;CS1591</NoWarn>' >> Directory.Build.props && \
    echo '    <TreatWarningsAsErrors>false</TreatWarningsAsErrors>' >> Directory.Build.props && \
    echo '    <WarningsAsErrors></WarningsAsErrors>' >> Directory.Build.props && \
    echo '    <DocumentationFile></DocumentationFile>' >> Directory.Build.props && \
    echo '    <GenerateDocumentationFile>false</GenerateDocumentationFile>' >> Directory.Build.props && \
    echo '  </PropertyGroup>' >> Directory.Build.props && \
    echo '</Project>' >> Directory.Build.props

# Restore packages
RUN dotnet restore Sonarr.sln \
    --disable-parallel \
    --verbosity minimal \
    --runtime linux-musl-x64 \
    --configfile NuGet.Config

# Build the solution
RUN dotnet build Sonarr.sln \
    -c Release \
    -f net8.0 \
    --no-restore \
    --verbosity minimal \
    --disable-parallel \
    -p:DebugType=portable \
    -p:DebugSymbols=true

# Find and publish the main project
RUN MAIN_PROJECT=$(find . -name "*Host*.csproj" | grep -v Test | head -1) && \
    echo "Publishing project: $MAIN_PROJECT" && \
    dotnet publish "$MAIN_PROJECT" \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained false \
    --no-restore \
    --no-build \
    --verbosity minimal \
    -p:PublishReadyToRun=false \
    -p:PublishSingleFile=false \
    -o /app/sonarr/bin

# Remove PDB files and other unnecessary files to save space
RUN find /app/sonarr/bin -name "*.pdb" -delete && \
    find /app/sonarr/bin -name "*.xml" -delete

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

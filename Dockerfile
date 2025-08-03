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

# Initial restore for building
RUN dotnet restore Sonarr.sln \
    --disable-parallel \
    --verbosity minimal \
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

# Restore specifically for the Host project with runtime identifier
RUN MAIN_PROJECT=$(find . -name "*Host*.csproj" | grep -v Test | head -1) && \
    echo "Restoring project for self-contained: $MAIN_PROJECT" && \
    dotnet restore "$MAIN_PROJECT" \
    --runtime linux-musl-x64 \
    --verbosity minimal \
    --configfile NuGet.Config

# Find and publish the main project as self-contained
RUN MAIN_PROJECT=$(find . -name "*Host*.csproj" | grep -v Test | head -1) && \
    echo "Publishing project: $MAIN_PROJECT" && \
    dotnet publish "$MAIN_PROJECT" \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained true \
    --verbosity minimal \
    -p:PublishReadyToRun=false \
    -p:PublishSingleFile=false \
    -p:PublishTrimmed=false \
    -p:UseAppHost=true \
    -o /app/sonarr/bin

# Debug: Check what was created
RUN echo "=== FILES CREATED ===" && \
    ls -la /app/sonarr/bin/ && \
    echo "=== CONFIG FILES ===" && \
    find /app/sonarr/bin -name "*.json" && \
    echo "=== EXECUTABLE FILES ===" && \
    find /app/sonarr/bin -type f -executable && \
    echo "=== HOST FILES ===" && \
    find /app/sonarr/bin -name "*Host*" && \
    echo "=== SONARR FILES ===" && \
    find /app/sonarr/bin -name "*Sonarr*" -type f

# Remove PDB files and other unnecessary files to save space
RUN find /app/sonarr/bin -name "*.pdb" -delete && \
    find /app/sonarr/bin -name "*.xml" -delete

# Runtime stage - use a minimal alpine image since we're self-contained
FROM alpine:3.18

LABEL maintainer="d3dx9"
ARG VERSION="1337"
ARG BUILD_DATE="2025-01-03"

# Install minimal runtime dependencies for Alpine Linux
RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet \
    libgcc \
    libstdc++ \
    zlib

# Copy built application
COPY --from=builder /app/sonarr/bin /app/sonarr/bin

# Debug: Show what was copied and find the correct executable
RUN echo "=== COPIED FILES ===" && \
    ls -la /app/sonarr/bin/ && \
    echo "=== EXECUTABLE FILES ===" && \
    find /app/sonarr/bin -type f -executable && \
    echo "=== POTENTIAL MAIN FILES ===" && \
    find /app/sonarr/bin -name "*Host*" -o -name "*Sonarr*" | grep -v ".dll" | head -5

# Make executable files executable (find the correct one)
RUN find /app/sonarr/bin -type f -executable -exec chmod +x {} \; && \
    if [ -f /app/sonarr/bin/Sonarr.Host ]; then \
        echo "Found Sonarr.Host executable"; \
    elif [ -f /app/sonarr/bin/NzbDrone.Host ]; then \
        echo "Found NzbDrone.Host executable"; \
        ln -s NzbDrone.Host /app/sonarr/bin/Sonarr.Host; \
    else \
        echo "Looking for any executable file..." && \
        EXEC_FILE=$(find /app/sonarr/bin -type f -executable | grep -v "\.so$" | head -1) && \
        if [ -n "$EXEC_FILE" ]; then \
            echo "Found executable: $EXEC_FILE" && \
            ln -s "$(basename "$EXEC_FILE")" /app/sonarr/bin/Sonarr.Host; \
        else \
            echo "No executable found, will try DLL approach"; \
        fi \
    fi

# Create package info
RUN echo -e "UpdateMethod=docker\nBranch=v5-develop\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
    printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
    rm -rf /app/sonarr/bin/Sonarr.Update

# Set working directory
WORKDIR /app/sonarr

# Expose port
EXPOSE 8989

# Try to run the executable, fallback to DLL if needed
CMD if

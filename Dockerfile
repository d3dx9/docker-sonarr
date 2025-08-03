# syntax=docker/dockerfile:1

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# Install git and other build dependencies
RUN apk add --no-cache git nodejs npm yarn

# Set memory limits for .NET
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

WORKDIR /src

# Clone the official Sonarr repository
RUN git clone --depth 1 --branch develop https://github.com/Sonarr/Sonarr.git . && \
    echo "Building from commit: $(git rev-parse HEAD)"

# Set working directory to src
WORKDIR /src

# Install frontend dependencies and build UI
RUN yarn install --frozen-lockfile --network-timeout 120000 && \
    yarn build --production

# Create a Directory.Build.props to override project settings globally
RUN echo '<Project>' > src/Directory.Build.props && \
    echo '  <PropertyGroup>' >> src/Directory.Build.props && \
    echo '    <NoWarn>$(NoWarn);NETSDK1188;CS1591</NoWarn>' >> src/Directory.Build.props && \
    echo '    <TreatWarningsAsErrors>false</TreatWarningsAsErrors>' >> src/Directory.Build.props && \
    echo '    <WarningsAsErrors></WarningsAsErrors>' >> src/Directory.Build.props && \
    echo '    <DocumentationFile></DocumentationFile>' >> src/Directory.Build.props && \
    echo '    <GenerateDocumentationFile>false</GenerateDocumentationFile>' >> src/Directory.Build.props && \
    echo '  </PropertyGroup>' >> src/Directory.Build.props && \
    echo '</Project>' >> src/Directory.Build.props

# Set working directory to src for .NET operations
WORKDIR /src/src

# Restore packages
RUN dotnet restore --verbosity minimal

# Build the solution
RUN dotnet build -c Release -f net8.0 --no-restore --verbosity minimal

# Publish the Console application (main entry point)
RUN dotnet publish NzbDrone.Console/NzbDrone.Console.csproj \
    -c Release \
    -f net8.0 \
    -r linux-musl-x64 \
    --self-contained true \
    --verbosity minimal \
    -p:PublishReadyToRun=false \
    -p:PublishSingleFile=false \
    -p:PublishTrimmed=false \
    -o /app/sonarr/bin

# Copy the frontend build to the output
COPY --from=builder /src/_output/UI /app/sonarr/bin/UI

# Remove PDB files and other unnecessary files to save space
RUN find /app/sonarr/bin -name "*.pdb" -delete && \
    find /app/sonarr/bin -name "*.xml" -delete

# Runtime stage - use minimal alpine since we're self-contained
FROM alpine:3.18

LABEL maintainer="Sonarr Team"
ARG VERSION="4.0"
ARG BUILD_DATE="2025-01-03"

# Install minimal runtime dependencies for Alpine Linux
RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    libgcc \
    libstdc++ \
    zlib \
    ca-certificates

# Copy built application
COPY --from=builder /app/sonarr/bin /app/sonarr/bin

# Make the executable file executable
RUN chmod +x /app/sonarr/bin/Sonarr

# Create sonarr user and group
RUN addgroup -g 13001 -S sonarr && \
    adduser -u 13001 -S sonarr -G sonarr

# Create directories and set permissions
RUN mkdir -p /config /downloads /tv && \
    chown -R sonarr:sonarr /app/sonarr /config /downloads /tv

# Create package info
RUN echo -e "UpdateMethod=docker\nBranch=develop\nPackageVersion=${VERSION}\nPackageAuthor=Sonarr Team" > /app/sonarr/package_info && \
    printf "Version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version

# Set working directory
WORKDIR /app/sonarr

# Switch to sonarr user
USER sonarr

# Expose port
EXPOSE 8989

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8989/ping || exit 1

# Run the main Sonarr executable
CMD ["./bin/Sonarr", "-nobrowser", "-data=/config"]

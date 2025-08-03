# syntax=docker/dockerfile:1

FROM alpine:3.22

LABEL maintainer="d3dx9"
ARG VERSION="1337"
ARG BUILD_DATE

# .NET SDK 8.0.405 installieren
RUN echo "**** install packages ****" && \
    apk add --no-cache \
      icu-libs \
      sqlite-libs \
      xmlstarlet \
      git \
      curl \
      bash && \
    echo "**** prepare tempdir ****" && \
    mkdir -p /run/sonarr-temp && \
    echo "**** install .NET SDK 8.0.405 ****" && \
    curl -SL https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -o dotnet-install.sh && \
    bash dotnet-install.sh --version 8.0.405 --install-dir /usr/lib/dotnet && \
    ln -s /usr/lib/dotnet/dotnet /usr/bin/dotnet

# Sonarr aus Fork bauen
RUN echo "**** build sonarr from latest v5-develop commit ****" && \
    mkdir -p /app/sonarr/bin && \
    cd /tmp && \
    git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git Sonarr && \
    cd Sonarr && \
    echo "Building from commit: $(git rev-parse HEAD)" && \
    dotnet publish src/Sonarr.sln \
      -c Release \
      -f net8.0 \
      -r linux-musl-x64 \
      --self-contained false \
      -o /app/sonarr/bin && \
    echo -e "UpdateMethod=docker\nBranch=v5-develop\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
    printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
    echo "**** cleanup ****" && \
    rm -rf /app/sonarr/bin/Sonarr.Update /tmp/* && \
    apk del git curl bash

# Startkommando (anpassbar)
CMD ["/app/sonarr/bin/Sonarr"]

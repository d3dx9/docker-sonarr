# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="artex.club - Sonarr - version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment variables
ENV XDG_CONFIG_HOME="/config/xdg" \
  SONARR_CHANNEL="v5-develop" \
  SONARR_BRANCH="v5-develop" \
  COMPlus_EnableDiagnostics=0 \
  TMPDIR=/run/sonarr-temp \
  DOTNET_ROOT=/usr/lib/dotnet \
  PATH="$PATH:/usr/lib/dotnet"

# install dependencies and dotnet sdk 8.0.405
RUN echo "**** install packages ****" && \
  apk add --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet \
    git \
    curl \
    bash && \
  echo "**** install .NET SDK 8.0.405 ****" && \
  curl -SL https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -o dotnet-install.sh && \
  bash dotnet-install.sh --version 8.0.405 --install-dir /usr/lib/dotnet && \
  ln -s /usr/lib/dotnet/dotnet /usr/bin/dotnet

# build sonarr from source
RUN echo "**** build sonarr from latest v5-develop commit ****" && \
  mkdir -p /app/sonarr/bin && \
  cd /tmp && \
  git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git Sonarr && \
  cd Sonarr && \
  echo "Building from commit: $(git rev-parse HEAD)" && \
  dotnet publish src/Sonarr.Console \
    -c Release \
    -r linux-musl-x64 \
    --self-contained false \
    -o /app/sonarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION:-LocalBuild}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf /app/sonarr/bin/Sonarr.Update /tmp/* && \
  apk del git curl bash

# add local files (like configs or init scripts)
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config

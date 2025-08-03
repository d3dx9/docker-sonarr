# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# set environment variables
ENV XDG_CONFIG_HOME="/config/xdg" \
  SONARR_CHANNEL="v4-stable" \
  SONARR_BRANCH="main" \
  COMPlus_EnableDiagnostics=0 \
  TMPDIR=/run/sonarr-temp

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet \
    git \
    dotnet6-sdk && \
  echo "**** build sonarr from specific commit ****" && \
  mkdir -p /app/sonarr/bin && \
  cd /tmp && \
  git clone https://github.com/d3dx9/Sonarr-1.git && \
  cd Sonarr && \
  # Hier Ihren spezifischen Commit-Hash eintragen
  git checkout f7aed9547e0e7b21f0f8afad682b9afa4a95ad23 && \
  dotnet publish src/Sonarr.Console -c Release -r linux-musl-x64 --self-contained false -o /app/sonarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION:-LocalBuild}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/sonarr/bin/Sonarr.Update \
    /tmp/* && \
  apk del git dotnet6-sdk

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989

VOLUME /config

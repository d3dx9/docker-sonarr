46
#8 2.346 ----------------
#8 2.346 Installed an ASP.NET Core HTTPS development certificate.
#8 2.346 To trust the certificate, view the instructions: https://aka.ms/dotnet-https-linux
#8 2.346
#8 2.346 ----------------
#8 2.346 Write your first app: https://aka.ms/dotnet-hello-world
#8 2.346 Find out what's new: https://aka.ms/dotnet-whats-new
#8 2.346 Explore documentation: https://aka.ms/dotnet-docs
#8 2.346 Report issues and find source on GitHub: https://github.com/dotnet/core
#8 2.346 Use 'dotnet --help' to see available commands or visit: https://aka.ms/dotnet-cli
#8 2.346 --------------------------------------------------------------------------------------
#8 3.269   Determining projects to restore...
#8 6.315   Retrying 'FindPackagesByIdAsync' for source 'https://api.nuget.org/v3-flatcontainer/microsoft.netcore.app.runtime.win-x86/index.json'.
#8 6.315   No file descriptors available : '/root/.local/share/NuGet/http-cache/670c1461c29885f9aa22c281d8b7da90845b38e4$ps:_api.nuget.org_v3_index.json/list_microsoft.netcore.app.runtime.win-x86.dat-new'
#8 6.383   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/dynamitey/index.json'.
#8 6.383   Unknown socket error (pkgs.dev.azure.com:443)
#8 6.383     Unknown socket error
#8 6.384   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/servarr.fluentmigrator.runner/index.json'.
#8 6.384   Unknown socket error (pkgs.dev.azure.com:443)
#8 6.384     Unknown socket error
#8 6.384   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/servarr.fluentmigrator.runner.postgres/index.json'.
#8 6.384   Unknown socket error (pkgs.dev.azure.com:443)
#8 6.384     Unknown socket error
#8 6.425   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/sixlabors.imagesharp/index.json'.
#8 6.425   Too many open files in system (pkgs.dev.azure.com:443)
#8 6.425     Too many open files in system
#8 6.426   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/monotorrent/index.json'.
#8 6.426   Too many open files in system (pkgs.dev.azure.com:443)
#8 6.426     Too many open files in system
#8 6.427   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/microsoft.extensions.dependencyinjection.abstractions/index.json'.
#8 6.427   Too many open files in system (pkgs.dev.azure.com:443)
#8 6.427     Too many open files in system
#8 6.428   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/system.security.cryptography.protecteddata/index.json'.
#8 6.428   Too many open files in system (pkgs.dev.azure.com:443)
#8 6.428     Too many open files in system
#8 7.278 /usr/lib/dotnet/sdk/8.0.405/NuGet.targets(174,5): error : No file descriptors available : '/root/.local/share/NuGet/http-cache/670c1461c29885f9aa22c281d8b7da90845b38e4$ps:_api.nuget.org_v3_index.json/nupkg_system.reflection.emit.4.7.0.dat' [/tmp/Sonarr/src/Sonarr.sln]
#8 ERROR: process "/bin/sh -c echo \"**** build sonarr from latest v5-develop commit ****\" &&     mkdir -p /app/sonarr/bin &&     cd /tmp &&     git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git Sonarr &&     cd Sonarr &&     echo \"Building from commit: $(git rev-parse HEAD)\" &&     dotnet publish src/Sonarr.sln       -c Release       -f net8.0       -r linux-musl-x64       --self-contained false       -o /app/sonarr/bin &&     echo -e \"UpdateMethod=docker\\nBranch=v5-develop\\nPackageVersion=${VERSION}\\nPackageAuthor=[linuxserver.io](https://linuxserver.io)\" > /app/sonarr/package_info &&     printf \"Linuxserver.io version: ${VERSION}\\nBuild-date: ${BUILD_DATE}\" > /build_version &&     echo \"**** cleanup ****\" &&     rm -rf /app/sonarr/bin/Sonarr.Update /tmp/* &&     apk del git curl bash" did not complete successfully: exit code: 1
------
 > [3/3] RUN echo "**** build sonarr from latest v5-develop commit ****" &&     mkdir -p /app/sonarr/bin &&     cd /tmp &&     git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git Sonarr &&     cd Sonarr &&     echo "Building from commit: $(git rev-parse HEAD)" &&     dotnet publish src/Sonarr.sln       -c Release       -f net8.0       -r linux-musl-x64       --self-contained false       -o /app/sonarr/bin &&     echo -e "UpdateMethod=docker\nBranch=v5-develop\nPackageVersion=1337\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info &&     printf "Linuxserver.io version: 1337\nBuild-date: ${BUILD_DATE}" > /build_version &&     echo "**** cleanup ****" &&     rm -rf /app/sonarr/bin/Sonarr.Update /tmp/* &&     apk del git curl bash:
6.426   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/monotorrent/index.json'.
6.426   Too many open files in system (pkgs.dev.azure.com:443)
6.426     Too many open files in system
6.427   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/microsoft.extensions.dependencyinjection.abstractions/index.json'.
6.427   Too many open files in system (pkgs.dev.azure.com:443)
6.427     Too many open files in system
6.428   Retrying 'FindPackagesByIdAsync' for source 'https://pkgs.dev.azure.com/Servarr/7ab38f4e-5a57-4d70-84f4-94dd9bc5d6df/_packaging/323efe4e-c7d8-4bcd-acfe-5afb38d520bf/nuget/v3/flat2/system.security.cryptography.protecteddata/index.json'.
6.428   Too many open files in system (pkgs.dev.azure.com:443)
6.428     Too many open files in system
7.278 /usr/lib/dotnet/sdk/8.0.405/NuGet.targets(174,5): error : No file descriptors available : '/root/.local/share/NuGet/http-cache/670c1461c29885f9aa22c281d8b7da90845b38e4$ps:_api.nuget.org_v3_index.json/nupkg_system.reflection.emit.4.7.0.dat' [/tmp/Sonarr/src/Sonarr.sln]
------
Dockerfile:26

--------------------

  25 |     # Sonarr aus Fork bauen

  26 | >>> RUN echo "**** build sonarr from latest v5-develop commit ****" && \

  27 | >>>     mkdir -p /app/sonarr/bin && \

  28 | >>>     cd /tmp && \

  29 | >>>     git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git Sonarr && \

  30 | >>>     cd Sonarr && \

  31 | >>>     echo "Building from commit: $(git rev-parse HEAD)" && \

  32 | >>>     dotnet publish src/Sonarr.sln \

  33 | >>>       -c Release \

  34 | >>>       -f net8.0 \

  35 | >>>       -r linux-musl-x64 \

  36 | >>>       --self-contained false \

  37 | >>>       -o /app/sonarr/bin && \

  38 | >>>     echo -e "UpdateMethod=docker\nBranch=v5-develop\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \

  39 | >>>     printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \

  40 | >>>     echo "**** cleanup ****" && \

  41 | >>>     rm -rf /app/sonarr/bin/Sonarr.Update /tmp/* && \

  42 | >>>     apk del git curl bash

  43 |

--------------------

failed to solve: process "/bin/sh -c echo \"**** build sonarr from latest v5-develop commit ****\" &&     mkdir -p /app/sonarr/bin &&     cd /tmp &&     git clone --depth 1 --branch v5-develop https://github.com/d3dx9/Sonarr-1.git Sonarr &&     cd Sonarr &&     echo \"Building from commit: $(git rev-parse HEAD)\" &&     dotnet publish src/Sonarr.sln       -c Release       -f net8.0       -r linux-musl-x64       --self-contained false       -o /app/sonarr/bin &&     echo -e \"UpdateMethod=docker\\nBranch=v5-develop\\nPackageVersion=${VERSION}\\nPackageAuthor=[linuxserver.io](https://linuxserver.io)\" > /app/sonarr/package_info &&     printf \"Linuxserver.io version: ${VERSION}\\nBuild-date: ${BUILD_DATE}\" > /build_version &&     echo \"**** cleanup ****\" &&     rm -rf /app/sonarr/bin/Sonarr.Update /tmp/* &&     apk del git curl bash" did not complete successfully: exit code: 1

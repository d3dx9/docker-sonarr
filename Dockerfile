# --------- BUILD STAGE ---------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# Clone the develop-v5 branch from your repository
RUN apt-get update && \
    apt-get install -y git curl && \
    git clone --branch v5-develop https://github.com/d3dx9/Sonarr-1.git .

# Install Node.js and Yarn for frontend
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn

# Install frontend dependencies (adjust path if your UI folder is different)
WORKDIR /app/UI
RUN yarn install

# Optional: build frontend assets, ignore error if no build script
RUN yarn build || yarn run build || true

WORKDIR /app

# Restore and build Sonarr (x86)
RUN dotnet restore src/Sonarr.sln
RUN dotnet build src/Sonarr.sln -c Release
RUN dotnet publish src/NzbDrone.Console/Sonarr.Console.csproj -c Release  -f net8.0   /p:TreatWarningsAsErrors=false /p:WarningsNotAsErrors=SA1200 -o /publish /p:CopyLocalLockFileAssemblies=true
RUN dotnet build src/NzbDrone.Mono/Sonarr.Mono.csproj -c Release -f net8.0
# Kopiere nur DLLs, die NICHT im ref-Ordner liegen:
RUN find . -name "Sonarr.Mono.dll" -exec cp {} /publish/ \;
RUN find . -name "Mono.Posix.NETStandard.dll" ! -path "*/ref/*" -exec cp {} /publish/ \;
RUN find . -path "./src/*/bin/Release/net8.0/*.dll" -exec cp -n {} /publish/ \;
RUN find . -name "*.so" -exec cp -n {} /publish/ \;

# --------- RUNTIME STAGE ---------
FROM mcr.microsoft.com/dotnet/aspnet:8.0
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0
WORKDIR /app
COPY --from=build /publish .
EXPOSE 8989
ENTRYPOINT ["./Sonarr"]

-------

failed to solve: process "/bin/sh -c dotnet build Sonarr.sln     -c Release     -f net8.0     --no-restore     --verbosity minimal     --disable-parallel     -p:DebugType=portable     -p:DebugSymbols=true     -p:NoWarn=\"NETSDK1188;CS1591\"     -p:TreatWarningsAsErrors=false     -p:WarningsAsErrors=\"\"     -p:DocumentationFile=\"\"" did not complete successfully: exit code: 1

root@linux-plexaio:~# docker compose up
WARN[0000] /root/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
#1 [internal] load local bake definitions
#1 reading from stdin 488B done
#1 DONE 0.0s

#2 [internal] load git source https://github.com/d3dx9/docker-sonarr.git
#2 0.330 ref: refs/heads/master HEAD
#2 0.330 129cd3d95defcb0ac89d1009df02363117eb8835       HEAD
#2 0.638 129cd3d95defcb0ac89d1009df02363117eb8835       refs/heads/master
#2 0.304 ref: refs/heads/master HEAD
#2 0.304 129cd3d95defcb0ac89d1009df02363117eb8835       HEAD
#2 0.745 From https://github.com/d3dx9/docker-sonarr
#2 0.745  t [tag update]      master     -> master
#2 0.745  + 84c8744...129cd3d master     -> origin/master  (forced update)
#2 DONE 1.5s

#3 resolve image config for docker-image://docker.io/docker/dockerfile:1
#3 DONE 0.4s

#4 docker-image://docker.io/docker/dockerfile:1@sha256:9857836c9ee4268391bb5b09f9f157f3c91bb15821bb77969642813b0d00518d
#4 CACHED
Dockerfile:30

--------------------

  28 |     # Create a Directory.Build.props to override project settings globally

  29 |     RUN cat > Directory.Build.props << 'EOF'

  30 | >>> <Project>

  31 |       <PropertyGroup>

  32 |         <NoWarn>$(NoWarn);NETSDK1188;CS1591</NoWarn>

--------------------

failed to solve: dockerfile parse error on line 30: unknown instruction: <Project>

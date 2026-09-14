# SphereServer 0.56b

Ultima Online game server, written in C++.

This project continues development from the SphereServer **0.56b** release
([`56b-20130616`](https://github.com/Sphereserver/Source/releases/tag/56b-20130616)) of
[Sphereserver/Source](https://github.com/Sphereserver/Source), with the goal of keeping its
behavior while fixing bugs and modernizing the build. The history of the previous fork is kept in the
[`legacy`](../../tree/legacy) branch.

## Download

Every commit pushed to `main` is built automatically and published on
[GitHub Releases](../../releases).

| Package | Status |
| --- | --- |
| `SphereSvr-windows-x86.zip` | Reference build |
| `SphereSvr-linux-x86.tar.gz` | Reference build |
| `SphereSvr-windows-x64-experimental.zip` | Experimental, not 64-bit safe yet |
| `SphereSvr-linux-x64-experimental.tar.gz` | Experimental, not 64-bit safe yet |

Each release includes a `SHA256SUMS.txt` file to verify the downloads.

> [!WARNING]
> The 0.56b codebase was written for 32-bit systems. 64-bit builds compile, but may corrupt data
> (for example, packets or map files) until the port is finished. Use the x86 builds for real servers.

### Running on Linux

The x86 build is a 32-bit binary that requires glibc 2.34 or later (Debian 12, Ubuntu 22.04 or newer).
On a 64-bit system, install the 32-bit runtime libraries first:

```sh
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libmariadb3:i386 libstdc++6:i386
```

The server can run without a terminal attached (for example, as a systemd service or in a container).

## Repository layout

| Path | Contents |
| --- | --- |
| `src/common` | Shared code: scripting, resources, files, maps, bundled third-party libraries |
| `src/graysvr` | Game server: characters, items, clients, world |
| `src/network` | Network layer and packet definitions |
| `src/sphere` | Threads, mutexes, async database queue, profiling |
| `src/tables` | Script keyword tables included by the sources |
| `config` | Default `sphere.ini`, `sphereCrypt.ini` and `sphere.dic` |
| `scripts` | Default script pack |
| `docs` | Manual, revision history and packet documentation |
| `tools` | Build helper scripts |

## Building on Linux

The easiest way is to build inside a Debian container using [Docker](https://docs.docker.com/get-docker/),
which is what the CI does:

```sh
tools/docker-build.sh 32 NIGHTLY=1    # 32-bit, output in build/linux32-nightly/
tools/docker-build.sh 64 NIGHTLY=1    # 64-bit (experimental), output in build/linux64-nightly/
```

To build natively, install `g++`, `make`, `git` and the MariaDB client development package for the
target architecture (`libmariadb-dev` or `libmariadb-dev:i386`), then run:

```sh
make ARCH=32 [NIGHTLY=1] [DEBUG=1]
```

## Building on Windows

Requirements:

- Visual Studio 2022 or later, with the `Desktop development with C++` workload
- [vcpkg](https://learn.microsoft.com/vcpkg/get_started/get-started-msbuild), integrated with MSBuild
  (`vcpkg integrate install`). It installs the MariaDB client library declared in `vcpkg.json`
  on the first build.

Open `SphereSvr.vcxproj`, select a configuration (`Debug`, `Nightly` or `Release`) and a platform
(`Win32` or `x64`), then build. The output is placed in `build\<Platform>-<Configuration>\`.

From a Developer Command Prompt:

```bat
msbuild SphereSvr.vcxproj -m -p:Configuration=Nightly -p:Platform=Win32
```

## Build configurations

| Configuration | Description |
| --- | --- |
| `Release` | Optimized build |
| `Nightly` | Optimized build flagged as nightly (`_NIGHTLYBUILD`), used for automated releases |
| `Debug` | Unoptimized build with debug checks (`_DEBUG`) |

The build number shown on server startup is the number of commits in the history of the build.

## License

Licensed under the [Apache License 2.0](LICENSE).

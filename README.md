# SphereServer Legacy

[![Build](https://github.com/raydienull/Source/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/raydienull/Source/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/raydienull/Source?include_prereleases&label=release)](https://github.com/raydienull/Source/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)

Ultima Online game server, written in C++.

SphereServer Legacy continues the upstream SphereServer **0.56b** release
([`56b-20130616`](https://github.com/Sphereserver/Source/releases/tag/56b-20130616)) of
[Sphereserver/Source](https://github.com/Sphereserver/Source). It keeps the original behaviour,
script pack and save format while fixing bugs and modernizing the build. The history of the
previous fork is kept in the [`legacy`](../../tree/legacy) branch.

- Linux and Windows, 64-bit and 32-bit
- Builds with only a compiler and `make`; the MySQL layer is optional
- Prebuilt packages for every commit on `main`

## Contents

- [Download](#download)
- [Quick start](#quick-start)
- [Building](#building)
- [Running](#running)
- [Project layout](#project-layout)
- [64-bit notes](#64-bit-notes)
- [Contributing](#contributing)
- [License](#license)

## Download

Every commit on `main` is built for Linux and Windows, x64 and x86, and published on
[GitHub Releases](../../releases) with a `SHA256SUMS.txt` to verify the downloads. Each package
holds the server, the default configuration and the script pack.

## Quick start

```sh
git clone https://github.com/raydienull/Source.git && cd Source
make MYSQL=0

mkdir -p myshard/save myshard/accounts myshard/logs
cp -r config/* scripts build/linux64-release/spheresvr myshard/
cd myshard
# Set MULFILES in sphere.ini to your Ultima Online client files, then:
./spheresvr
```

## Building

### Linux

`make` builds a 64-bit release server into `build/linux<arch>-<config>/spheresvr`.

| Option | Default | Meaning |
| --- | --- | --- |
| `ARCH=64` / `ARCH=32` | `64` | Target architecture. `32` needs a 32-bit toolchain |
| `MYSQL=0` | `1` | Build without the database layer, so only a compiler is needed |
| `DEBUG=1` | off | Unoptimized build with debug checks and symbols |
| `NIGHTLY=1` | off | Flag the build as nightly, used by CI releases |

Other targets: `make help`, `make flags` (print the compiler command lines) and `make clean`.

`MYSQL=0` only drops the `DB.*` script object and the async query thread. Use it unless your
scripts talk to MySQL. With `MYSQL=1`, `make` checks for the client library first and says what to
install if it is missing.

| Distribution | Build tools | Database layer (`MYSQL=1`) |
| --- | --- | --- |
| Debian / Ubuntu | `apt-get install g++ make git` | `libmariadb-dev` |
| Fedora / RHEL | `dnf install gcc-c++ make git` | `mariadb-connector-c-devel` |
| Arch Linux | `pacman -S base-devel git` | `mariadb-libs` |
| Alpine | `apk add g++ make git linux-headers` | `mariadb-connector-c-dev` |

For a 32-bit build on a 64-bit host, install `g++-multilib` and run `make ARCH=32 MYSQL=0`.
Current Debian and Ubuntu do not package `libmariadb-dev:i386`, so a 32-bit build with the database
layer needs the Docker build below.

### Docker

Builds inside a Debian container, independent of the host toolchain. CI uses it.

```sh
tools/docker-build.sh                  # 64-bit, into build/linux64-release/
tools/docker-build.sh 32               # 32-bit, into build/linux32-release/
tools/docker-build.sh 64 NIGHTLY=1     # any make option can follow
```

`SPHERE_BUILD_IMAGE` selects another base image than `debian:bookworm-slim`.

### Windows

Requires Visual Studio 2022 or later with the *Desktop development with C++* workload, and
[vcpkg](https://learn.microsoft.com/vcpkg/get_started/get-started-msbuild) integrated with MSBuild
(`vcpkg integrate install`), which installs the MariaDB client from `vcpkg.json`.

Open `SphereSvr.vcxproj`, pick a configuration (`Debug`, `Nightly`, `Release`) and a platform
(`x64` or `Win32`), and build. From a Developer Command Prompt:

```bat
msbuild SphereSvr.vcxproj -m -p:Configuration=Release -p:Platform=x64
```

Output goes to `build\<Platform>-<Configuration>\`.

### macOS

Not supported.

## Running

A server directory needs the default `config` and `scripts`, the `save`, `accounts` and `logs`
directories, and `MULFILES` in `sphere.ini` pointing at the client files (`map0.mul`,
`tiledata.mul` and the rest). The server runs in the foreground without a terminal, so it works as a
systemd service or in a container.

Prebuilt Linux packages need glibc 2.34 or later (Debian 12, Ubuntu 22.04 or newer) and
`libmariadb3`. The x86 package also needs the 32-bit runtime on a 64-bit system:

```sh
sudo dpkg --add-architecture i386 && sudo apt-get update
sudo apt-get install libstdc++6:i386 libmariadb3:i386
```

## Project layout

```
.
├── src/
│   ├── common/        Shared code: scripting, resources, files, maps, encryption
│   ├── graysvr/       Game server: characters, items, clients, world
│   ├── network/       Network layer and packets
│   ├── sphere/        Threads, mutexes, async database queue, profiling
│   └── tables/        Script keyword tables included by the sources
├── third_party/       Bundled libraries: zlib, libev, Twofish, DEELX, MTRand
├── config/            Default sphere.ini, sphereCrypt.ini and sphere.dic
├── scripts/           Default script pack, extras in scripts/add-on
├── docs/              Scripting, protocol and upstream history references
├── tools/             Build and CI helper scripts
├── Makefile           Linux build
├── SphereSvr.vcxproj  Windows build (with vcpkg.json)
└── .github/           CI workflow and repository settings
```

The build number shown on startup is the number of commits in the build's history.

## 64-bit notes

64-bit is the default build. 32-bit stays available with `ARCH=32` or `Win32` for shards that
want the binary upstream shipped.

The 0.56b code was written for 32-bit systems: its base types were `unsigned long`, 8 bytes on
64-bit Linux, so packets, MUL records and the Twofish keystream all changed size and the x64 build
did not start. The types are now fixed width, `grayproto.h` asserts the wire sizes at compile
time, and both builds load the same client files and script pack with identical results.

Before running x64 in production, note that it has not yet run a live shard for long, and that
implicit `size_t` to `int` narrowing remains in string and file handling (lengths stay far below
2 GB, so it is latent rather than a known fault).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bundled libraries are described in
[third_party/README.md](third_party/README.md) and reference documentation in
[docs/](docs/README.md).

## License

Licensed under the [Apache License 2.0](LICENSE).

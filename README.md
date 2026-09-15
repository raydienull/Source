# SphereServer 0.56b

Ultima Online game server, written in C++.

This project continues development from the SphereServer **0.56b** release
([`56b-20130616`](https://github.com/Sphereserver/Source/releases/tag/56b-20130616)) of
[Sphereserver/Source](https://github.com/Sphereserver/Source), keeping its behaviour while fixing
bugs and modernizing the build. The history of the previous fork is kept in the
[`legacy`](../../tree/legacy) branch.

## Contents

- [Download](#download)
- [Quick start](#quick-start)
- [Building on Linux](#building-on-linux)
- [Building on Windows](#building-on-windows)
- [Running](#running)
- [64-bit and 32-bit](#64-bit-and-32-bit)
- [Repository layout](#repository-layout)

## Download

Every commit pushed to `main` is built for Linux and Windows, x64 and x86, and published on
[GitHub Releases](../../releases) with a `SHA256SUMS.txt` to verify the downloads.

## Quick start

```sh
# 1. Get a copy
git clone https://github.com/raydienull/Source.git && cd Source

# 2. Build a 64-bit server (only g++ and make needed)
make MYSQL=0

# 3. Set up a server directory
mkdir -p myshard/save myshard/accounts myshard/logs
cp -r config/* scripts build/linux64-release/spheresvr myshard/
cd myshard

# 4. Point MULFILES in sphere.ini at your Ultima Online client files, then
./spheresvr
```

## Building on Linux

`make` builds a 64-bit release server. Everything else is an option:

| Option | Default | Meaning |
| --- | --- | --- |
| `ARCH=64` / `ARCH=32` | `64` | Target architecture. `32` is optional and needs a 32-bit toolchain |
| `MYSQL=0` | `1` | Build without the database layer, so nothing beyond a compiler is needed |
| `DEBUG=1` | off | Unoptimized build with debug checks (`_DEBUG`) and debug symbols |
| `NIGHTLY=1` | off | Flag the build as nightly (`_NIGHTLYBUILD`), used for automated releases |

| Target | Does |
| --- | --- |
| `make` | Build `build/linux<arch>-<release\|debug\|nightly>/spheresvr` |
| `make help` | List targets and options |
| `make flags` | Print the exact compiler and linker command lines |
| `make clean` | Remove `build/`, for every architecture and configuration |

The build uses every CPU core by default. Each architecture and configuration has its own
directory under `build/`, so a 64-bit and a 32-bit build can live side by side.

`MYSQL=0` drops the `DB.*` script object and the async query thread. Everything else is
identical, and the binary then links against nothing but the C and C++ runtimes. Use it unless
your scripts talk to MySQL. With `MYSQL=1`, `make` checks for a usable client library before it
compiles anything and tells you what to install if it is missing.

### Debian / Ubuntu

```sh
sudo apt-get install g++ make git                 # enough for MYSQL=0
sudo apt-get install libmariadb-dev               # add this for the database layer
make
```

### Fedora / RHEL

```sh
sudo dnf install gcc-c++ make git                 # enough for MYSQL=0
sudo dnf install mariadb-connector-c-devel        # add this for the database layer
make
```

### Arch Linux

```sh
sudo pacman -S --needed base-devel git            # enough for MYSQL=0
sudo pacman -S --needed mariadb-libs              # add this for the database layer
make
```

### Alpine

```sh
apk add g++ make git linux-headers                # enough for MYSQL=0
apk add mariadb-connector-c-dev                   # add this for the database layer
make
```

### 32-bit build (optional)

On a 64-bit host, add the 32-bit toolchain first:

```sh
sudo apt-get install g++-multilib                 # Debian / Ubuntu
make ARCH=32 MYSQL=0
```

`libmariadb-dev:i386` is not packaged on current Debian and Ubuntu releases, so a native 32-bit
build with the database layer is not possible there. Use `MYSQL=0`, or build in a container as
described below. `make ARCH=32` detects a missing toolchain or library and says which way to go.

### Docker

Builds inside a Debian container, so the result does not depend on the host toolchain. It is what
CI uses, and the only way to get a 32-bit build with the database layer on a modern distribution:

```sh
tools/docker-build.sh                    # 64-bit, output in build/linux64-release/
tools/docker-build.sh 32                 # 32-bit, output in build/linux32-release/
tools/docker-build.sh 64 NIGHTLY=1       # any make option can follow
```

Set `SPHERE_BUILD_IMAGE` to use another base image than `debian:bookworm-slim`.

### macOS

Not supported. The server uses Linux and Windows specific code paths, so there is no macOS build.

## Building on Windows

Requirements:

- Visual Studio 2022 or later, with the `Desktop development with C++` workload
- [vcpkg](https://learn.microsoft.com/vcpkg/get_started/get-started-msbuild), integrated with
  MSBuild (`vcpkg integrate install`). It installs the MariaDB client library declared in
  `vcpkg.json` on the first build.

Open `SphereSvr.vcxproj`, pick a configuration (`Debug`, `Nightly` or `Release`) and a platform
(`x64` by default, or `Win32`), then build. The output goes to `build\<Platform>-<Configuration>\`.

From a Developer Command Prompt:

```bat
msbuild SphereSvr.vcxproj -m -p:Configuration=Release
msbuild SphereSvr.vcxproj -m -p:Configuration=Release -p:Platform=Win32
```

## Running

A server directory needs the default `config` and `scripts`, directories to save to, and a path
to the Ultima Online client files:

```sh
mkdir -p myshard/save myshard/accounts myshard/logs
cp -r config/* scripts myshard/
cp build/linux64-release/spheresvr myshard/
```

Then set `MULFILES` in `myshard/sphere.ini` to the directory holding `map0.mul`, `tiledata.mul`
and the rest. The server runs in the foreground and needs no terminal attached, so it works as a
systemd service or in a container.

Prebuilt Linux binaries need glibc 2.34 or later (Debian 12, Ubuntu 22.04 or newer). The x64
package needs `libmariadb3`. The x86 package is a 32-bit binary, so on a 64-bit system it needs
the 32-bit runtime:

```sh
sudo apt-get install libmariadb3                  # x64 package

sudo dpkg --add-architecture i386 && sudo apt-get update
sudo apt-get install libstdc++6:i386 libmariadb3:i386   # x86 package
```

## 64-bit and 32-bit

64-bit is the default build. 32-bit remains available with `ARCH=32` (Linux) or `Win32` (Windows)
for shards that want to stay on the binary upstream shipped, which has years of production use.

The 0.56b codebase was written for 32-bit systems. The base types were spelled `unsigned long`,
which is 8 bytes on 64-bit Linux, so `DWORD` and everything built on it silently doubled in width
there. The Linux x64 build did not even start: it aborted on
`ASSERT(MAX_BUFFER >= sizeof(CCommand))`, because the packet union had grown to 21822 bytes
against a 15360 byte socket buffer. Underneath that, 29 of the 47 packet structures and 10 of the
14 MUL record structures had a different size on the two builds, and the Twofish login encryption
produced a different keystream.

That is fixed. The types are fixed width, `grayproto.h` asserts the wire widths at compile time so
the problem cannot come back silently, and every packet member, MUL record and Twofish block
matches the 32-bit build exactly. Both builds load the same client files and the same script pack
with byte-identical output.

Worth knowing before running x64 in production:

- It has not yet been run against a live shard for any length of time.
- Implicit `size_t` to `int` narrowing remains in string and file handling. Lengths in this
  codebase stay far below 2 GB, so it is a latent class rather than a known fault.

## Repository layout

| Path | Contents |
| --- | --- |
| `src/common` | Shared code: scripting, resources, files, maps, bundled third-party libraries |
| `src/graysvr` | Game server: characters, items, clients, world |
| `src/network` | Network layer and packet definitions |
| `src/sphere` | Threads, mutexes, async database queue, profiling |
| `src/tables` | Script keyword tables included by the sources |
| `config` | Default `sphere.ini`, `sphereCrypt.ini` and `sphere.dic` |
| `scripts` | Default script pack, with optional extras in `scripts/add-on` |
| `docs` | Script manual, revision history and packet documentation (see [docs/README.md](docs/README.md)) |
| `tools` | Build helper scripts |
| `makefile` | Linux build |
| `SphereSvr.vcxproj`, `vcpkg.json` | Windows build |

Bundled third-party code lives under `src/common`: zlib 1.2.5, libev 4.1 (only the backends Linux
uses), the Twofish reference implementation, and the deelx regular expression header.

The build number shown on server startup is the number of commits in the history of the build.

## License

Licensed under the [Apache License 2.0](LICENSE).

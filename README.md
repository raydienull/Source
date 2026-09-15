# SphereServer 0.56b

Ultima Online game server, written in C++.

This project continues development from the SphereServer **0.56b** release
([`56b-20130616`](https://github.com/Sphereserver/Source/releases/tag/56b-20130616)) of
[Sphereserver/Source](https://github.com/Sphereserver/Source), keeping its behaviour while fixing
bugs and modernizing the build. The history of the previous fork is kept in the
[`legacy`](../../tree/legacy) branch.

## Download

Every commit pushed to `main` is built for Windows and Linux, x86 and x64, and published on
[GitHub Releases](../../releases) with a `SHA256SUMS.txt` to verify the downloads.

x86 is still the reference build: it is what upstream shipped and what most shards run. x64 now
lays out every packet, MUL record and save value exactly like x86 does - see
[64-bit](#64-bit) below for what that means and what is still unverified.

## Quick start

```sh
# 1. Get a copy
git clone https://github.com/raydienull/Source.git && cd Source

# 2. Build (only g++ and make needed)
make ARCH=64 MYSQL=0

# 3. Set up a server directory
mkdir -p myshard && cp -r config/* scripts myshard/ && cp build/linux64-release/spheresvr myshard/
cd myshard

# 4. Point MULFILES in sphere.ini at your Ultima Online client files, then
./spheresvr
```

## Building

| Option | Default | Meaning |
| --- | --- | --- |
| `ARCH=32` / `ARCH=64` | `32` | Target architecture |
| `MYSQL=0` | `1` | Build without the database layer, so nothing external is needed |
| `NIGHTLY=1` | off | Flag the build as nightly (`_NIGHTLYBUILD`), used for automated releases |
| `DEBUG=1` | off | Unoptimized build with debug checks (`_DEBUG`) |

The output is `build/linux<arch>-<config>/spheresvr`. `make flags` prints the exact compiler
command line, and `make clean` removes `build/`.

`MYSQL=0` drops the `DB.*` script object and the async query thread. Everything else is
identical, and the binary then links against nothing but the C and C++ runtimes. Use it unless
your scripts talk to MySQL.

### Debian / Ubuntu

```sh
sudo apt-get install g++ make git                 # enough for MYSQL=0
sudo apt-get install libmariadb-dev               # add this for the database layer
make ARCH=64
```

For a 32-bit build on a 64-bit host, add the 32-bit toolchain:

```sh
sudo dpkg --add-architecture i386 && sudo apt-get update
sudo apt-get install g++-multilib
make ARCH=32 MYSQL=0
```

`libmariadb-dev:i386` is not packaged on current Debian and Ubuntu releases, so a native 32-bit
build with the database layer is not possible there. Either use `MYSQL=0`, or build in a 32-bit
container (see [Docker](#docker) below), which is what CI does.

### Fedora / RHEL

```sh
sudo dnf install gcc-c++ make git                 # enough for MYSQL=0
sudo dnf install mariadb-connector-c-devel        # add this for the database layer
make ARCH=64
```

### Arch Linux

```sh
sudo pacman -S --needed base-devel git            # enough for MYSQL=0
sudo pacman -S --needed mariadb-libs              # add this for the database layer
make ARCH=64
```

### Alpine

```sh
apk add g++ make git linux-headers                # enough for MYSQL=0
apk add mariadb-connector-c-dev                   # add this for the database layer
make ARCH=64
```

### macOS

Not supported. The server uses Linux and Windows specific code paths, so there is no macOS build.

### Docker

Builds inside a Debian container, so the result does not depend on the host toolchain. This is
also the only way to get a 32-bit build with the database layer on a modern distribution, and it
is what CI uses:

```sh
tools/docker-build.sh 32 NIGHTLY=1    # output in build/linux32-nightly/
tools/docker-build.sh 64 NIGHTLY=1    # output in build/linux64-nightly/
```

### Windows

Requirements:

- Visual Studio 2022 or later, with the `Desktop development with C++` workload
- [vcpkg](https://learn.microsoft.com/vcpkg/get_started/get-started-msbuild), integrated with
  MSBuild (`vcpkg integrate install`). It installs the MariaDB client library declared in
  `vcpkg.json` on the first build.

Open `SphereSvr.vcxproj`, pick a configuration (`Debug`, `Nightly` or `Release`) and a platform
(`Win32` or `x64`), then build. The output goes to `build\<Platform>-<Configuration>\`.

From a Developer Command Prompt:

```bat
msbuild SphereSvr.vcxproj -m -p:Configuration=Nightly -p:Platform=Win32
```

## Running

A server directory needs the default `config` and `scripts`, a place to save to, and a path to
the Ultima Online client files:

```sh
mkdir -p myshard/save myshard/accounts
cp -r config/* scripts myshard/
```

Then set `MULFILES` in `myshard/sphere.ini` to the directory holding `map0.mul`, `tiledata.mul`
and the rest. The server runs in the foreground and needs no terminal attached, so it works as a
systemd service or in a container.

Prebuilt Linux binaries need glibc 2.34 or later (Debian 12, Ubuntu 22.04 or newer). The x86
package is a 32-bit binary, so on a 64-bit system install the 32-bit runtime:

```sh
sudo dpkg --add-architecture i386 && sudo apt-get update
sudo apt-get install libstdc++6:i386 libmariadb3:i386
```

## 64-bit

The 0.56b codebase was written for 32-bit systems. The base types were spelled `unsigned long`,
which is 8 bytes on 64-bit Linux, so `DWORD` and everything built on it silently doubled in width
there. The effect was worse than the old warning suggested: the Linux x64 build did not run at
all, aborting at startup on `ASSERT(MAX_BUFFER >= sizeof(CCommand))`, because the packet union had
grown to 21822 bytes against a 15360 byte socket buffer.

Underneath that, 29 of the 47 packet structures and 10 of the 14 MUL record structures had a
different size on the two builds, and the Twofish login encryption produced a different keystream.

That is fixed. The types are fixed width, `grayproto.h` asserts the wire widths at compile time so
the problem cannot come back silently, and every packet member, MUL record and Twofish block now
matches the 32-bit build exactly. Both builds load the same client files and the same script pack
with byte-identical output.

What is still worth knowing before running x64 in production:

- It has not been run against a live shard for any length of time. x86 has years of that.
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
| `scripts` | Default script pack |
| `docs` | Manual, revision history and packet documentation |
| `tools` | Build helper scripts |

Bundled third-party code lives under `src/common`: zlib 1.2.5, libev 4.1, the Twofish reference
implementation, and the deelx regular expression header.

The build number shown on server startup is the number of commits in the history of the build.

## License

Licensed under the [Apache License 2.0](LICENSE).

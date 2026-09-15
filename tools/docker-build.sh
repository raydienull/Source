#!/usr/bin/env bash
# Builds the Linux server inside a Debian container, so the result does not depend on the host toolchain.
# This is also the way to get a 32-bit build with the database layer on a modern 64-bit distribution,
# and it is what the CI workflow uses.
#
# Usage:   tools/docker-build.sh [64|32] [make options...]
# Example: tools/docker-build.sh                 # 64-bit release build
#          tools/docker-build.sh 32 NIGHTLY=1    # 32-bit nightly build

set -euo pipefail

ARCH=64
case "${1:-}" in
	32|64) ARCH="$1"; shift ;;
	-h|--help)
		echo "Usage: $0 [64|32] [make options...]"
		exit 0
		;;
esac

case "${ARCH}" in
	32) PLATFORM="linux/386" ;;
	64) PLATFORM="linux/amd64" ;;
esac

IMAGE="${SPHERE_BUILD_IMAGE:-debian:bookworm-slim}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker run --rm --platform "${PLATFORM}" \
	--volume "${ROOT_DIR}:/src" --workdir /src \
	--env ARCH="${ARCH}" --env HOST_UID="$(id -u)" --env HOST_GID="$(id -g)" \
	"${IMAGE}" bash -euo pipefail -c '
		apt-get update -qq
		apt-get install -y -qq --no-install-recommends ca-certificates g++ git libmariadb-dev make >/dev/null
		git config --global --add safe.directory /src
		# Give build output back to the host user
		trap "chown -R ${HOST_UID}:${HOST_GID} build src/common/version.h 2>/dev/null || true" EXIT
		make ARCH="${ARCH}" "$@"
	' bash "$@"

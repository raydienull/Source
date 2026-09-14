#!/usr/bin/env bash
# Builds the Linux server inside a Debian container, so the result does not depend on the host toolchain.
# The same script is used by the CI workflow.
#
# Usage: tools/docker-build.sh <32|64> [make options...]
# Example: tools/docker-build.sh 32 NIGHTLY=1

set -euo pipefail

ARCH="${1:-}"
case "${ARCH}" in
	32) PLATFORM="linux/386" ;;
	64) PLATFORM="linux/amd64" ;;
	*)
		echo "Usage: $0 <32|64> [make options...]" >&2
		exit 1
		;;
esac
shift

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

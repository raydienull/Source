#!/usr/bin/env bash
# Checks that every source file is built by the Makefile or SphereSvr.vcxproj,
# and that neither lists a file that does not exist.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Listed paths, normalized to forward slashes
listed=$( {
	grep -oE '(src|third_party)/[^ \\]+\.(c|cpp)' Makefile
	grep -oE 'Include="(src|third_party)\\[^"]+\.(c|cpp)"' SphereSvr.vcxproj | sed -e 's/^Include="//' -e 's/"$//' -e 's#\\#/#g'
} | sort -u )

status=0

while read -r file; do
	[[ -f "${file}" ]] || { echo "Listed but missing: ${file}"; status=1; }
done <<< "${listed}"

# libev backends are included by wrapper_ev.c, not built on their own
while read -r file; do
	grep -qxF "${file}" <<< "${listed}" || { echo "Not built by any project: ${file}"; status=1; }
done < <(find src third_party -name '*.c' -o -name '*.cpp' | grep -vE '^third_party/libev/ev(_[a-z]+)?\.c$' | sort)

[[ ${status} -eq 0 ]] && echo "Source lists are up to date."
exit ${status}

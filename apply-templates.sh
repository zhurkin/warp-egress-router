#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

debian_image="$(jq -r '.debian.image' versions.json)"
debian_suite="$(jq -r '.debian.suite' versions.json)"
warp_version="$(jq -r '.warp.version' versions.json)"

for value in debian_image debian_suite warp_version; do
    if [[ -z "${!value}" || "${!value}" == "null" ]]; then
        echo "ERROR: ${value} is not defined in versions.json" >&2
        exit 1
    fi
done

sed \
    -e "s|%%DEBIAN_IMAGE%%|${debian_image}|g" \
    -e "s|%%DEBIAN_SUITE%%|${debian_suite}|g" \
    -e "s|%%WARP_VERSION%%|${warp_version}|g" \
    Dockerfile.template > Dockerfile

echo "Generated Dockerfile"
echo "  Debian image: debian:${debian_image}"
echo "  Debian suite: ${debian_suite}"
echo "  WARP version: ${warp_version}"

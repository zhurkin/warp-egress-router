#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

debian_image="$(jq -r '.debian.image' versions.json)"
debian_suite="$(jq -r '.debian.suite' versions.json)"

if [[ -z "$debian_image" || "$debian_image" == "null" ]]; then
    echo "ERROR: debian.image is not defined in versions.json" >&2
    exit 1
fi

if [[ -z "$debian_suite" || "$debian_suite" == "null" ]]; then
    echo "ERROR: debian.suite is not defined in versions.json" >&2
    exit 1
fi

sed \
    -e "s|%%DEBIAN_IMAGE%%|${debian_image}|g" \
    -e "s|%%DEBIAN_SUITE%%|${debian_suite}|g" \
    Dockerfile.template > Dockerfile

echo "Generated Dockerfile"
echo "  Debian image: debian:${debian_image}"
echo "  Debian suite: ${debian_suite}"

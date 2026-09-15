#!/bin/sh
set -eu

mkdir -p \
    /run/cloudflare-warp \
    /var/lib/cloudflare-warp \
    /var/log/cloudflare-warp

setup_router()
{
    echo "Waiting for CloudflareWARP interface..."

    while ! ip link show CloudflareWARP >/dev/null 2>&1; do
        sleep 1
    done

    echo "CloudflareWARP interface detected"

    nft delete table ip warp-router 2>/dev/null || true

    nft add table ip warp-router

    nft 'add chain ip warp-router postrouting {
        type nat hook postrouting priority srcnat;
        policy accept;
    }'

    nft 'add rule ip warp-router postrouting
        oifname "CloudflareWARP" masquerade'

    echo "WARP egress routing configured"

    nft list table ip warp-router
}

# Wait for WARP to become connected and configure forwarding/NAT.
# On a fresh installation this simply waits until the user creates
# a WARP registration and connects.
setup_router &

exec /bin/warp-svc

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

    nft -f - <<'NFT'
table ip warp-router {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        oifname "CloudflareWARP" masquerade
    }
}
NFT

    echo "WARP egress routing configured"
    nft list table ip warp-router
}

setup_router &

exec /usr/bin/warp-svc

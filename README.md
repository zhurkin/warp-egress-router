# warp-egress-router

Containerized Cloudflare WARP egress gateway for routed network traffic.

`warp-egress-router` runs the official Cloudflare WARP Linux client in an isolated Docker network namespace using `TunnelOnly` mode. It is intended to act as a dedicated WARP egress router without changing the default routing of the Docker host.

## Why

Running WARP directly on a Linux host in tunnel mode can affect the host's routing and firewall configuration.

This project isolates WARP inside a container:

```text
Client / Router
      |
      v
warp-egress-router
      |
      v
CloudflareWARP
      |
      v
Cloudflare WARP
      |
      v
Internet

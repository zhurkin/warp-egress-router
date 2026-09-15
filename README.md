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
```

The Docker host keeps its normal default route and can continue running other networking services independently.

## Features

- Official Cloudflare WARP Linux client
- WARP `TunnelOnly` mode
- Isolated Docker network namespace
- Persistent WARP registration
- IPv4 forwarding
- Automatic NAT/MASQUERADE through `CloudflareWARP`
- Routed UDP traffic supported
- Host routing remains independent from the WARP tunnel
- Multiple independent WARP clients can run on the same host using separate network namespaces
- Debian 13.6 slim base image

## Use cases

- Dedicated WARP Internet egress
- Policy-based routing through WARP
- Selective traffic forwarding from routers or VPN gateways
- WARP egress for WireGuard-connected networks
- Building multi-egress networking setups

## Requirements

The container requires access to `/dev/net/tun` and network administration capabilities.

Example Docker Compose configuration:

```yaml
services:
  warp-egress-router:
    image: <dockerhub-user>/warp-egress-router:0.1.0
    container_name: warp-egress-router

    cap_add:
      - NET_ADMIN
      - NET_RAW

    devices:
      - /dev/net/tun:/dev/net/tun

    sysctls:
      net.ipv4.ip_forward: "1"

    volumes:
      - warp-state:/var/lib/cloudflare-warp
      - warp-logs:/var/log/cloudflare-warp

    restart: unless-stopped

volumes:
  warp-state:
  warp-logs:
```

## First registration

Each deployment should use its own WARP registration.

After starting the container:

```bash
docker compose exec warp-egress-router \
  warp-cli --accept-tos registration new
```

Set tunnel mode:

```bash
docker compose exec warp-egress-router \
  warp-cli --accept-tos mode tunnel_only
```

Connect:

```bash
docker compose exec warp-egress-router \
  warp-cli --accept-tos connect
```

Check status:

```bash
docker compose exec warp-egress-router \
  warp-cli --accept-tos status
```

The registration is stored in the persistent `warp-state` volume.

Do not copy a WARP registration between simultaneously running instances.

## How routing works

The Cloudflare WARP client creates a `CloudflareWARP` interface and its own policy routing table.

Transit traffic routed through the container is source-NATed before leaving through the WARP interface:

```text
Transit client
     |
     v
container eth0
     |
     v
IP forwarding
     |
     v
SNAT / MASQUERADE
     |
     v
CloudflareWARP
     |
     v
Internet
```

The outer WARP transport continues to use the container's normal underlay connection, preventing recursive routing through the WARP tunnel itself.

## Persistent state

WARP registration data is stored outside the image:

```text
/var/lib/cloudflare-warp
```

This allows the container to be rebuilt or recreated without creating a new WARP registration each time.

Registration data and credentials must not be committed to Git.

## Project status

Early development.

Current focus:

- Stable WARP egress routing
- Reproducible Docker images
- Persistent container lifecycle
- Selective upstream routing

Future work may include integration with external tunnel transports and redundant egress paths.

## Security

This image requires `NET_ADMIN` and access to `/dev/net/tun`.

Run it only on trusted hosts and review the container configuration before deployment.

## Disclaimer

This is an unofficial project and is not affiliated with or endorsed by Cloudflare.

Cloudflare and WARP are trademarks of Cloudflare, Inc.

## License

MIT

# External Service Health Check

[![Repository](https://img.shields.io/badge/github-SiriosDev%2FExternal--Service--HealthCheck-5a61a4?style=for-the-badge&logo=github&logoColor=white)
](https://github.com/SiriosDev/External-Service-HealthCheck)
[![Version](https://img.shields.io/github/v/tag/SiriosDev/External-Service-HealthCheck?style=for-the-badge&label=version&sort=semver)
](https://github.com/SiriosDev/External-Service-HealthCheck)
[![License](https://img.shields.io/github/license/SiriosDev/External-Service-HealthCheck?style=for-the-badge)
](https://github.com/SiriosDev/External-Service-HealthCheck/blob/main/LICENSE)

[![Build](https://img.shields.io/github/actions/workflow/status/SiriosDev/external-service-healthcheck/build_image.yml?style=for-the-badge&label=Build)
](https://github.com/SiriosDev/External-Service-HealthCheck/actions/workflows/build_image.yml)
[![Sync](https://img.shields.io/github/actions/workflow/status/SiriosDev/external-service-healthcheck/sync_info.yml?style=for-the-badge&label=Sync)
](https://github.com/SiriosDev/External-Service-HealthCheck/actions/workflows/sync_info.yml)

[![Docker Pulls](https://img.shields.io/docker/pulls/siriosdev/external-service-healthcheck?style=for-the-badge&logo=docker&label=Pulls&logoColor=white)
](https://hub.docker.com/r/siriosdev/external-service-healthcheck)
[![Ghcr Pulls](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fghcr-badge.elias.eu.org%2Fapi%2Fsiriosdev%2Fexternal-service-healthcheck&query=downloadCount&style=for-the-badge&logo=github&label=Pulls&color=2496ed)
](https://github.com/SiriosDev/External-Service-HealthCheck/pkgs/container/external-service-healthcheck)

[![Image](https://img.shields.io/badge/ghcr-ghcr.io%2Fsiriosdev%2Fexternal--service--healthcheck-5a61a4?style=for-the-badge&logo=github&logoColor=white)
](https://hub.docker.com/r/siriosdev/external-service-healthcheck)
[![Image](https://img.shields.io/badge/dockerhub-siriosdev%2Fexternal--service--healthcheck-2c64bb?style=for-the-badge&logo=docker&logoColor=white)
](https://github.com/SiriosDev/External-Service-HealthCheck/pkgs/container/external-service-healthcheck)


External Service Health Check is a small containerized helper designed with stack-based deployments in mind. It checks the health status of a containerized service from another stack, which is useful when a service depends on another service running in another stacks for wherever technical or logistical reasons.

The check is driven by the `TARGET_SERVICE` environment variable. If the target container defines a Docker healthcheck and reports `healthy`, this container is considered `healthy`. Otherwise, it is considered `unhealthy`. If the target container does not define a Docker healthcheck, the script also reports `unhealthy`.

> [!WARNING]
> This image exists to solve a specific personal need. In practice, it is a continuously running container with a healthcheck script and and an access to the Docker socket, so anyone with execution access to it can interact with the Docker daemon through that socket. At minimum, I recommend mounting the socket as read-only. I have not yet explored a reliable way to further restrict access, so if you have suggestions, feel free to open an issue or a PR.

## How It Works

The internal `healthcheck.sh` script:

1. Reads the `TARGET_SERVICE` environment variable.
2. Calls `docker inspect` on the target container name.
3. Exit with 0 only when the inspected container reports the `healthy` status.
4. Otherwise, exit with 1 for all the other status containers including containers without a healthcheck.

| Exit Codes | Resultant Status |
| ---------- | ---------------- |
| 0          | healthy          |
| 1          | unhealthy        |

## Example `compose.yaml`

```yaml
services:
  # Example of a service that depends on an external service.
  my-service:
    image: nginx:alpine
    container_name: my-service
    depends_on:
      checker:
        condition: service_healthy

  # Example of basic usage of this image
  checker:
    image: ghcr.io/external-service-healthcheck:latest
    container_name: checker
    environment:
      TARGET_SERVICE: my-external-service # Normally this matches `container_name`; otherwise use `docker ps` to find the target container name.
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```


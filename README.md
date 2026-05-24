# External Service Health Check

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


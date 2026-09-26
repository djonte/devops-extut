# Investigate the problems

Build and start the insecure image:

```bash
cd /root/tutorial
docker build -t checkov-tutorial:insecure .
docker run -d --name checkov-tutorial -p 8000:8000 checkov-tutorial:insecure
```

## Root user

Check the user ID of the running process:

```bash
docker exec checkov-tutorial id -u
```

The result is `0`, which means the process runs as root. If an attacker takes control of the application, root gives them more permissions inside the container than they need.

## Missing health check

The application is healthy at first:

```bash
curl -i http://localhost:8000/health
```

Now create a flag that makes the health endpoint return HTTP 503. The application process will keep running.

```bash
docker exec checkov-tutorial touch /tmp/app-unhealthy
curl -i http://localhost:8000/health
```

Ask Docker for the container health status:

```bash
docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' checkov-tutorial
docker inspect --format '{{.State.Running}}' checkov-tutorial
```

Docker reports `no-healthcheck` and `true`. It knows that the process is running, but it cannot detect that the application is unhealthy.

## Mutable base-image tag

Inspect the exact image digest that `python:latest` resolved to during this build:

```bash
docker image inspect python:latest --format '{{index .RepoDigests 0}}'
```

The digest identifies the image content downloaded today. The `latest` tag can point to different content in a future build, which makes builds less predictable. An explicit version tag is better for this tutorial. A digest is stronger when exact image immutability is required.

Remove the insecure container before continuing:

```bash
docker rm -f checkov-tutorial
```

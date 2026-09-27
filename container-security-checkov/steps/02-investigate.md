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
docker exec checkov-tutorial id
```

The result includes `uid=0(root)`, which means the process runs as root. Confirm that it can write inside the root user's home directory:

```bash
docker exec checkov-tutorial sh -c 'touch /root/permission-test && ls -l /root/permission-test'
```

The command succeeds because the container process has root privileges. If an attacker takes control of the application, root gives them more permissions inside the container than they need. Container root is isolated from the host by default, but using fewer privileges still reduces what a compromised process can change inside the container.

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

Inspect the digest that `python:latest` currently resolves to:

```bash
docker buildx imagetools inspect python:latest | head -n 4
```

The top-level digest should match the digest shown next to `python:latest` in the earlier build output. It identifies the image content available today. The `latest` tag can point to different content in a future build, which makes builds less predictable. An explicit version tag is better for this tutorial. A digest is stronger when exact image immutability is required.

Remove the insecure container before continuing:

```bash
docker rm -f checkov-tutorial
```

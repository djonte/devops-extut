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

Look for output similar to this:

```text
Name:      docker.io/library/python:latest
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:...
```

The value after `Digest:` should match the digest shown next to `python:latest` in the earlier build output, for example:

```text
FROM docker.io/library/python:latest@sha256:...
```

The digest identifies the image content available now. The tag can resolve to different content later even when the Dockerfile has not changed:

```text
Monday: python:latest -> sha256:aaa...
Friday: python:latest -> sha256:bbb...
```

This example is illustrative; the real tag does not need to change during the tutorial. An explicit version tag is more predictable than `latest`. A digest is stronger when exact image immutability is required.

Remove the insecure container before continuing:

```bash
docker rm -f checkov-tutorial
```

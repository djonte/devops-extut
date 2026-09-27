# Verify the fixed container

Start the fixed image:

```bash
docker run -d --name checkov-tutorial -p 8000:8000 checkov-tutorial:fixed
```

Verify that the application responds and does not run as root:

```bash
curl --fail http://localhost:8000/health
docker exec checkov-tutorial id -u
```

The user ID should be different from `0`.

Docker may first report `starting`. Wait until the health check succeeds:

```bash
for attempt in {1..20}; do
  [ "$(docker inspect --format '{{.State.Health.Status}}' checkov-tutorial)" = "healthy" ] && break
  sleep 1
done
docker inspect --format '{{.State.Health.Status}}' checkov-tutorial
```

Now enable the same controlled application failure as before:

```bash
docker exec checkov-tutorial touch /tmp/app-unhealthy
for attempt in {1..30}; do
  [ "$(docker inspect --format '{{.State.Health.Status}}' checkov-tutorial)" = "unhealthy" ] && break
  sleep 1
done
docker inspect --format 'running={{.State.Running}} health={{.State.Health.Status}}' checkov-tutorial
```

Docker should report `running=true health=unhealthy`. The process is still running, but Docker can now detect that the application is not healthy.

Clean up the practice container:

```bash
docker rm -f checkov-tutorial
```

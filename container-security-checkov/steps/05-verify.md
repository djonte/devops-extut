# Verify the fixed container

Start the fixed image:

```bash
docker run -d --name checkov-tutorial -p 8000:8000 checkov-tutorial:fixed
```

Verify that the application responds and does not run as root:

```bash
curl --fail http://localhost:8000/health
docker exec checkov-tutorial id
docker exec checkov-tutorial ls -l /app/app.py
```

The output should include `uid=10001(appuser)`, and `app.py` should be owned by `appuser`.

Try the same write that succeeded in the insecure container:

```bash
if docker exec checkov-tutorial touch /root/permission-test; then
  echo "Unexpected: appuser wrote to /root"
else
  echo "Expected: appuser cannot write to /root"
fi
```

This time Docker should report `Permission denied`, followed by the expected message. The application still works, but the process no longer has root's permissions inside the container.

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

Click **Check** to run the final automatic verification. It rebuilds your Dockerfile and checks the Checkov policies, non-root permissions, application response, and Docker health status.

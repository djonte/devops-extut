# Fix the Dockerfile

Open the **Editor** tab in Killercoda and select `/root/tutorial/Dockerfile`. You can also edit it in the terminal:

```bash
nano /root/tutorial/Dockerfile
```

Make these changes:

1. Replace `python:latest` with the tested `python:3.13-slim` image. This removes the mutable `latest` tag:

   ```dockerfile
   FROM python:3.13-slim
   ```

2. Create a dedicated user after `FROM`. The application does not need root privileges:

   ```dockerfile
   RUN useradd --create-home appuser
   ```

3. Keep `WORKDIR /app`, then copy the application with ownership set to `appuser`:

   ```dockerfile
   COPY --chown=appuser:appuser app.py .
   ```

4. Set the runtime user before `CMD` so the application starts as `appuser`:

   ```dockerfile
   USER appuser
   ```

5. Add a health check before `CMD` that requests `http://127.0.0.1:8000/health`.

Your health check can use Python, which is already available in the image:

```dockerfile
HEALTHCHECK --interval=5s --timeout=3s --start-period=3s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)" || exit 1
```

If you get stuck, compare your file with the reference solution:

```bash
cat /opt/tutorial-solution/Dockerfile.solution
```

The goal is not only to make the scanner green. Each change should address one of the behaviors observed in the previous step.

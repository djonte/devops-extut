# Fix the Dockerfile

Open the Dockerfile in an editor:

```bash
nano /root/tutorial/Dockerfile
```

Make these changes:

1. Replace `python:latest` with the tested `python:3.13-slim` image.
2. Create a dedicated user named `appuser`.
3. Copy the application with ownership set to `appuser`.
4. Set `USER appuser` before the container starts.
5. Add a health check that requests `http://127.0.0.1:8000/health`.

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

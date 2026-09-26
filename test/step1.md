# Scan the Dockerfile

Move to the tutorial directory and inspect the starter Dockerfile:

```bash
cd /root/tutorial
cat Dockerfile
```

It uses `python:latest`, does not set a `USER`, and does not define a `HEALTHCHECK`.

Run Checkov with the three checks used in this tutorial:

```bash
checkov -f Dockerfile --framework dockerfile --skip-download \
  --check CKV_DOCKER_2,CKV_DOCKER_3,CKV_DOCKER_7
```

The scan should report three failed checks:

- `CKV_DOCKER_2`: the image has no health check.
- `CKV_DOCKER_3`: no non-root user is created.
- `CKV_DOCKER_7`: the base image uses `latest`.

Checkov reads the Dockerfile. It does not build or run the application, so we will investigate the runtime behavior next.

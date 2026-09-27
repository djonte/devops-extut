# Scan and rebuild

Run the same targeted Checkov scan again:

```bash
cd /root/tutorial
checkov -f Dockerfile --framework dockerfile --skip-download \
  --check CKV_DOCKER_2,CKV_DOCKER_3,CKV_DOCKER_7
```

All three checks should now pass. If one fails, read its file location and check the related Dockerfile instruction.

Build the fixed image:

```bash
docker build -t checkov-tutorial:fixed .
```

A passing static scan does not prove that the application starts or that the health check works. We still need runtime verification.

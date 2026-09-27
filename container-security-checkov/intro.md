# Container Security with Checkov

In this tutorial, you will find and fix security misconfigurations in a Dockerfile. You will use Checkov for static analysis and Docker to verify the result at runtime.

The starter Dockerfile has three problems:

- The application runs as root.
- The base image uses the mutable `latest` tag.
- The image has no health check.

## Learning outcomes

After the tutorial, you should be able to:

1. Scan a Dockerfile with Checkov and understand its findings.
2. Explain why root containers, mutable image tags and missing health checks can cause problems.
3. Fix the Dockerfile and confirm that the selected checks pass.
4. Compare static scan results with the behavior of a running container.
5. Explain what a static scan can and cannot prove.

The workflow is:

```text
scan -> investigate -> fix -> rescan -> rebuild -> verify
```

The environment is temporary. The intentionally insecure container is only used inside this tutorial.

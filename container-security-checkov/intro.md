# Container Security with Checkov

In this tutorial, you will find and fix security misconfigurations in a Dockerfile. You will use Checkov for static analysis and Docker to verify the result at runtime.

The starter Dockerfile has three problems:

- The application runs as root.
- The base image uses the mutable `latest` tag.
- The image has no health check.

## DevOps relevance
This tutorial connects infrastructure as code, automated feedback, and runtime verification. Using Git to track the Dockerfile provides teammates with the ability to review configuration changes before they are merged, by then also coupling that workflow with Checkov, part of that review can be automated to find potential security issues in the configuration, such as missing non-root user.

Running these checks after each change helps catch problems early on, and in a CI pipeline, a failed check can stop the change from progressing toward deployment until the problem is addressed.

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

## Architecture & workflow overview
![Container security tutorial architecture](./images/architecture-overview.png)
Checkov reads the Dockerfile without building or running it. Docker then uses the Dockerfile and app.py to build an image, then starts a container from that image. The Python application exposes an HTTP endpoint (`/health`) on port 8000. After a HEALTHCHECK command is added, Docker will periodically it inside the container and record whether the application responded successfully.

### Design decisions
- **Checkov for static checks:** Using Checkov for static checks allows us to detect configuration problems before running the application. This is of course very important if we want to verify our configuration before deployment. We selected three checks to connect each finding to a conrete change.
- **Small Python application:** We use a simple Python application to keep setup simple and focus on container configuration. Python is also conveniently used to perform the health check.
- **Non-root user:** This application does not need root privileges. Restricting its permissions follows the basic security principle of least privilege.
- **Explicit base-image version:** A version tag makes the intended runtime clearer than latest. Tags can still change, a digest is more appropriate when exact image immutability is required.
- **An HTTP health check:** A running process may still fail to serve requests. Checking an endpoint gives Docker an application-level signal, although it only covers the behaviour tested by that endpoint.
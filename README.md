# Container Security with Checkov

This repository contains a Killercoda tutorial about Dockerfile security. The tutorial uses Checkov to find three problems and Docker to show why the problems matter at runtime.

The scenario is in [`container-security-checkov/`](container-security-checkov/).

## Tutorial flow

1. Scan an insecure Dockerfile.
2. Run the insecure container and inspect its behavior.
3. Fix the Dockerfile.
4. Scan and build the fixed version.
5. Verify the non-root user and Docker health status.

Checkov is pinned to version `3.3.8` in the scenario setup.

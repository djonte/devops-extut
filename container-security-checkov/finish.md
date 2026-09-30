# Finished

You used Checkov to find three Dockerfile problems, investigated why they matter, fixed them, and verified the result at runtime.

You should now be able to explain these differences:

- A static scan checks configuration patterns. It does not prove that the application works.
- A non-root user reduces unnecessary privileges, but it does not remove every security risk.
- A version tag is more predictable than `latest`, but a digest gives stronger immutability.
- A health check detects a chosen failure signal. It does not repair the application or prove that it is secure.

## Reflection

Consider these questions:

1. Where would you run this Checkov scan in a real development workflow?
2. What other runtime or security tests would you add before deployment?
3. When would pinning an image by digest be worth the maintenance cost?


### Who is this useful for?

This approach is useful for developers and DevOps learners who maintain Dockerfiles and want to introduce automated configuration checks. It assumes basic familiarity with containers and terminal commands.

### Where would you use it?

Run the static scan during local development and in pull-request CI pipelines to catch configuration mistakes early. After building the image, run container tests to verify permissions and application behaviour. Keeping these checks alongside the application makes them repeatable when its configuration changes.

### What are the limitations?

Passing these three checks does not establish that an image is secure. This tutorial does not scan dependencies for known vulnerabilities, detect embedded secrets, or assess host and network configuration.

A non-root user limits privileges but does not prevent every attack.
A health check detects only the failures it tests for, and Docker marking
a container unhealthy does not automatically repair it.

This approach is therefore useful as one layer of validation. It is
insufficient on its own for a production security assessment, and its
Docker-specific checks do not directly apply to applications deployed
without containers.
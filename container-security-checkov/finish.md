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

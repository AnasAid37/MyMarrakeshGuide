# Security Policy

MyMarrakeshGuide treats security defects as production incidents.

## Reporting a vulnerability

Do not open a public issue. Use the repository's private vulnerability-reporting flow under **Security → Advisories → Report a vulnerability**. Include:

- the affected component and version;
- reproducible steps;
- impact analysis;
- proof-of-concept material that does not expose user data;
- a safe contact method for follow-up.

Public disclosure must be coordinated after a fix is available and affected deployments have had a reasonable remediation window.

## Supported versions

Only the current production release and the active release candidate receive security fixes.

## Secure development requirements

- Never commit credentials, private keys, production exports, access tokens, or customer data.
- Use the generated local secrets from `pnpm bootstrap:env`.
- All authorization decisions must execute on the server.
- All security-sensitive changes require tests and peer review.
- Production dependencies with known critical vulnerabilities block release.

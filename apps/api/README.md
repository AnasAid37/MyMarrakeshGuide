# API application

NestJS REST API exposed under `/api/v1`.

## Boundaries

- Controllers handle transport concerns only.
- Application services coordinate use cases.
- Domain rules remain framework-independent.
- Infrastructure adapters implement application-owned ports.
- Host-scoped data access must prove organization membership before repository execution.
- All public errors use safe problem-detail responses and a request ID.

## Health endpoints

- `/api/v1/health/live`: process liveness
- `/api/v1/health/ready`: PostgreSQL and Redis readiness
- `/api/v1/security/csrf-token`: signed double-submit token issuance

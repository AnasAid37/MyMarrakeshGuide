# Contributing

## Development workflow

1. Use Node.js 24.18.1 and pnpm 11.18.0.
2. Run `make setup` once.
3. Create a branch using `type/short-description`, such as `feat/traveler-onboarding`.
4. Keep domain changes isolated to their owning module.
5. Add or update tests before opening a pull request.
6. Run `pnpm check` and `pnpm build` locally.

## Commit format

Use Conventional Commits, for example:

```text
feat(trips): add activity replacement policy
fix(auth): revoke refresh token family after replay
```

## Pull request requirements

- Explain the business behavior, not only implementation details.
- Include migration and rollback notes for database changes.
- Include screenshots for user-interface changes.
- Document new environment variables.
- Do not weaken validation, authorization, logging redaction, or tenant isolation.

# telemed-ia-appointment-scheduling-db

Database schema of the **appointment-scheduling** bounded context.

Part of team `telemed-ia`, Grupo 2.

## What this repo is

Owns the structure and migrations of the `appointment_scheduling` schema
inside the single PostgreSQL instance defined by `-infra-postgres`.

This repo does **not** define a database instance. Per Anexo J.3.1,
the instance is owned by the infra repo. This repo only ships the
migration executor.

## Stack

| Component | Version |
|---|---|
| PostgreSQL | 16 |
| Flyway | 10.20.1 |
| Docker | latest |

## Structure

```text
01_ddl/          definition (schema, tables, triggers, indexes)
02_dml/          data (seed, patches)
03_dcl/          access (roles, grants)
04_tcl/          transactions
05_rollbacks/    reversals (U<n>__*.sql)
deploy/          compose.yml with only the Flyway executor
flyway.conf      Flyway configuration
```

## How to apply migrations

From `-infra-postgres`:

```bash
docker compose --env-file env/dev.env --profile tooling run --rm appointment-scheduling-db-migrate
```

## Rules

- Schema is `appointment_scheduling`; nothing lives in `public`.
- No FK to other domains (Anexo J.3.4).
- A migration already applied is never edited.
- Every V has a U in `05_rollbacks/` with the same number.
- `flyway_history_appointment_scheduling` is the control table for this domain.

## Related documentation

- `telemed-ia-docs/02-domain/domain-map.md`
- `telemed-ia-docs/02-domain/entities-and-rules.md`
- `telemed-ia-docs/09-microservices/services/06-appointment-service/data-model.md`
- `telemed-ia-docs/05-architecture/decisions/records/ADR-009-appointment-availability-ownership.md`

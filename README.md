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

## Identificadores (UUID)

Desde `V009__migrate_ids_to_uuid.sql`, todos los identificadores de
`appointment_scheduling` son `uuid`:

- `appointments.id`, `patient_id`, `professional_id`,
  `preconsultation_summary_id`, `post_summary_id`.
- `professional_availability.id`, `professional_id`.

Motivo: alineación con `identity-and-access` (sub del JWT es UUID),
`intelligent-agent-db` (exige UUID) y la norma del curso
("camelCase JSON and UUID ids").

Seed de desarrollo: `professional_availability` conserva el seed
original `5001` traducido al uuid determinista
`00000000-0000-0000-0000-000000005001`. Cualquier seed futuro debe
usar UUIDs fijos reproducibles.

Reversión: `U009` solo elimina los índices añadidos. La reversión de
tipo no es simétrica; ver el comentario en `U009`.

## Outbox (V011 + V012)

`V011__create_outbox_event.sql` crea la tabla `outbox_event` para el
patrón Transactional Outbox. `V012__harden_outbox_event.sql` la
endurece con:

- `event_id uuid UNIQUE DEFAULT gen_random_uuid()`: UUID público del
  evento (distinto del `id` interno de la fila). Es el que viaja en el
  envelope ADR-011 como `eventId` y el que el consumidor usa como
  `Idempotency-Key` o para deduplicar.
- `correlation_id varchar(100) NOT NULL DEFAULT gen_random_uuid()::text`:
  propagado desde `X-Correlation-Id` del request original.
- `attempts int NOT NULL DEFAULT 0`, `last_error text`:
  usados por el `OutboxPoller` para backoff y diagnóstico. Tras N
  intentos (`outboxMaxAttempts`), el evento pasa a `FAILED`.
- `updated_at timestamptz NOT NULL DEFAULT now()`: trazabilidad de
  status/attempts.
- Índices `idx_outbox_event_failed` e `idx_outbox_event_event_type`.

## Related documentation

- `telemed-ia-docs/02-domain/domain-map.md`
- `telemed-ia-docs/02-domain/entities-and-rules.md`
- `telemed-ia-docs/09-microservices/services/06-appointment-service/data-model.md`
- `telemed-ia-docs/05-architecture/decisions/records/ADR-009-appointment-availability-ownership.md`

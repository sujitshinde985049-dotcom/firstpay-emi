# Database Design

## Summary

Supabase PostgreSQL is the source of truth. UUIDs, foreign keys, normalized identifiers, check constraints, unique indexes, restrictive deletion behavior, transactions, and RLS protect data independently of the mobile app.

## Entities

### `patsansthas`

Contains all approved legal/profile fields and status `ACTIVE`, `INACTIVE`, or `SUSPENDED`. Registration number and short code are unique. Status changes are audited. Records are never hard-deleted.

Patsanstha Admin may update display name, email, mobile, address fields, and logo only. Platform Super Admin controls legal name, registration number, short code, and status.

### `branches`

Every row has non-null `patsanstha_id`. `(patsanstha_id, branch_code)` is unique. Status is `ACTIVE` or `INACTIVE`. Records are never hard-deleted. Composite ownership constraints prove branch and user tenant consistency.

### `user_profiles`

Links unique `auth_user_id` to the authoritative role and status. Email is normalized; employee code is unique inside a tenant. Only `PLATFORM_SUPER_ADMIN` may have null `patsanstha_id`. Tenant roles require a tenant. Branch Manager and Operator require one primary `branch_id` in Phase 1. Status is `ACTIVE`, `INACTIVE`, or `LOCKED`. Records are never hard-deleted.

### `audit_logs`

Append-only records contain optional tenant, actor, action, entity, safe before/after JSON, network metadata, and timestamp. Application roles have no update/delete policy or grant. Passwords, tokens, reset links, keys, and secrets are excluded by allowlist.

## Constraints and indexes

- Unique normalized `patsansthas.registration_number` and `short_code`
- Unique `branches(patsanstha_id, branch_code)`
- Unique `user_profiles.auth_user_id`
- Unique `user_profiles(patsanstha_id, employee_code)` for tenant users
- Composite branch/tenant ownership constraint
- Tenant/status indexes for branches and profiles
- Audit indexes on `(patsanstha_id, created_at desc)` and `created_at desc`
- Restrictive foreign-key deletion and role/tenant/branch compatibility checks

## RLS matrix

| Table | Platform Super Admin | Patsanstha Admin | Branch Manager | Operator |
|---|---|---|---|---|
| patsansthas | platform manage | own limited read/update | own read | own read |
| branches | all | own tenant manage | primary branch limited | primary branch read |
| user_profiles | platform/initial admin | own tenant permitted manage | primary branch read | self read |
| audit_logs | platform read | own tenant read | narrowly permitted | denied |

Policies derive the active profile using `auth.uid()`. Tenant `USING` and `WITH CHECK` conditions prevent client-submitted ownership changes. Inactive/locked users and inactive/suspended tenant users are denied.

## Atomic operations

Sensitive changes and their audit entries run in one transaction where practical. Last-admin protection must lock/check safely under concurrency. Security-definer functions use fixed `search_path`, minimal grants, explicit authorization, and tests.

Privileged Supabase Auth invitations run through an authorized Edge Function or backend. The service-role key never enters Flutter.

## Pagination and seed data

Server-side ordering is deterministic. Default page size is 20; allowed sizes are 20, 50, and 100.

Development seed data contains one demo Platform Super Admin, two fictional Patsansthas, two branches per tenant, and one demo admin, manager, and operator per tenant. No real personal data or real passwords enter version control.
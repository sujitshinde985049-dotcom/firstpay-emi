# Security

## Objective

One Patsanstha must never view or modify another Patsanstha's data. Flutter is an untrusted client; mobile validation and hidden screens are not security controls. Server/database authorization and RLS provide the boundary.

## Required controls

- Supabase Auth for passwords and sessions
- Authoritative profile, role, tenant, branch, user-status, and tenant-status checks
- RLS and `WITH CHECK` on tenant-owned tables
- No trusted `patsanstha_id` from mobile input
- No service-role key, database password, production signing key, or private secret in Flutter
- Privileged administration only through an authorized backend/Edge Function
- Secure storage for appropriate session material and complete tenant-state cleanup on logout
- Validated password-reset/invitation deep links with allowlisted scheme/host
- Append-only sanitized audit records
- Safe error messages, origin/rate controls where supported, and no account enumeration

## Mobile threats

| Threat | Mitigation |
|---|---|
| Modified/reverse-engineered app | RLS and trusted backend checks; no embedded privileged secret |
| Tenant ID substitution | Ignore client authority; verified profile plus RLS |
| Stolen device/session | Secure storage, logout cleanup, short-lived refreshed sessions, server status checks |
| Token leakage | Never log tokens; redact crash reports and diagnostics |
| Malicious deep link | Validate scheme, host, purpose, state, and destination |
| Cached tenant data after account switch | Provider/cache invalidation and secure cleanup |
| Screenshots/clipboard exposure | Mask sensitive fields; avoid copying secrets; assess screenshot controls per screen |
| Offline stale data | Phase 1 defaults to explicit offline/retry behavior until caching is approved |
| Role escalation | Assignment matrix, self-change denial, database constraints/tests |
| Concurrent last-admin removal | Transactional locking and invariant check |
| Audit tampering/leakage | No update/delete grants; explicit safe-field allowlist |

## Status behavior

Inactive or locked users lose protected access. Users of inactive or suspended Patsansthas lose access immediately on the next verified operation. History remains preserved. Only Platform Super Admin can restore a suspended tenant.

## Local and build security

Environment and signing files are ignored. Production signing credentials are never used by automation. Release publishing is manual. Debug logs, analytics, and crash reporting must not capture tokens, passwords, reset links, personal details, or audit secrets. Android backup/export and iOS keychain accessibility require explicit review in Step 2.

## Verification gate

Required real-RLS tests prove cross-tenant read/update denial, tenant-ID tampering denial, unauthorized branch denial, Operator admin denial, inactive-user denial, suspended-tenant denial, role escalation denial, append-only audit behavior, and secret redaction.
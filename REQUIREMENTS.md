# FirstPay Phase 1 Requirements

## Product boundary

FirstPay is an Android-first, iOS-compatible Flutter administration app for multiple Patsansthas. Every Patsanstha has isolated branches, staff, data, settings, and dashboard. One tenant must never read or modify another tenant's data.

Phase 1 excludes members, loans, mandates, PhonePe, UPI AutoPay, collections, payment processing, reports, SMS, WhatsApp, live transactions, and Flutter web as the primary product.

## In scope

1. Flutter foundation and FirstPay Material 3 design system
2. Supabase authentication and session foundation
3. Protected, role-aware mobile navigation
4. Dashboard shells for all four roles without fake financial data
5. Patsanstha, branch, and staff management
6. Authorized audit log viewing
7. Multi-tenant database/RLS security
8. Loading, empty, error, retry, and offline states

## Roles

| Capability | Platform Super Admin | Patsanstha Admin | Branch Manager | Operator |
|---|---:|---:|---:|---:|
| Manage Patsansthas | Yes | Limited own profile | No | No |
| Manage branches | All | Own tenant | Limited assigned branch | No |
| Manage staff | Initial admin | Permitted own tenant | No | No |
| Assign roles | Initial admin | Non-platform tenant roles | No | No |
| View audit logs | Platform | Own tenant | Permitted only | No |
| View dashboard/profile | Platform | Own tenant | Assigned branch | Limited |

Users cannot promote themselves. Patsanstha Admin cannot grant `PLATFORM_SUPER_ADMIN`. Branch Manager cannot assign roles. The last active Patsanstha Admin cannot be disabled without a replacement.

## Approved founder decisions

- Authorized administrators invite staff; users set passwords through secure email links. No temporary password is displayed.
- Branch Manager and Operator have one primary branch in Phase 1.
- Patsanstha Admin edits only display name, email, mobile, address, and logo. Platform Super Admin controls legal name, registration number, short code, and status.
- Suspended tenant users immediately lose access; history remains; only Platform Super Admin restores access.
- Audit logs are append-only and have no edit/delete mobile action.
- Server pagination defaults to 20 and supports 20, 50, and 100.
- Phase 1 is English; visible strings are centralized for later Marathi localization.
- Platform Super Admin uses a secure documented bootstrap with no real hardcoded credentials.

## Authentication acceptance

Login, logout, forgot/reset password deep links, session restoration, protected routes, disabled/locked-user checks, inactive/suspended-tenant checks, role navigation, and server/database authorization are required. Supabase Auth owns passwords. Appropriate session information uses secure storage; tokens are never logged.

## Mobile UX acceptance

Touch targets are at least 48 logical pixels. Forms remain keyboard-safe, avoid clipping and duplicate submission, preserve safe input, and mask sensitive values. Lists use mobile cards, search, filter bottom sheets, pull-to-refresh, server pagination/load-more, and clear loading/empty/error/offline states. Destructive changes require confirmation. Android back behavior and accessible contrast are verified.

## Data and security acceptance

- UUID primary keys and versioned migrations
- Every tenant-owned table includes `patsanstha_id`
- Tenant scope comes from verified profile data, never client authority
- RLS with `WITH CHECK` prevents cross-tenant ownership changes
- No hard deletion of protected records
- Privileged Auth administration occurs through an authorized backend/Edge Function; no service-role key in Flutter
- Required cross-tenant, role, status, and tampering tests pass

No feature is complete until formatting, analysis, relevant tests, and Android debug build have actually passed.
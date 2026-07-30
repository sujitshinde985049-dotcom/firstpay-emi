# Flutter Architecture

## Architecture summary

FirstPay uses feature-first clean architecture without unnecessary layers. Widgets display state and collect input; Riverpod controllers coordinate use cases; repositories own data access; Supabase PostgreSQL and RLS enforce the final security boundary.

```text
Flutter screen
  → Riverpod controller/notifier
  → domain rule/use case when needed
  → repository
  → Supabase client or approved Dio service
  → PostgreSQL constraints and RLS
  → append-only audit entry
```

Flutter is an untrusted client. GoRouter guards and hidden controls improve usability but do not provide tenant security.

## Revised folder structure

```text
firstpay/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── bootstrap.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router/
│   │   ├── theme/
│   │   └── localization/
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   ├── security/
│   │   ├── storage/
│   │   └── widgets/
│   ├── features/
│   │   ├── authentication/{data,domain,presentation}/
│   │   ├── dashboard/{data,domain,presentation}/
│   │   ├── patsansthas/{data,domain,presentation}/
│   │   ├── branches/{data,domain,presentation}/
│   │   ├── staff/{data,domain,presentation}/
│   │   ├── audit_logs/{data,domain,presentation}/
│   │   └── profile/{data,domain,presentation}/
│   ├── services/supabase/
│   └── shared/
├── test/{unit,widget,fixtures}/
├── integration_test/
├── supabase/{migrations,functions,tests}/
├── supabase/seed.sql
├── assets/branding/
├── pubspec.yaml
├── analysis_options.yaml
├── build.yaml
└── documentation
```

A Flutter web target is not the primary product and should not be generated initially. Android is delivered first while `ios/` remains build-compatible.

## Packages

- `flutter_riverpod`: state, dependency injection, and testable providers
- `go_router`: navigation, deep links, and coarse route redirects
- `supabase_flutter`: Auth, session, and RLS-protected data access
- `dio`: approved HTTP calls such as authorized Edge Functions; no invented APIs
- `freezed_annotation` and `json_annotation`: immutable models and JSON contracts
- `flutter_secure_storage`: appropriate protected local session material
- `freezed`, `json_serializable`, and `build_runner`: development code generation
- `mocktail`: test doubles
- Flutter SDK `flutter_test` and `integration_test`

No package is added merely for convenience. Inter may use a standard Flutter package only if its dependency and offline behavior are acceptable; otherwise use a clean system sans-serif until branding assets are approved.

## State management

Riverpod providers expose repositories and session state. Feature controllers use immutable Freezed states for idle/loading/data/empty/error/offline outcomes. Widgets never call Supabase directly. Providers are scoped and invalidated on logout so tenant data does not survive account changes.

## Navigation

GoRouter listens to verified authentication/profile state and handles password-reset deep links. Role navigation uses bottom destinations for primary sections and a drawer/profile menu for secondary actions:

- Platform Super Admin: Dashboard, Patsansthas, Audit Logs; Settings secondary
- Patsanstha Admin: Dashboard, Branches, Staff, Audit Logs; Settings secondary
- Branch Manager: Dashboard, Branch Staff; Profile secondary
- Operator: Dashboard; Profile secondary

Android system back behavior, nested navigation, deep-link validation, and restoration require tests.

## Authentication

Supabase Auth owns passwords and sessions. Authorized administrators send invitations; users set passwords using secure email links. Temporary passwords are never displayed. The app restores an existing session, loads the authoritative profile, and denies inactive/locked users or users whose tenant is inactive/suspended.

Secure storage protects appropriate local session material. Tokens, passwords, and reset links are never logged. Logout clears feature state and cached tenant data. Privileged user provisioning runs through an authorized Edge Function or backend; the service-role key never enters Flutter.

## Supabase and RLS

Every tenant-owned row carries `patsanstha_id`. The app never treats a submitted tenant ID as authority. Policies derive identity from `auth.uid()` and the verified `user_profiles` row. `WITH CHECK` prevents ownership changes. Branch roles are limited to their one Phase 1 primary branch. Audit logs allow authorized reads and controlled inserts but no update/delete.

Security-definer functions must use a fixed `search_path`, minimal grants, explicit authorization, and regression tests. Sensitive mutations and audit entries should be atomic.

## Database summary

Four Phase 1 entities remain: `patsansthas`, `branches`, `user_profiles`, and append-only `audit_logs`. UUIDs, foreign keys, check constraints, unique indexes, normalized identifiers, timestamps, and RLS provide defense in depth. Server-side pages support sizes 20, 50, and 100.

## Important design choices

- Branch Manager and Operator have one primary branch in Phase 1, with repository interfaces that can evolve later.
- English strings are centralized for future Marathi localization.
- A suspended tenant immediately loses access while all historical data remains.
- Legal identity fields and tenant status are restricted to Platform Super Admin.
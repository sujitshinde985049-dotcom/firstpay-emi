# Development Plan

The project advances one major step at a time. A later step does not begin while required checks fail.

## Step 1 — Flutter plan and documentation

Status: documentation revised for the approved Android-first Flutter product. No application modules, package files, migrations, or platform folders are created in this step.

## Step 2 — Flutter foundation

1. Confirm Flutter/Android tooling and initialize Android plus iOS-compatible platforms without making web primary.
2. Pin compatible stable packages and create a Flutter-appropriate `.gitignore`.
3. Configure strict analysis, formatting, generated-code conventions, and safe environment loading.
4. Add Riverpod, GoRouter, Supabase initialization, secure storage boundary, and repository interfaces.
5. Add FirstPay Material 3 theme, corporate logo, reusable mobile states, and a design-system preview screen.
6. Run `flutter pub get`, formatting, analysis, tests, and Android debug build. Stop on failures.

No business management module is built in Step 2.

## Step 3 — Database and RLS

Create versioned migrations, constraints, indexes, grants, RLS, atomic audit helpers, Edge Function authorization design, safe demo seed approach, and real tenant-isolation tests.

## Step 4 — Authentication

Build invitation-compatible login, logout, forgot/reset password deep links, session restoration, secure cleanup, route protection, and user/tenant status checks.

## Step 5 — Role dashboards

Build role-aware dashboard shells and permitted navigation only, without fake financial data.

## Step 6 — Patsansthas

Build Platform Super Admin list, search, filters, server pagination, create/view/edit/status flows, initial admin invitation, confirmations, and audit events.

## Step 7 — Branches and staff

Build tenant-isolated branch and staff management, role/branch assignment, last-admin protection, password reset initiation, and mobile states.

## Step 8 — Audit and review

Build authorized audit views and review tenant isolation, authorization, secure storage, deep links, accessibility, Android back behavior, offline handling, mobile UX, and iOS compatibility.

## Step 1 files

Update: `README.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`, `DATABASE.md`, `SECURITY.md`, `DEVELOPMENT_PLAN.md`, `DESIGN_SYSTEM.md`, `TESTING.md`, and `AGENTS.md`.

Step 2 will create Flutter platform folders, `lib/`, `test/`, `integration_test/`, `pubspec.yaml`, lockfile, analysis/build configuration, safe `.env.example`, `.gitignore`, and initial assets. Database files begin in Step 3.

## Resolved founder decisions

- Staff use secure email invitation/password setup; no temporary passwords.
- Branch Manager and Operator have one primary branch in Phase 1.
- Patsanstha Admin may edit display/contact/address/logo fields only.
- Suspended tenants immediately lose access; only Platform Super Admin restores them.
- Audit logs are append-only with no mobile edit/delete action.
- Server page sizes are 20, 50, and 100; default 20.
- Phase 1 is English with centralized strings for future Marathi.
- Platform Super Admin uses a documented secure bootstrap with no real hardcoded credentials.

## Assumptions still requiring confirmation

1. Android application ID and iOS bundle ID (proposed placeholder: `com.firstpay.app`).
2. Minimum Android SDK and supported Android versions, chosen after checking current stable Flutter requirements.
3. Exact password-reset/invitation deep-link domain and scheme.
4. Whether offline mode is message-and-retry only (recommended for Phase 1) or permits cached read-only records.
5. Audit display time zone (proposed: store UTC and display device-local time with an explicit zone).
6. Whether registration, short, branch, and employee codes are case-insensitively unique after trimming (recommended).
7. Approved organization name and contact details needed for Android/iOS metadata.

Restrictive security defaults apply until these are confirmed and the decision is documented before implementation.
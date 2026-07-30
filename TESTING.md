# Testing Strategy

## Principles

Security tests prove allowed and denied behavior. Mobile UI validation is never treated as tenant security. Every bug fix receives a regression test, and no test uses real personal or financial data.

## Test layers

### Dart unit tests (`flutter_test`)

Test normalization, validation, permission policies, role navigation, Freezed state transitions, repository mapping, pagination, audit redaction, status rules, and last-admin decisions.

### Widget tests (`flutter_test`)

Test role shells, keyboard-safe forms, validation, loading/empty/error/offline states, duplicate-submit prevention, filter sheets, confirmation dialogs, text scaling, and Android back behavior. Override Riverpod providers with controlled fakes.

### Repository/integration tests

Use mocktail for isolated failures and a real local Supabase environment for database behavior. Test session restoration, status changes, errors, pagination, and cache cleanup. Do not use an owner/service connection for RLS assertions.

### Required database/RLS cases

1. Patsanstha A cannot read Patsanstha B.
2. Patsanstha A cannot update Patsanstha B.
3. Changing a local request `patsanstha_id` does not bypass security.
4. Branch Manager cannot access an unauthorized branch.
5. Operator cannot perform admin operations.
6. Inactive/locked users lose access.
7. Inactive/suspended tenant users lose access.
8. Patsanstha Admin cannot grant Platform Super Admin.
9. A user cannot promote themselves.
10. Last-admin protection holds under concurrent requests.
11. Audit logs cannot be updated/deleted.
12. Audit payloads exclude secrets.

### Device tests (`integration_test`)

Cover login/logout, password-reset deep-link routing, session restoration, role navigation, restricted direct routes, key management journeys, status confirmations, offline/retry behavior, app resume, and representative Android screen sizes. iOS compatibility is checked when macOS/Xcode infrastructure is available.

## Commands

```powershell
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
```

No command is reported as passing unless it ran against the current state. Missing Flutter, Android SDK, emulator, device, macOS, or Xcode is reported exactly.

## Step reporting

Report files created/changed, packages installed, commands, formatter/analyzer/test/build results, errors found/fixed, security precautions, remaining risks, and exact next step. A major step stops while required checks fail.
# Mandatory FirstPay Engineering Rules

1. FirstPay is a multi-tenant financial application.
2. Never trust tenant identifiers from the mobile client.
3. Enforce tenant access using verified server data and RLS.
4. Do not put the Supabase service-role key in Flutter.
5. Do not store UPI PIN, OTP, Aadhaar, PAN or bank details in Phase 1.
6. Do not log tokens, passwords or secrets.
7. Every database change requires a migration.
8. Every protected operation requires authorization tests.
9. Audit logs are append-only.
10. Do not hard-delete protected records.
11. Do not invent external API endpoints.
12. Do not integrate PhonePe in Phase 1.
13. Do not automatically publish the app.
14. Do not sign a release APK with production credentials.
15. Run format, analyze, tests and build before claiming completion.
16. Do not modify unrelated modules without explanation.

## Working agreement

- Follow `DEVELOPMENT_PLAN.md` and stop a major step when required checks fail.
- Flutter is untrusted. GoRouter and hidden widgets do not replace server authorization or RLS.
- Never package a service-role key, database password, signing credential, or private server secret in the app.
- Privileged Auth administration belongs in an explicitly authorized Edge Function or backend.
- Widgets do not call Supabase directly; use repositories and Riverpod providers.
- Clear tenant-scoped state and caches on logout/account change.
- Centralize English strings for later Marathi localization.
- Every bug fix requires a regression test.
- Do not create a Flutter web target as the primary product.
- Never claim an unexecuted formatter, analyzer, test, device run, or Android build passed.
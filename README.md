# FirstPay Mobile

FirstPay is an Android-first Flutter application for administering multiple cooperative credit societies (Patsansthas). Phase 1 covers secure authentication, role-aware navigation, tenant/branch/staff administration, dashboard shells, audit viewing, and loading/error/empty/offline states.

Phase 1 explicitly excludes members, loans, mandates, PhonePe, UPI AutoPay, collections, payment processing, reports, SMS, WhatsApp, and live financial transactions.

> Current status: Step 1 documentation only. No Flutter project or application module has been created and no feature is claimed to work.

## Approved stack

- Flutter and Dart; Android first, iOS-compatible
- Supabase PostgreSQL, Supabase Auth, and Row Level Security
- Riverpod, GoRouter, Dio, Freezed, `json_serializable`
- `flutter_secure_storage`
- Material 3 with a custom FirstPay design system
- `flutter_test`, `integration_test`, and mocktail
- GitHub, without automatic publishing

Exact stable, mutually compatible versions will be selected and pinned during Step 2.

## Beginner setup guide

These commands are planned for Step 2 and later; the app has not been scaffolded yet.

### Install Flutter

Install the stable Flutter SDK from [docs.flutter.dev](https://docs.flutter.dev/get-started/install), add Flutter to `PATH`, then verify:

```powershell
flutter --version
dart --version
flutter doctor -v
```

The first two commands print installed versions. Flutter Doctor explains which Android or iOS tools are ready and what is missing.

### Install Android Studio and an emulator

Install Android Studio with the Android SDK, platform tools, and emulator. Open **Device Manager**, create a recent Android virtual device, and start it. If requested:

```powershell
flutter doctor --android-licenses
```

This lets you review and accept Android SDK licenses.

For a physical Android device, enable Developer Options and USB debugging, connect it, approve the computer, and run:

```powershell
flutter devices
```

This lists devices Flutter can use.

### Install dependencies

```powershell
flutter pub get
```

This downloads the packages pinned by the project lockfile.

### Configure Supabase

Create a Supabase project, then copy the future safe example configuration:

```powershell
Copy-Item .env.example .env
```

Only the Supabase project URL, anonymous key, and approved public app configuration may enter Flutter. Never include a service-role key, database password, signing credential, or private server secret.

### Run migrations and demo seed data

```powershell
supabase db push
supabase db reset
```

The first command applies migrations to a confirmed linked project. The second recreates a local database and loads demo data; it is destructive and must never target production.

### Run the app and quality checks

```powershell
flutter run
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
```

These commands run the app, verify formatting, analyze code, run automated tests, run device integration tests, and create a development APK. A debug APK is not a production-signed release.

## Documentation

- [REQUIREMENTS.md](REQUIREMENTS.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [DATABASE.md](DATABASE.md)
- [SECURITY.md](SECURITY.md)
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)
- [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)
- [TESTING.md](TESTING.md)
- [AGENTS.md](AGENTS.md)
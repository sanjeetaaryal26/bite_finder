# Setup Guide

This app can run locally without any backend setup.

## 1) Prerequisites
- Flutter 3.22+ (stable channel)
- Dart SDK (bundled with Flutter)
- Git
- Android Studio (for Android SDK, emulator, platform tools)
- VS Code or Android Studio for editing

## 2) Install Flutter
Use the official guide for your OS:
- https://docs.flutter.dev/get-started/install

After install, verify:
```bash
flutter doctor
```
Fix issues reported by `flutter doctor` before continuing.

## 3) Android setup (for most contributors)
1. Install Android Studio.
2. Open Android Studio once and install:
   - Android SDK
   - Android SDK Command-line Tools
   - Android Emulator (optional, but recommended)
3. Accept licenses:
```bash
flutter doctor --android-licenses
```

## 4) Clone and install dependencies
```bash
git clone <your-repo-url>
cd bites/bite_finder
flutter pub get
```

## 5) Run the app
Start an emulator (or connect a physical device), then run:
```bash
flutter run
```

To list available devices:
```bash
flutter devices
```

## 6) Run tests
```bash
flutter test
```

## Common fixes
- If Gradle/JDK errors appear, install the Android Studio bundled JDK and rerun `flutter doctor`.
- If no devices are shown, run `flutter devices` and check emulator/device USB debugging status.
- If dependencies fail, run:
  - `flutter clean`
  - `flutter pub get`

## Notes
- Data is mocked locally and persisted with SharedPreferences.
- No backend setup is required for local development.
- A default admin account is auto-created on first app launch:
  - Email: `admin@bitefinder.app`
  - Password: `Admin@12345`

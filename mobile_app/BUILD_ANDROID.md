# Build Senior Social India Android APK

This document explains how to create a test Android APK for Senior Social India.

## Current status

The Flutter app foundation is stored in this folder.

Firebase Android configuration has been added at:

```text
mobile_app/firebase/android/google-services.json
```

The Android package name is:

```text
in.seniorsocial.app
```

## Build locally

Install Flutter, then run:

```bash
cd mobile_app
flutter create --platforms=android,ios .
mkdir -p android/app
cp firebase/android/google-services.json android/app/google-services.json
flutter pub get
flutter build apk --release
```

The APK will be created here:

```text
mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

## Notes

- This APK is for testing only.
- For Play Store publishing, a signed Android App Bundle is required.
- iPhone publishing requires Apple Developer membership and TestFlight/App Store setup.

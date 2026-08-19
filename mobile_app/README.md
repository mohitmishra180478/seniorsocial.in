# Senior Social India Mobile App

This folder contains the Flutter mobile app foundation for Senior Social India.

## Target platforms

- Android
- iPhone / iOS

## Availability positioning

Senior Social India supports access for Indian families in India, United Kingdom, United States, Canada, Australia, UAE and Singapore. Local events and community groups begin India-first, while family support access can be global.

## App screens planned

1. Splash screen
2. Welcome screen
3. Register / Login
4. Email verification
5. Mobile OTP verification
6. Senior profile form
7. Pending admin approval
8. Activities and groups
9. Contact support
10. Privacy Policy and Terms & Safety

## Backend

The mobile app will use the existing Firebase project:

- Project ID: senior-social-india
- Authentication: Email/Password and Phone
- Firestore: users collection

## Important setup still required

Before building APK or iOS TestFlight, create mobile app entries inside Firebase Console:

1. Firebase Console > Project settings > Your apps
2. Add Android app
3. Add iOS app
4. Download google-services.json for Android
5. Download GoogleService-Info.plist for iOS
6. Run FlutterFire configuration or manually place the config files

## Development command

```bash
cd mobile_app
flutter pub get
flutter run
```

## Android build command

```bash
flutter build apk --release
```

## iOS build command

```bash
flutter build ipa --release
```

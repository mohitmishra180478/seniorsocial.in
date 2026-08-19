# Senior Social India - Mobile Release Checklist

## Current technical status
- Flutter app foundation created under `mobile_app/`
- Android Firebase app registered
- iOS Firebase app registered
- Android `google-services.json` added
- iOS `GoogleService-Info.plist` added
- Firebase Authentication enabled
- Firestore database created
- Website Privacy Policy and Terms & Safety pages added

## Android testing checklist
1. Install Flutter on the build machine.
2. Clone the GitHub repository.
3. Open terminal in `mobile_app`.
4. Run `flutter create --platforms=android,ios .`
5. Confirm `android/app/google-services.json` exists.
6. Run `flutter pub get`.
7. Run `flutter run` for emulator/device testing.
8. Run `flutter build apk --release` for APK.
9. Test registration, login, email verification and Firestore profile creation.
10. Test Privacy Policy and Terms links.

## Android publishing checklist
1. Create Google Play Developer account.
2. Create app in Play Console.
3. Upload app icon, feature graphic and screenshots.
4. Add app description from `STORE_LISTING.md`.
5. Add Privacy Policy URL: `https://seniorsocial.in/privacy.html`.
6. Complete Data safety form.
7. Upload signed AAB build.
8. Select countries: India, UK, US, Canada, Australia, UAE, Singapore.
9. Submit for review.

## iOS testing checklist
1. Use a Mac with Xcode and Flutter.
2. Open `mobile_app/ios` after Flutter project generation.
3. Confirm bundle ID is `in.seniorsocial.app`.
4. Confirm `GoogleService-Info.plist` is added to the iOS app target.
5. Run on iPhone simulator/device.
6. Test registration, login, profile creation and support links.

## iOS publishing checklist
1. Create Apple Developer account.
2. Create app in App Store Connect.
3. Bundle ID: `in.seniorsocial.app`.
4. Upload screenshots and app icon.
5. Add Privacy Policy URL: `https://seniorsocial.in/privacy.html`.
6. Add support URL: `https://seniorsocial.in`.
7. Upload build using Xcode or Transporter.
8. Test through TestFlight.
9. Select countries: India, UK, US, Canada, Australia, UAE, Singapore.
10. Submit for App Review.

## Before public launch
- Replace test Firestore rules with production rules.
- Add real admin UID in Firebase config / Firestore rules.
- Test user deletion/data request workflow.
- Test blocked/pending/approved status.
- Review privacy wording with a legal professional before store launch.

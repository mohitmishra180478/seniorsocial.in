# Senior Social iOS setup

The iOS Firebase configuration is already present at:

```text
mobile_app/ios/Runner/GoogleService-Info.plist
```

Bundle ID:

```text
in.seniorsocial.app
```

## What is ready

- Flutter app code is shared with Android.
- Firebase iOS config is in the repo.
- GitHub Actions workflow `Build iOS` has been added.
- The workflow can check whether the app compiles for iOS without code signing.

## Run iOS build check

1. Open GitHub.
2. Go to **Actions**.
3. Select **Build iOS**.
4. Click **Run workflow**.

This produces an unsigned build artifact. It proves the iOS app can compile, but it is not an installable App Store/TestFlight build.

## To install on a real iPhone

Apple requires signing. You need:

- Apple Developer account.
- App ID / Bundle ID: `in.seniorsocial.app`.
- Apple signing certificate.
- Provisioning profile.
- Xcode on a Mac, or GitHub Actions signing secrets.

## Recommended practical path

For first iPhone testing, use a Mac with Xcode:

```bash
cd mobile_app
flutter create . --platforms=ios --org in.seniorsocial --project-name senior_social
flutter pub get
open ios/Runner.xcworkspace
```

Then in Xcode:

1. Select **Runner**.
2. Set Bundle Identifier to `in.seniorsocial.app`.
3. Select your Apple Developer Team.
4. Connect iPhone by cable.
5. Click Run.

## TestFlight / App Store later

For TestFlight/App Store, create a signed archive from Xcode or configure GitHub Actions with Apple signing secrets. Do not commit certificates, provisioning profiles, or private keys into GitHub.

# Atelýam

Atelýam is a Flutter community for sharing original clothing and handmade designs. People can show their work, explore designs from others, and connect with fashion makers.

[Get Atelýam on Google Play](https://play.google.com/store/apps/details?id=com.gurbanov.atelyam)

## Features

- Create a profile and share clothing, craft, or fashion designs.
- Browse community posts, save favorites, and interact through likes and comments.
- Discover makers and their products.
- Manage a business profile and products from the app.

## Development

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and the toolchain for your target platform. Android builds use JDK 17 with this project's Gradle version. Then run:

```sh
flutter pub get
flutter run
```

Firebase is used for messaging and analytics. Android uses `android/app/google-services.json`; iOS uses its own Firebase configuration. The mobile app also depends on its backend services for account and product data.

The included `third_party/iconly` copy retains the original icon font and glyphs while making the icon definitions compatible with current Flutter versions.

## Checks

```sh
flutter analyze --no-fatal-infos
flutter build apk --debug
```

The analyzer currently reports legacy style notices. The check above still fails on warnings and errors. GitHub Actions runs the same checks on pull requests and `main`.

## Android release signing

The Android app ID is `com.gurbanov.atelyam`. Android currently declares version `9.0.6 (18)` in `android/app/build.gradle`; `pubspec.yaml` has a different version for Flutter and iOS. Reconcile these versions before publishing a new store update.

An Android release requires an upload keystore and a local `android/key.properties` file. Copy [`android/key.properties.example`](android/key.properties.example) and fill it with your own paths and credentials. The properties file and keystore are ignored by Git. A release build intentionally fails when signing information is missing.

```sh
flutter build apk --release
```

Verify the resulting APK's package, version, and signing certificate before distributing it. A source-only GitHub Release does not contain an installable APK.

## Screenshots

![Atelýam community feed](https://play-lh.googleusercontent.com/iVcy-lGmKrYFUA0aqKhpBhc5CXPjHopqgwdp3HN75U8HX1XS7we6lArvb5N2_DzLJA=w1052-h592-rw)

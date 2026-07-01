# Plan — Fix Android Native Splash Screen White Flash

**Branch:** fix/android-native-splash-white-flash_91
**Issue:** #91
**Date:** 2026-06-30

## Goal
Eliminate the white flash / white background with Flutter launcher icon that appears on Android before Flutter initializes. The app already has a polished Dart-level `SplashScreen` widget; the native Android splash (shown before the Flutter engine draws its first frame) needed to match it visually so the startup transition is imperceptible.

## Approach
Used the `flutter_native_splash` package (dev dependency) to generate native Android splash assets. Configured background colors only — no icon — to match the existing Dart `SplashScreen` exactly (`#FAFAFA` light / `#121212` dark). The generator handles all API level variants, including the previously missing `values-v31/styles.xml` for Android 12+ (which was the source of the launcher-icon-on-white behavior).

No `main.dart` changes were needed: the native splash auto-dismisses when Flutter draws its first frame, which is the Dart `SplashScreen`.

Alternative considered: hand-editing the XML files directly. Rejected in favor of the package approach since it correctly handles all density/API-level permutations including API 31+.

## Changes
- `pubspec.yaml` — added `flutter_native_splash: ^2.4.4` to dev_dependencies
- `flutter_native_splash.yaml` — new config: `color: #FAFAFA`, `color_dark: #121212`, android only, no image
- `android/app/src/main/res/drawable/launch_background.xml` — overwritten by generator
- `android/app/src/main/res/drawable/background.png` — new solid `#FAFAFA` fill
- `android/app/src/main/res/drawable-night/launch_background.xml` — new dark variant
- `android/app/src/main/res/drawable-night/background.png` — new solid `#121212` fill
- `android/app/src/main/res/drawable-v21/launch_background.xml` — overwritten by generator
- `android/app/src/main/res/drawable-night-v21/launch_background.xml` — new dark v21 variant
- `android/app/src/main/res/drawable-v21/background.png` — new v21 solid fill
- `android/app/src/main/res/values/styles.xml` — overwritten, `#FAFAFA` light background
- `android/app/src/main/res/values-night/styles.xml` — overwritten, `#121212` dark background
- `android/app/src/main/res/values-v31/styles.xml` — new, Android 12+ `windowSplashScreenBackground: #FAFAFA`
- `android/app/src/main/res/values-night-v31/styles.xml` — new, Android 12+ `windowSplashScreenBackground: #121212`

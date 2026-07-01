# Plan — Fix Android Native Splash: Invisible Native Splash (Option B)

**Branch:** fix/android-native-splash-white-flash_91
**Issue:** #91
**Date:** 2026-07-01

## Goal
After the first fix (plan #69), two problems remained: the native and Dart splash screens were still visually distinct, and dark mode showed a white background. Switch to Option B: make the native splash completely invisible by matching the Dart SplashScreen's exact background color with no icon.

## Approach
The root cause of the dark-mode white flash was that `flutter_native_splash` generated bitmap references (`@drawable/background`) in all `launch_background.xml` files. When Android resolves `@drawable/background` on a dark-mode API 21+ device, the qualifier specificity of `v21` can win over `night`, causing the light `#FAFAFA` PNG to be used instead of the dark one.

Fix: replace all bitmap references with `@color/splash_background` — a named color resource that Android resolves cleanly through the `values/` vs `values-night/` system. On API 31+ (Android 12+), add a transparent empty vector drawable as `windowSplashScreenAnimatedIcon` to suppress the launcher icon the OS injects by default.

Result: native splash shows an invisible solid background (`#FAFAFA` light / `#121212` dark) with no icon, indistinguishable from the Dart SplashScreen background. The user perceives a single uninterrupted splash experience.

## Changes
- `android/app/src/main/res/values/colors.xml` — added `splash_background: #FAFAFA`
- `android/app/src/main/res/values-night/colors.xml` — new, `splash_background: #121212`
- `android/app/src/main/res/drawable/launch_background.xml` — bitmap replaced with `@color/splash_background`
- `android/app/src/main/res/drawable-night/launch_background.xml` — same
- `android/app/src/main/res/drawable-v21/launch_background.xml` — same
- `android/app/src/main/res/drawable-night-v21/launch_background.xml` — same
- `android/app/src/main/res/drawable/transparent_splash_icon.xml` — new empty 288dp vector
- `android/app/src/main/res/values-v31/styles.xml` — added `windowSplashScreenAnimatedIcon` → transparent vector
- `android/app/src/main/res/values-night-v31/styles.xml` — same

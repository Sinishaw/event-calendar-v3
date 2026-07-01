# Plan — Fix iOS Native Splash Invisible Background

**Branch:** fix/ios-native-splash-invisible_95
**Issue:** #95
**Date:** 2026-07-01

## Goal
Make the iOS native launch screen invisible so the user perceives only the Dart SplashScreen, matching the approach applied to Android in plan #70.

## Approach
Enable `ios: true` in `flutter_native_splash.yaml` and run the generator. The generator:
1. Creates `LaunchBackground.imageset` with `background.png` (#FAFAFA, light) and `darkbackground.png` (#121212, dark) — 1×1 PNGs used as a full-screen fill
2. Updates `LaunchScreen.storyboard` to add a `LaunchBackground` imageView pinned to all edges (scaleToFill), covering the hardcoded white root view color
3. Replaces `LaunchImage` PNGs with transparent 1×1 images (no icon shown)

After the generator run, Android files that were incorrectly reverted (bitmap references) are restored from `develop` HEAD. `Info.plist` formatting-only changes are also restored to keep the diff clean.

## Changes
- `flutter_native_splash.yaml` — `ios: false` → `ios: true`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard` — added full-screen `LaunchBackground` imageView with edge constraints
- `ios/Runner/Assets.xcassets/LaunchBackground.imageset/` — new; light/dark 1×1 color PNGs + Contents.json
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/` — replaced with transparent 1×1 PNGs; Contents.json updated with dark appearance variant

# Plan — Add iOS Phone Launch Icons

**Branch:** enhancement/ios-phone-launch-icons_83
**Issue:** #83
**Date:** 2026-06-29

## Goal
Add correct launch icons for iOS phone devices using phone-specific icons from the `croped-icons/iOS` directory, and remove unnecessary iPad-only launch icon files and references.

## Approach
1. Copy phone-specific launch icons from `croped-icons/iOS` to `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
2. Delete unused, iPad-only launch icon files from `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
3. Update `Contents.json` to remove iPad entries, leaving only `iphone` and `ios-marketing` configurations.
4. Verify iOS configuration build compiles successfully.

## Changes
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` — Removed all iPad-specific configurations, leaving only iPhone and iOS marketing assets.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png` — Overwritten with new 20@2x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png` — Overwritten with new 20@3x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png` — Overwritten with new 29@1x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png` — Overwritten with new 29@2x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png` — Overwritten with new 29@3x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png` — Overwritten with new 40@2x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png` — Overwritten with new 40@3x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png` — Overwritten with new 60@2x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png` — Overwritten with new 60@3x icon.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` — Overwritten with new 1024x1024 marketing icon.
- Deleted the following iPad-only assets:
  - `Icon-App-20x20@1x.png`
  - `Icon-App-40x40@1x.png`
  - `Icon-App-76x76@1x.png`
  - `Icon-App-76x76@2x.png`
  - `Icon-App-83.5x83.5@2x.png`

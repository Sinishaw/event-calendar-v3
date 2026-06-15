# Plan — Fix Xcode Project Parse Error and Empty Firebase Options

**Branch:** fix/ios-build-error_2
**Issue:** #2
**Date:** 2026-06-15

## Goal
Resolve the issue where Flutter/Xcode fails to run because `ios/Runner.xcodeproj/project.pbxproj` was truncated to 0 bytes, and `lib/main.dart` fails to compile because the newly introduced `lib/firebase_options_dev.dart` and `lib/firebase_options_prod.dart` files are empty.

## Approach
1. Restored the Xcode project configuration file `ios/Runner.xcodeproj/project.pbxproj` from the parent commit `c7ea3eead17cb9ef888f0570809eddaea4c2e86f` where it was valid.
2. Populated both `lib/firebase_options_dev.dart` and `lib/firebase_options_prod.dart` with valid `DefaultFirebaseOptions` declarations derived from the original `lib/firebase_options.dart` to support the multi-environment switching logic without compilation errors.
3. Verified the fix by running analysis and compiling a no-codesign iOS build successfully.

## Changes
- [project.pbxproj](file:///Users/sinishaw/My_Projects/event-calendar-v3/ios/Runner.xcodeproj/project.pbxproj) — Restored Xcode configuration from parent commit.
- [firebase_options_dev.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/firebase_options_dev.dart) — Added default development Firebase configuration.
- [firebase_options_prod.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/firebase_options_prod.dart) — Added default production Firebase configuration.

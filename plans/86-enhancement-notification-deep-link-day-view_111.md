# Plan — iOS Notification Tap: Set UNUserNotificationCenter Delegate

**Branch:** enhancement/notification-deep-link-day-view_111
**Issue:** #111
**Date:** 2026-07-05

## Goal
The Dart-side deep-link routing (plans 85) worked on Android but iOS still opened the home page when the app was minimized or terminated. Fix the native iOS delivery gap so notification taps reach Dart.

## Approach

**Root cause (iOS-only)**: `ios/Runner/AppDelegate.swift` never set `UNUserNotificationCenter.current().delegate`. On iOS, notification-tap responses are delivered to Dart via `flutter_local_notifications` *only* when the app is registered as the `UNUserNotificationCenter` delegate. Without it:
- **Background/minimized**: `onDidReceiveNotificationResponse` never fires → stream never emits → listener never runs.
- **Terminated**: `getNotificationAppLaunchDetails().didNotificationLaunchApp` stays `false` → cold-start check finds nothing.

Both fall through to `_goHome()`. Android uses a different (intent-based) delivery path that needs no delegate, which is why Android already worked.

**Fix**: In `didFinishLaunchingWithOptions`, assign the delegate:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```
`FlutterAppDelegate` conforms to `UNUserNotificationCenterDelegate` and multiplexes callbacks to every registered plugin, so both `flutter_local_notifications` and `firebase_messaging` receive their events. `FirebaseAppDelegateProxyEnabled` is unset (swizzling on by default), so FCM keeps forwarding cleanly — no conflict.

## Changes
- `ios/Runner/AppDelegate.swift` — set `UNUserNotificationCenter.current().delegate` in `didFinishLaunchingWithOptions`

## Note
This is a native change — a full iOS rebuild (`flutter run` / rebuild in Xcode) is required. Hot reload and hot restart will not pick it up.

# Plan — Add Calendar Notification Icon for Android FCM

**Branch:** enhancement/android-fcm-notification-icon_99
**Issue:** #99
**Date:** 2026-07-01

## Goal
Replace the plain white circle shown in the Android notification bar with a recognizable calendar outline icon as a placeholder until a branded asset is designed.

## Approach
Android 5+ requires notification small icons to be monochrome white on transparent background. Create a simple calendar outline vector drawable and register it in three places: FCM metadata in AndroidManifest.xml (for FCM-delivered messages) and AndroidInitializationSettings in NotificationService (for flutter_local_notifications-delivered messages). Use the existing `ic_launcher_background` color (#113766) as the notification accent color.

## Changes
- `android/app/src/main/res/drawable/ic_notification.xml` — new white outline calendar vector (body, header divider, two date pins)
- `android/app/src/main/AndroidManifest.xml` — added `default_notification_icon` and `default_notification_color` FCM metadata
- `lib/services/notifications/notification_service.dart` — updated `AndroidInitializationSettings` from `@mipmap/ic_launcher` to `ic_notification`

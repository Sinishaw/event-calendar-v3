# Plan — Fix Exact Alarm Save Crash

**Branch:** fix/exact-alarm-save-crash_80
**Issue:** #80
**Date:** 2026-06-26

## Goal
Prevent task saving from crashing when Android denies exact alarms during local notification scheduling.

## Approach
Use the approved robust option: declare Android scheduled-notification support, request/check exact-alarm capability through `flutter_local_notifications`, and fall back to inexact alarms when exact scheduling is unavailable. `SCHEDULE_EXACT_ALARM` was chosen instead of `USE_EXACT_ALARM` to avoid the stronger store-policy path unless the app explicitly needs that permission category.

Alternatives considered:
- Add manifest permission only, which is simple but can still crash if access is denied or revoked.
- Disable exact alarms entirely, which avoids permission issues but loses precise notification timing for users who grant access.

## Changes
- `android/app/src/main/AndroidManifest.xml` — Added `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, and the `flutter_local_notifications` scheduled notification receivers.
- `lib/services/notifications/notification_service.dart` — Added exact-alarm capability/request logic and a retry fallback to `AndroidScheduleMode.inexactAllowWhileIdle` when exact scheduling is denied.

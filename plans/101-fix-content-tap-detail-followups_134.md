# Plan — Content-detail navigation: device-testing follow-up fixes

**Branch:** fix/content-tap-opens-detail_134
**Issue:** #134 (continuation)
**Date:** 2026-07-17

## Goal
Complete #134 after on-device testing revealed three additional root causes that
prevented content taps from reaching the detail page (plus quiet an unrelated
offline-refresh log noise, folded in by request).

## Fixes
1. **`contentId` dropped on payload read-back.** `scheduleCalendarMark` writes
   `contentId` into the notification JSON, but every site that rebuilds a
   `NotificationPayload` from `pendingNotificationRequests()` omitted it, so the
   in-app list rows saw `contentId=null` and fell back to the clamped notif id
   (lookup miss -> list page). Added `contentId: payLoad.contentId` in:
   - `notification_service.dart` `getAllNotificationsList`
   - `daily_user_event_list.dart` `_getAllNotifications`
   - `local_notification.dart` (two reconstruction sites)
2. **Background / terminated notification tap -> home.** The immediate "notify"
   notification was shown with `payload: ""`, so `_handleNotificationTap` couldn't
   decode it and fell to `_goHome`. Added `_contentTapPayload(message)` (main.dart)
   that builds a payload carrying `contentId` + `contentSource`, passed to
   `showNotification`, so the tap routes to the detail page.
3. **Offline-refresh unhandled exception (unrelated, folded in).**
   `CloudFireStore.cacheGroupedRecords` did a server `.get().then(...)` with no
   error handler, so an offline refresh logged a red `cloud_firestore/unavailable`
   "Unhandled Exception". Added `.catchError` to both server-refresh branches.

## Changes
- `lib/screens/events/models/notification_payload.dart` — `contentId` field (+ json).
- `lib/services/notifications/notification_service.dart` — set `contentId` in `scheduleCalendarMark`; propagate it in `getAllNotificationsList`.
- `lib/screens/events/models/local_notification.dart` — propagate `contentId` (two sites).
- `lib/screens/plans/widgets/daily_user_event_list.dart` — propagate `contentId`; "more..." opens specific detail.
- `lib/screens/home/widgets/single_month_container.dart` — chevron opens specific detail.
- `lib/screens/company/models/company_content_model.dart` — `getContentById` (collection-group).
- `lib/screens/company/widgets/content_detail_page.dart` — `openFromPayload` helper.
- `lib/main.dart` — `_openContentDetail` delegates to helper; `_contentTapPayload` for the notify notification.
- `lib/firebase/firestore/firestore.dart` — `.catchError` on offline server refresh.

## Verification
- `flutter analyze` on changed files: no new issues.
- `flutter build apk --debug`: passes.
- Device-verified: day "more...", month chevron, foreground dialog, and
  background/terminated notification tap all open the specific content detail.
- Temporary debug logging used during investigation removed.

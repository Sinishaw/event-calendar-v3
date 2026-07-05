# Plan — Notification Tap Deep-Link Navigation

**Branch:** enhancement/notification-deep-link-day-view_111
**Issue:** #111
**Date:** 2026-07-05

## Goal
Tapping any notification currently opens the home page on both platforms. Wire up the existing but unsubscribed notification stream and cold-start launch details so taps route to the correct screen based on notification type.

## Approach

**Root cause**: `NotificationService.selectNotificationStream` was declared as a local variable inside `initNotifications()` — it was written to (via `.add()`) but never subscribed to externally. `Globals.notificationAppLaunchDetails` was declared but never populated, so cold-start taps were silently ignored.

**Routing rules**:
| Source | Destination |
|---|---|
| `ContentSource.UserTask` | `UserEventPage` Day View tab, scrolled to event date |
| `CompanyEvent / TopicEvent / NationalEvent` | `ContentDetailPage` with Firestore-fetched `CompanyContentModel` |
| Unavailable / unknown | Home page (`Globals.displayingIndex = 0`) |

**`getCompanyContentById`**: `CompanyContentModel` had no single-item fetch. Added one using a Firestore `where('id', isEqualTo: id).limit(1)` query on `Companies/{company}/Contents`. Returns `null` on miss → falls back to home.

**`initialShowDayView` / `initialDayViewDate`**: Added to `UserEventPage` constructor so the notification tap can open directly on the Day View tab anchored to the event's GC date, bypassing the form tab.

## Changes
- `lib/services/notifications/notification_service.dart` — promoted `selectNotificationStream` to `static final` class field; removed local declaration; populated `Globals.notificationAppLaunchDetails` at end of `initNotifications()`; added `globals.dart` import; added `pendingTapPayload` static string set inside `onDidReceiveNotificationResponse`
- `lib/screens/plans/user_event_page.dart` — added `initialShowDayView` (default `false`) and `initialDayViewDate` params; in `initState()` set `_showDayView`, `_dayViewDate`, `_dayPageBaseDate` and schedule `_loadDayViewEvents` post-frame when `initialShowDayView` is true
- `lib/screens/company/models/company_content_model.dart` — added `getCompanyContentById(company, id)` method
- `lib/main.dart` — added `ContentDetailPage` and `UserEventPage` imports; `_ContainerPageState` gains `WidgetsBindingObserver` mixin, `dispose()` (removes observer), `didChangeAppLifecycleState()` (checks `pendingTapPayload` on resume), `_checkPendingNotification()` (primary path: pending payload; fallback: `getNotificationAppLaunchDetails()`); stream listener clears `pendingTapPayload` before processing to prevent double-fire

## iOS behaviour notes
- **Foreground**: `onDidReceiveNotificationResponse` → stream emits → listener fires immediately
- **Background (minimized or suspended)**: `onDidReceiveNotificationResponse` fires as iOS activates the app, sets `pendingTapPayload`; `AppLifecycleState.resumed` fires shortly after → `_checkPendingNotification()` picks it up
- **Terminated (cold start)**: `onDidReceiveNotificationResponse` fires during plugin initialization (plugin queues the response), sets `pendingTapPayload`; post-frame callback fires → `_checkPendingNotification()` picks it up; `getNotificationAppLaunchDetails()` is the fallback if `pendingTapPayload` is null

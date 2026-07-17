# Plan — Sync calendar marks with content publish/unpublish state

**Branch:** fix/mark-on-calendar-fcm-payload_131
**Issue:** #131 (continuation)
**Date:** 2026-07-17

## Goal
Make company/content calendar marks track the content's published state:
- Publish (`st=1`) + `markOnCalendar` + future `markDate` -> mark appears, even
  before/without an FCM send.
- Unpublish (`st=0`), unmark, or past date -> the mark is cancelled.
- No duplicates when an FCM is also sent.

Also fixes the originally reported bug: an unpublished content's notification
lingered because the app received no signal on unpublish.

## Root cause of the lingering notification
Marks live only as OS-scheduled local notifications. Plain unpublish sends no
FCM (FCM is sent on publish), so nothing cancelled the scheduled notification.
Edit-then-publish "worked" only because re-scheduling with the same id replaced it.

## Firestore schema (confirmed from a sample doc)
`markOnCalendar` (bool), `markDate` (Timestamp), `tagColor` (string),
`ageRestriction` (string), `st` (int: 0=unpublished, 1=published; docs are
re-flagged, never deleted), `id` (string), `source` ("Company").

## Approach — client-side reconciliation (no backend change)
1. `toModelList` parses `markOnCalendar`, `markDate`, `tagColor`, `ageRestriction`
   (null-safe via the doc data map, so older docs without these don't break).
2. `NotificationService.scheduleCalendarMark(...)` — one shared scheduler keyed by
   `calendarMarkId(contentId) = (int.tryParse(id) ?? 0) & 0x7FFFFFFF`. Reused by the
   FCM handlers and reconciliation, so both converge on the same entry (dedup).
3. `CompanyContentModel.reconcileCalendarMarks(all)` — iterates the **full** fetched
   list (all statuses); per document: schedule if published+marked+future, else
   cancel (only if a pending *content* notification exists — never touches user
   tasks/national days). Per-document decisions mean a stale/empty cache can't
   mass-cancel valid marks.
4. Hooked (fire-and-forget, self-guarded) into `getUserRelatedContents`, the single
   choke point used by both home and company screens.
5. Refactored both `_saveLocalNotification` copies (FcmHandler.dart, main.dart) to
   delegate to `scheduleCalendarMark`, removing the duplicated payload logic and
   consolidating the earlier age/ID/orElse hardening (see plan 98) into one place.

Alternatives considered:
- Backend sends an unpublish FCM -> simpler client but requires a web-app change; user chose reconciliation.
- Durability (mark visible on/after the highlight day; same-day/past dates) -> still out of scope (root cause B).

## Changes
- `lib/services/notifications/notification_service.dart` — `calendarMarkId`, `scheduleCalendarMark`; imports core_model + local_date_model.
- `lib/firebase/cloudMessaging/FcmHandler.dart` — delegate; drop now-unused imports.
- `lib/main.dart` — delegate; drop now-unused imports.
- `lib/screens/company/models/company_content_model.dart` — parse mark fields; `reconcileCalendarMarks`; hook in `getUserRelatedContents`.

## Verification
- Targeted `flutter analyze` on the four files: no new issues.
- `flutter build apk --debug`: succeeds.
- Functional check pending on device: publish (mark appears without FCM), unpublish (mark cancelled on next sync), FCM send (no duplicate).

## Known limitations
- Reconciliation reflects the cache -> unpublish takes effect after the next server sync, not instantly.
- Root cause B (mark disappears when the notification fires; same-day/past dates) unchanged.

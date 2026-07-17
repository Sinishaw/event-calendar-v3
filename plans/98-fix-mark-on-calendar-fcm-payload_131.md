# Plan — Fix mark-on-calendar FCM events not appearing on highlight date

**Branch:** fix/mark-on-calendar-fcm-payload_131
**Issue:** #131
**Date:** 2026-07-17

## Goal
Make company content sent with `markOnCalendar=true` via FCM actually appear on
the selected highlight date. Currently no marked push ever shows up.

## Root cause (confirmed from on-device log)
`_saveLocalNotification` (duplicated in `lib/firebase/cloudMessaging/FcmHandler.dart`
and `lib/main.dart`) threw `type 'Null' is not a subtype of type 'String'` and
the exception was silently swallowed by the outer FCM handler (only a debugPrint).

The throw came from `age: int.parse(message.data["age"])` — the FCM payload has
**no `age` key**; it sends `ageRestriction`. `int.parse(null)` throws, so the
event was never scheduled and never appeared.

Likely next blocker after that: the FCM `id` (e.g. `160623183813`) exceeds a
32-bit int, which Android notification IDs require — scheduling would still fail.

## Approach
Targeted hardening of `_saveLocalNotification` in both files (kept behavior
identical for valid payloads):
1. `age` read from `ageRestriction` with a safe parse: `int.tryParse(message.data["ageRestriction"] ?? "") ?? 0`.
2. Clamp the notification ID to 32-bit: `(int.tryParse(message.data["id"] ?? "") ?? 0) & 0x7FFFFFFF`, stored and scheduled consistently (cancellation reads the stored id, so no breakage).
3. Add `orElse` defaults to the three enum `firstWhere` calls (tagColor -> regular,
   repeatOption -> noRecurrence, contentSource -> CompanyEvent) so a future
   missing/renamed key can't silently kill the feature again.

Alternatives considered:
- Structural durability fix (persist marked events so they stay visible on/after
  the highlight day, and handle same-day/past dates) — intentionally **out of
  scope** here; the calendar still reads only the OS pending-notification queue.

## Changes
- `lib/firebase/cloudMessaging/FcmHandler.dart` — hardened `_saveLocalNotification`.
- `lib/main.dart` — hardened `_saveLocalNotification` (background-handler copy).

## Verification
- `flutter analyze` on both files: no new issues (only pre-existing warnings).
- No secrets in diff.
- Functional check pending: send a test "mark on calendar" push and confirm the
  event appears on the highlight date (was failing before).

# Plan — Add Event Duration Field for Accurate Day View Block Sizing

**Branch:** enhancement/event-duration-day-view_105
**Issue:** #105
**Date:** 2026-07-02

## Goal
Store a user-selected duration on each event so the day view timeline paints blocks
that reflect actual event length instead of a hardcoded 1-hour default.

## Approach
Add `int? durationMinutes` to `NotificationPayload`. Duration lives inside the
notification payload JSON — same persistence path as every other field. Existing
payloads without the key fall back to 60 via `json['durationMinutes'] as int? ?? 60`,
so there is no migration risk or crash on old data.

`DayEvent.fromNotificationPayload` derives `endTime` from `durationMinutes` instead
of the previous hardcoded `+ 1 hour`. `DayLayoutEngine` and `DayTimeline` already
read `endTime` for block height — no changes needed there.

The form gets a compact chip row (15 min / 30 min / 1 hr / 2 hr / 3 hr) styled
consistently with the other picker cards. Default is 60 min. Edit mode loads the
saved value from the payload.

## Changes
- `lib/screens/events/models/notification_payload.dart` — add `durationMinutes` field, update constructor, `fromJson` (null-safe `?? 60` fallback), `toJson`
- `lib/screens/day_view/models/day_event.dart` — derive `endTime` from `payload.durationMinutes ?? 60`
- `lib/screens/plans/user_event_page.dart` — add `_selectedDurationMinutes` state, reset/load in `_resetEntry`/`_initEditMode`, `_durationPicker()` chip widget, pass to `_getNotificationPayload`

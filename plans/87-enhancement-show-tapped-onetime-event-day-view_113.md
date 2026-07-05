# Plan — Show Tapped One-Time Event in Day View

**Branch:** enhancement/show-tapped-onetime-event-day-view_113
**Issue:** #113
**Date:** 2026-07-05

## Goal
Tapping a fired one-time event notification deep-linked to an empty Day View, because all event views read from `pendingNotificationRequests()` and fired one-time notifications drop out of that list. Show the tapped event at least on open; it may disappear on later fresh navigation (no persistence added — Option B).

## Approach
The tapped notification's payload already carries the full event (title, body, date, time, duration, tag). Pass that payload into `UserEventPage` and inject it into the day view's event list when the list is built — but only for the payload's own date, and only if the pending loop didn't already add it (dedupe by `id`).

Because a fired one-time notification is no longer pending, the injected copy is the only thing that renders it. For a still-pending event (e.g. recurring), the normal loop already adds it and the dedupe guard skips the injection — so injection only ever actually adds the fired-one-time case, which is the target.

Scope kept minimal: only `UserEventPage`'s embedded day view (where the deep-link lands) is touched. The standalone `DayViewPage`, month calendar, and daily list are intentionally left alone — consistent with "show it at least when it opens, can disappear later."

Considered and rejected: persisting user events in a real store (Option A) — correct long-term but far larger; the user explicitly chose the lightweight interim.

## Changes
- `lib/screens/plans/user_event_page.dart` — added `initialDayViewEvent` (`NotificationPayload?`) constructor param; in `_loadDayViewEvents()` inject it via `DayEvent.fromNotificationPayload()` guarded by date-match + dedupe-by-id
- `lib/main.dart` — pass `initialDayViewEvent: p` in `_handleNotificationTap`'s `ContentSource.UserTask` case

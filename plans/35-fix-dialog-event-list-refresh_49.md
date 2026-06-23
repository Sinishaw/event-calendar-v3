# Plan — Fix: Dialog Event List Does Not Refresh After Adding Event

**Branch:** fix/dialog-event-list-refresh_49
**Issue:** #49
**Date:** 2026-06-23

## Goal
After saving an event from `UserEventPage` (opened via the `+` button in the day long-press dialog), the `DailyUserEventList` inside the dialog immediately shows the new event when the user presses back — no close/reopen required.

## Root Causes
1. `Navigator.push(...)` was fire-and-forget — the dialog had no signal that the user returned.
2. `DailyUserEventList` is `StatelessWidget` — without a `key`, Flutter reuses the same instance on parent rebuild and does not re-run its `FutureBuilder`.
3. `allNotificationPayloadList` / `filteredNotificationPayloadList` are instance-level fields that accumulate across builds and are never cleared on re-render.

## Approach
Three minimal surgical changes to `task_and_event_dialog.dart`:

1. **`_refreshKey` counter** — `int` field on the state, initialized to `0`.
2. **`await` navigation + `setState`** — `onTap: () async`, `await Navigator.push(...)`, then `if (mounted) setState(() => _refreshKey++)` after the push completes.
3. **`ValueKey(_refreshKey)` on `DailyUserEventList`** — When the key changes, Flutter disposes the old instance (clearing its lists) and creates a fresh one, re-firing `_getSingleDayNotifications()` via `FutureBuilder`.

## Changes
- `lib/screens/home/widgets/task_and_event_dialog.dart` — Added `_refreshKey`, awaited navigation, `setState` on return, `ValueKey` on `DailyUserEventList`

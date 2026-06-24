# Plan — Deletion Refresh Fix for Month Grid

**Branch:** feature/swipe-to-edit-event_61
**Issue:** #61
**Date:** 2026-06-24

## Goal
Fix the bug where deleting the last event (or any event) from the daily events list via swipe-delete does not refresh the monthly calendar grid event indicators immediately. The monthly calendar grid should update immediately after the event is deleted from the dialog.

## Approach
- Invoke the `onEventsChanged` callback inside the `onDismissed` handler of the `Dismissible` widget in `daily_user_event_list.dart`.
- When an event is dismissed via swipe-left, the notification is cancelled, and `onEventsChanged` is called to notify the parent dialog and the home page's monthly calendar grid state that the events lists should be rebuilt.
- The parent dialog and calendar grid dots will rebuild dynamically, showing the updated list of events immediately and removing the indicator dots from the month grid if no events remain.

## Changes
- [daily_user_event_list.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/plans/widgets/daily_user_event_list.dart) — Invoke `onEventsChanged` inside `onDismissed` callback of `Dismissible` for the `endToStart` direction.

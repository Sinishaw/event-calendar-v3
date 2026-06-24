# Plan — Swipe Right to Edit Event

**Branch:** feature/swipe-to-edit-event_61
**Issue:** #61
**Date:** 2026-06-24

## Goal
Implement a swipe-right gesture on event/task list items in the daily user events list to open that event/task in edit mode. All properties of the event (title, description, category, repeat settings, alarm, and dates/times) should be populated on the form, and the page should clearly indicate it is in edit mode.

## Approach
- **Translations**: Added `"editEventOrTask"` to `app_en.arb`, `app_am.arb`, `app_or.arb`, and `app_te.arb` and ran `flutter gen-l10n`.
- **Bidirectional Swipe**: Changed `direction` in `Dismissible` inside `daily_user_event_list.dart` to `DismissDirection.horizontal`.
- **Creative Swipe Backgrounds**: Moved delete background to `secondaryBackground` with a fading red-accented gradient (transparent-to-red) and thin red border, and added a new edit background to `background` with a fading teal-accented gradient (teal-to-transparent) and thin teal border for a creative, distinct UI.
- **Swipe Action & Callback**: Modified `confirmDismiss` on `Dismissible` to detect `startToEnd` (swipe right), open `UserEventPage` with `eventToEdit: payload`, and call the `onEventsChanged` callback to refresh parent dialog/views upon return (returning `false` to avoid removing the item).
- **Edit Mode Initialization**: Added `eventToEdit` parameter to `UserEventPage` and extracted all event fields in `_initEditMode()` inside `initState` to prepopulate form text controllers and state parameters.
- **Creative Edit UI Indicators**: Added localized `editEventOrTask` title in the `AppBar`, a prominent and creative orange/gold gradient banner with a circular edit icon badge at the top of the body column, and swapped the save FAB icon to `Icons.check_rounded`. Hided the daily events list in edit mode to focus user input.
- **Edit Saving Logic**: Modified `_saveEvent()` in `UserEventPage` to cancel the old notifications first before scheduling the updated event notifications, and pop the navigation stack after a 1.5-second delay so that the success snackbar/toast remains visible to the user.
- **Date Change behavior**: When an event's date is modified, staying on the old date's dialog is preferred because the user might have other events on that day they want to manage, but the edited event will disappear from the current day's list (since it moved to the new date) and the calendar grid dots will update immediately to show it on the new date.

## Changes
- [app_en.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_en.arb) — Add editEventOrTask key.
- [app_am.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_am.arb) — Add editEventOrTask key.
- [app_or.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_or.arb) — Add editEventOrTask key.
- [app_te.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_te.arb) — Add editEventOrTask key.
- [daily_user_event_list.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/plans/widgets/daily_user_event_list.dart) — Implement swipe-right to edit, gradients, and `onEventsChanged` callback.
- [task_and_event_dialog.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/task_and_event_dialog.dart) — Pass `onEventsChanged` callback.
- [user_event_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/plans/user_event_page.dart) — Add `eventToEdit`, populate fields, show orange gradient edit indicators/banners, cancel old notification on save, and pop with 1.5s delay.

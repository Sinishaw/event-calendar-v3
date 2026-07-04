# Plan — National Days in Day View All-Day Strip

**Branch:** enhancement/national-days-in-day-view_109
**Issue:** #109
**Date:** 2026-07-03

## Goal
Surface national and religious days in the day view so users see cultural significance at a glance without switching to a separate screen.

## Approach
The `AllDayStrip` widget already sits above the timeline in both `DayViewPage` and `UserEventPage`'s day view tab — it just needed data. `HolidayAndNationalEvents.getDailHolidays(etYear, etMonth, etDay)` already exists and returns the right list. The missing link was converting results to `DayEvent(isAllDay: true)` and appending them in each load method.

Added `DayEvent.fromNationalDay()` factory so the conversion is defined once. Colors by `HolidayType`: Christian=gold `#F5A623`, Federal=Ethiopian green `#078930`, Muslim=teal `#009688`, Others=violet `#7B61FF`. ID offset `90000 + index` avoids collision with notification IDs.

Both `_loadEvents()` (DayViewPage) and `_loadDayViewEvents()` (UserEventPage) now call `MonthModel.toEc()` on the GC date, call `getDailHolidays()`, and append the results. No changes to `AllDayStrip`, `DayTimeline`, or any build methods.

## Changes
- `lib/screens/day_view/models/day_event.dart` — `fromNationalDay()` factory + `_colorForHolidayType()` static helper; new import for `fixed_national_events_detail.dart`
- `lib/screens/day_view/day_view_page.dart` — append national days after notification events in `_loadEvents()`; new imports for `core_model.dart` and `holiday_and_national_events.dart`
- `lib/screens/plans/user_event_page.dart` — identical append block in `_loadDayViewEvents()`; new import for `holiday_and_national_events.dart`

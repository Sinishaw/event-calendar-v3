# Plan — Add Google Calendar-Style Day View

**Branch:** feature/day-view_101
**Issue:** #101
**Date:** 2026-07-01

## Goal
A scrollable 24-hour day timeline (Google Calendar benchmark) accessible from the existing event form. Long press a time slot to pre-fill the form's date and time. Existing calendar events rendered as colored tag-coded blocks. Zero changes to existing business logic.

## Approach
Entry point: a compact "View Day" icon button added next to the date picker in `_dateTimePickerRow()`. It pushes `DayViewPage` with the currently selected date. Long press on the timeline calls `onTimeSelected`, pops back a `DateTime`, and the form updates date + time in state.

All layout math flows through `TimelineUtils` (single `hourHeight` constant). Overlap detection runs in `DayLayoutEngine` before render. Event color uses the same `Globals.categoryColorList` / primaryColor-for-national mapping as `DailyUserEventList`.

## Architecture (extensible)
- `DayEvent` — unified display model; factory from `NotificationPayload`; future sources add factory constructors
- `TimelineUtils` — all Y↔DateTime math; change `hourHeight` to zoom
- `DayLayoutEngine` — column-split overlap algorithm; swap strategy without touching widgets
- `DayTimeline` — `CustomPainter` grid + `Stack/Positioned` events + `GestureDetector` long press
- `DayViewPage` — accepts `onTimeSelected` callback; reusable from any caller
- `AllDayStrip` — wired but empty; ready for all-day events
- `DayNavHeader` — emits dates via callback; can drive week view header

## Changes
- `lib/screens/day_view/models/day_event.dart` — new unified display model
- `lib/screens/day_view/utils/timeline_utils.dart` — Y↔DateTime math + scroll helpers
- `lib/screens/day_view/utils/day_layout_engine.dart` — overlap column-split algorithm
- `lib/screens/day_view/widgets/current_time_indicator.dart` — red line, auto-updates 1/min
- `lib/screens/day_view/widgets/all_day_strip.dart` — all-day strip (empty, extensible)
- `lib/screens/day_view/widgets/day_nav_header.dart` — prev/next day navigation
- `lib/screens/day_view/widgets/day_event_block.dart` — colored event card
- `lib/screens/day_view/widgets/day_timeline.dart` — scrollable grid + events + long press
- `lib/screens/day_view/day_view_page.dart` — main screen
- `lib/screens/plans/user_event_page.dart` — import + view-day icon button + `_openDayView()`

# Plan — Day View Bug Fixes: Colors, Tab UX, Loading & Rendering

**Branch:** feature/day-view_101
**Issue:** #101
**Date:** 2026-07-01

## Goal
Fix three bugs reported after initial day view implementation:
1. Header showing wrong light purple color instead of brand primary
2. View-day icon button in awkward position; replace with a segmented pill tab (Form | Day View)
3. Infinite loading spinner on first open; black/yellow overflow stripes on events

## Approach

### Bug 1 — Colors
`DayViewPage` AppBar had `backgroundColor: Colors.transparent` which fell back to a system-default surface tint (purple). Removed the explicit `Colors.transparent` so the AppBar inherits `AppBarTheme` from the remote-config primary color.

### Bug 2 — Tab UX
Removed the 48×48 view-day icon button from `_dateTimePickerRow()` and the corresponding `_openDayView()` Navigator.push approach entirely. Replaced with a narrow (36px) segmented pill control at the top of `UserEventPage.body`, rendering two pills: **Form** and **Day View**. Switching tabs shows either the existing form content or an embedded day timeline in-place — no route push, no context loss. Long-pressing a time slot in the embedded timeline pre-fills the form's date, time, and ET time, then auto-switches back to the Form tab.

### Bug 3 — Loading + Rendering
- **Loading**: `_loadEvents()` was called directly in `initState`, triggering `setState(() => _loading = true)` and `Theme.of(context)` before the first frame. Fixed by deferring to `WidgetsBinding.instance.addPostFrameCallback`. Removed the redundant `setState(() => _loading = true)` since `_loading = true` is the field default.
- **Rendering stripes**: `DayTimeline` used `MediaQuery.of(context).size.width` inside an `Expanded` widget, giving the full screen width instead of the available timeline width. Replaced with `LayoutBuilder` wrapping the event `Stack` so `constraints.maxWidth` is used for all `Positioned` event block coordinates. Added `.clamp()` guards on `width` and `height` to prevent negative or overflow values.

## Changes
- `lib/screens/day_view/day_view_page.dart` — defer `_loadEvents` to postFrameCallback; remove transparent AppBar
- `lib/screens/day_view/widgets/day_timeline.dart` — rewrite with `LayoutBuilder` for correct width; remove `MediaQuery` usage in Positioned children
- `lib/screens/plans/user_event_page.dart` — add tab switcher (Form | Day View); embed DayTimeline inline; remove icon button and Navigator.push; add `_loadDayViewEvents`, `_onTimelineTimeLongPressed`, `_dayScrollController`

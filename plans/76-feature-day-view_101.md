# Plan — Day View: DayEventBlock Overflow + SafeArea Bottom Breathing Room

**Branch:** feature/day-view_101
**Issue:** #101
**Date:** 2026-07-01

## Goal
Fix persistent `RenderFlex overflowed by 22 pixels on the bottom` in the day view
and add breathing room at the bottom of the timeline scroll area.

## Root Cause
`DayEventBlock` used `event.duration.inMinutes < 30` to decide whether to render
the short (title-only) or full (title + time range) layout. For events near midnight,
`DayLayoutEngine` truncates their visual height to however many pixels remain before
end-of-day (e.g. 16px for an event starting at 23:45), but the event's `duration`
is still 60 minutes. The full-content `Column` (~28px content + 8px padding = 36px)
was placed into a 16px Positioned box → 22px RenderFlex overflow.

## Approach
1. Add a `height` parameter to `DayEventBlock` so the widget knows its actual
   rendered height, independent of `event.duration`.
2. Use `height` for the layout decision:
   - `height < 14` → colored bar only, no text at all
   - `14 ≤ height < 36` → title-only (short mode)
   - `height ≥ 36` → full title + time range
3. Pass `blockH` from `DayTimeline` into `DayEventBlock`.
4. Wrap `_buildDayViewContent()` and `DayViewPage` body with
   `SafeArea(top: false)` so the Column accounts for the system
   navigation bar inset.
5. Add `bottomPadding` prop to `DayTimeline` (default 24px); embedded
   mode passes `systemPadding + 24` for extra scroll-end breathing room.

## Changes
- `lib/screens/day_view/widgets/day_event_block.dart` — add `height` param; render colored bar / short / full based on actual height
- `lib/screens/day_view/widgets/day_timeline.dart` — pass `blockH` to DayEventBlock; add `bottomPadding` prop applied to ScrollView
- `lib/screens/plans/user_event_page.dart` — wrap embedded day view in SafeArea(top:false); pass bottomPadding
- `lib/screens/day_view/day_view_page.dart` — wrap body Column in SafeArea(top:false)

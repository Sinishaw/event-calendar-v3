# Plan — Redesign Day Long-Press Dialog Header

**Branch:** enhancement/day-dialog-header-redesign_47
**Issue:** #47
**Date:** 2026-06-23

## Goal
Redesign the header area of the long-press day popup (`ShowDayTaskAndEventsDialog`) to be modern and consistent with the app's glassmorphic, card-based design system. Add a `+` icon button to the header for quick event creation.

## Approach
The existing header was a plain `Padding` + `Row` with two `Column` widgets using hardcoded font sizes and `Theme.of(context).primaryColor` — flat, no visual hierarchy, no depth.

**New header design:**
- Dialog container uses `BorderRadius.circular(20)`, `BoxDecoration` with a themed `boxShadow` using `primary.withValues(alpha: 0.18)`
- Full-width gradient strip: `LinearGradient` from `primaryColor.withValues(alpha:)` top-left to bottom-right — adapts to dark/light mode
- ET day: large bold `44px` text in `primaryColor` with `FontWeight.w800`  
- Weekday: pill/chip container (`BorderRadius.circular(20)`, primary border + fill) with month/year inline
- GC day: `28px FontWeight.w700` in `onSurface.withValues(alpha: 0.55)` — secondary priority
- `+` icon: `36×36` rounded-rect button (`BorderRadius.circular(12)`) in the top-right, navigates to `UserEventPage` (same action as old bottom `add_circle`)
- Thin gradient accent divider (1.5px) below header fading from `primary` to transparent
- `DailyUserEventList` and all business logic completely untouched
- Fixed deprecated `dialogBackgroundColor` → `colorScheme.surface`

## Changes
- `lib/screens/home/widgets/task_and_event_dialog.dart` — Redesigned header, added `+` icon, fixed deprecation

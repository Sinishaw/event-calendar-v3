# Plan — Modernize home month header: nav icons & weekday row

**Branch:** enhancement/home-month-header-modern_136
**Issue:** #136
**Date:** 2026-07-23

## Goal
Refresh the home-page month header so it reads modern instead of dated:
the month-navigation arrows and the weekday-title row (Mon, Tue …).

## Approach (chosen with the user)
- **Nav icons** (`headerNavigation`, single_month_container.dart): replace the sharp
  `Icons.arrow_back_ios` / `arrow_forward_ios` with rounded chevrons
  (`chevron_left_rounded` / `chevron_right_rounded`) inside soft circular tinted
  buttons (primary @ 8%). Extracted a `_monthNavButton` helper (Material + InkResponse,
  38x38 circle). Header stays 50px tall, so the grid cell-height calc is unaffected.
- **Weekday row** (`monthHeader`, month_callables.dart): drop the muddy `primary @20%`
  fill and the hard 0.5px border. Labels are now uppercase, letter-spaced (0.3),
  size 12, w600, muted (primary @60%); weekend (Sat/Sun) dimmer (@45%). A faint
  hairline bottom divider (primary @8%) keeps separation from the grid. Row height
  kept ~27px (vertical padding 5) so the grid cell-height estimate stays valid.

## Changes
- `lib/screens/home/widgets/single_month_container.dart` — rounded chevrons in
  circular buttons; `_monthNavButton` helper.
- `lib/screens/home/model/month_callables.dart` — clean/minimal weekday row.

## Verification
- `flutter analyze` on both files: no new issues (only pre-existing `withOpacity` infos).
- `flutter build apk --debug`: passes.
- Visual check pending on device.

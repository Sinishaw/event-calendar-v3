# Plan — Professional Month Grid Layout & Cell Styling

**Branch:** enhancement/professional-month-grid-layout_16
**Issue:** #16
**Date:** 2026-06-21

## Goal
Improve visual hierarchy, styling, and clarity of the main calendar month grid view by showing Ethiopian and Gregorian dates side-by-side (with Ethiopian date styled bolder) and graying out non-month days. Also modernize the holiday/event underline indicator with a centered circular dot indicator, configured via remote holiday colors and positioned closer to the dates.

## Approach
- Refactored `single_month_container.dart` in `getMonthGrid()` to arrange the dates inside a horizontal `Row` rather than a vertical/wrapped stack.
- Configured holiday and Sunday text/indicator color to fetch from Firebase Remote Config properties (`holidayColorLight` and `holidayColorDark` depending on the active theme brightness) with a fallback to `Colors.redAccent`.
- Registered `holidayColorLight` and `holidayColorDark` defaults (hex `#FF5252`) in the remote config setup.
- Styled the active Ethiopian day with `FontWeight.w700` (bold) and the Gregorian day with a smaller `fontSize: 11` and `FontWeight.w400` (italicized) for clean contrast.
- Styled non-month days (previous/next month) with lighter weight (`FontWeight.w300`) and a semi-transparent grayed-out color (`holidayColor` or grey with opacity).
- Retained the `adey.png` image rendering when `geezDay == "0"` to preserve special New Year assets in Meskerem.
- Replaced the horizontal underline bar for holidays/events with a sleek, centered circle dot of diameter `6.0` underneath the date row, positioned closer by reducing top margin to `2.0`.
- Rendered a constant-height empty space when there is no event to prevent grid cells from shifting vertically.

## Changes
- `lib/screens/home/widgets/single_month_container.dart` — Refactored day cell styling, event dot indicators, spacing adjustments, and added a private helper to resolve remote holiday colors.
- `lib/firebase/remoteConfig/firebase_remote_config.dart` — Registered default values for the new `holidayColorLight` and `holidayColorDark` remote config parameters.

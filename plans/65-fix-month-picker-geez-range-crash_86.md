# Plan — Fix Month Picker Geez Year Range Crash

**Branch:** fix/month-picker-geez-range-crash_86
**Issue:** #86
**Date:** 2026-06-29

## Goal
Fix the `RangeError` (length) crash in `MonthPickerDialog` that occurs when scrolling the year range in Year View with Geez number formatting enabled.

## Approach
- Align `startYear` calculation in `_buildHeader` by capping it at `2039` when `_isYearView` is true. This matches the logic in `_buildYearGrid`, ensuring the header text matches the displayed grid years and stays within the `1900..2050` range.
- Add safe array index bounds checking helper `_getSafeGeezYear` for `GeezNumbers.geezYears` access to prevent any future out-of-bounds index exceptions.

## Changes
- `lib/screens/home/widgets/month_picker_dialog.dart` — Modified `_buildHeader` to align the `startYear` calculation and implemented the `_getSafeGeezYear` helper method.

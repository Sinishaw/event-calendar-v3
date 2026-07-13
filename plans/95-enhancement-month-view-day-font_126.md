# Plan — Month View: larger, thinner day numbers

**Branch:** enhancement/month-view-day-font_126
**Issue:** #126
**Date:** 2026-07-13

## Goal
Make the Ethiopian day numbers in the home month grid a bit more visible (larger) with a slightly thinner font, without losing the active (current-month) vs grayed (other-month) distinction.

## Approach
In `single_month_container.dart` the day-number style is `etDayFontSize` + `fontWeight` (active `w700`, prev/next `w300`); the active/gray distinction is carried by **color** (`cellColor`), so thinning the active weight keeps it. Only the Ethiopian day number is touched — the Gregorian sub-number and all colors are unchanged.

## Changes
- `lib/screens/home/widgets/single_month_container.dart`:
  - `etDayFontSize`: `isGeezNumbers ? 16 : 18` → `isGeezNumbers ? 18 : 20` (a little larger).
  - Active day `fontWeight`: `w700` (bold) → `w500` (medium, thinner). Prev/next stays `w300`.

## Verification
- `dart analyze` clean (pre-existing unrelated warnings only).
- `flutter run`: month view day numbers are larger and lighter; current-month days still full-colored, other-month days still grayed; today/holiday highlighting unchanged.

## Note
Values are easy to tune (e.g. `w500`↔`w600`, size ±1) if the user wants it a touch different after seeing it.

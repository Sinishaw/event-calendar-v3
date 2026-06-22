# Plan — Modern Date Converter UI Redesign (Fixes)

**Branch:** `enhancement/modern-date-converter-ui_25`
**Issue:** #25
**Date:** 2026-06-22

## Goal
Adjust the date converter's manual input dialog to prevent the year text field from being cut off by the clear button, and fix the "Today" button bug where returning to today sometimes required a second click.

## Approach
- Assigned uneven flex values to the input row (3 for day, 3 for month, 4 for year) to grant the year field more space.
- Configured the clear `IconButton` inside text fields to use zero padding and empty constraints, minimizing its width footprint.
- Added a `_isProgrammaticScroll` state guard flag to `ConverterPage` to ignore `onSelectedItemChanged` notifications during programmatic scrolling (such as when the user clicks "Today", toggles tabs, or inputs a date).
- Rewrote `scrollToInitialDay()` as an asynchronous method that awaits the animation of all three controllers using `Future.wait`.
- Updated the "Today" button and tab toggle handlers to asynchronously animate the scroll wheels while guarding with `_isProgrammaticScroll = true/false`, eliminating the previous calendar type toggling workaround.

## Changes
- `lib/screens/converter/input_based_converter_dialog.dart` — Adjusted flex layout to 3:3:4 and styled clear button icon to be compact.
- `lib/screens/converter/converter_page.dart` — Added `_isProgrammaticScroll` state guard, made scroll animation asynchronous, guarded scroll selections, and updated "Today" and tab toggle tap handlers.

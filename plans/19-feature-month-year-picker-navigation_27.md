# Plan — Month and Year Picker Navigation

**Branch:** `feature/month-year-picker-navigation_27`
**Issue:** #27
**Date:** 2026-06-22

## Goal
Redesign the calendar month picker dialog to have a modern, unified, and elegant user interface, and add the ability to interactively navigate through multiple years inside the dialog (both via year chevrons and a decade-based year selection grid).

## Approach
- Unified the three disjointed floating panels into a single, cohesive dialog card with rounded corners (`Radius: 24`), a subtle border, and deep drop shadows.
- Added local state variables (`_localShowingYear` and `_isYearView`) to keep year changes temporary and prevent calendar year updates when users cancel/dismiss the dialog.
- Designed a tap-to-toggle year title button in the header that switches the main body view between a Month Selection grid and a Year Selection grid.
- Implemented year increment/decrement chevron buttons that change the year by 1 in Month View and shift the decade by 12 years in Year View.
- Configured a 4-column month selection grid with rounded pill shapes, high-contrast primary selection colors, and an outline indicator for the current "Today" month.
- Configured a 3x4 grid for selecting years within the currently navigated decade range.
- Restyled the footer today action button into an integrated today date card that shows the Gregorian and Ethiopian today dates stacked with a clean icon.

## Changes
- `lib/screens/home/widgets/month_picker_dialog.dart` — Complete UI redesign and year selection/grid view integration.

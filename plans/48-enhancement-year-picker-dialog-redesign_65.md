# Plan — Redesign Year Picker Dialog to Scrollable Grid

**Branch:** enhancement/year-picker-dialog-redesign_65
**Issue:** #65
**Date:** 2026-06-24

## Goal
Redesign `YearPickerDialog` into a modern, scrollable year grid picker (from 1900 to 2050) to prevent typing errors and keyboard overlay issues. Also, add click indicators (downward chevron arrows) to the year header titles of the Year page and National Days page.

## Approach
- Overhaul `YearPickerDialog` in `year_picker_dialog.dart` using a custom `Dialog` with rounded corners (`BorderRadius.circular(24)`), brand primary colors, and card shadows.
- Replace the text input field with a scrollable `GridView` of years:
  - Add auto-scroll centering in `initState` to focus on the active year.
  - Render selected year in a solid primary-colored pill and the current system year with a bold primary border.
- Add small downward chevron icons (`Icons.keyboard_arrow_down_rounded`) next to the year titles in both `national_event_page.dart` and `year_page.dart`.

## Changes
- [year_picker_dialog.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/year/widgets/year_picker_dialog.dart) — Implement scrollable year grid selection and premium glassmorphic styling.
- [national_event_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/national_event_page.dart) — Add downward chevron next to year title.
- [year_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/year/year_page.dart) — Add downward chevron next to year title.

# Plan — Dock Add Button & Mirror Header Date Layout

**Branch:** enhancement/dock-add-button_63
**Issue:** #63
**Date:** 2026-06-24

## Goal
- Refine the bottom-docked plus button styling to be a curved rectangle (rounded square) matching the original design.
- Re-align and format the Gregorian (GC) date block in the top-right corner of the dialog header to mirror the Ethiopian (ET) date block in the left corner (large day number on top, details below it).

## Approach
- Modify the bottom plus button in `task_and_event_dialog.dart` to use a `BoxDecoration` with `BorderRadius.circular(12)`, border, semi-transparent background, and a primary-colored icon.
- Format the GC date block in the top-right header:
  - Day number size increased to `44` with `FontWeight.w800`.
  - Details (Month/Year text and Weekday chip) placed below the day number.
  - Symmetrically mirror the left corner layout with appropriate cross-alignment (`CrossAxisAlignment.end` and right-aligned weekday chip).

## Changes
- [task_and_event_dialog.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/task_and_event_dialog.dart) — Update plus button shape and GC date block layout.

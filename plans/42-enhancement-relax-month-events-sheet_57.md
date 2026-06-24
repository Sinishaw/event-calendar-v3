# Plan — Relax Month Events Sheet

**Branch:** enhancement/relax-month-events-sheet_57
**Issue:** #57
**Date:** 2026-06-23

## Goal
Relax the layout spacing and typography of the month events swipe-up sheet (DraggableScrollableSheet) and ensure it does not partially hide the bottom row of monthly calendar days when collapsed.

## Approach
- Reduce the collapsed height of the events sheet by setting `initialChildSize` and `minChildSize` to `0.06` (from `0.1`).
- Adjust the margin of the drag handle pill to `EdgeInsets.only(top: 2, bottom: 10)` to pull the sheet further down, keeping the bottom row of calendar days fully visible.
- Increase spacing between items to `12.0` (from `8.0`).
- Relax the padding of list items inside `_companyAndTopicContentBuilder` and `_nationalAndPersonalContentBuilder` to `vertical: 10, horizontal: 14` (from `vertical: 6, horizontal: 10`).
- Scale up the leading badge icon container size to `38x38` (from `30x30`) and the icons/loaders inside to `18` or `16`.
- Boost typography sizes for events: titles to `14` (from `12`), bodies to `12` (from `10`), and timestamps to `11` (from `9.5`).

## Changes
- [single_month_container.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/single_month_container.dart) — Modify `DraggableScrollableSheet` size and padding/spacing/typography inside event content builders.

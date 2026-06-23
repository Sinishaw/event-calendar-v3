# Plan — Resolve Drag Handle Column Layout Overflow

**Branch:** enhancement/month-events-sheet-redesign_33
**Issue:** #33
**Date:** 2026-06-23

## Goal
Resolve the RenderFlex layout overflow error occurring when the month events sheet is collapsed.

## Approach
When the sheet is collapsed, the parent constraints can restrict the height of the sheet's container to a very small size (e.g., 23.4px).
- A `Column` containing a fixed-height drag handle (29px) and an `Expanded(ListView)` will overflow because the handle is taller than the container, and `Expanded` gets a negative height constraint.
- To fix this, we will remove the `Column` and `Expanded` hierarchy. Instead, we will feed the drag handle directly into the `ListView.builder` at `index == 0` (increasing the item count by 1).
- The `ListView` handles any small constraints (like `23.4px`) gracefully by clipping items without raising layout errors, while also enabling scroll drag physics across the entire sheet.

## Changes
- [single_month_container.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/single_month_container.dart) — Restructure the sheet content builder.

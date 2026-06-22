# Plan — Adjust Save FAB Position and Size

**Branch:** feature/event-task-form-redesign_29
**Issue:** #29
**Date:** 2026-06-23

## Goal
Minimize the Save button size (both width and height) by switching to a compact, icon-only layout featuring the globally recognized save icon, and position it directly at the top of the bottom navigation menu with minimal space.

## Approach
1. Change the FAB in `user_event_page.dart` from `FloatingActionButton.extended` to a standard `FloatingActionButton` containing only the `Icons.save_rounded` icon.
2. Keep the `RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))` shape to match the rest of the application's card and text field design language.
3. Position the FAB using a custom `_CustomFABLocation` that offsets the standard location by `+14` pixels vertically, placing the button directly above the bottom navigation menu with a clean `2.0` pixel gap.

## Changes
- [user_event_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/plans/user_event_page.dart) — Convert extended FAB to icon-only FAB, adjust layout coordinates.

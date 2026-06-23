# Plan — Month Events Swipe-up Sheet Redesign

**Branch:** enhancement/month-events-sheet-redesign_33
**Issue:** #33
**Date:** 2026-06-23

## Goal
Redesign the Month Events swipe-up sheet (`DraggableScrollableSheet` in `single_month_container.dart`) and its individual event items to use a modern, curved container with dynamic glassmorphism and persistent drag handle, consistent with the style of `daily_user_event_list.dart`.

## Approach
1. **Curved Glassmorphic Panel**:
   - Restructure `DraggableScrollableSheet`'s builder to return a card container with rounded top corners (`24px`).
   - Read `Globals.setting.menuBackgroundOpacity` to determine the background color. If the opacity is less than `1.0`, wrap the container in a `BackdropFilter` (blur: `15.0`) to create a translucent glassmorphic backdrop.
   - Add a persistent centered header drag handle pill (44px wide, 5px high) that does not scroll away.
2. **Refactored Event List Items**:
   - Clean up the event list view by removing index-specific drag handle layout branching. Every item inside the `ListView.builder` will render a regular event card.
   - Refactor `_companyAndTopicContentBuilder` and `_nationalAndPersonalContentBuilder` to use card layouts matching the styling of `daily_user_event_list.dart`.
   - Replace raw dividers and list backgrounds with margin-spaced cards (`SizedBox(height: 12)`).
   - Use `categoryColor.withOpacity(0.12)` for circular icon backgrounds and add clock/calendar icons to align details.

## Changes
- [single_month_container.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/single_month_container.dart) — Redesign `DraggableScrollableSheet` structure, handle layouts, and event builders.

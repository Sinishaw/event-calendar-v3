# Plan — Modernize Bottom Navigation Bar Icons

**Branch:** enhancement/modernize-bottom-menu-icons_71
**Issue:** #71
**Date:** 2026-06-25

## Goal
Update the bottom navigation bar active and inactive icons to display modern, context-appropriate symbols.

## Approach
Replace the traditional icons with the recommended modern set:
- **Home Tab**: Use calendar-focused icons (`calendar_month_outlined` and `calendar_month`) instead of the generic house.
- **Year Tab**: Use date range icons (`date_range_outlined` and `date_range`) instead of the abstract grid.
- **Converter Tab**: Use horizontal arrows (`swap_horiz`) to represent swapping and converting calendar dates.
- **Content Tab**: Use newspaper icons (`newspaper_outlined` and `newspaper`) instead of the note pad with a pencil.

## Changes
- [bottom_navigation.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/menu/bottom_navigation.dart) — Update `_inactiveIcons` and `_activeIcons` lists.

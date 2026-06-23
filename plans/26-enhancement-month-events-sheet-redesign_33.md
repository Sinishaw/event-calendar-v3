# Plan — Compact Month Event Cards

**Branch:** enhancement/month-events-sheet-redesign_33
**Issue:** #33
**Date:** 2026-06-23

## Goal
Redesign the Month Events swipe-up sheet's list items to be extremely compact, ensuring three events are fully visible within the viewport when pulled up, and replacing the verbose "more..." text with modern trailing chevrons.

## Approach
1. **Compact Sizing**:
   - Reduced vertical container padding of cards from `8` to `6`, and horizontal from `12` to `10`.
   - Reduced bottom item spacing from `12.0` to `8.0`.
   - Reduced category badge size from `32/36` to `30`, and inner icon size to `14`.
   - Set title font size to `12`.
2. **Text Preview Optimization**:
   - Restricted description body text to `maxLines: 1` instead of `2` to prevent excessive card heights for long text.
   - Tweaked font sizes (body to `10`) and reduced vertical line spacing.
3. **Icons & Chevrons**:
   - Standardized chevron circle container padding to `3` and chevron size to `16` for cleaner navigation.

## Changes
- [single_month_container.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/single_month_container.dart) — Redesigned builders for compact cards, spacing, and icon sizes.

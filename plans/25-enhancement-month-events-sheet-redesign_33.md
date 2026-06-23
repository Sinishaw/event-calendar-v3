# Plan — Compact Event Cards with Trailing Chevron Icons

**Branch:** enhancement/month-events-sheet-redesign_33
**Issue:** #33
**Date:** 2026-06-23

## Goal
Redesign the event item cards inside the Month Events swipe-up sheet to be more compact, allowing the user to see three events on a full screen/scroll, and replace the verbose "more..." text buttons with modern trailing chevrons.

## Approach
1. **Compact Layout & Spacing**:
   - Reduce internal padding of the card container from `12` to `8` (vertical) and `10` (horizontal).
   - Reduce spacing between items from `12` to `8`.
   - Set the body/description text to `maxLines: 2` instead of `3`.
   - Reduce category icon badge size to `34` or `36` pixels (icon size `16` or `18`).
2. **Trailing Chevron Navigation**:
   - Replace the bottom "more..." action cards with a clean `Icons.chevron_right_rounded` icon positioned as a trailing element in the card's main `Row`.
   - This eliminates the vertical space taken by the bottom action row, significantly shortening the cards so three events easily fit in one scroll.

## Changes
- [single_month_container.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/single_month_container.dart) — Update card builders for compact size and trailing chevrons.

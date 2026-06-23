# Plan — Redesign National Days Page

**Branch:** enhancement/national-days-redesign_39
**Issue:** #39
**Date:** 2026-06-23

## Goal
Redesign the National Days page (`lib/screens/events/national_event_page.dart`) to present a modern, responsive, and elegant UI matching the new visual aesthetics.

## Approach
1. **Modern Cards & Shadows**:
   - Replaced transparent items and raw dividers with elegant rounded card containers (`BorderRadius.circular(16)`).
   - Added subtle borders (`1.2px`) and soft shadows to individual cards.
   - Used a semi-transparent glassmorphic background tint (`theme.cardColor.withOpacity(isDark ? 0.35 : 0.65)`).
2. **Category Color-Coding**:
   - Mapped card borders and leading icons to colors reflecting holiday categories (Christian -> primary, Muslim -> green, Federal -> secondary accent, Others -> blue-grey).
3. **Circular Leading Badges**:
   - Replaced square icon containers with clean circular badges with a subtle 8% background category color opacity.
4. **Clean date details**:
   - Stacked Ethiopian (larger, bold) and Gregorian (smaller, italicized) dates vertically to avoid row clipping on small viewports.
5. **Modern Trailing Chevrons**:
   - Replaced the outdated `Icons.read_more` button with a clean trailing chevron icon (`Icons.chevron_right_rounded`, size 18) wrapped in a circular background accent.

## Changes
- [national_event_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/national_event_page.dart) — Redesigned list cards, badges, date layouts, and trailing chevron navigation.

# Plan — Collapsible Ads Panel Feedback Adjustments (Part 3)

**Branch:** feature/collapsible-ads-panel_55
**Issue:** #55
**Date:** 2026-06-23

## Goal
Remove the redundant close button from the ads panel header and center the title.

## Approach
- **Removed Redundant Close Button**: Removed the close `IconButton` inside the panel header row in `_buildPanel`. Since user gestures (dragging back, tapping outside barrier) and tapping the floating tab already dismiss the ads panel, the close icon is redundant.
- **Centered Header Title**: Centered the "Featured" header title for a clean, symmetrical appearance.

## Changes
- `lib/screens/home/home_page.dart` — Refactored the ads panel header structure in `_buildPanel()`.

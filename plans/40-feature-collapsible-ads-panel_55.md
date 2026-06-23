# Plan — Collapsible Ads Panel Feedback Adjustments (Part 2)

**Branch:** feature/collapsible-ads-panel_55
**Issue:** #55
**Date:** 2026-06-23

## Goal
Implement layout refinements for vertical ad cards to display full-size images with a translucent footer text overlay, and horizontally align the floating bottom edge tab to the opposite side of the side menu to prevent overlapping the event drag handle.

## Approach
- **Horizontal Tab Offset Alignment**: Changed the `Center` widget inside `_buildTab` to an `Align` widget. For horizontal panel configurations (`top`/`bottom`), the tab aligns horizontally (`Alignment.centerLeft` or `Alignment.centerRight`) to the opposite side of the `leftMenu` remote config setting (e.g. right side if side menu is left), keeping it completely away from the center drag handle.
- **Full-Size Card Overlay (Vertical Ads)**: Redesigned `_getVerticalContentProvider` to use a `Stack(fit: StackFit.expand)` layout:
  - Background: Full size, cover-fitted image.
  - Overlay: A Positioned bottom-aligned container (`bottom: 0`, `left: 0`, `right: 0`) featuring a translucent dark background (`Colors.black.withValues(alpha: 0.65)`) and backdrop blur (`BackdropFilter` with `ImageFilter.blur(sigmaX: 5, sigmaY: 5)`).
  - Content: Legible white/white70 text showing the Title and up to 2 lines of Body description.

## Changes
- `lib/screens/home/home_page.dart` — Updates to `_buildTab` alignments and `_getVerticalContentProvider` card structure.

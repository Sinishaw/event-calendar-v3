# Plan — Collapsible Ads Panel Feedback Adjustments

**Branch:** feature/collapsible-ads-panel_55
**Issue:** #55
**Date:** 2026-06-23

## Goal
Incorporate user feedback on panel widths, layout typography/images, carousel duplication, and edge tab position alignment.

## Approach
- **Refined Typography & Spacing (Vertical Ads)**: Removed `Expanded` from the image widget inside `_getVerticalContentProvider()` and set its height to a fixed `100.0`. Added `Expanded` around the body text, allowing up to 3 lines of description text to sit comfortably inside the card.
- **Deduplication in Vertical Carousel**: Fixed the carousel builder logic in `_playVerticalCarousel` to avoid wrapping `second = 0` when content size is odd. Instead, we render a `SizedBox.shrink()` on the second item slot, eliminating duplicate pages.
- **Narrower Side Panel**: Updated `panelWidth` calculation to `(screenWidth * 0.65).clamp(220.0, 260.0)` to make it slightly narrower.
- **Tab Placement (Non-Overlapping)**: Offset the horizontal top/bottom ads tab away from the calendar swipe/drag handle. The tab is aligned to the opposite side of the `leftMenu` setting (left if menu is right, right if menu is left).

## Changes
- `lib/screens/home/home_page.dart` — Updates to dimensions, tab alignments, card contents, and itemBuilder logic.

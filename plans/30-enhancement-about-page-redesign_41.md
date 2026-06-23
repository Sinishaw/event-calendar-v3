# Plan — Redesign About the App Page (Single Page Layout)

**Branch:** enhancement/about-page-redesign_41
**Issue:** #41
**Date:** 2026-06-23

## Goal
Redesign the About the App page (`lib/screens/about/about_page.dart`) to have a clean, modern, and responsive card-based layout on a single scrollable page (removing tabs). Combines the Service Provider and Developer sections with optimized space utilization and compact social media icons.

## Approach
1. **Single Scroll Layout**:
   - Removed `DefaultTabController`, `TabBar`, and `TabBarView` to unify the page.
2. **Provider Section**:
   - Rendered the cover banner (if available) at the top of the list.
   - Brand Card: Logo (left), Title ("Service Provider"), and company name in clean typography.
   - Description Card: About description presented with elegant, low-profile padding.
   - Contact Card: Consolidated Phone, Website, and Email in a single bordered card.
   - Compact Social Row: Sleek row of small circular buttons (Facebook, X, Instagram, YouTube) displaying only active links.
3. **Developer Section**:
   - Restructured the Developer section to contain no large cover image, only the circular company logo (`assets/images/elexicon.png`) within a Brand Header.
   - App Version Card: Clean card containing version number and summary.
   - Contact Card: Consolidated Phone, Website, and Email for eLexicon.
   - Compact Social Row: Sleek row of small circular buttons for eLexicon (Facebook, X, LinkedIn).
4. **Space Optimization & Social Icons Redesign**:
   - Tighter spacing (`8px` to `12px` margins) and compact card padding (`12px`) to save vertical screen space.
   - Redesigned social buttons to be much smaller (`36px` diameter with `16px` icons) with clean, transparent borders.

## Changes
- [about_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/about/about_page.dart) — Overhauled tab-less layout, combined provider & developer sections, optimized spacing, and redesigned compact social media buttons.

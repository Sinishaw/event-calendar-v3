# Plan — Redesign Content Detail Page

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Redesign `ContentDetailPage` to match the premium glassmorphic styling, replacing the rigid split layouts with a smooth parallax scrolling image header, bold headlines, clean horizontal meta-data blocks, stylized link cards, and a sticky bottom action bar.

## Approach
- Overhaul `ContentDetailPage` in `content_detail_page.dart` to use a `CustomScrollView` with a `SliverAppBar`.
- Implement a parallax image header collapsing dynamically to the AppBar height.
- Place a translucent floating circle avatar back button overlaid directly on the top-left of the image header.
- Add an inline expand/zoom floating action button in the bottom right corner of the header.
- Lay out article text preview with premium gradients, clean margins, business/calendar icons for metadata, and customized spacing.
- Replace the simple text link to official sources with a modern bordered primary-tinted card button.
- Implement a sticky bottom action bar containing a symmetrical row of:
  - An outlined red delete button.
  - A filled primary brand-colored share button.
- Keep delete alerts and undo notifications matching the newly updated premium snackbar/dialog specifications.

## Changes
- [content_detail_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/widgets/content_detail_page.dart) — Redesign detail page layouts and actions.

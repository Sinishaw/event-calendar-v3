# Plan — Finalize Duplication Removal & Verify Unified Details Page

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Verify and complete the cleanup of duplicate `ContentDetailPage` classes, replacing the duplicate file import in `home_page.dart` with the unified, modernized detail page widget.

## Approach
- Confirm that the duplicate `ContentDetailPage` file `lib/screens/events/widgets/content_detail_page.dart` has been deleted.
- Update `home_page.dart` imports and constructor calls to point to the unified `ContentDetailPage` with `inAppDialogSource: false`.
- Run static analysis to verify there are no compilation issues.

## Changes
- [content_detail_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/widgets/content_detail_page.dart) — [DELETE] Removed duplicate page.
- [home_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/home_page.dart) — Update import and call parameters.

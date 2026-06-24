# Plan — Remove Duplicate Detail Page & Reuse Modern Redesign

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Avoid duplicated detail page code and reuse the newly modernized `ContentDetailPage` when clicking featured ads in the Home page.

## Approach
- Identify and delete the duplicate `ContentDetailPage` file: [content_detail_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/widgets/content_detail_page.dart).
- Update the import in `home_page.dart` to point to the unified modernized detail page: [content_detail_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/widgets/content_detail_page.dart).
- Pass `inAppDialogSource: false` to the modernized `ContentDetailPage` instantiation points in `home_page.dart` to ensure proper SnackBar display on the home screen context.

## Changes
- [content_detail_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/widgets/content_detail_page.dart) — [DELETE] Remove duplicate file.
- [home_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/home_page.dart) — Update import and pass `inAppDialogSource: false`.

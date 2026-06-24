# Plan — Fix National Day Article Page Import Error

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Fix a compilation error in `national_day_article_page.dart` caused by removing the duplicate `ContentDetailPage` file, and point it to the unified, modernized detail widget instead.

## Approach
- Modify `national_day_article_page.dart` to change the relative import statement to point to `package:event_calendar_v2/screens/company/widgets/content_detail_page.dart`.
- Update the `ContentDetailPage` instantiation on line 60 to pass `inAppDialogSource: false`.
- Run static analysis to verify the app compiles cleanly.

## Changes
- [national_day_article_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/widgets/national_day_article_page.dart) — Fix ContentDetailPage import and instantiation parameters.

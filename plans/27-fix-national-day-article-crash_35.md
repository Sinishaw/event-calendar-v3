# Plan — Fix NationalDayArticlePage Null Check Crash

**Branch:** fix/national-day-article-crash_35
**Issue:** #35
**Date:** 2026-06-23

## Goal
Fix the `Null check operator used on a null value` crash occurring when opening `NationalDayArticlePage` from the Month Events sheet.

## Approach
1. **Pass Parameters correctly**:
   - In `single_month_container.dart`, pass `holidayName: payload.title` inside the navigation push builder. This resolves the source omission where `holidayName` was omitted during constructor invocation.
2. **Defensive null-safety fallback**:
   - In `national_day_article_page.dart`, replaced the force unwrap `widget.holidayName!` with a null-safe fallback `widget.holidayName ?? ''` inside the AppBar title configuration. This guarantees the page will load gracefully even if it is opened without a name.

## Changes
- [single_month_container.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/single_month_container.dart) — Passed the missing `holidayName` argument.
- [national_day_article_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/widgets/national_day_article_page.dart) — Replaced force unwrap with fallback value in AppBar title.

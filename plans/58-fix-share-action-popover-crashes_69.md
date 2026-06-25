# Plan — Fix Share Action Popover Crashes on iPad

**Branch:** fix/share-action-popover-crashes_69
**Issue:** #69
**Date:** 2026-06-25

## Goal
Resolve `PlatformException` crashes when tapping share buttons on iPad and macOS by passing `sharePositionOrigin` parameters calculated from the widget's `RenderBox` bounds.

## Approach
- Modify all share trigger callbacks to retrieve the local widget's `RenderBox` via `context.findRenderObject() as RenderBox?`.
- Calculate `sharePositionOrigin` as `box.localToGlobal(Offset.zero) & box.size` (or fallback to null if the box is null).
- Pass `sharePositionOrigin` to all `Share.share(...)` calls.

## Changes
- [copy_right_menu_item.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/menu/copy_right_menu_item.dart) — Add `sharePositionOrigin` to sidebar app share.
- [company_content.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/company_content.dart) — Add `sharePositionOrigin` to company content feed item share.
- [content_detail_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/widgets/content_detail_page.dart) — Add `sharePositionOrigin` to content detail page share button.
- [national_day_article_page.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/widgets/national_day_article_page.dart) — Add `sharePositionOrigin` to national day article list item share.

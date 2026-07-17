# Plan — Content notification & event taps open the content detail page

**Branch:** fix/content-tap-opens-detail_134
**Issue:** #134
**Date:** 2026-07-17

## Goal
Tapping a content notification (foreground or background) or a content event in a
list should open that specific content's `ContentDetailPage` — not the home page,
the day view, or the generic `CompanyContentPage` list.

## Root causes
1. `_openContentDetail` (main.dart) looked up the content with `p.id.toString()`,
   but `p.id` is the 32-bit-clamped notification id (added in #132), not the real
   Firestore content id. Large ids fail the lookup and fall back to `_goHome()`.
   (`getCompanyContentById` also only searched one company's collection.)
2. The day-view "more..." and the home month draggable chevron opened the
   `CompanyContentPage` list instead of the specific detail page.

## Approach
1. `NotificationPayload` gains a `contentId` (String) field (+ toJson/fromJson,
   null-safe) so the original Firestore id survives alongside the lossy notif id.
2. `NotificationService.scheduleCalendarMark` sets `contentId: id` (the original
   content id) when building the payload — so both FCM and reconciliation carry it.
3. `CompanyContentModel.getContentById(id)` — a collection-group query (`Contents`)
   cache-first then server, so it resolves content across any company/topic.
4. `ContentDetailPage.openFromPayload(context, payload, {onNotFound})` — one shared
   helper that resolves the content by `contentId` (fallback `id.toString()`) and
   pushes the detail page, invoking `onNotFound` if it can't resolve.
5. Rewire all entry points to the helper:
   - Notification tap: `_openContentDetail` -> `openFromPayload(..., onNotFound: _goHome)`.
   - Day-view "more..." + month chevron: `openFromPayload(..., onNotFound: <push CompanyContentPage>)`
     so the list page remains a graceful fallback.

Unchanged (already correct): `CompanyContentPage` list rows, home carousel, and the
foreground in-app dialog already open the detail directly.

## Changes
- `lib/screens/events/models/notification_payload.dart` — `contentId` field + json.
- `lib/services/notifications/notification_service.dart` — set `contentId` in `scheduleCalendarMark`.
- `lib/screens/company/models/company_content_model.dart` — `getContentById` (collection-group).
- `lib/screens/company/widgets/content_detail_page.dart` — static `openFromPayload` helper.
- `lib/main.dart` — `_openContentDetail` delegates to the helper.
- `lib/screens/plans/widgets/daily_user_event_list.dart` — "more..." opens specific detail.
- `lib/screens/home/widgets/single_month_container.dart` — chevron opens specific detail.

## Verification
- `flutter analyze` on the changed files: no new issues (only pre-existing deprecations/unused).
- `flutter build apk --debug`: succeeds.
- Functional check pending on device: tap a content notification (fg/bg) -> detail;
  day "more..." / month chevron -> that content's detail; existing list/carousel/dialog still work.

## Note
Older notifications scheduled before this change won't carry `contentId`; the helper
falls back to `id.toString()` (works only for small ids). New marks scheduled after
this change carry the real id. Re-sending / reconciliation refreshes existing marks.

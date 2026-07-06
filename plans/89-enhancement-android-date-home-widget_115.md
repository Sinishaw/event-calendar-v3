# Plan — Date Widget: Tap-to-Open + Live Settings Sync

**Branch:** enhancement/android-date-home-widget_115
**Issue:** #115
**Date:** 2026-07-06

## Goal
Two follow-ups on the date widget (same branch, uncommitted):
1. Tapping the widget opens the app (calendar).
2. Changing number format or language in-app updates the widget immediately (previously only refreshed on app launch/resume, so in-app changes lagged).

## Approach

### Tap to open (native)
`home_widget` 0.8.0 ships `HomeWidgetLaunchIntent`. Gave the layout root an id (`@+id/widget_root`) and, in `DateWidgetProvider.onUpdate`, attached `HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)` via `setOnClickPendingIntent`. Tapping the text opens the app to its normal landing screen — no Dart routing needed.

### Live settings sync
Root cause: the widget only refreshed on launch + `AppLifecycleState.resumed`, but number-format / language changes happen in the foreground (no resume), so the cached names/format stayed stale.

- Added `HomeWidgetService.refreshNow()` — Android-guarded, never-throws helper: `cacheLocalizedNames()` → `updateDateWidget()` → `scheduleMidnightRefresh()`. `main.dart`'s `_refreshDateWidget()` now delegates to it (removed duplicated logic; `dart:io` import dropped from `main.dart`).
- `_onPressNumberFormat` ([setting_page.dart](lib/screens/settings/setting_page.dart)) calls `refreshNow()` after saving the preference.
- `_onLanguageSelected` calls `refreshNow()` inside a `WidgetsBinding.addPostFrameCallback`, so the `MaterialApp` rebuild has re-run `reinitializeGlobalsWithSelectedLanguage` and `MonthGlobals` holds the new localized ET names before they're cached.

## Changes
- `lib/services/home_widget/home_widget_service.dart` — new `refreshNow()`; added `dart:io` + `flutter/foundation` imports.
- `lib/main.dart` — `_refreshDateWidget()` delegates to `HomeWidgetService.refreshNow()`; removed now-unused `dart:io` import.
- `lib/screens/settings/setting_page.dart` — refresh widget on number-format and language change; import the service.
- `android/.../DateWidgetProvider.kt` — launch PendingIntent on the widget root (`HomeWidgetLaunchIntent`).
- `android/.../res/layout/widget_date.xml` — added `@+id/widget_root` to the root.

## Verification
- `flutter build apk --debug` succeeds. ✓
- On device: tap widget → app opens. Change number format (Geez↔Eng) in Settings → widget digits update immediately (no backgrounding). Change language → ET month/weekday names update immediately.

# Plan — Android Home-Screen Date Widget (Ethiopian + Gregorian)

**Branch:** enhancement/android-date-home-widget_115
**Issue:** #115
**Date:** 2026-07-06

## Goal
A simple, fully-transparent Android home-screen widget showing today's **full Ethiopian date** (larger, top) over the **full Gregorian date** (smaller, bottom). White text with a thin dark-gray edge for readability on any wallpaper; resizes freely; stays accurate across midnight (a few minutes' lag tolerable, no waking a sleeping device).

## Approach
`home_widget` v0.8.0 was already a dependency but had no Android provider — built from scratch.

- **Content:** ET = localized weekday + month + day + year, digits following the app's number-format preference (Geez default / English). GC = English weekday + month + day + year.
- **Outline:** native `TextView` with a symmetric dark-gray shadow halo (`shadowColor #CC2B2B2B`, radius 3, dx/dy 0). RemoteViews can't do a true per-glyph stroke; the halo stays crisp at any size. Rejected: rendering a Flutter image (`renderFlutterWidget`) — a true stroke but blurs when enlarged.
- **Transparency:** root layout has no background; only the two TextViews paint.
- **Responsiveness:** `autoSizeTextType="uniform"` on both TextViews (ET 14–44sp, GC 10–22sp) scales text to the widget width. API 26+; below that the `textSize` fallback applies.
- **Freshness:** refresh on app launch/resume (full localization via context) + a self-rescheduling Workmanager one-off ~1 min after next local midnight. Workmanager respects Doze, so it runs once the device is next awake past midnight rather than waking it.

**Isolate constraint:** localized ET month/weekday names come from `MonthGlobals`, which needs a `BuildContext`. So the foreground caches those arrays + the number-format preference into `SharedPreferences`; the background midnight task rebuilds strings from that cache using only isolate-safe pieces (`MonthModel.toEc`, `GeezNumbers`, static English lists). Same `updateDateWidget()` runs in both paths.

## Changes
- `lib/services/home_widget/home_widget_service.dart` — new service: `cacheLocalizedNames()`, `updateDateWidget()` (build ET/GC strings from cache + save + `HomeWidget.updateWidget`), `scheduleMidnightRefresh()` (Workmanager one-off), isolate-safe string builders reusing the `_getEtSelectedDateString`/`gcMonthsLong` patterns.
- `lib/main.dart` — `callbackDispatcher` handles the `dateWidgetRefresh` task (update + reschedule); `_ContainerPageState` refreshes on init post-frame and on `resumed` (Android-only guard); added `dart:io` + service imports.
- `android/app/src/main/kotlin/com/example/event_calendar_v2/DateWidgetProvider.kt` — `HomeWidgetProvider` subclass; renders `date_et`/`date_gc` into the layout.
- `android/app/src/main/res/layout/widget_date.xml` — transparent vertical layout, two autosizing white TextViews with dark shadow halo.
- `android/app/src/main/res/xml/date_widget_info.xml` — resizable (both axes), `updatePeriodMillis=0` (app-driven), `previewLayout`.
- `android/app/src/main/AndroidManifest.xml` — `DateWidgetProvider` receiver + appwidget metadata.

## Verification
- `flutter build apk --debug` succeeds (native provider, layout, widget-info, manifest all compile/link). ✓
- On device: add the widget → ET full date on top (larger), GC below (smaller), white text with dark edge readable on white and black wallpapers; resize small→large scales text and stays transparent; toggling number format / language updates after the app runs; date flips within minutes of midnight once awake.

## Extensibility
The planned event-list widget = a new provider + layout + a new `HomeWidgetService` method; nothing here changes.

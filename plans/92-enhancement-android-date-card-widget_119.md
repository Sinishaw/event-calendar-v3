# Plan — Android "Date Card" Widget (medium)

**Branch:** enhancement/android-date-card-widget_119
**Issue:** #119
**Date:** 2026-07-08

## Goal
A second Android home-screen widget (the existing text widget is untouched), all-Ethiopian except the bottom line. Final layout is a centered vertical stack (the initial vertical-weekday screenshot idea was dropped for legibility/responsiveness):

```
   weekday          (Ethiopian)
     DAY            (Ethiopian, large, fills the middle)
  month year        (Ethiopian)
  full Gregorian date
```

Transparent, numerals per the Geez/English setting. Width locked at 2 columns; height resizable 1–2 rows (2x1 ↔ 2x2, never larger).

## Approach
Reuses the existing widget architecture: strings are computed in `HomeWidgetService` and shared via home_widget's `SharedPreferences`; a new `AppWidgetProvider` renders them. `updateDateWidget()` already runs on app resume, settings change, event add/edit/delete, and Android midnight — so the card stays in sync automatically.

- Emit flat ET components for today (`et_day`, `et_weekday`, `et_month_year`) alongside `date_et`/`date_gc`, reusing `_num()` (Geez/Arabic) + the cached localized `etMonths`/`etWeekdays`.
- Refresh both Android providers from `updateDateWidget()`.
- Transparent root + white text with a dark shadow halo (same readable-on-any-wallpaper treatment as the first widget).

## Changes
- `lib/services/home_widget/home_widget_service.dart` — `androidCardProvider` constants; `_keyEtDay/_keyEtWeekday/_keyEtMonthYear`; `_saveEtComponents()`; second `HomeWidget.updateWidget(...)` for the card provider.
- `android/app/src/main/kotlin/com/example/event_calendar_v2/DateCardWidgetProvider.kt` — `HomeWidgetProvider` rendering `tv_card_day/month_year/weekday/gc` + launch `PendingIntent`.
- `android/app/src/main/res/layout/widget_date_card.xml` — centered vertical `LinearLayout` (transparent): weekday, big day (`layout_weight=1`, fills middle), month/year, GC bottom; every line `maxLines=1` + autosize (no wrapping); white + dark halo.
- `android/app/src/main/res/xml/date_card_widget_info.xml` — `resizeMode="vertical"`, width pinned to 2 columns, height 1–2 rows (`targetCell 2×2`, `maxResize ≈ 2×2`).
- `android/app/src/main/AndroidManifest.xml` — `DateCardWidgetProvider` receiver.

## Notes
- No rotated/vertical text — the earlier screenshot's vertical weekday was dropped for a cleaner, responsive centered stack.
- Autosize needs API 26+ (graceful fixed-size fallback below).

## Verification
- `flutter build apk --debug` succeeds. ✓
- On device: add the **Date Card** widget → big ET day, vertical ET weekday, ET month+year, GC at the bottom; transparent; readable on light/dark wallpapers; number-format/language switch updates; tap opens the app; the original widget still works.

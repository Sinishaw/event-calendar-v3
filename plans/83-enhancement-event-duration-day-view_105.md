# Plan — Day View Header: ET Date Format & GC Month Locale Fix

**Branch:** enhancement/event-duration-day-view_105
**Issue:** #107
**Date:** 2026-07-03

## Goal
Two hot fixes on the date displays introduced in earlier prompts:
1. GC month names in the tab switcher date badge were using `AppLocalizations` short-month keys, which translate to the app language. They should always be English.
2. The day view nav header title needed restructuring: show small GC date at top (English, always) and bold ET date as the primary display, with the localized ET weekday name prepended.

## Approach

### Date badge GC months (user_event_page.dart)
Replaced the `l10n.jan/feb/.../dec` array with `MonthGlobals.gcMonthsShort` — the single existing source of English GC abbreviations in the project. Removed the `AppLocalizations l10n` parameter from `_selectedDateBadge` since it was only used for the month list.

### Day nav header restructure (day_nav_header.dart)
- Line 1 (small, 65% alpha): full GC date via `DateFormat('EEEE, MMM d, y', 'en')` — forced English locale.
- Line 2 (bold): ET date prefixed with the localized ET weekday name.
  - `_etDayName(weekday, l10n)` maps `DateTime.monday`–`sunday` to `l10n.monday`–`l10n.sunday`.
  - `_etDateString(gcDate, context)` calls `MonthModel.toEc()` + `MonthGlobals.etMonthsLong` for the month name, then assembles `"$dayName $monthName $day, $year"`.
  - GC short months reuse `MonthGlobals.gcMonthsShort` in the fallback path.
- Added imports: `app_localizations.dart`, `core_model.dart`, `month_globals.dart`.

## Changes
- `lib/screens/plans/user_event_page.dart` — `_selectedDateBadge`: use `MonthGlobals.gcMonthsShort`, remove `l10n` param
- `lib/screens/day_view/widgets/day_nav_header.dart` — new `_etDayName` + `_etDateString`, restructured date column, new imports

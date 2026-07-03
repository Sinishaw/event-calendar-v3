# Plan — Form UI Redesign: Date Badge, Layout Rearrangement, Localization

**Branch:** enhancement/event-duration-day-view_105
**Issue:** #107
**Date:** 2026-07-03

## Goal
Improve the `UserEventPage` form UX: surface the selected date near the tab switcher,
rearrange form rows into a cleaner two-column layout, replace the duration chip row with
a 2-column chip grid, and localize all four new string labels.

## Approach
- Selected date badge: sits to the right of the Form/Day View pill inside the same
  horizontal row. Shows the GC short month + day (line 1) and ET month + day (line 2)
  using `AppLocalizations` short-month keys and `MonthGlobals.etMonthsLong`. Geez
  number format is respected for the ET day.
- `_activeSelectedDateCard` widget removed from the form — the badge replaces it.
- Duration picker redesigned: `Column(header row + GridView.count(crossAxisCount: 2))`
  with `shrinkWrap: true` so it sizes to 3 rows of 2 chips each (5 chips total, last row
  has one chip alone).
- Form rows reordered: Date & Time → Duration + Importance Tag → Schedule + Repeat →
  Plan list (height `availableHeight / 1.9`, up from `/ 2.2`).
- 4 localization keys (`formTab`, `dayViewTab`, `duration`, `planListForTheDay`) added
  to all ARB files and both the abstract `AppLocalizations` class and all 4
  implementation dart files.

## Changes
- `lib/l10n/app_en.arb`, `app_am.arb`, `app_or.arb`, `app_te.arb` — 4 new keys each
- `lib/l10n/app_localizations.dart` — 4 new abstract getters
- `lib/l10n/app_localizations_en.dart`, `_am.dart`, `_or.dart`, `_te.dart` — 4 new overrides each
- `lib/screens/plans/user_event_page.dart`
  - `_tabSwitcher`: converted to `Padding + Row(Expanded pill, SizedBox, badge)`
  - `_selectedDateBadge`: new widget — compact date badge to the right of the tab pill
  - `_durationPicker`: redesigned as 2-column `GridView.count` (was horizontal `Wrap`)
  - `_activeSelectedDateCard`: deleted (unused after badge was added)
  - Form rows: Duration+Importance Tag in row 2, Schedule+Repeat in row 3, plan list in row 4
  - Plan list height: `availableHeight / 1.9` (was `/ 2.2`)
  - "PLAN LIST FOR THE DAY" header: uses `l10n.planListForTheDay.toUpperCase()`

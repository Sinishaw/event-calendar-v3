# Plan — iOS Large "Agenda" Widget + Medium Localization + Event Sync

**Branch:** enhancement/ios-date-home-widget_117
**Issue:** #117 (continuing work)
**Date:** 2026-07-06

## Goal
Make each iOS home-screen size purposeful. Replace the buggy Large calendar grid with an **agenda** widget, localize the Medium widget, and keep the widget in sync when events change.

## Approach
All content is precomputed in Dart (`HomeWidgetService`) and shared via the App Group; the Swift widget only displays it. The 14-day timeline window (advanced by WidgetKit at midnight) was enriched so each day carries everything the families need — no iOS background code.

- **Large → agenda**: ET date (left) + GC date (right) in the top corners with the **day number bold**; middle = up to 4 upcoming events (category color as a left bar + faint tinted badge, title bold, partial detail, time); if today has none, roll forward and label items localized **"Tomorrow"** / short ET date; empty → localized "No Event is Found". Bottom-center **"+"** deep-links to the add-event form; tapping the body opens that day's day view.
- **Medium → localized**: today's holiday (star + name), else next holiday + **"N days"** (spelled out, not "d"), else event count as a bell + number. Strings come localized from Dart.
- **Small / lock-screen rectangular**: unchanged.
- **Sync**: `HomeWidgetService.refreshNow()` runs on event create/edit and delete.

Reused: per-day event filter (one-time/daily/weekly) from `daily_user_event_list.dart`; category colors `Globals.categoryColorList` indexed by `EventTagOption`; holiday lookups `HolidayAndNationalEvents`; localized strings via `Globals.context`; widget-tap routing mirrors `_handleNotificationTap`.

## Changes
- `lib/services/home_widget/home_widget_service.dart` — window entries now carry ET/GC date components, a color-coded `agenda` (`_agendaFrom`, `_eventsForGcDay`, `_colorHexForTag`, `_clock`, `_shortEtLabel`), and localized `daysLabel`/`noEventsLabel`; removed the month-grid builder.
- `ios/DateWidget/DateWidget.swift` — new `AgendaItem` model + GC fields; `LargeAgendaView` (corner dates, agenda rows, "+" `Link`, `widgetURL`); localized `MediumView`; `Color(hex:)` initializer; dropped grid views.
- `lib/main.dart` — `_ContainerPageState` subscribes to `HomeWidget.widgetClicked` + checks `initiallyLaunchedFromHomeWidget()`; `_handleWidgetUri` routes `add` → `UserEventPage()`, `day` → day view. Removed the old `_AppState` example dialog.
- `lib/screens/plans/user_event_page.dart` — `refreshNow()` at the end of `_saveEvent()` (create + edit).
- `lib/screens/plans/widgets/daily_user_event_list.dart` — `refreshNow()` after the delete (dismiss) handler.
- `lib/l10n/app_{en,am,or,te}.arb` — added `tomorrow`; regenerated.

## Verification
- `dart analyze` clean; `flutter build ios --debug --simulator` succeeds.
- On device: Large shows corner dates (day bold) + color-coded agenda + "+"; add/edit/delete syncs; empty-today shows Tomorrow/date; "+" opens add form, body opens day view; Medium localized with "N days"; language/number-format switch updates; midnight rollover via the window.

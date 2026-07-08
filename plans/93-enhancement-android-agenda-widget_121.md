# Plan — Android Agenda Widget (port of the iOS Large agenda)

**Branch:** enhancement/android-agenda-widget_121
**Issue:** #121
**Date:** 2026-07-08

## Goal
Port the iOS Large agenda widget to Android as a third, independent provider (existing two untouched): ET date (left) + GC date (right) in the top corners with an enlarged day number, up to 4 color-coded upcoming events in the middle, and a "+" to add.

Final design (after review): corner shows the **day on top** with `weekday, month year` on one line below; a **light divider** separates header and body; the card background is **solid and theme-aware** (white in light mode / dark in night mode); each event sits on a **faint tint of its color** (like iOS); tapping an event opens its **exact day scrolled to the event's time**.

## Approach
Reuses the shared `HomeWidgetService` + the agenda helpers already written for iOS (`_agendaFrom`, `_colorHexForTag`, `_num`, `_eventsForGcDay`, localized labels via `Globals.context`). The widget uses its own `ag_*` data keys so it's fully independent of the other providers (and of the still-in-review card PR #120 — no merge coupling).

Android RemoteViews can't do a live backdrop blur or a SwiftUI list, so: the "glass" is a translucent-white rounded drawable, and the agenda is 4 fixed inline rows (iOS caps at 4). Dark text for contrast on the frosted white. `<View>` isn't a RemoteViews-supported type, so the color bars are `ImageView`s tinted via `setInt(..., "setBackgroundColor", color)`.

## Changes
- `lib/services/home_widget/home_widget_service.dart` — `androidAgendaProvider` constants; `_saveAndroidAgendaData(now, prefs)` (Android-guarded) writing `ag_et_*` + `ag_gc_*` corner components, `agenda_today` (JSON via `_agendaFrom`), `agenda_empty`; a third `HomeWidget.updateWidget(...)`. `_agendaFrom` items now also carry `gcDate` + `scrollMin` (for the per-event tap). Runs on resume / settings change / event add·edit·delete / midnight.
- `lib/main.dart` — `_handleWidgetUri` parses `t` (minutes) and passes `initialDayViewScrollMinutes`.
- `lib/screens/plans/user_event_page.dart` — new `initialDayViewScrollMinutes`; one-shot scroll of the day-view timeline to that minute-of-day on open.
- `android/.../AgendaWidgetProvider.kt` — reads `ag_*` keys, parses `agenda_today` (`org.json`); per row: color bar + faint row tint (`color & 0xFFFFFF | 0x22000000`) + per-event tap `://day?d=<date>&t=<min>`; combines the corner sub-line; empty label; `+` → `://add`, empty area → `://day`.
- `android/.../res/layout/widget_agenda.xml` — solid theme card; corners = big day + `weekday, month year` sub-line; light divider; 4 inline rows (`ImageView` bar + title/detail + time); adaptive `@color/widget_*` text.
- `android/.../res/drawable/widget_glass_bg.xml` — rounded **solid** `@color/widget_bg` card (theme-aware).
- `android/.../res/values/colors.xml` + `values-night/colors.xml` — `widget_bg` / `widget_text_primary` / `widget_text_secondary` / `widget_divider` (light + dark).
- `android/.../res/xml/agenda_widget_info.xml` — resizable, default 4×3.
- `android/.../AndroidManifest.xml` — `AgendaWidgetProvider` receiver.

## Verification
- `dart analyze` clean; `flutter build apk --debug` succeeds. ✓
- On device: add the **Agenda** widget → glass card, ET/GC corners with bigger day, color-coded events; empty-today rolls forward ("Tomorrow"/date); none upcoming → "No Event is Found"; `+` opens add form; body opens day view; add/edit/delete + language/number-format changes update it; other two widgets unaffected.

## Notes
- "Glass" is a translucent card (no true blur in RemoteViews); alpha tunable.
- 4 fixed rows (no scroll) — matches the iOS cap; upgradeable to a collection widget later.
- Dark text (vs iOS adaptive) for contrast on the white frost.

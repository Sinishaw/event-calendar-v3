# Plan — iOS Agenda Widget fixes (event tap, "+" add, row heights)

**Branch:** fix/ios-agenda-widget-taps-and-layout_123
**Issue:** #123
**Date:** 2026-07-08

## Goal
Three corrections to the shipped iOS Large agenda widget:
1. Tapping an **event** opens the day view on that event's **date, scrolled to the event**.
2. Tapping **"+"** reliably opens the **add-event form** (defaults to today).
3. A single (or few) event no longer **stretches** — each row takes only its content height, packed at the top.

## Approach
The routing already exists on `develop` (merged #122): `_handleWidgetUri` parses `d`+`t` → `UserEventPage(initialShowDayView, initialDayViewDate, initialDayViewScrollMinutes)`, and `_agendaFrom` emits `gcDate`/`scrollMin` per item. So the fixes are **iOS Swift only** (`ios/DateWidget/DateWidget.swift`); no Dart changes.

## Changes

### Widget-tap crash + routing (iOS scene delegate)
Tapping the widget opened its URL (`eventcalendarwidget://…`), which iOS handed to Flutter's route deep linking → `pushNamed("/?d=…&t=…")` → crash ("Could not find a generator for route"). Under the app's `FlutterSceneDelegate`, home_widget's app-delegate URL hook does **not** fire, so its `widgetClicked` never delivered the tap — the route channel is the only one that receives the URL on iOS.

We handle it by **intercepting the route push in a `WidgetsBindingObserver` and applying it via a pending-link**, so it's never pushed as a route over the splash (an earlier `onGenerateRoute` version pushed the day view/form on top of the splash, which the splash's 2s `pushReplacement(ContainerPage)` then replaced with home):
- **Widget URLs are path-based** (`eventcalendarwidget://open/day?d=…&t=…`, `…/open/add`) so the action survives (Flutter drops the host; first path segment carries `day`/`add`).
- **`_AppState` is a `WidgetsBindingObserver`** (added before `MaterialApp`'s, so it runs first) and overrides `didPushRouteInformation`: for a widget link it stashes `HomeWidgetService.pendingWidgetUri`, opens it immediately via `App.navigatorKey` when `appReady` (warm tap), else leaves it for `ContainerPage`; returns `true` to swallow it (no default route push → no crash, no splash clobber).
- **`ContainerPage`** sets `HomeWidgetService.appReady = true` on mount and consumes any pending link post-frame (cold start, after the splash) via `_handleWidgetUri` (accepts host- or path-based URIs). `MaterialApp` keeps `home: SplashScreen()` + a `navigatorKey`.
- Android is unaffected: home_widget uses a custom launch action Flutter's deep-linker ignores, so it keeps routing through `widgetClicked`.

### `ios/DateWidget/DateWidget.swift`
- **Fix 1**: added `gcDate`/`scrollMin` (optional) to `AgendaItem` (JSON already carried them); each `AgendaRow` is wrapped in a `Link` → `://day?d=<gcDate ?? day.d>&t=<scrollMin ?? 0>`. Container `.widgetURL(://day?d=day.d)` stays for corners/empty area (today).
- **Fix 2**: the "+" `Link` now has `.padding(.vertical,6).frame(maxWidth:.infinity).contentShape(Rectangle())` — a full-width bottom hit target that routes to `://add` (the add form already defaults to today via `_resetEntry`).
- **Fix 3**: rows live in `VStack(spacing:6){…}.frame(maxWidth:.infinity, alignment:.top)` + trailing `Spacer(minLength:0)`; `AgendaRow` gets `.fixedSize(horizontal:false, vertical:true)` so it never stretches.

## Verification
- `flutter build ios --debug --simulator` succeeds. ✓
- On device: tap an event → its date opens scrolled to the event; tap "+" (bottom strip) → add form on today; corners/empty → today; 1 event = compact top row, 2+ = natural heights packed top-down with "+" at the bottom.

## Notes
- Multiple `Link`s + `widgetURL` coexist on iOS 17+ (device is iOS 26); pre-17 degrades to the whole-widget `widgetURL` (today).

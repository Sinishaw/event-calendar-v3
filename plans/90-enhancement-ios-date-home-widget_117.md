# Plan — iOS Home-Screen Date Widget (WidgetKit)

**Branch:** enhancement/ios-date-home-widget_117
**Issue:** #117
**Date:** 2026-07-06

## Goal
Bring the Android date widget (full localized Ethiopian date on top, full Gregorian below) to iOS via a WidgetKit extension: small + medium home-screen and a lock-screen accessory, white text with a dark halo, closest-to-transparent background, tap-to-open, and live refresh.

## Approach
All date logic already lives in Dart (`HomeWidgetService`) and writes `date_et` / `date_gc`, which on iOS land in a shared App Group `UserDefaults`. The WidgetKit extension only *displays* those strings — no date conversion in Swift. To roll the date over at midnight without the app running, the Dart side also stores a precomputed 14-day window (`date_window`) and the Swift `TimelineProvider` emits one entry per local midnight.

**App Group:** `group.com.example.eventCalendarV2` — identical in `Runner.entitlements`, `DateWidget.entitlements`, and `HomeWidget.setAppGroupId(...)`.

## Changes (in-repo)
- `lib/services/home_widget/home_widget_service.dart` — `iosWidgetName = 'DateWidget'`; `refreshNow()` now runs on Android **and** iOS (Workmanager midnight scheduling stays Android-only); `updateDateWidget()` stores `date_window` (today..+14) on iOS and passes `iOSName` to `HomeWidget.updateWidget` so `WidgetCenter.reloadTimelines(ofKind:)` fires. Reuses `_buildEtDateString` / `_buildGcDateString`.
- `lib/main.dart` — `setAppGroupId('group.com.example.eventCalendarV2')` (was placeholder). Existing resume/init + Settings refreshes now cover iOS automatically.
- `ios/DateWidget/DateWidget.swift` — `TimelineProvider` reads the App Group `UserDefaults`, decodes `date_window`, builds midnight entries (fallback: `date_et`/`date_gc` → placeholder); SwiftUI views for `systemSmall`/`systemMedium` (white text + dark shadow halo, clear container background) and `accessoryRectangular` (iOS 16+, system-tinted); `@main WidgetBundle` for future widgets.
- `ios/Runner/Runner.entitlements`, `ios/DateWidget/DateWidget.entitlements` — App Group.

## Guided Xcode steps (user, one-time — required before it builds/runs)
1. **Add the target:** Xcode → *File ▸ New ▸ Target ▸ Widget Extension* → name **DateWidget**, uncheck "Include Live Activity" & "Include Configuration Intent" → Activate the scheme when prompted. Set the DateWidget target's *iOS Deployment Target* to 15.0.
2. **Use the provided code:** delete Xcode's generated `DateWidget.swift`/`.entitlements` and instead add the ones already in `ios/DateWidget/` (drag into the DateWidget target, or replace the generated files' contents). Ensure `DateWidget.swift` is in the **DateWidget** target only.
3. **App Groups capability:** select **Runner** target → *Signing & Capabilities* → **+ Capability ▸ App Groups** → check/add `group.com.example.eventCalendarV2`, and set *Code Signing Entitlements* = `Runner/Runner.entitlements`. Repeat for the **DateWidget** target with `DateWidget/DateWidget.entitlements`.
4. **Keep the extension pod-free:** do not add DateWidget to the Podfile `Runner` block (it only uses WidgetKit + UserDefaults).
5. Run `flutter run` (or build from Xcode).

## Verification (after Xcode steps)
1. Add the widget (small + medium) → ET full date on top (larger), GC below (smaller), white text with dark edge, minimal/no card on iOS 17+.
2. Add the lock-screen accessory → both dates show (system-tinted).
3. Change number format (Geez↔Eng) / language in Settings → widget updates (foreground `reloadTimelines`).
4. Advance the clock past midnight → date flips from the precomputed window without launching the app.
5. Tap the widget → app opens.

## Notes / trade-offs
- iOS transparency is closest-possible (clear container background), not guaranteed full transparency.
- Midnight rollover without the app relies on the 14-day window; if unopened >14 days it goes stale until next launch (app refreshes on every resume).
- App Groups needs the capability on the signing identity — Xcode automatic signing handles it.
- The Swift/entitlements can't compile until the Xcode target exists, so `flutter build ios` verification is deferred to after step 1–4; Dart analysis is clean.

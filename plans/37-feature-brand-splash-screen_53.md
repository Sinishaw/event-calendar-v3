# Plan — Brand-Aware Pulse Animation Splash Screen

**Branch:** feature/brand-splash-screen_53
**Issue:** #53
**Date:** 2026-06-23

## Goal
Implement a premium, themed, and brand-aware splash screen for the application. The splash screen should use a generic calendar icon that pulses smoothly and a glassmorphic linear progress loader that reflects the current company's primary theme color. It must run inside `MaterialApp` to access themes and localizations, avoiding any visual flashes of the default light theme on startup.

## Approach
1. **Early Initialization**: Initialized `SharedPreferences` and loaded the company configurations synchronously in `main()` before calling `runApp`. This allows `ThemeProvider` and `LanguageChangeProvider` to construct themselves synchronously on the very first frame with the user's correct local preferences, eliminating default theme flashes.
2. **MaterialApp Integration**: Modified `main.dart` to mount `MaterialApp` immediately, with the `home` property set to the new `SplashScreen` widget.
3. **Pulsing Icon & Progress**: Created a custom `SplashScreen` widget. It features:
   - A theme-adaptive background (`Color(0xFF121212)` for Dark, `Color(0xFFFAFAFA)` for Light) matching the theme to avoid visual startup jumps.
   - A centered glassmorphic circular card containing a generic calendar icon (`Icons.calendar_month_rounded`) that pulses with a scale animation.
   - A glowing shadow effect around the icon that oscillates with the animation.
   - A modern linear progress loader matching the brand's primary color (`theme.primaryColor`) dynamically.
   - A localized loading status message at the bottom.
4. **Transition**: Implemented background initialization of Firebase, notifications, and dynamic links inside the splash screen. After initialization is complete (with a minimum duration threshold of 2.0 seconds), the screen fades out smoothly to the main page using `PageRouteBuilder` with `FadeTransition` (duration: 600ms).
5. **Robustness & Error Handling**:
   - Added guards in `HomePage` to render the fallback gradient if `MonthGlobals.etShowingMonth` is still null during the first frame (before `SingleMonthContainer` finishes initializing).
   - Removed the forced unwrap (`!`) on the network image URL fallback to ensure zero Null check exceptions.
   - Wrapped Firebase messaging `getToken()` calls in both `main.dart` and `FcmHandler.dart` with `try/catch` and `.catchError` handlers to handle cases where the APNS token is not set (e.g. on iOS Simulators).

## Changes
- `lib/main.dart` — Synchronous initialization of SharedPreferences and company config in `main()`, removed root `FutureBuilder` inside `runApp`, and set `home` of `MaterialApp` to the new `SplashScreen`. Caught APNS token exceptions in `registerUserIdInFirestore()`. Cleaned up unused import of `FirebaseDynamicLink`.
- `lib/screens/splash/splash_screen.dart` — Created the new splash screen widget with custom pulse/glow animation, loading indicator, and localized loading text.
- `lib/screens/home/home_page.dart` — Added safety checks for `MonthGlobals.etShowingMonth` and resolved forced unwrap operator of month image URLs to prevent startup crashes.
- `lib/firebase/cloudMessaging/FcmHandler.dart` — Caught unhandled APNS token exceptions in `_getToken()`.
- `lib/l10n/app_en.arb` — Added `"loading": "Loading..."` localization key.
- `lib/l10n/app_am.arb` — Added `"loading": "በመጫን ላይ..."` localization key.
- `lib/l10n/app_or.arb` — Added `"loading": "Fe'amaa jira..."` localization key.
- `lib/l10n/app_te.arb` — Added `"loading": "ይፅዕን ኣሎ..."` localization key.

# Plan — Resolve Initial Theme Flash on Startup

**Branch:** fix/theme-flash-on-startup_45
**Issue:** #45
**Date:** 2026-06-23

## Goal
Eliminate the brief flash of the default light theme when launching the app by loading the configured theme synchronously within the `ThemeProvider` constructor.

## Approach
- Since `Globals.initGlobals()` runs and resolves SharedPreferences asynchronously before `App` is built, all preferences are readable synchronously when `ThemeProvider` is created.
- Add a helper `_getThemeSync(String themeType)` to `ThemeProvider` to construct the `ThemeData` immediately based on the local company config or default styles.
- Set `currentTheme` synchronously in the constructor instead of letting it start as `null` and waiting for an asynchronous callback.
- Modify `getAppTheme()` to use this sync helper and call `notifyListeners()`.

## Changes
- `lib/configs/theme/theme_model.dart` — Synchronized initialization of `currentTheme` inside `ThemeProvider`.

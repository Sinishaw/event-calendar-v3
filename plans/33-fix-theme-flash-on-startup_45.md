# Plan — Fix Default Image Flash on Home Page

**Branch:** fix/theme-flash-on-startup_45
**Issue:** #45
**Date:** 2026-06-23

## Goal
When the app starts, the home page briefly shows a hardcoded yellow gradient with a `default_image.png` asset before the remote config month image is loaded. This is visually jarring, especially now that the theme flash has been resolved. The fallback must not show any default image and must match the current theme colors to blend seamlessly.

## Approach
- The fallback widget is rendered when `Globals.monthImagesList[0]` is still `null` (i.e., before `initMonthsImage()` completes).
- **Removed:** The hardcoded `RadialGradient` with `#f7d031` yellow colors and the `Image.asset("assets/images/default_image.png")` with its `TweenAnimationBuilder` fade-in.
- **Replaced with:** A plain `Container` with a `LinearGradient` that uses `Theme.of(context).primaryColor.withValues(alpha: 0.25)` fading to `Theme.of(context).scaffoldBackgroundColor`. This ensures the placeholder always matches the current theme (dark or light) and is invisible to the user.
- **Cleaned up:** Removed the now-unused `utilities.dart` import from `home_page.dart`.

## Changes
- `lib/screens/home/home_page.dart` — Replaced hardcoded fallback with a theme-adaptive gradient placeholder; removed unused `Utility` import

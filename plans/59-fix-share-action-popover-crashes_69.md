# Plan — Platform-Aware Rate Button

**Branch:** fix/share-action-popover-crashes_69
**Issue:** #69
**Date:** 2026-06-25

## Goal
Make the side menu rate button platform-aware by routing iOS users to the Apple App Store and Android users to the Google Play Store, using the bundle ID `com.elexicon.ethiopiancalendar`.

## Approach
- Modify the `star_rate` button's `onPressed` callback in `copy_right_menu_item.dart`.
- Check `Theme.of(context).platform == TargetPlatform.iOS`.
- If true, attempt to launch App Store deep link `itms-apps://itunes.apple.com/app/com.elexicon.ethiopiancalendar` with fallback to `https://apps.apple.com/app/com.elexicon.ethiopiancalendar`.
- If false, attempt to launch Play Store deep link `market://details?id=com.elexicon.ethiopiancalendar` with fallback to `https://play.google.com/store/apps/details?id=com.elexicon.ethiopiancalendar`.

## Changes
- [copy_right_menu_item.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/menu/copy_right_menu_item.dart) — Implement platform-aware deep links for App Store and Play Store.

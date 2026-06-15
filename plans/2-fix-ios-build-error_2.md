# Plan — Differentiate Dev and Prod Firebase Configurations

**Branch:** fix/ios-build-error_2
**Issue:** #2
**Date:** 2026-06-15

## Goal
Configure the production Firebase configuration in `lib/firebase_options_prod.dart` with the correct production app identifiers (using the bundle ID `com.elexicon.eventCalendarV2` and associated App IDs), while keeping the development configuration in `lib/firebase_options_dev.dart` targeting the `com.example.eventCalendarV2` bundle ID.

## Approach
1. Modify `lib/firebase_options_prod.dart` to use the production Firebase configuration retrieved from the `event_calendar_v2` project setup.
2. Ensure `lib/firebase_options_dev.dart` remains configured with the development Firebase configurations.
3. Verify that both versions compile without errors.

## Changes
- [firebase_options_prod.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/firebase_options_prod.dart) — Updated Firebase configurations to use production bundle IDs and App IDs.
- [README.md](file:///Users/sinishaw/My_Projects/event-calendar-v3/README.md) — Appended environment running instructions.

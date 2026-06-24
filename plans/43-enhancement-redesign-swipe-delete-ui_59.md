# Plan — Redesign Swipe-to-Delete Background UI

**Branch:** enhancement/redesign-swipe-delete-ui_59
**Issue:** #59
**Date:** 2026-06-24

## Goal
Redesign the swipe-to-delete background layout revealed when swiping an item left on the day long-press dialog (`ShowDayTaskAndEventsDialog`). Replace the solid red background and white icon with a professional red border, a subtle light-red tinted background, and a red delete icon.

## Approach
Modified the `Dismissible` background container in `daily_user_event_list.dart`:
- Replaced `color: Colors.redAccent.withOpacity(0.9)` with a light-red tint (`color: Colors.redAccent.withValues(alpha: 0.05)`).
- Added a border (`border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 0.8)`) to define the card borders cleanly when revealed.
- Changed icon color to `Colors.redAccent` and size to `26` for a cleaner look.

## Changes
- [daily_user_event_list.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/plans/widgets/daily_user_event_list.dart) — Modify `Dismissible` widget background parameters.

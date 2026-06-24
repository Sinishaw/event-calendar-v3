# Plan — Dock Add Button to Bottom Center of Daily Dialog

**Branch:** enhancement/dock-add-button_63
**Issue:** #63
**Date:** 2026-06-24

## Goal
Move the "Add Event" (plus) button from the top right corner of the daily events dialog to the bottom center of the dialog, floating over the list of events.

## Approach
- Wrap the dialog's main layout `Column` in a `Stack` widget within `task_and_event_dialog.dart`.
- Position a custom circular gradient plus button at the bottom center (`bottom: 16`), featuring the primary color, white icon, and a drop shadow.
- Remove the old plus button and spacing from the header row on the right side.

## Changes
- [task_and_event_dialog.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/home/widgets/task_and_event_dialog.dart) — Relocate the plus button to the bottom center of the Stack, styled as a circular floating button.

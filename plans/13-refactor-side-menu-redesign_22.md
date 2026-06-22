# Plan — Modern Side Menu Redesign (Update)

**Branch:** refactor/side-menu-redesign_22
**Issue:** #22
**Date:** 2026-06-22

## Goal
Fix the selection highlighting state of side menu items so that each page index >= 4 is correctly indicated as active when clicked, rather than falling back to Plans.

## Approach
- Replaced the selected item condition check in `side_menu.dart` from `Globals.selectedIndex` to `Globals.displayingIndex`.
- This ensures that pages after index 4 (Plans at 5, National Days at 6, About App at 7, Setting at 8, Terms at 9) correctly display their highlighting capsule, since `Globals.selectedIndex` is capped at `4` by the bottom navigator shell.

## Changes
- `lib/menu/side_menu.dart` — Changed item `isSelected` checks to check `Globals.displayingIndex` matching target page numbers.

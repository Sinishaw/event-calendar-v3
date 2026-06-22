# Plan — Modern Side Menu Redesign (Update 4)

**Branch:** refactor/side-menu-redesign_22
**Issue:** #22
**Date:** 2026-06-22

## Goal
Fix side menu background opacity so that the entire drawer is translucent to the screen behind it, without fading the header image to a solid background color.

## Approach
- Removed the outer `Theme` copy wrapper around the `Drawer`.
- Configured the drawer's `backgroundColor` directly on the `Drawer` widget using the translucent config color.
- Configured `surfaceTintColor: Colors.transparent` on the `Drawer` widget to prevent Material 3 from overlaying a solid tint color.

## Changes
- `lib/menu/side_menu.dart` — Configured `backgroundColor` and `surfaceTintColor` on the `Drawer` widget directly, removing the `Theme` copy wrapper.

# Plan — Modern Side Menu Redesign (Update 3)

**Branch:** refactor/side-menu-redesign_22
**Issue:** #22
**Date:** 2026-06-22

## Goal
Fix side menu header image transparency so it aligns with the transparent look of the drawer body without fading into a solid background color.

## Approach
- Set `color: Colors.transparent` on the `BoxDecoration` of the `DrawerHeader` container.
- Passed the remote config `opacity` value directly to the `DecorationImage`'s `opacity` parameter to make the image itself translucent.
- Re-added the `opacity` parameter to `SideMenuHeader` constructor and called it with `menuOpacity` in `side_menu.dart`.

## Changes
- `lib/menu/side_menu_header.dart` — Configured transparent background and applied opacity directly to the `DecorationImage`.
- `lib/menu/side_menu.dart` — Restored the `opacity` parameter argument when instantiating `SideMenuHeader`.

# Plan — Modern Side Menu Redesign (Update 2)

**Branch:** refactor/side-menu-redesign_22
**Issue:** #22
**Date:** 2026-06-22

## Goal
Fix side menu header styling by removing the transparency fade on the banner image, while keeping the overall drawer canvas background translucent.

## Approach
- Removed the `Opacity` wrapper widget from `SideMenuHeader`.
- Removed the `opacity` constructor parameter from `SideMenuHeader` class in `side_menu_header.dart`.
- Cleaned up the instantiation of `SideMenuHeader` in `side_menu.dart` by removing the `opacity` parameter.

## Changes
- `lib/menu/side_menu_header.dart` — Removed the `Opacity` widget around `DrawerHeader` and cleaned up constructor parameters.
- `lib/menu/side_menu.dart` — Updated `SideMenuHeader` instantiation to remove the `opacity` argument.

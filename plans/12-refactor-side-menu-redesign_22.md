# Plan — Modern Side Menu Redesign

**Branch:** refactor/side-menu-redesign_22
**Issue:** #22
**Date:** 2026-06-22

## Goal
Refactor the drawer side menu layout, items, and headers to implement a modern, elegant, and responsive design, supporting both left-opening and right-opening configurations dynamically.

## Approach
- Removed the rigid device height-based item size calculations.
- Integrated `isSelected` parameter support to `SideMenuItem` to render active capsule highlights on currently viewed pages.
- Dynamically rounded the drawer sheet inner edges based on the `widget.isLeftMenu` position configuration.
- Polished copyright info and action alignments at the drawer bottom.

## Changes
- `lib/menu/side_menu_item.dart` — Refactored layout to use auto-sizing, container margins, and active capsule highlighting with Material 3 values.
- `lib/menu/side_menu.dart` — Dynamically rounded drawer corners based on the layout side and supplied selections to list items.
- `lib/menu/copy_right_menu_item.dart` — Standardized alignments, padding, and fallback primary coloring.

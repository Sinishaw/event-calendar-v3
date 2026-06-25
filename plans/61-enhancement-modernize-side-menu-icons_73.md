# Plan — Modernize Side Menu Icons

**Branch:** enhancement/modernize-side-menu-icons_73
**Issue:** #73
**Date:** 2026-06-25

## Goal
Establish a cohesive, modern visual theme across the application by upgrading the side menu navigation icons.

## Approach
Update [side_menu.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/menu/side_menu.dart) to replace all old blocky/generic icons in `SideMenuItem` widgets with cohesive, modern rounded-corner Material icons:
- **Home**: `Icons.today_rounded` (cohesive with bottom menu)
- **Year**: `Icons.grid_view_rounded` (cohesive with bottom menu)
- **Date Converter**: `Icons.change_circle_rounded` (cohesive with bottom menu)
- **Archives**: `Icons.feed_rounded` (cohesive with bottom menu)
- **Plans**: `Icons.edit_calendar_rounded` (modern calendar todo symbol)
- **National Days**: `Icons.celebration_rounded` (modern styled celebration)
- **About App**: `Icons.info_rounded` (rounded info bubble)
- **Setting**: `Icons.settings_rounded` (rounded gear icon)
- **Terms & Conditions**: `Icons.description_rounded` (modern document symbol)

## Changes
- [side_menu.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/menu/side_menu.dart) — Replace the old icons in all `SideMenuItem` instantiations.

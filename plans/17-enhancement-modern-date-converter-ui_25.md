# Plan — Modern Date Converter UI Redesign

**Branch:** `enhancement/modern-date-converter-ui_25`
**Issue:** #25
**Date:** 2026-06-22

## Goal
Redesign the Date Converter page to have a modern, elegant, and beautiful appearance while preserving all existing conversion logic. The page should fit the device screen, use theme-aware pill toggles, and creatively separate the Ethiopian/Gregorian result dates.

## Approach
- Replaced hardcoded `SingleChildScrollView + SizedBox(height)` hack with `LayoutBuilder` + `ConstrainedBox` + `IntrinsicHeight` for responsive fit-to-screen (scrolling only when the device is too small).
- Replaced `GridView.count` tab selector with a modern segmented-control pill toggle using `AnimatedContainer`.
- Added glassmorphic selection band on the scroll wheels with `BackdropFilter` and a subtle border.
- Added Day/Month/Year column headers above the scroll wheels.
- Replaced `Card` + `GestureDetector` buttons with pill-shaped `Material` + `InkWell` chips.
- Redesigned result panel: side-by-side layout with a creative vertical gradient divider and centered swap icon, soft rounded container with subtle border instead of hard edges.
- Modernized `InputBasedConverterDialog`: rounded 20px clip, matching pill toggle, outlined input fields with filled backgrounds, full-width pill CTA button.
- Enhanced `AgeCalculatorDialog`: primaryColor glow ring shadow, visible accent ring border.
- Updated `TabViewItem`: AnimatedContainer, pill shape (radius 24), theme-aware coloring.

## Changes
- `lib/screens/converter/converter_page.dart` — Full layout + visual redesign
- `lib/screens/converter/tab_view_item.dart` — Pill shape, animated transitions, theme colors
- `lib/screens/converter/input_based_converter_dialog.dart` — Rounded inputs, modern toggle, CTA button
- `lib/screens/converter/age_calculator_dialog.dart` — Glow ring shadow, accent border

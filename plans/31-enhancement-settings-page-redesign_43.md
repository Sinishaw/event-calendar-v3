# Plan — Settings Page & Setup Flows Redesign

**Branch:** enhancement/settings-page-redesign_43
**Issue:** #43
**Date:** 2026-06-23

## Goal
Redesign the settings page (`lib/screens/settings/setting_page.dart`), the company grid selection page (`lib/screens/company/widgets/selectable_company_grid.dart`), and the subscription topics selection dialog (`lib/screens/topic/widgets/topic_picker_dialog.dart`) to use the modern, elegant, glassmorphic card-based layout. Implement a custom modal language picker dialog instead of the legacy dropdown menu.

## Approach
- Modify `CompanyPreferenceTemplate` and `TopicTemplate` to store data properties rather than hardcoded Flutter `Container` widgets.
- Group setting options into clean rounded card panels with subtle borders.
- Replace language dropdown with a list tile that displays the selected language and launches a custom `LanguagePickerDialog` on tap.
- Design `LanguagePickerDialog` with native script labels, checkboxes, and smooth animation cues.
- Redesign `CompanyGridViewItem` and `TopicGridItem` to support card themes, transparent background borders for logos, and checkmark overlays for active items.
- Ensure all theme/language callbacks and Firestore/RemoteConfig updates function correctly.

## Changes
- `lib/screens/company/models/company_preference_model.dart` — Refactored to store raw data properties.
- `lib/screens/topic/model/topic_template.dart` — Refactored to store raw data properties.
- `lib/screens/settings/setting_page.dart` — Settings layout redesigned with card groups, and added custom language picker dialog.
- `lib/screens/company/widgets/selectable_company_grid.dart` — Redesigned company selection grid layout.
- `lib/screens/company/widgets/company_grid_view_item.dart` — Redesigned company selection grid item.
- `lib/screens/topic/widgets/topic_picker_dialog.dart` — Redesigned subscription topic picker grid and bottom navigation.
- `lib/screens/topic/widgets/topic_grid_item.dart` — Redesigned subscription topic grid item.
- `lib/screens/topic/widgets/selectable_topic_grid.dart` — Updated to match the refactored `TopicTemplate`.

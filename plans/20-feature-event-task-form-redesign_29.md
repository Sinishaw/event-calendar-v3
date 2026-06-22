# Plan — Event & Task Form and Selector Popups Redesign

**Branch:** `feature/event-task-form-redesign_29`
**Issue:** #29
**Date:** June 22, 2026

## Goal
Redesign the Event & Task creation form page and all five selector popups (category picker, repeat picker, alert schedule picker, local date picker, and local time picker) to feature a modern, unified, and premium user interface with dynamic glassmorphic backgrounds and responsive layouts. Provide space to display events by using space efficiently, restyle the daily event list items, make toast alerts accurate and floating, position the Save button as a floating button in the right corner, and preserve the selected date after saving an event to let the user immediately see their new entry.

## Approach
- Removed nested Scaffolds and solid headers in dialog popups, replacing them with a custom translucent Dialog.
- Handled dialog opacity dynamically from the settings (`Globals.setting.menuBackgroundOpacity`), defaulting to solid 1.0.
- Implemented state-based segmented pill toggles and selection highlight overlays in Date/Time picker wheels.
- Replaced the bottom save text button in Date and Time picker dialogs with a modern, circular checkmark select button.
- Overhauled UserEventPage to use responsive layout builders, outlined & filled TextFields, side-by-side date/time picker triggers, and a highly compact 3-row grid layout for selectors (Date/Time, Category/Alert, Repeat/Active Date Badge) to save vertical space.
- Styled the daily event list items as modern rounded cards with category-themed borders and circular icons.
- Redesigned the save button into a compact extended Floating Action Button with a save icon and text in the bottom right corner, using a GestureDetector to preserve the onLongPress functionality for canceling notifications.
- Enhanced the toast reminder duration calculation to round to the nearest minute, resolving any seconds/milliseconds offset inaccuracies.
- Updated `_resetEntry` to accept a `keepDate` parameter, preserving the currently selected date upon successful save.

## Changes
- `lib/screens/plans/widgets/event_category_picker.dart` — Redesigned into a unified glassmorphic dialog card.
- `lib/screens/plans/widgets/notification_repeat_picker.dart` — Redesigned with custom icons, highlight selections, and dynamic opacity.
- `lib/screens/plans/widgets/notification_schedule_picker.dart` — Redesigned matching the picker style.
- `lib/shared/widgets/date_picker_dialog_local.dart` — Replaced tab bar navigation with segmented controls and custom overlays, and replaced the save text button with a circular check select button.
- `lib/shared/widgets/time_picker_dialog_local.dart` — Modernized layouts using segmented control toggles, custom selection overlays, and replaced the save text button with a circular check select button.
- `lib/screens/plans/widgets/daily_user_event_list.dart` — Restyled personal, national, and company event items as modern cards with category-themed borders, circular icons, and rounded dismissible swipe actions.
- `lib/screens/plans/user_event_page.dart` — Replaced standard fields and buttons with custom glassmorphic cards in a compact grid, a bottom-right corner extended FloatingActionButton (with GestureDetector for long press), centered badge layouts, and added `keepDate` preservation logic.
- `lib/common/globals.dart` — Redesigned the toast notification style to be a modern floating pill, and updated the duration math to round to the nearest minute.

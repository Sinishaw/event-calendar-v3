# Plan — iOS Scroll Wheel Tick Sounds

**Branch:** enhancement/picker-scroll-haptics_31
**Issue:** #31
**Date:** 2026-06-23

## Goal
Implement iOS-like selection click sounds (the "kerrr" wheel ticking sound/feedback) when the wheels in the date and time picker dialogs are scrolled, restricted to the iOS platform to ensure native-feeling UX.

## Approach
On iOS and Android, scrolling the wheel pickers triggers `HapticFeedback.selectionClick()` for standard haptic feedback. To deliver the native-sounding mechanical scroll click sound, we explicitly call `SystemSound.play(SystemSoundType.click)` ONLY if the target platform is iOS (`Theme.of(context).platform == TargetPlatform.iOS`).
1. Import `package:flutter/services.dart` in both picker dialog files.
2. In the `onSelectedItemChanged` callbacks of `ListWheelScrollView` widgets:
   - Call `HapticFeedback.selectionClick()` on all platforms.
   - Guarded by platform detection, call `SystemSound.play(SystemSoundType.click)` on iOS only.

## Changes
- [date_picker_dialog_local.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/shared/widgets/date_picker_dialog_local.dart) — Add platform guard for iOS-only click sound.
- [time_picker_dialog_local.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/shared/widgets/time_picker_dialog_local.dart) — Add platform guard for iOS-only click sound.

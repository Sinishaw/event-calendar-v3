# Plan — Remove Ginbot 20 National Holiday

**Branch:** fix/remove-ginbot-20_37
**Issue:** #37
**Date:** 2026-06-23

## Goal
Remove the obsolete `ginbot20` (Derg Downfall Day) holiday from the list of Ethiopian national holidays.

## Approach
1. **Remove Calculations**:
   - In `holiday_and_national_events.dart`, removed the fixed date definition and addition logic for Ginbot 20.
2. **Enum & Globals Lists Alignment**:
   - In `enums.dart`, removed `ginbot20` from the `EthiopianFixedHoliday` enum.
   - In `globals.dart`, removed `AppLocalizations.of(context!)!.ginbot20` from the global `ethiopianFixedHolidays` lists, and removed its corresponding description string from `ethiopianFixedHolidaysDescription`. This maintains index alignment between the enum and the lists.
3. **Localization Resources Cleanup**:
   - Removed the `"ginbot20"` translation key from `app_am.arb`, `app_en.arb`, `app_or.arb`, and `app_te.arb`.
   - Removed the key in all translation sections of `languages.json`.
   - Regenerated the localization classes by running `flutter gen-l10n --output-dir=lib/l10n --no-synthetic-package`.

## Changes
- [holiday_and_national_events.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/events/models/holiday_and_national_events.dart) — Removed calculation logic.
- [enums.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/shared/enums.dart) — Removed enum value.
- [globals.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/common/globals.dart) — Removed entries in global lists.
- [languages.json](file:///Users/sinishaw/My_Projects/event-calendar-v3/assets/files/languages.json) — Removed JSON translation entries.
- [app_am.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_am.arb) — Removed AM translation.
- [app_en.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_en.arb) — Removed EN translation.
- [app_or.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_or.arb) — Removed OR translation.
- [app_te.arb](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/l10n/app_te.arb) — Removed TE translation.
- Generated localization classes inside `lib/l10n/` — Regenerated via Flutter tool.

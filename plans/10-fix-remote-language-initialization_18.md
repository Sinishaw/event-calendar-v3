# Plan — Fix Remote Settings Initialization and User Preference Retention

**Branch:** fix/remote-language-initialization_18
**Issue:** #18
**Date:** 2026-06-22

## Goal
Resolve the race condition during startup where the remote language setting is not applied when the app is first opened. Ensure that once a user overrides the default language, theme, or number formatting, the preference is retained and not overwritten by subsequent updates, onboarding deep links, or company selection.

## Approach
1. Refactored `fetchCompanyPreferredByUser` to be fully asynchronous so that app initialization waits for the company remote config fetch to finish and populate SharedPreferences before the UI builds.
2. Added a constructor to `LanguageChangeProvider` to read the stored language from SharedPreferences on startup.
3. Created `UserLanguageOverride`, `UserThemeOverride`, and `UserNumberFormatOverride` flags in SharedPreferences, set to `true` when the user manually changes settings in settings.
4. Added mapping/normalization methods `normalizeTheme` (maps `"dark"`, `"light"`, `"system"` to `"Dark"`/`"Light"`) and `normalizeNumberFormat` (maps `"english"`, `"geez"` to `"Eng"`/`"ግዕዝ"`) in `Utility` class.
5. Guarded language, theme, and number format preference overwrites in `company_model.dart`, `selectable_company_grid.dart` and `dynamicLink.dart` using these override flags.
6. Updated the company check condition in `configureCompany()` to ensure the deep-link company config is not skipped when the local preference is set to `"DEFAULT"` on the very first start.

## Changes
- `lib/common/constants.dart` — Added `UserLanguageOverride`, `UserThemeOverride`, and `UserNumberFormatOverride` preference keys.
- `lib/screens/settings/setting_page.dart` — Set the override flags to `true` on user selections.
- `lib/utils/utilities.dart` — Added `normalizeTheme` and `normalizeNumberFormat` static helpers.
- `lib/language/language_change_provider.dart` — Added constructor to initialize `_currentLocal` from SharedPreferences.
- `lib/screens/company/models/company_model.dart` — Refactored `fetchCompanyPreferredByUser` to return a `Future<void>`, use `await` on the remote config fetch, and guard and normalize settings.
- `lib/firebase/dynamicLink/dynamicLink.dart` — Guarded and normalized settings, called `changeLocal` to update the language provider on onboarding, and corrected the `configureCompany` default company check condition.
- `lib/screens/company/widgets/selectable_company_grid.dart` — Guarded and normalized settings when selecting a company.

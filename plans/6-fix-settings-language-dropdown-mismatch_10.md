# Plan — Fix Settings Page Crash: Language Dropdown Value Mismatch

**Branch:** fix/settings-language-dropdown-mismatch_10
**Issue:** #10
**Date:** 2026-06-20

## Goal
Eliminate the Flutter assertion crash that fires every time the Settings page is opened:
`There should be exactly one item with [DropdownButton]'s value: am.`

## Approach
When the MMCY company config is loaded via `dynamicLink.dart`, the `defaultLanguage` field from Remote Config (e.g. `"am"` or `"Amharic"`) is stored directly into `Constants.LanguagePreference`. The Settings page `DropdownButton` reads this value and sets it as the selected item. However, the dropdown items use full display names (`"አማርኛ"`, `"Oromiffa"`, etc.), so `"am"` never matches, causing the assertion failure.

Fix: add a `_langCodeToDisplayName` normalisation map (as a `static const`) inside `_SettingPageState` that covers all ISO codes and known alternate names. In `_initLanguageOptions()`, resolve the stored value through this map before assigning to `_languageDropdownValue`. Also persist the corrected display name back to SharedPreferences so the mismatch doesn't recur on subsequent launches.

Alternatives considered:
- Fixing the source: changing `dynamicLink.dart` to always store the display name. Rejected as a standalone fix — the RC JSON value is outside our control and could be in any format.
- Using the language code as the dropdown item value throughout. Rejected — requires refactoring `onChanged` logic and all places that read `LanguagePreference`.

## Changes
- `lib/screens/settings/setting_page.dart` — added `_langCodeToDisplayName` static map; refactored `_initLanguageOptions()` to normalise stored language value, re-persist if corrected, and re-validate after the options list is built.
- `plans/6-fix-settings-language-dropdown-mismatch_10.md` — this plan file.

# Plan — Fix MonthImageUrls.fromJson Crash: String Not Subtype of int?

**Branch:** fix/month-image-urls-id-type-cast_8
**Issue:** #8
**Date:** 2026-06-20

## Goal
Eliminate the `type 'String' is not a subtype of type 'int?'` crash that fires on every app launch from `MonthImageUrls.fromJson`, which crashes both `Globals.initMonthsImage()` and `Globals.initCompanySettingFromLocalIfAny()`.

## Approach
The `id` field in the month image URLs JSON arrives from Firebase Remote Config and cached SharedPreferences as a `String` (e.g. `"5"`), not an `int`. The `fromJson` constructor blindly assigned it to `int?`, causing a `_TypeError` at runtime.

Fix: introduce a top-level `_parseInt(dynamic value)` helper (following the same pattern as `_parseDouble` already present in `company_config_model.dart`) that handles `int`, `double`, `String`, and `null` inputs safely. Replace the bare `json['id']` assignment with `_parseInt(json['id'])`.

Alternatives considered:
- Casting inline with `(json['id'] as int?)` — rejected; this throws the same error for `String` input.
- Changing the Remote Config JSON to use numeric literals — rejected; would require coordinated Remote Config publish and doesn't protect against cached old values.

## Changes
- `lib/common/config/month_image_urls_model.dart` — replaced `json['id']` with `_parseInt(json['id'])` in `fromJson`; added `_parseInt` top-level helper function.

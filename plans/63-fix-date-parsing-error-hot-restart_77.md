# Plan — Fix Date Parsing Error on Hot Restart

**Branch:** fix/date-parsing-error-hot-restart_77
**Issue:** #77
**Date:** 2026-06-26

## Goal
Fix the `FormatException: Invalid date format` error that occurs during hot restart in Android emulator when parsing date fields from local company config.

## Root Cause
1. `CompanyProfile.established` field contains an empty string `""` which cannot be parsed by `DateTime.parse()`
2. `CompanyConfig.expirationDate` contains date-only format "2026-09-30" but `DateTime.parse()` expects full ISO 8601 format with time component
3. Both issues occur during `initCompanySettingFromLocalIfAny()` in `globals.dart` line 85

## Approach
Create a safe date parsing helper function similar to the existing `_parseDouble()` function that:
- Handles null/empty strings gracefully by returning null
- Parses date-only strings (YYYY-MM-DD) by appending time component if needed
- Uses `DateTime.tryParse()` instead of `DateTime.parse()` to avoid exceptions

Apply this helper to both date parsing locations:
- `CompanyConfig.fromJson` for `expirationDate`
- `CompanyProfile.fromJson` for `established`

## Changes
- **lib/common/config/company_config_model.dart** — Add `_parseDateTime()` helper function and use it for `expirationDate` parsing
- **lib/common/config/company_profile_model.dart** — Add `_parseDateTime()` helper function and use it for `established` parsing

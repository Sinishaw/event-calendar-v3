# Plan — Replace Platform-Inconsistent Delete Confirmation Dialog

**Branch:** fix/delete-confirmation-dialog-redesign_51
**Issue:** #51
**Date:** 2026-06-23

## Goal
Replace the platform-adaptive `AlertDialog` used for delete confirmations inside `DailyUserEventList` (which renders in a Cupertino style on iOS and Material on Android) with a custom, beautifully-designed glassmorphic Dialog that renders identically and consistently across both platforms.

## Approach
Instead of relying on Flutter's platform-adaptive `AlertDialog` which looks completely different on iOS and Android, we implement a custom dialog using Flutter's basic `Dialog` widget. 
The dialog background is set to transparent, allowing us to build a custom-designed glassmorphic styled Container.
Features:
- Rounded corners (`20.0` border radius) matching the app's modern UI.
- A red-accented gradient header with a delete icon in a matching circular container.
- Clean text styling using values derived from the theme (`Theme.of(context)`).
- Distinct labeled text buttons for "Cancel" (muted style) and "Delete" (red accent text and icon).
- Fully localized buttons and texts using localizations (`AppLocalizations`). Added `cancel` and `delete` keys to Amharic, English, Oromo, and Tigrinya localizations.

## Changes
- `lib/screens/plans/widgets/daily_user_event_list.dart` — Replaced `AlertDialog` inside `confirmDismiss` with the new custom themed Dialog widget. Cleaned up unused `font_awesome_flutter` import.
- `lib/l10n/app_en.arb` — Added `cancel` and `delete` localization keys.
- `lib/l10n/app_am.arb` — Added `cancel` and `delete` localization keys.
- `lib/l10n/app_or.arb` — Added `cancel` and `delete` localization keys.
- `lib/l10n/app_te.arb` — Added `cancel` and `delete` localization keys.

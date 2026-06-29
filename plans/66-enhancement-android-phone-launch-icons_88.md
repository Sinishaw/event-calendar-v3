# Plan — Add Android Phone Launch Icons

**Branch:** enhancement/android-phone-launch-icons_88
**Issue:** #88
**Date:** 2026-06-29

## Goal
Add correct launch icons for Android devices using phone-specific icons from the `croped-icons/Android` directory, configuring full adaptive and legacy round icon support.

## Approach
1. Copy legacy (`ic_launcher.png`) and adaptive foreground (`ic_launcher_foreground.png`) icons from `croped-icons/Android/mipmap-<density>` to `android/app/src/main/res/mipmap-<density>` for all densities.
2. Omit unnecessary background image files and store listing graphics to keep the application bundle light and clean.
3. Define the solid background color in `colors.xml`.
4. Create the adaptive xml definitions under `mipmap-anydpi-v26` and declare `android:roundIcon` in the manifest.

## Changes
- `android/app/src/main/res/values/colors.xml` — Defined `ic_launcher_background` as `#113766`.
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` — Defined adaptive icon.
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` — Defined round adaptive icon.
- `android/app/src/main/AndroidManifest.xml` — Added `android:roundIcon="@mipmap/ic_launcher_round"` attribute.
- Copied files under `android/app/src/main/res/mipmap-<density>/`:
  - `ic_launcher.png`
  - `ic_launcher_foreground.png`

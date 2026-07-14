# Plan — Clear Android Gradle/AGP/Kotlin version warnings (safe bumps)

**Branch:** chore/android-toolchain-bump_128
**Issue:** #128
**Date:** 2026-07-14

## Goal
Clear the three "support will soon be dropped" toolchain warnings on `flutter run` (Android) by bumping to the recommended minimums, without breaking the build.

## Approach
Bumped the versions, then hit (and fixed) a required Kotlin-2.2 DSL migration: Kotlin 2.2 turns the old `kotlinOptions {}` block into a hard error, so both usages were migrated to the `compilerOptions` DSL. Verified with a real APK build.

## Changes
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle `8.12` → `8.14.3`.
- `android/settings.gradle.kts` — AGP `8.9.1` → `8.11.1`; Kotlin `2.1.0` → `2.2.20`.
- `android/app/build.gradle.kts` — removed `android { kotlinOptions { jvmTarget = "11" } }`; added top-level `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_11) } }`.
- `android/build.gradle.kts` — subprojects `KotlinCompile` block: `kotlinOptions { jvmTarget = … }` → `compilerOptions { jvmTarget.set(JvmTarget.fromTarget(…)) }`.

## Result / verification
- `flutter clean && flutter build apk --debug` **succeeds**.
- The three Gradle/AGP/Kotlin "will soon be dropped" warnings are **gone**.
- **Left as-is (documented, safe):** the "applies the Kotlin Gradle Plugin / migrate to Built-in Kotlin" warning + the third-party plugin KGP list + the `-Xlint:deprecation` note — these depend on the plugin ecosystem / a riskier template migration, and version bumps don't affect them.
- Rollback if needed: `git checkout -- android/gradle/wrapper/gradle-wrapper.properties android/settings.gradle.kts android/app/build.gradle.kts android/build.gradle.kts`.

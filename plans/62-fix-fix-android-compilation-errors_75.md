# Plan — Fix Android Compilation and Gradle Build Errors

**Branch:** fix/fix-android-compilation-errors_75
**Issue:** #75
**Date:** 2026-06-26

## Goal
Resolve Gradle and compilation build crashes when running the application on Android emulators/devices.

## Approach
1. **Dynamic Namespace Fallback & Package Stripping**:
   Inject fallback namespaces dynamically in `android/build.gradle.kts` for older packages lacking the `namespace` field in their `build.gradle` file. Automatically read and strip the `package="..."` attribute from their `src/main/AndroidManifest.xml` to avoid new AGP 8.0+ build requirements crashes.
2. **Forced Stable Dependency Resolution Strategy**:
   Transitive dependencies were trying to fetch pre-release Glance libraries which require Android API 37. Since only API 36 is locally installed on the development system, we add a `resolutionStrategy` in `android/app/build.gradle.kts` to force `androidx.glance` to stable `1.1.0`.
3. **Core Library Desugaring**:
   Enable desugaring inside the app's `compileOptions` and add the `com.android.tools:desugar_jdk_libs:2.1.4` dependency to support newer Java features required by the local notifications plugin on older platforms.
4. **Timezone & Workmanager Package Modernization**:
   - Replace `flutter_native_timezone_updated_gradle` with `flutter_timezone: ^3.0.1` and migrate `lib/services/notifications/notification_service.dart`.
   - Replace the obsolete git-fork of `workmanager` with the stable release `workmanager: ^0.9.0` from pub.dev to remove v1 Android Embedding dependencies that no longer exist in newer Flutter versions.
5. **Align JVM Compiler Targets**:
   Dynamically match the Kotlin compiler's `jvmTarget` to each subproject's Java `targetCompatibility` to prevent compiler version target mismatches.

## Changes
- [pubspec.yaml](file:///Users/sinishaw/My_Projects/event-calendar-v3/pubspec.yaml) — Swap timezone and workmanager packages.
- [notification_service.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/services/notifications/notification_service.dart) — Update to `FlutterTimezone` API.
- [build.gradle.kts](file:///Users/sinishaw/My_Projects/event-calendar-v3/android/build.gradle.kts) — Dynamic namespace and Kotlin JVM target alignment blocks.
- [build.gradle.kts](file:///Users/sinishaw/My_Projects/event-calendar-v3/android/app/build.gradle.kts) — Compile SDK settings, desugaring configuration, and resolution strategies.

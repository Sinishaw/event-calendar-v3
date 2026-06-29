# Plan — Fix iOS Firebase SPM Deployment Target

**Branch:** fix/ios-deployment-target_82
**Issue:** #82
**Date:** 2026-06-29

## Goal
Align the iOS deployment target in the Xcode project with Firebase Swift Package Manager requirements to prevent Target Integrity compilation errors.

## Approach
- Normalize all `IPHONEOS_DEPLOYMENT_TARGET` values to `15.0` in `ios/Runner.xcodeproj/project.pbxproj`.
- Ensure Podfile target matches this minimum (already configured to `15.0`).
- Preserve dependency adjustments in `ios/Podfile.lock` resulting from package alignment.

## Changes
- `ios/Runner.xcodeproj/project.pbxproj` — Normalized iOS deployment targets to `15.0`.
- `ios/Podfile.lock` — Updated plugin dependencies (`flutter_timezone`, `workmanager_apple`).

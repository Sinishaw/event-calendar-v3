# Plan — Untrack stale workspace-level SPM Package.resolved

**Branch:** chore/untrack-stale-spm-resolved_130
**Issue:** #130
**Date:** 2026-07-15

## Goal
Stop the stale workspace-level SwiftPM `Package.resolved` from perpetually
showing as a deletion in the working tree.

## Approach
There are two SPM `Package.resolved` files:
- `ios/Runner.xcodeproj/project.xcworkspace/.../Package.resolved` — the
  **canonical** file Flutter's SwiftPM integration maintains. Stays tracked.
- `ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved` — a **stale
  duplicate** committed during the "M4 mac" setup (commit `c7ea3ee`); its
  pinned versions have since diverged (e.g. app-check 11.3.0 vs 11.2.0). The
  active Flutter/SPM tooling prunes it within seconds of any restore, so git
  perpetually reports it as deleted and it cannot be kept in sync.

Fix: untrack the stale file (`git rm --cached`) and add its exact path to
`.gitignore`. The canonical project-level file is left tracked, so reproducible
SPM resolution is unaffected.

Alternative considered: leave it as an accepted `D` in the worktree. Rejected —
it keeps `git status` permanently dirty for no benefit.

## Changes
- `.gitignore` — ignore `ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- `ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved` — removed from
  the index (untracked only; canonical project-level file kept).

## Verification
- `git status` shows only the staged deletion + `.gitignore` edit; the phantom
  ` D` no longer reappears after the tooling prunes the file.
- No secrets in the diff.

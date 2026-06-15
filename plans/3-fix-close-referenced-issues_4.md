# Plan — Support Refs Keyword in Issue Closing Workflow

**Branch:** fix/close-referenced-issues_4
**Issue:** #4
**Date:** 2026-06-15

## Goal
Modify the Github Action workflow that automatically closes referred issues on PR merge to recognize the `Refs #<issueNumber>` format, in addition to standard GitHub keywords.

## Approach
Updated the regex pattern inside the issue-closing job in `.github/workflows/close-linked-issues.yaml` to include case-insensitive matches for `refs?` and `references?` keywords (e.g. `Refs #123`, `references #456`).

## Changes
- [close-linked-issues.yaml](file:///Users/sinishaw/My_Projects/event-calendar-v3/.github/workflows/close-linked-issues.yaml) — Updated regex pattern inside the run script.

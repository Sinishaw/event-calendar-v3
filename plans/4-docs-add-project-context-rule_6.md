# Plan — Add Project Context Rule File for Agent Sessions

**Branch:** docs/add-project-context-rule_6
**Issue:** #6
**Date:** 2026-06-20

## Goal
Create `.agents/rules/project-context.md` — an always-on Markdown rule file that gives every future agent session immediate, accurate knowledge of the project without requiring redundant codebase analysis.

## Approach
Analysed the full project by reading: `pubspec.yaml`, `README.md`, `lib/main.dart`, `lib/common/globals.dart`, `lib/common/constants.dart`, all `lib/screens/*/`, all `lib/firebase/*/`, `lib/services/`, `lib/shared/`, `lib/configs/`, `lib/l10n/`, `lib/menu/`, `lib/utils/`, and `lib/pages.dart`. Synthesised findings into a structured Markdown file with six sections.

Alternatives considered:
- Generating a KI (Knowledge Item) instead — rejected; the user explicitly requested a rule file at `.agents/rules/`.
- Auto-generating from code comments — not viable; code comments are sparse.

## Changes
- `.agents/rules/project-context.md` — new file; always-on project context covering name/purpose, directory tree, module table, technologies/data flows (with Firestore collection map and four annotated flow diagrams), actors/roles table, and known issues/gotchas.

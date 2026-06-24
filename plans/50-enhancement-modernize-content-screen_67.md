# Plan — Revert Content Image Aspect Ratio Scaling

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Revert the image sizing in `CompanyContentPage` to let images render at their natural aspect ratio (instead of cropping to a fixed height of 180), so that they are fully and clearly visible.

## Approach
- Modify the main content image `CachedNetworkImage` in `company_content.dart`.
- Remove the fixed `height: 180` and `fit: BoxFit.cover` constraints, allowing it to scale dynamically to the full width of the card.
- Restore the original placeholder `minHeight: 200` constraints for loading states.
- Retain the modernized `BorderRadius.circular(12)` on the image container.

## Changes
- [company_content.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/company_content.dart) — Revert image size/aspect-ratio constraints.

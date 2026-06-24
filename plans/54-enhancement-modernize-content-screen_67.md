# Plan — Adjust Content Feed Card Margins

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Reduce the horizontal margins of the cards in `CompanyContentPage` to let the content span wider and display beautifully with smaller padding on the left and right.

## Approach
- Modify the horizontal margin on line 72 of `company_content.dart` from `16` to `8`.
- Retain vertical spacing and layout structure.

## Changes
- [company_content.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/company_content.dart) — Reduce card horizontal margins to 8.

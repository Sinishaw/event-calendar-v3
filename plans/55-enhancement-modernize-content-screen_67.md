# Plan — Remove Content Feed Card Margins & Internal Padding

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Optimize horizontal screen space utilization in `CompanyContentPage` by removing outer horizontal card margins and reducing the internal padding.

## Approach
- Modify `company_content.dart` to change card margins from `horizontal: 8` to `horizontal: 0` (full-bleed cards).
- Change card internal padding from `EdgeInsets.all(16.0)` to `EdgeInsets.symmetric(vertical: 12, horizontal: 8)` to maximize display area for images and text description.

## Changes
- [company_content.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/company_content.dart) — Change outer margin to 0 and inner padding to 8px horizontal.

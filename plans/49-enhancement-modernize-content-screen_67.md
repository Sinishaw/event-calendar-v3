# Plan — Modernize Company Content Page & Fix Back Button

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Overhaul `CompanyContentPage` to render a proper centered title and dynamic back button (when popped as a route), modernize list item cards with rounded corners, drop shadows, and logo thumbnails, implement pull-to-refresh, and redesign the delete confirmation modal.

## Approach
- Add a transparent `AppBar` inside `CompanyContentPage` with `Navigator.canPop(context)` condition to show a back button when it is pushed in full screen, but hide it when shown as a root tab.
- Refactor the list builder to wrap each item in a modern bordered, shaded card.
- Set card images to `BoxFit.cover` inside a rounded `ClipRRect(borderRadius: BorderRadius.circular(12))` to prevent image stretching.
- Wrap the main content feed in a `RefreshIndicator` so users can pull-to-refresh the company channel feed.
- Update the delete dialog into a clean rounded card layout with red accent gradient headers.
- Modernize the delete undo SnackBar to a floating, rounded notification banner.

## Changes
- [company_content.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/company_content.dart) — Full layout overhaul and back button addition.

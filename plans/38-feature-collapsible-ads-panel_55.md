# Plan — Collapsible Ads Panel Redesign

**Branch:** feature/collapsible-ads-panel_55
**Issue:** #55
**Date:** 2026-06-23

## Goal
Replace the intrusive vertical/horizontal carousel layout that blocked monthly headers and logos with a highly responsive, collapsible, and edge-aligned glassmorphic ads drawer panel. Fix the data duplication bug inside `_loadFreshContent()` and resolve null safety crash risks.

## Approach
- **Data Query Caching**: Moved the query execution of `_loadFreshContent()` to a state variable `_loadFreshContentFuture` inside `initState` and `_companyChangedListenerCallback` to prevent starting new asynchronous operations on every widget rebuild.
- **Deduplication**: Replaced the appending list population in `_loadFreshContent` with local scoping assignments, preventing duplicate items from stacking in the UI.
- **Overlay Stack Design**: Wrapped the main UI layout Column in a root Stack.
- **Edge-aligned Panel**: Created a responsive sliding overlay utilizing `AnimatedPositioned`. Depending on remote config `adsScreenLocation` (`left`, `right`, `top`, `bottom`):
  - In collapsed state, displays as a glassmorphic tab containing a campaign icon and notification badge showing the count of active advertisements.
  - In expanded state, slides open from the edge to display the auto-play advertisements carousel inside a glassmorphic card.
- **Gestures & Close Options**: Added tap-outside-to-dismiss barrier, an explicit close button, and swipe/drag gestures (e.g. swipe left on left-aligned drawer) to collapse.
- **Null Safety**: Removed force-unwrapping of `imageUrl`, `title`, and `body` in the card builder, adding safe fallbacks and campaign placeholder icons.

## Changes
- `lib/screens/home/home_page.dart` — Complete rewrite of ads rendering, lifecycle events, and layout stack.

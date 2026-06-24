# Plan — Implement Pull-to-Refresh Firestore Sync

**Branch:** enhancement/modernize-ads-screen_67
**Issue:** #67
**Date:** 2026-06-24

## Goal
Make drag-and-release refresh actually fetch new documents from the Firestore server instead of just reading from the local cache.

## Approach
- Add `syncGroupedRecordsFromServer` to `CloudFireStore` in `firestore.dart` to perform a server-source query `.get(GetOptions(source: Source.server))` for updated company contents and save them to the local cache.
- Update `getUserRelatedContents` in `CompanyContentModel` to accept a `forceRefresh` parameter. When true, it awaits `syncGroupedRecordsFromServer` before reading from the cache.
- Update `CompanyContentPage` to pass `forceRefresh: true` during a pull-to-refresh event, ensuring the spinner remains active until the Firestore network call completes.

## Changes
- [firestore.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/firebase/firestore/firestore.dart) — Add `syncGroupedRecordsFromServer` method.
- [company_content_model.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/models/company_content_model.dart) — Add `forceRefresh` parameter to `getUserRelatedContents`.
- [company_content.dart](file:///Users/sinishaw/My_Projects/event-calendar-v3/lib/screens/company/company_content.dart) — Set `forceRefresh` during manual refresh.

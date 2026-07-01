# Plan — Fix FCM Background Message Handler Not Registered

**Branch:** fix/fcm-background-handler-registration_97
**Issue:** #97
**Date:** 2026-07-01

## Goal
Background FCM messages are silently dropped when the app is backgrounded. Android receives the broadcast (`FLTFireMsgReceiver`) and starts `FlutterFirebaseMessagingBackgroundService` in a separate isolate, but the handler is never invoked.

## Approach
The background isolate calls `main()` directly — it never starts the widget tree or the splash screen FutureBuilder where `FirebaseMessaging.onBackgroundMessage()` was previously registered. Per Firebase docs, the handler must be registered at the top level in `main()` before `runApp()`. Moving the single call there ensures the background isolate registers it immediately on startup.

## Changes
- `lib/main.dart` — added `FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler)` in `main()` after `WidgetsFlutterBinding.ensureInitialized()`, before `runApp()`
- `lib/main.dart` — removed the duplicate registration from inside `initializeApp()`

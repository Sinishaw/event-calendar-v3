# Project Context — Event Calendar V3 (Mobile)

> **Always-on context for every agent session.** Read this before making any changes.

---

## 1. Project Name & Purpose

**Name:** Event Calendar V3 (package: `event_calendar_v2`)
**Platform:** Flutter mobile app (iOS & Android primary; Web/macOS/Linux/Windows stubs present)
**Purpose:** A multi-tenant Ethiopian calendar app that displays the Ethiopian (Ge'ez) calendar alongside Gregorian, supports Ethiopian national holidays, allows users to create personal event reminders, subscribe to topic-based content channels (e.g. "ethiopia", "culture", "health"), and follow a specific "Company" which white-labels the app's theme, language, and content feed.

**Two Firebase environments:**
- `dev` → Firebase project `eventcalendarstaging` (default when running `flutter run`)
- `prod` → Firebase project `coolcalendarplatform` (via `flutter run --dart-define=ENV=prod`)

---

## 2. Directory & File Structure

```
event-calendar-v3/
├── .agents/rules/          # AI agent rules (this file + constitution.md)
├── .github/                # GitHub Actions / PR templates
├── android/                # Android native project
├── ios/                    # iOS native project
├── assets/
│   ├── images/             # App images (splash, flags, defaults)
│   └── files/languages.json  # Available languages config
├── lib/
│   ├── main.dart           # App entry point, Firebase init, routing shell
│   ├── pages.dart          # Central screen index (Pages.screenViewOptions[])
│   ├── firebase_options.dart            # Placeholder (delegates to dev/prod)
│   ├── firebase_options_dev.dart        # Dev Firebase config
│   ├── firebase_options_prod.dart       # Prod Firebase config
│   ├── common/
│   │   ├── constants.dart              # All SharedPreferences keys & string constants
│   │   ├── globals.dart                # Global static state, helpers, holiday lists
│   │   ├── geez_numbers.dart           # Ethiopic/Ge'ez numeral conversion
│   │   └── config/
│   │       ├── company_config_model.dart   # CompanyConfig model (theme, branding, features)
│   │       ├── company_profile_model.dart  # CompanyProfile sub-model
│   │       ├── generam_config_model.dart   # GeneralConfig (terms & policies wrapper)
│   │       ├── month_image_urls_model.dart # 13-month header image URLs model
│   │       └── terms_and_policies_model.dart  # Terms versioning model
│   ├── configs/
│   │   ├── company/
│   │   │   └── application_configs.dart    # Theme builder from company Remote Config JSON
│   │   └── theme/
│   │       └── theme_model.dart            # ThemeProvider (ChangeNotifier, light/dark)
│   ├── firebase/
│   │   ├── cloudMessaging/
│   │   │   └── FcmHandler.dart             # FCM token, foreground/background msg, topic subscribe
│   │   ├── dynamicLink/
│   │   │   └── dynamicLink.dart            # Company onboarding via deep-link URI params
│   │   ├── firestore/
│   │   │   └── firestore.dart              # CloudFireStore: cache-first content & user queries
│   │   └── remoteConfig/
│   │       └── firebase_remote_config.dart # FirebaseRC: fetch & read Remote Config values
│   ├── l10n/               # Flutter gen-l10n output + ARB source files
│   │   ├── app_en.arb / app_am.arb / app_or.arb / app_te.arb  # Translations
│   │   └── app_localizations*.dart         # Generated localisation delegates
│   ├── language/
│   │   └── language_change_provider.dart   # LanguageChangeProvider (ChangeNotifier)
│   ├── menu/
│   │   ├── bottom_navigation.dart          # Bottom nav bar (4 tabs + menu trigger)
│   │   ├── side_menu.dart                  # Drawer side menu
│   │   ├── side_menu_header.dart           # Drawer header with company logo
│   │   ├── side_menu_item.dart             # Individual drawer row
│   │   └── copy_right_menu_item.dart       # Copyright footer in drawer
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_page.dart              # Main monthly calendar view
│   │   │   ├── month_globals.dart          # Month-level static data (names, day labels, etc.)
│   │   │   ├── model/
│   │   │   │   ├── core_model.dart         # MonthModel: EC↔GC date conversion logic
│   │   │   │   ├── day_model.dart          # DayModel data container
│   │   │   │   └── month_callables.dart    # Month calculation helpers
│   │   │   ├── animation/                  # Calendar swipe/scroll animations
│   │   │   └── widgets/
│   │   │       ├── single_month_container.dart  # Full month grid widget
│   │   │       ├── month_picker_dialog.dart     # Month/year picker overlay
│   │   │       └── task_and_event_dialog.dart   # Day-tap event detail dialog
│   │   ├── year/
│   │   │   ├── year_page.dart              # 13-month year grid overview
│   │   │   └── widgets/                    # Year grid sub-widgets
│   │   ├── converter/
│   │   │   ├── converter_page.dart         # EC↔GC date/time converter UI (tabbed)
│   │   │   ├── input_based_converter_dialog.dart  # Manual input converter dialog
│   │   │   ├── age_calculator_dialog.dart  # Age calculator using EC dates
│   │   │   └── tab_view_item.dart          # Reusable tab item
│   │   ├── events/
│   │   │   ├── national_event_page.dart    # Ethiopian national holidays & events list
│   │   │   ├── models/
│   │   │   │   ├── holiday_and_national_events.dart  # Holiday/national event model
│   │   │   │   ├── local_notification.dart           # LocalNotification model (user events stored in SharedPreferences)
│   │   │   │   ├── notification_payload.dart         # NotificationPayload (FCM → scheduled notification)
│   │   │   │   ├── fixed_national_events_detail.dart # Fixed holiday detail model
│   │   │   │   └── company_fields.dart               # Company event field keys
│   │   │   └── widgets/                    # Event list item widgets
│   │   ├── plans/
│   │   │   ├── user_event_page.dart        # User's personal scheduled events list
│   │   │   └── widgets/                    # Event card sub-widgets
│   │   ├── company/
│   │   │   ├── company_content.dart        # Company/topic content feed (ads + articles)
│   │   │   ├── models/
│   │   │   │   ├── company_model.dart          # CompanyModel: sync following company to/from Firestore
│   │   │   │   ├── company_content_model.dart  # Content caching from Firestore by topic
│   │   │   │   ├── company_content_fields.dart # Firestore field name constants
│   │   │   │   └── company_preference_model.dart  # User company preference wrapper
│   │   │   └── widgets/                    # Content card, ads carousel widgets
│   │   ├── topic/
│   │   │   ├── model/
│   │   │   │   ├── topic_model.dart        # Topic: local/remote sync, subscribe/unsubscribe
│   │   │   │   └── topic_template.dart     # Topic JSON template
│   │   │   └── widgets/                    # Topic list UI components
│   │   ├── settings/
│   │   │   └── setting_page.dart           # Settings UI (language, theme, notifications, week start)
│   │   ├── terms/
│   │   │   └── terms_of_service.dart       # Terms of service screen
│   │   └── about/
│   │       └── about_page.dart             # About/version info screen
│   ├── services/
│   │   └── notifications/
│   │       └── notification_service.dart   # flutter_local_notifications wrapper (schedule, show, cancel)
│   ├── shared/
│   │   ├── enums.dart                      # All app-wide enums (CalendarType, ContentSource, LogScreen, etc.)
│   │   ├── models/
│   │   │   ├── local_date_model.dart       # LocalDate (year/month/day) value object
│   │   │   └── local_time_model.dart       # LocalTime (hour/minute/period) value object
│   │   └── widgets/
│   │       ├── date_picker_dialog_local.dart  # Custom Ethiopian date picker dialog
│   │       └── time_picker_dialog_local.dart  # Custom 12-hr ET/GC time picker dialog
│   └── utils/
│       ├── utilities.dart                  # Utility: color convert, content caching, notification helpers
│       ├── firebase_logger.dart            # FirebaseLogger: Analytics screen view logging
│       └── url_helper.dart                 # URL launcher wrapper
├── plans/                  # Agent-generated implementation plan files (Markdown)
├── test/                   # Flutter widget/unit tests
├── pubspec.yaml            # Dependencies & assets
└── analysis_options.yaml   # Dart linting config
```

---

## 3. Modules & Features

| Module | Location | Purpose |
|--------|----------|---------|
| **Calendar (Home)** | `screens/home/` | Main monthly view of the Ethiopian calendar. Renders 13-month grid, highlights today, shows event indicators. Swipe gesture to navigate months. |
| **Date Conversion Engine** | `screens/home/model/core_model.dart` | Pure `MonthModel` class that converts between Ethiopian Calendar (EC) and Gregorian Calendar (GC) with leap-year handling for both systems. |
| **Year Overview** | `screens/year/` | 13-month mini-grid annual view; tapping a month navigates home. |
| **Converter** | `screens/converter/` | Tabbed UI for EC↔GC date conversion, age calculation in Ethiopian years, and time display in both Ethiopian 12-hr and Gregorian formats. |
| **National Events** | `screens/events/` | Lists Ethiopian public holidays (fixed + moveable, e.g. Easter/Fasika) with details. Holiday list is hard-coded in `Globals` and localized. |
| **User Plans / Events** | `screens/plans/` | Personal scheduler: create/edit/delete local events stored in `SharedPreferences` as `LocalNotification` objects; schedules device notifications. |
| **Company Content Feed** | `screens/company/` | Displays content (articles, ads) cached from Firestore filtered by the user's followed company topic. Acts as a white-label content channel. |
| **Topic Subscriptions** | `screens/topic/` | Users select interest topics (Ethiopia, culture, health, etc.) from a Remote Config list. Subscriptions are synced to Firestore `Topics/{topic}/Users` and FCM topic channels. |
| **Settings** | `screens/settings/` | Language, theme (light/dark), notification channels, week start day, number format (Ge'ez or Arabic). Stored in `SharedPreferences`. |
| **Notifications** | `services/notifications/` | Wraps `flutter_local_notifications` to schedule, show, and cancel notifications tied to user events and FCM push messages. |
| **FCM / Push Messaging** | `firebase/cloudMessaging/` | Handles foreground & background FCM messages; conditionally shows notifications based on user topic channel preferences; auto-schedules calendar-marked events from push payloads. |
| **Company Onboarding** | `firebase/dynamicLink/` | `FirebaseDynamicLink` configures the app's company identity on first launch via a hard-coded deep-link URI, reading company config JSON from Remote Config. (Firebase Dynamic Links SDK removed; URI handled manually.) |
| **Remote Config** | `firebase/remoteConfig/` | `FirebaseRemoteConfigV2` fetches and caches all company config, topic lists, general app properties, and month header images. |
| **Firestore Data Access** | `firebase/firestore/` | `CloudFireStore` performs cache-first content queries filtered by topic arrays; registers user FCM token in `Users` collection; tracks company & topic subscription counts in `MetaData` sub-collections. |
| **Localisation** | `l10n/` | Flutter gen-l10n supporting **English (en), Amharic (am), Afaan Oromo (or), Tigrinya (te)**. Language is switchable at runtime via `LanguageChangeProvider`. |
| **Theming** | `configs/theme/`, `configs/company/` | `ThemeProvider` toggles light/dark. `ApplicationConfigs` builds `ThemeData` from company-specific hex color values fetched via Remote Config. |
| **Global State** | `common/globals.dart` | Static singleton holding SharedPreferences instance, device dimensions, display index, month image URLs, holiday strings (re-initialized per language change). |

---

## 4. Key Technologies, Integrations & Data Flows

### Dependencies (key)
| Package | Version | Use |
|---------|---------|-----|
| `firebase_core` | ^4.1.0 | Firebase initialization |
| `cloud_firestore` | ^6.0.1 | Content & user data store |
| `firebase_remote_config` | ^6.0.1 | Company config, topic lists, month images |
| `firebase_messaging` | ^16.0.1 | Push notifications (FCM) |
| `firebase_analytics` | ^12.0.1 | Screen view & event tracking |
| `flutter_local_notifications` | ^19.4.0 | Device-level scheduled notifications |
| `shared_preferences` | ^2.5.3 | Local persistence (events, settings, tokens) |
| `provider` | ^6.1.5 | State management (ThemeProvider, LanguageChangeProvider) |
| `home_widget` | ^0.8.0 | iOS/Android home screen widget |
| `workmanager` | git fork | Background tasks for home widget updates |
| `cached_network_image` | ^3.4.1 | Image caching for company logos/content |
| `intl` | any | Date formatting; required by flutter_localizations |
| `timezone` | ^0.10.1 | Timezone-aware notification scheduling |
| `device_info_plus` | ^11.5.0 | Device metadata |
| `url_launcher` | ^6.3.2 | Open external URLs |
| `carousel_slider` | ^5.1.1 | Ads/content carousel |
| `share_plus` | ^11.0.0 | Native share sheet |

### Primary Data Flows

```
App Launch
  └─ Firebase.init (dev or prod config)
  └─ Globals.initGlobals()
        ├─ SharedPreferences.getInstance()
        ├─ FirebaseRemoteConfigV2.fetchRemoteConfig()   → caches all RC values
        ├─ CompanyModel.syncUserFollowingCompany()      → reads Firestore Companies/{id}
        ├─ CompanyModel.fetchCompanyPreferredByUser()   → sets CompanyPreference pref
        └─ Topic.initializeAndSyncTopics()              → loads & syncs FCM topic subs

Content Fetch (Company Feed)
  User's followed company + topic interests
  └─ CompanyContentModel.cacheUserRelatedContents()
        └─ CloudFireStore.cacheGroupedRecords("Contents", topicFilter)
              ├─ Source.cache first → show immediately
              └─ Source.server → fetch updates since lastContentUpdatedTimestamp

Push Notification Path (FCM → Local Notification)
  FCM message received (foreground or background)
  └─ FcmHandler / _firebaseMessagingBackgroundHandler
        ├─ Check user topic channel preference (SharedPreferences)
        ├─ If allowed & notifyUser=true → NotificationService.showNotification()
        └─ If markOnCalendar=true → NotificationService.zonedScheduleNotification()
              └─ Payload stored as NotificationPayload (JSON in SharedPreferences)

Company Onboarding (Deep Link)
  App start → FirebaseDynamicLink.configureAppFromDynamicLinkV2()
  └─ Parse hard-coded URI query params (company=<id>)
  └─ Read company JSON from Remote Config
  └─ Store to SharedPreferences (theme, language, logo, monthImages)
  └─ ThemeProvider.toggleTheme() to apply immediately

User Event Scheduling
  User creates event in UserEventPage
  └─ Saved as LocalNotification (JSON) in SharedPreferences
  └─ NotificationService.zonedScheduleNotification() → device alarm
  └─ Repeat options: none / daily / weekly / monthly / yearly / national
```

### Firestore Collections
| Collection | Purpose |
|-----------|---------|
| `Users/{fcmTokenPrefix}` | Registered device tokens |
| `Companies/{companyId}` | Company metadata + nested `MetaData/Installation` |
| `Topics/{topicId}/Users/{userId}` | Topic subscription records |
| `Topics/{topicId}/Contents` | Topic content articles |
| `Topics/{topicId}/MetaData/Subscription` | Subscription count |
| `MetaData/Installation` | Global install count |

---

## 5. Actors & Roles

| Actor | Description | Interactions |
|-------|-------------|-------------|
| **End User** | App user on iOS or Android | Views Ethiopian calendar, creates personal events, sets notifications, follows topics and company, changes language/theme |
| **Company (Tenant)** | Organisation that white-labels the app | Provides branding config (logo, colors, language, content) stored in Firebase Remote Config under their company key |
| **Topic Publisher** | Operator who posts content to a topic channel | Writes `Contents` documents to `Topics/{topicId}` in Firestore; sends FCM messages to topic channel |
| **Firebase Remote Config** | Server-side config store | Provides company configs, topic lists, general app properties, and month header image URLs to all clients |
| **Firebase Cloud Messaging** | Push service | Delivers topic-based and direct push notifications; triggers background content cache and calendar event scheduling |
| **Cloud Firestore** | Document database | Stores users, company data, topic subscriptions, and content articles |
| **Firebase Analytics** | Observability | Logs screen views (via `FirebaseLogger`) and user interactions |
| **Device OS** | iOS / Android | Delivers local scheduled notifications (via `flutter_local_notifications`); hosts home screen widget (via `home_widget`) |

---

## 6. Known Issues & Notes

- **APNS token** must be set before calling `FirebaseMessaging.getToken()` on iOS — current code has an unhandled exception guard around this.
- **`firebase_dynamic_links` SDK** has been removed. `FirebaseDynamicLink` class now uses a hard-coded URI (`example.page.link/?company=mmcy`). The file contains large commented-out legacy code blocks — do not delete; they provide migration context.
- **Firestore security rules** may deny unauthenticated reads (seen in runtime logs as `permission-denied`). The app uses anonymous/token-based identity via FCM, not Firebase Auth.
- **Package name** in `pubspec.yaml` is `event_calendar_v2` (historical; do not rename without updating all imports).
- **`workmanager`** is pinned to a git fork (`sunalwaysknows/flutter_workmanager`) — do not upgrade to pub.dev version without testing background tasks.
- **Environments**: always use `--dart-define=ENV=dev` (default) or `--dart-define=ENV=prod`. Never hardcode Firebase options directly.

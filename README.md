# Mobile - Event Calendar Version 3.0 

Revised by the help of AI

## Running the Application

This project supports running in separate development (staging) and production environments.

### 1. Run in Development/Staging (Default)
This connects to the `eventcalendarstaging` Firebase project:
```bash
flutter run
```
or explicitly:
```bash
flutter run --dart-define=ENV=dev
```

### 2. Run in Production
This connects to the `coolcalendarplatform` Firebase project:
```bash
flutter run --dart-define=ENV=prod
```

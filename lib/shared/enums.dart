// ignore_for_file: constant_identifier_names

enum ScrollableType { year, month, day }

enum CalendarType { Ethiopian, Gregorian, Hijira }

enum TimeFormat { Hour_24, Hour_12 }

enum TimePeriod { AM, PM }

enum RecordStatus { New, Published, Deleted }

enum GcMonth { January, February, March, April, May, June, July, August, September, October, November, December }

enum ContentSource { NationalEvent, UserTask, CompanyEvent, TopicEvent, GeneralEvent }

enum EventTagOption { regular, moderate, important, veryImportant, national }

enum NotificationRepeatOption { noRecurrence, daily, weekly, monthly, yearly, national }

enum NotificationScheduleOption {
  // noNotification,
  onTime,
  fiveMinuteEarlier,
  tenMinuteEarlier,
  fifteenMinuteEarlier,
  thirtyMinuteEarlier
}

enum SnackMessageType { information, success, warning, error, simple }

enum EthiopianFixedHoliday {
  newYear,
  meskel,
  genna,
  timket,
  siklet,
  fasika,
  eidAlFitur,
  mewlid,
  eidAlAdha,
  adwa,
  ginbot20,
  arbegnoch,
  labaderoch
}

enum AppTheme { light, dark }

enum LogoLocation { topLeft, topRight, bottomLeft, bottomRight }

enum AdsScreenLocation { top, right, bottom, left }

enum WeekDays { _, monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum HolidayType { christian, federal, muslim, others }

enum TimeScrollerType { hour, minute, second, period }

enum TopicSyncStatusOption { created, selected, followed, removed }

enum LogScreen {
  HomePage,
  YearPage,
  ConverterPage,
  CompanyContentPage,
  None,
  UserEventPage,
  HolidaysPage,
  AboutPage,
  SettingPage,
  TermsOfServicePage,
  NationalEventDetail,
  CompanyContentDetail,
  TopicContentDetail,
  NationalDayArticles,
  NationalDayArticleDetail,
}

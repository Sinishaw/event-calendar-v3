import 'dart:convert';

import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
import 'package:event_calendar_v2/screens/company/models/company_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/models/local_time_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/company_config_model.dart';
import 'config/generam_config_model.dart';
import 'config/month_image_urls_model.dart';

class Globals {
  static SharedPreferences? prefs;
  static int displayingIndex = 0;
  static int selectedIndex = 0;
  static bool yearGridMonthTap = false;
  static bool todayIsInitialized = false;
  static double? deviceWidth;
  static double? deviceHeight;
  static double? deviceDip;
  static BuildContext? context;

  static Map<String, dynamic>? jsonStr;
  static List<Text> languagesLocal = [];
  static List<Map<String, String?>> languagesNameValue = [];

  static List<String?> monthImagesList = List.generate(13, (index) => null);

  static NotificationAppLaunchDetails? notificationAppLaunchDetails;

  static Future<String> initGlobals() async {
    try {
      prefs = await SharedPreferences.getInstance();
      debugPrint('------ Global Config: Shared Preferences: Initialized');
      await FirebaseRemoteConfigV2.fetchRemoteConfig();
      debugPrint('------ Global Config: Remote Config: Initialized');
      await initializeCompany();
      debugPrint("------Global Config: Company Initialized");
      await initializeAndSyncTopics();
      debugPrint("------ Global Config: Initialized and Sync Topics");
      initCompanySettingIfAny();
      debugPrint("------ Global Config: Init Company Setting if Any");

      return "true";
    } catch (e) {
      return "false";
    }
  }

  static void initCompanySettingIfAny() {
    String? companyPref = Globals.prefs!.getString(Constants.CompanyPreference);
    if (companyPref == null) return;
    debugPrint("------ Company Pref ... $companyPref");

    String generalConfig = FirebaseRemoteConfig.instance.getString(Constants.GeneralAppProperties);
    if (generalConfig.isNotEmpty) {
      var generalSetting_ = GeneralConfig.fromJson(jsonDecode(generalConfig));
      debugPrint("------ General Setting Terms and Policies ... ${generalSetting_.termsAndPolicies!.terms}");
      generalSetting.termsAndPolicies = generalSetting_.termsAndPolicies;
    }

    String? stringConfig = FirebaseRemoteConfig.instance.getString(companyPref);
    debugPrint("------ Company Pref String Config... $stringConfig");
    if (stringConfig.isNotEmpty) {
      setting = CompanyConfig.fromJson(jsonDecode(stringConfig));
    }
  }

  static void initCompanySettingFromLocalIfAny() {
    String? localCompanyConfig = Globals.prefs!.getString(Constants.CompanyConfig);
    if (Globals.prefs!.getString(Constants.CompanyPreference) != null &&
        localCompanyConfig != null &&
        localCompanyConfig.isNotEmpty) {
      Map<String, dynamic>? jConfig = jsonDecode(Globals.prefs!.getString(Constants.CompanyConfig)!);
      debugPrint("------ Converted Map: $jConfig}");
      CompanyConfig oConfig = CompanyConfig.fromJson(jConfig);
      debugPrint("------ JSON Date: ${jConfig!["expirationDate"]}");
      debugPrint("------ OBJECT Date: ${oConfig.expirationDate}");
      Globals.setting = oConfig;
    }
  }

  static initializeCompany() async {
    debugPrint("------ Company Pref: ${Globals.prefs!.getString(Constants.CompanyPreference)}");
    debugPrint("------ Company Following: ${Globals.prefs!.getString(Constants.CompanyUserFollowing)}");
    await CompanyModel.syncUserFollowingCompany();
    debugPrint("------ Company Pref 2: ${Globals.prefs!.getString(Constants.CompanyPreference)}");
    debugPrint("------ Company Following 2: ${Globals.prefs!.getString(Constants.CompanyUserFollowing)}");
    await CompanyModel.fetchCompanyPreferredByUser();
    debugPrint("------ Company Pref 3: ${Globals.prefs!.getString(Constants.CompanyPreference)}");
    debugPrint("------ Company Following 3: ${Globals.prefs!.getString(Constants.CompanyUserFollowing)}");
  }

  static initDefaultCompanyTemporarily() {
    if (Globals.prefs!.getString(Constants.CompanyPreference) == null &&
        Globals.prefs!.getString(Constants.CompanyUserFollowing) == null) {
      Globals.prefs!.setString(Constants.CompanyPreference, "default");
    }
  }

  ///Load Topics from Remote Config and store them locally
  ///Check if there are new addition or removals of topics at RC and sync
  ///Sync pending user selection on app restart
  static initializeAndSyncTopics() async {
    debugPrint("------ Topic Level 1: ");
    Topic.initializeLocalTopics();
    debugPrint("------ Topic Level 2: ");
    Topic.refreshLocalTopicsFromRemoteConfig();
    debugPrint("------ Topic Level 3: ");
    await Topic.syncUserWithLatestTopics();
  }

  static CompanyConfig setting = CompanyConfig();
  static GeneralConfig generalSetting = GeneralConfig();

  static initMonthsImage() async {
    ///TODO: Must avoid any unexpected behavior or other errors.
    prefs = await SharedPreferences.getInstance();
    var monthImagesSharedPref = Globals.prefs!.getString(Constants.MonthImages);

    ///Read if there is available monthImages downloaded from remote config.
    if (monthImagesSharedPref != null && monthImagesSharedPref.isNotEmpty) {
      Map<String, dynamic>? monthImagesMapped = jsonDecode(monthImagesSharedPref);
      var monthImages = MonthImageUrls.fromJson(monthImagesMapped);
      monthImagesList[0] = monthImages.msUrl;
      monthImagesList[1] = monthImages.tkUrl;
      monthImagesList[2] = monthImages.hdUrl;
      monthImagesList[3] = monthImages.thUrl;
      monthImagesList[4] = monthImages.trUrl;
      monthImagesList[5] = monthImages.ykUrl;
      monthImagesList[6] = monthImages.mgUrl;
      monthImagesList[7] = monthImages.mzUrl;
      monthImagesList[8] = monthImages.gnUrl;
      monthImagesList[9] = monthImages.snUrl;
      monthImagesList[10] = monthImages.hmUrl;
      monthImagesList[11] = monthImages.nhUrl;
      monthImagesList[12] = monthImages.pgUrl;

      String? url;
      for (int i = 0; i < 13; i++) {
        if (monthImagesList[i] != null && monthImagesList[i]!.isNotEmpty) {
          url = monthImagesList[i];
          break;
        }
      }

      ///Adjust the urls after the first month based on their availability or not
      ///if url is not available, then the previous available url will be used
      ///else the url for the month will be used
      for (int i = 0; i < 13; i++) {
        if (monthImagesList[i] == null || monthImagesList[i]!.isEmpty) {
          monthImagesList[i] = url;
        } else {
          url = monthImagesList[i];
        }
      }
    }

    ///TODO: Recheck if it is required to validate image urls belongs to company storage or
    ///can support external urls

    // print("URLS FROM AFTER ADJUSTMENT......");
    // monthImagesList.forEach((element) {
    //   print("URL : $element");
    // });
  }

  ///TODO: Messages should come from language config
  ///Show Toast message (Snack Bar)
  static void showSnack({BuildContext? context, SnackMessageType? type = SnackMessageType.simple, String? message}) {
    Icon? icon;
    Color backgroundColor = Colors.blueAccent;
    Color textColor = Colors.white;
    Color iconColor = Colors.white;
    double iconSize = 32.0;
    String title = "";

    switch (type!) {
      case SnackMessageType.information:
        {
          icon = Icon(
            Icons.info,
            color: iconColor,
            size: iconSize,
          );
          textColor = Colors.white;
          backgroundColor = Colors.blueAccent;
          title = "Notice";
        }
        break;
      case SnackMessageType.success:
        {
          icon = Icon(
            Icons.check_circle,
            color: iconColor,
            size: iconSize,
          );
          textColor = Colors.white;
          backgroundColor = Colors.green.withOpacity(0.95);
          title = "Success";
        }
        break;
      case SnackMessageType.warning:
        {
          icon = Icon(
            Icons.warning,
            color: iconColor,
            size: iconSize,
          );
          textColor = Colors.black;
          backgroundColor = Colors.amber;
          title = "Warning!";
        }
        break;
      case SnackMessageType.error:
        {
          icon = Icon(
            Icons.error,
            color: iconColor,
            size: iconSize,
          );
          textColor = Colors.white;
          backgroundColor = Colors.red;
          title = "Error!";
        }
        break;
      case SnackMessageType.simple:
        {
          Color? tc = Theme.of(context!).textTheme.bodyLarge!.color;
          textColor = tc!;
          backgroundColor = Theme.of(context).dialogBackgroundColor;
          // title = message;
        }
        break;
    }

    Widget messageContainer = type != SnackMessageType.simple
        ? ListTile(
            leading: icon,
            title: Text(
              title,
              style: TextStyle(color: textColor),
            ),
            subtitle: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                message!,
                style: TextStyle(color: textColor),
              ),
            ),
          )
        : ListTile(
            title: Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          );

    final snackBar = SnackBar(
      // elevation: 6.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      // behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      content: messageContainer,
      // action: SnackBarAction(
      //   label: 'X',
      //   onPressed: () {
      //     // Some code to undo the change.
      //   },
      // ),
    );

    /// Find the ScaffoldMessenger in the widget tree
    /// and use it to show a SnackBar.
    ScaffoldMessenger.of(context!).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static List<String?> ethiopianFixedHolidays = [
    AppLocalizations.of(context!)!.newYear,
    AppLocalizations.of(context!)!.meskel,
    AppLocalizations.of(context!)!.genna,
    AppLocalizations.of(context!)!.timket,
    AppLocalizations.of(context!)!.siklet,
    AppLocalizations.of(context!)!.fasika,
    AppLocalizations.of(context!)!.eidAlFitur,
    AppLocalizations.of(context!)!.mewlid,
    AppLocalizations.of(context!)!.eidAlAdha,
    AppLocalizations.of(context!)!.adwa,
    AppLocalizations.of(context!)!.ginbot20,
    AppLocalizations.of(context!)!.arbegnoch,
    AppLocalizations.of(context!)!.labaderoch,
  ];

  ///TODO: Get holidays descriptions from language config
  static List<String> ethiopianFixedHolidaysDescription = [
    "Description ... የኢትዮጵያ አዲስ ዓመት/እንቁጣጣሽ/",
    "Description ... የመስቀል በዓል",
    "Description ... ልደቱ ለእግዚእነ/ገና/",
    "Description ... የጥምቀት በዓል",
    "Description ... የስቅለት በዓል",
    "Description ... የትንሳኤ በዓል",
    "Description ... የኢድ አልፈጥር በዓል",
    "Description ... የመውሊድ በዓል",
    "Description ... የኢድ አልአድሀ/አረፋ/ በዓል",
    "Description ... የአድዋ ድል በዓል",
    "Description ... ደርግ የወደቀበት ቀን",
    "Description ... የአርበኞች የድል ቀን",
    "Description ... የላባደሮች ቀን"
  ];

  ///Category options and assigned colors
  static List<String> categoryList = [
    AppLocalizations.of(context!)!.regular,
    AppLocalizations.of(context!)!.moderate,
    AppLocalizations.of(context!)!.important,
    AppLocalizations.of(context!)!.veryImportant,
  ];
  static List<Color> categoryColorList = [
    const Color(0xFF009900),
    const Color(0xFFe7eb34),
    const Color(0xFFFFA500),
    const Color(0xFFFF0000),
    const Color(0xFFAAAAAA)
  ];

  ///Recurrence of notification options
  static List<String> notificationRepeatOptionList = [
    AppLocalizations.of(context!)!.noRepeat,
    AppLocalizations.of(context!)!.daily,
    AppLocalizations.of(context!)!.weekly,
    "Monthly",
    "Yearly",
    "National"
  ];

  ///Notification schedule options
  static List<String> notificationScheduleOptionList = [
    AppLocalizations.of(context!)!.onTime,
    AppLocalizations.of(context!)!.fiveMinutesEarlier,
    AppLocalizations.of(context!)!.tenMinutesEarlier,
    AppLocalizations.of(context!)!.fifteenMinutesEarlier,
    AppLocalizations.of(context!)!.thirtyMinutesEarlier,
  ];

  ///region  TIME Related

  ///Generate unique user event id with combination of date information
  static String getUniqueEventId({DateTime? dateTime}) {
    DateTime now = dateTime ?? DateTime.now();
    String month = now.month < 10 ? "0${now.month}" : "${now.month}";
    String day = now.day > 9 ? "${now.day}" : "0${now.day}";
    String hour = now.hour > 9 ? "${now.hour}" : "0${now.hour}";
    String minute = now.minute > 9 ? "${now.minute}" : "0${now.minute}";
    String second = now.second > 9 ? "${now.second}" : "0${now.second}";
    // String _milliSecond = now.millisecond>9?"${now.millisecond}":"0${now.millisecond}";
    String id = "${now.year}$month$day$hour$minute$second";
    return id;
  }

  ///Returns unused value of sequential event ID number, if null then return 1
  static int? getNextEventNumber() {
    int? id = Globals.prefs!.getInt(Constants.NextEventIdNumber);
    if (id != null) {
      Globals.prefs!.setInt(Constants.NextEventIdNumber, ++id);
      return id;
    }
    //Next line executes if there is no id generated so far
    Globals.prefs!.setInt(Constants.NextEventIdNumber, 1);
    return 1;
  }

  ///Get 12 hour Ethiopian format time from Gregorian 24 hour format
  static LocalTime? getEtTimeFromGc24Time(DateTime? dt) {
    if (dt == null) return null;
    int hour;

    ///Init Et hour
    if (dt.hour < 7) {
      hour = dt.hour + 6;
    } else if (dt.hour < 19) {
      hour = dt.hour - 6;
    } else {
      hour = dt.hour - 18;
    }

    LocalTime et12HourFormatTime = LocalTime.hourMinute12(hour, dt.minute, getTimePeriod(dt.hour));
    return et12HourFormatTime;
  }

  ///Convert 24 hour format to 12 hour format of Gregorian time
  static LocalTime getGcTimeFromGc24Time(DateTime dt) {
    // if (dt == null) return null;

    int hour;

    ///Init Gc hour
    hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;

    LocalTime gc12HourFormatTime = LocalTime.hourMinute12(hour, dt.minute, getTimePeriod(dt.hour));
    return gc12HourFormatTime;
  }

  ///Get time period (AM, PM)
  static TimePeriod getTimePeriod(int hour24) {
    if (hour24 < 12) return TimePeriod.AM;
    return TimePeriod.PM;
  }

  ///Get formatted Ethiopian time hh:mm:period in string format
  static String getEtTimeDetails(hour) {
    LocalTime etTime = Globals.getEtTimeFromGc24Time(hour)!;
    String etTimeString = "${etTime.hour! < 10 ? "0${etTime.hour}" : "${etTime.hour}"} : "
        "${etTime.minute! > 9 ? "${etTime.minute}" : "0${etTime.minute}"}: ${MonthGlobals.timePeriodEt[etTime.period!.index]}";
    return etTimeString;
  }

  ///Get formatted Gregorian time hh:mm:period in string format
  static String getGcTimeDetails(hour) {
    LocalTime gcTime = Globals.getGcTimeFromGc24Time(hour);
    String gcTimeString = "${gcTime.hour! < 10 ? "0${gcTime.hour}" : "${gcTime.hour}"} : "
        "${gcTime.minute! > 9 ? "${gcTime.minute}" : "0${gcTime.minute}"}: ${MonthGlobals.timePeriodGc[gcTime.period!.index]}";
    return gcTimeString;
  }

  ///Get application showing theme
  static AppTheme getAppTheme() {
    String? theme = Globals.prefs!.getString(Constants.ThemePreference);
    if (theme == null || theme == "Light") {
      return AppTheme.light;
    } else {
      return AppTheme.dark;
    }
  }

  static String alarmIsSetFor_ = AppLocalizations.of(context!)!.alarmIsSetFor;
  static String days_ = AppLocalizations.of(context!)!.days;
  static String hour_ = AppLocalizations.of(context!)!.hour;
  static String minute_ = AppLocalizations.of(context!)!.minute;

  ///Type shows success or failure where as Time shows the duration of the time set from now
  ///eg. Notification is set after 2 days 4 hours and 56 seconds
  static void showSaveResultMessage(
      {BuildContext? context,
      SnackMessageType? type,
      String? message,
      required LocalDate gcDate,
      required LocalTime gcTime,
      LocalDate? etDate}) {
    DateTime now = DateTime.now();
    DateTime schedule = DateTime(gcDate.year!, gcDate.month!, gcDate.day!, gcTime.hour!, gcTime.minute!);

    Duration diff = schedule.difference(now);

    debugPrint("------ Alarm is set after: $diff");

    int dayResult = diff.inDays;
    int hourResult;
    hourResult = diff.inHours;
    hourResult %= 24;
    int minuteResult;
    minuteResult = diff.inMinutes;
    minuteResult %= 60;

    ///Remove zero values from string message
    String resultString = "$alarmIsSetFor_"
        "${dayResult > 0 ? " $dayResult $days_" : ""}"
        "${hourResult > 0 ? " $hourResult $hour_" : ""}"
        "${minuteResult > 0 ? " $minuteResult $minute_" : ""}";

    showSnack(context: context, type: type, message: resultString);
  }

  static void reinitializeGlobalsWithSelectedLanguage(BuildContext ctx) {
    categoryList = [
      AppLocalizations.of(context!)!.regular,
      AppLocalizations.of(context!)!.moderate,
      AppLocalizations.of(context!)!.important,
      AppLocalizations.of(context!)!.veryImportant
    ];

    categoryColorList = [
      const Color(0xFF009900),
      const Color(0xFFe7eb34),
      const Color(0xFFFFA500),
      const Color(0xFFFF0000),
      const Color(0xFFAAAAAA)
    ];

    notificationRepeatOptionList = [
      AppLocalizations.of(context!)!.noRepeat,
      AppLocalizations.of(context!)!.daily,
      AppLocalizations.of(context!)!.weekly,
      "Monthly",
      "Yearly",
      "National"
    ];

    notificationScheduleOptionList = [
      AppLocalizations.of(context!)!.onTime,
      AppLocalizations.of(context!)!.fiveMinutesEarlier,
      AppLocalizations.of(context!)!.tenMinutesEarlier,
      AppLocalizations.of(context!)!.fifteenMinutesEarlier,
      AppLocalizations.of(context!)!.thirtyMinutesEarlier
    ];

    ethiopianFixedHolidays = [
      AppLocalizations.of(context!)!.newYear,
      AppLocalizations.of(context!)!.meskel,
      AppLocalizations.of(context!)!.genna,
      AppLocalizations.of(context!)!.timket,
      AppLocalizations.of(context!)!.siklet,
      AppLocalizations.of(context!)!.fasika,
      AppLocalizations.of(context!)!.eidAlFitur,
      AppLocalizations.of(context!)!.mewlid,
      AppLocalizations.of(context!)!.eidAlAdha,
      AppLocalizations.of(context!)!.adwa,
      AppLocalizations.of(context!)!.ginbot20,
      AppLocalizations.of(context!)!.arbegnoch,
      AppLocalizations.of(context!)!.labaderoch
    ];
    alarmIsSetFor_ = AppLocalizations.of(context!)!.alarmIsSetFor;
    days_ = AppLocalizations.of(context!)!.days;
    hour_ = AppLocalizations.of(context!)!.hour;
    minute_ = AppLocalizations.of(context!)!.minute;
  }
}

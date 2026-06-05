// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_time_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String channelId = "13_MONTHS_DEFAULT_NOTIFICATION_CHANNEL";
const String channelName = "13 MONTHS DEFAULT NOTIFICATION CHANNEL";
const String channelDescription =
    "Notifications other than, user tasks, interests or company will be displayed under this channel.";

const String channelIdCompany = "COMPANY_NOTIFICATION_CHANNEL";
const String channelNameCompany = "COMPANY NOTIFICATION CHANNEL";
const String channelDescriptionCompany =
    "Notifications that comes from company that is providing the calendar service to you.";

const String channelIdInterest = "USER_INTEREST_NOTIFICATION_CHANNEL";
const String channelNameInterest = "USER INTEREST NOTIFICATION CHANNEL";
const String channelDescriptionInterest =
    "Notifications that shows based on your selection of interest in side of the app(subscribed interest topics)";

/// TODO: Configure to open notification landing page on notification tap
class NotificationService {
  static String? selectedNotificationPayload;
  static List<NotificationPayload> globalNotificationPayload = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Check if notification is granted for android and inform user what to do with UI
  Future<bool> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await NotificationService()
              .flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      return granted;
    }
    return false;
  }

  /// Request iOS or Android user to grant notification
  // Future<bool> requestPermissions() async {
  //   if (Platform.isIOS) {
  //     await NotificationService()
  //         .flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
  //         ?.requestPermissions(
  //           alert: true,
  //           badge: true,
  //           sound: true,
  //         );
  //     return true;
  //   } else if (Platform.isAndroid) {
  //     final AndroidFlutterLocalNotificationsPlugin? androidImplementation = NotificationService()
  //         .flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  //     final bool? grantedNotificationPermission = await androidImplementation?.requestPermission();
  //     return grantedNotificationPermission ?? false;
  //   }
  //   return false;
  // }

  /// Request iOS or Android user to grant notification
Future<bool> requestPermissions() async {
  if (Platform.isIOS) {
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        NotificationService()
            .flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final bool? granted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  } else if (Platform.isAndroid) {
    // For Android < 13 (API < 33), notifications are automatically granted
    if (await _isAndroid13OrAbove()) {
      // Use permission_handler to request runtime notification permission on Android 13+
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }
  return false;
}

/// Helper to check if device is Android 13+ (API 33+)
Future<bool> _isAndroid13OrAbove() async {
  if (!Platform.isAndroid) return false;
  final int sdkInt = await DeviceInfoPlugin().androidInfo.then((info) => info.version.sdkInt);
  return sdkInt >= 33;
}


  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  /// Notification Initialization
  Future<void> initNotifications() async {
    await _configureLocalTimeZone();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

    /// A notification action which triggers a App navigation event
    const String navigationActionId = 'id_3';

    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      //   // didReceiveLocalNotificationStream.add(
      //   //   ReceivedNotification(
      //   //     id: id,
      //   //     title: title,
      //   //     body: body,
      //   //     payload: payload,
      //   //   ),
      //   // );
      // },
      // notificationCategories: darwinNotificationCategories,
    );
    
    

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  ///Show notification right away (no schedule)
  Future<void> showNotification({title, body, payload, String? notificationSource}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    NotificationDetails nd = getNotificationDetails(notificationSource);
    debugPrint("------ Notification Payload: $payload");
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      nd,
      payload: payload,
    );
  }

  /// One-time Scheduler
  Future<void> zonedScheduleNotification(
      {required int id,
      required DateTime date,
      String? title,
      String? body,
      String? payload,
      String? notificationSource}) async {
    final int timeDiff = date.difference(DateTime.now()).inSeconds;
    debugPrint("------ Notification set in seconds: $timeDiff");
    debugPrint("------ Setting one-time notification with ID: $id");
    NotificationDetails nd = getNotificationDetails(notificationSource);

    await flutterLocalNotificationsPlugin
        .zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.now(tz.local).add(Duration(seconds: timeDiff)),
          nd,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        )
        .then((value) => debugPrint("------ One-time notification is set with ID: $id"));
  }

  /// Daily Notification Scheduler
  Future<void> scheduleDailyNotification({
    required int id,
    required LocalTime time,
    String? title,
    String? body,
    String? payload,
    String? notificationSource,
  }) async {
    debugPrint("------ Setting daily notification with ID: $id");
    NotificationDetails nd = getNotificationDetails(notificationSource);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDailyHour(time: time),
      nd,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint("------ Daily notification is set with ID: $id");
  }

  tz.TZDateTime _nextInstanceOfDailyHour({
    required LocalTime time,
  }) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour!, time.minute!);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Weekly Notification Scheduler

  Future<void> scheduleWeeklyNotification(
      {required int id,
      String? title,
      String? body,
      required DateTime date,
      required LocalTime time,
      String? payload,
      String? notificationSource}) async {
    debugPrint("------ Setting weekly notification with ID: $id");
    NotificationDetails nd = getNotificationDetails(notificationSource);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeeklyHour(date, time),
      nd,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    debugPrint("------ Weekly notification is set with ID: $id");
  }

  tz.TZDateTime _nextInstanceOfWeeklyHour(DateTime date, LocalTime time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfDailyHour(time: time);
    while (scheduledDate.weekday != date.weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancel Notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Notification Detail
  static NotificationDetails getNotificationDetails(String? incomingTopic) {
    // String? company = Globals.prefs!.getString(Constants.CompanyUserFollowing);
    String? company;
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    if (incomingTopic == null) {
      return NotificationDetails(
          android: AndroidNotificationDetails(channelId, channelName,
              channelDescription: channelDescription,
              enableVibration: true,
              vibrationPattern: vibrationPattern,
              enableLights: true,
              color: const Color.fromARGB(255, 255, 255, 255),
              ledColor: const Color.fromARGB(255, 255, 255, 255),
              ledOnMs: 1000,
              ledOffMs: 500));
    }
    if (incomingTopic == company) {
      return const NotificationDetails(
          android: AndroidNotificationDetails(channelIdCompany, channelNameCompany,
              channelDescription: channelDescriptionCompany));
    }
    return const NotificationDetails(
        android: AndroidNotificationDetails(channelIdInterest, channelNameInterest,
            channelDescription: channelDescriptionInterest));
  }

  Future<List<NotificationPayload>> getAllNotificationsList() async {
    List<NotificationPayload> allList = [];
    final List<PendingNotificationRequest> pendingNotificationList =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var pendingNotification in pendingNotificationList) {
      Map<String, dynamic> payloadMap = jsonDecode(pendingNotification.payload!);
      var payLoad = NotificationPayload.fromJson(payloadMap);

      NotificationPayload notificationPayload = NotificationPayload(
        id: pendingNotification.id,
        title: pendingNotification.title,
        body: pendingNotification.body,
        createdDateTime: payLoad.createdDateTime,
        scheduledDateTime: payLoad.scheduledDateTime,
        eventTagOption: payLoad.eventTagOption,
        scheduleOption: payLoad.scheduleOption,
        repeatOption: payLoad.repeatOption,
        gD: payLoad.gD,
        gM: payLoad.gM,
        gY: payLoad.gY,
        eD: payLoad.eD,
        eM: payLoad.eM,
        eY: payLoad.eY,
        weekday: payLoad.weekday,
        contentSource: payLoad.contentSource,
        topic: payLoad.topic,
        age: payLoad.age,
        icon: payLoad.icon,
        visible: payLoad.visible,
      );
      /*if (_notificationPayload.visible == 'true')*/
      allList.add(notificationPayload);
    }
    globalNotificationPayload.clear();
    globalNotificationPayload.addAll(allList);
    return allList;
  }

  Future<List<NotificationPayload>> getMonthNotifications(int? year, int? month) async {
    List<NotificationPayload> allList = [];
    allList = await getAllNotificationsList();
    List<NotificationPayload> monthList = [];
    for (var element in allList) {
      ///Show notifications "from" or "after" their schedule time month
      if (MonthGlobals.etShowingYear! >= element.eY!) {
        element.eM = Utility.getZeroOrNumber(element.eM) - 1;
        if (element.eY != MonthGlobals.etShowingYear ||
            (element.eY == MonthGlobals.etShowingYear && element.eM! <= MonthGlobals.etShowingMonth! - 1)) {
          ///Onetime notifications
          if (element.repeatOption == NotificationRepeatOption.noRecurrence) {
            if (element.eY == year && element.eM == month! - 1) {
              monthList.add(element);
            }
          } else {
            ///Repeating  notifications
            monthList.add(element);
          }
        }
      }
    }
    return monthList;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_time_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class LocalNotification {
  final String CHANNEL_ID = "13_MONTHS_DEFAULT_NOTIFICATION_CHANNEL";
  final String CHANNEL_NAME = "13 MONTHS DEFAULT NOTIFICATION CHANNEL";
  final String CHANNEL_DESCRIPTION =
      "Notifications other than, user tasks, interests or company will be displayed under this channel.";

  final String CHANNEL_ID_COMPANY = "COMPANY_NOTIFICATION_CHANNEL";
  final String CHANNEL_NAME_COMPANY = "COMPANY NOTIFICATION CHANNEL";
  final String CHANNEL_DESCRIPTION_COMPANY =
      "Notifications that comes from company that is providing the calendar service to you.";

  final String CHANNEL_ID_INTEREST = "USER_INTEREST_NOTIFICATION_CHANNEL";
  final String CHANNEL_NAME_INTEREST = "USER INTEREST NOTIFICATION CHANNEL";
  final String CHANNEL_DESCRIPTION_INTEREST =
      "Notifications that shows based on your selection of interest in side of the app(subscribed interest topics)";

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ///TODO: Commented
  // static final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
  //     BehaviorSubject<ReceivedNotification>();
  // static final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

  // static const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');
  static const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

  static String? selectedNotificationPayload;
  static List<NotificationPayload> globalNotificationPayload = [];

  static Future<void> _configureLocalTimeZone() async {
    ///TODO: Commented
    // tz.initializeTimeZones();
    // final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static Future<void> initLocalNotificationSettings() async {
    ///TODO: Commented
    // await _configureLocalTimeZone();
    // Globals.notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/launcher_icon');

    // final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
    //     requestAlertPermission: false,
    //     requestBadgePermission: false,
    //     requestSoundPermission: false,
    //     onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
    //       print("Payload.............. $payload");
    //       didReceiveLocalNotificationSubject
    //           .add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
    //     });
    // const MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings(
    //     requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);
    // final InitializationSettings initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: initializationSettingsMacOS);
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: (String? payload) async {
    //   if (payload != null) {
    //     debugPrint('notification payload: $payload');
    //   }
    //   selectedNotificationPayload = payload;
    //   selectNotificationSubject.add(payload);
    // });
  }

  static void requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void configureDidReceiveLocalNotificationSubject(BuildContext context) {
    ///TODO: Commented
    // didReceiveLocalNotificationSubject.stream.listen((ReceivedNotification receivedNotification) async {
    //   await showDialog(
    //     context: context,
    //     builder: (BuildContext context) => CupertinoAlertDialog(
    //       title: receivedNotification.title != null ? Text(receivedNotification.title!) : null,
    //       content: receivedNotification.body != null ? Text(receivedNotification.body!) : null,
    //       actions: <Widget>[
    //         CupertinoDialogAction(
    //           isDefaultAction: true,
    //           onPressed: () async {
    //             Navigator.of(context, rootNavigator: true).pop();
    //             await Navigator.push(
    //               context,
    //               MaterialPageRoute<void>(builder: (BuildContext context) => Container()
    //                   // SecondPage(receivedNotification.payload),
    //                   ),
    //             );
    //           },
    //           child: const Text('Ok'),
    //         )
    //       ],
    //     ),
    //   );
    // });
  }

  static void configureSelectNotificationSubject() {
    ///TODO: Commented
    // selectNotificationSubject.stream.listen((String? payload) async {
    //   // await Navigator.pushNamed(context, '/secondPage');
    // });
  }

  static void initPermission(BuildContext context) {
    requestPermissions();
    configureDidReceiveLocalNotificationSubject(context);
    configureSelectNotificationSubject();
  }

  ///CORE NOTIFICATION METHODS
  static NotificationDetails getNotificationDetails(String? incomingTopic) {
    String? company = Globals.prefs!.getString(Constants.CompanyUserFollowing);

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
            ledOffMs: 500),
      );
    }
    if (incomingTopic == company) {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          channelIdCompany,
          channelNameCompany,
          channelDescription: channelDescriptionCompany,
        ),
      );
    }
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        channelIdInterest,
        channelNameInterest,
        channelDescription: channelDescriptionInterest,
      ),
    );
  }

  ///Show notification right away (no schedule)
  static Future<void> showNotification({title, body, payload, String? notificationSource}) async {
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

  static Future<void> zonedScheduleNotification(
      {required int id,
      required DateTime date,
      String? title,
      String? body,
      String? payload,
      String? notificationSource}) async {
    final int timeDiff = date.difference(DateTime.now()).inSeconds;
    debugPrint("----- Scheduling Date Time Difference from Now = $timeDiff");

    NotificationDetails nd = getNotificationDetails(notificationSource);
    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: timeDiff)),
      nd,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleDailyNotification(
      {required int id,
      required LocalTime time,
      String? title,
      String? body,
      String? payload,
      String? notificationSource}) async {
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
      ///TODO: Checkout if datetimecomponents can solve daily and weekly notification triggered earlier
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfDailyHour({required LocalTime time}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour!, time.minute!);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  ///Weekly event scheduler
  static Future<void> scheduleWeeklyNotification(
      {required int id,
      String? title,
      String? body,
      required DateTime date,
      String? payload,
      String? notificationSource}) async {
    NotificationDetails nd = getNotificationDetails(notificationSource);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeeklyNotification(date),
      nd,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfWeeklyNotification(DateTime date) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTimeRecurrence(date);
    while (scheduledDate.weekday != date.weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static tz.TZDateTime _nextInstanceOfTimeRecurrence(DateTime date) {
    debugPrint("------ Year:${date.year}M:${date.month}D:${date.day}H:${date.hour}M:${date.minute}Day:${date.weekday}");
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, date.year, date.month, date.day, date.hour, date.minute);
    if (scheduledDate.isBefore(date)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> checkPendingNotificationRequests(BuildContext context) async {
    // final List<PendingNotificationRequest> pendingNotificationRequests =
    //     await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    // return showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) => AlertDialog(
    //     content: Column(
    //       children: [
    //         Text(
    //             'Title: ${pendingNotificationRequests.first.title} \n Body: ${pendingNotificationRequests.first.body}'),
    //         Text('Payload: ${pendingNotificationRequests.first.payload}')
    //       ],
    //     ),
    //     actions: <Widget>[
    //       FlatButton(
    //         onPressed: () {
    //           Navigator.of(context).pop();
    //         },
    //         child: const Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
    globalNotificationPayload = [];
    await getAllNotifications();
    await printAllNotifications();
  }

  static Future<void> getAllNotifications() async {
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
          visible: payLoad.visible);

      globalNotificationPayload.add(notificationPayload);
    }
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
        // element.eM -= 1;
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

  static Future<void> printAllNotifications() async {
    if (globalNotificationPayload == null) print("NO PENDING NOTIFICATION FOUND!");

    ///Print all pending notification that is saved as payload and decoded from json
    for (var pl in globalNotificationPayload) {
      debugPrint("------ id: ${pl.id}");
      debugPrint("------ title: ${pl.title}");
      debugPrint("------ body: ${pl.body}");
      debugPrint("------ createdDate: ${pl.createdDateTime!.month}");
      debugPrint("------ scheduledDate: ${pl.scheduledDateTime}");
      debugPrint("------ tag: ${pl.eventTagOption}");
      debugPrint("------ schedule: ${pl.scheduleOption}");
      debugPrint("------ repeat: ${pl.repeatOption}");
      debugPrint("------ gD: ${pl.gD}");
      debugPrint("------ gM: ${pl.gM}");
      debugPrint("------ gY: ${pl.gY}");
      debugPrint("------ eD: ${pl.eD}");
      debugPrint("------ eM: ${pl.eY}");
      debugPrint("------ eY: ${pl.body}");
      debugPrint("weekday: ${pl.weekday}");

      debugPrint("contentSource: ${pl.contentSource}");
      debugPrint("topic: ${pl.topic}");
      debugPrint("age: ${pl.age}");
      debugPrint("icon: ${pl.icon}");
      debugPrint("visible: ${pl.visible}");
    }
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

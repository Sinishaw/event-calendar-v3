import 'dart:convert';

import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/screens/company/widgets/content_detail_page.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FcmHandler {
  final BuildContext context;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FcmHandler(this.context) {
    messaging.getInitialMessage();
    debugPrint("------ Foreground Message Handler...");
    _getToken();
    _handleForegroundMessage();
  }

  _handleForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("------ Got a message whilst in the foreground!");
      debugPrint("------ Message data: ${message.data}");
      debugPrint("------ Message data is not empty: ${message.data.isNotEmpty}");
      debugPrint("------ Message data is not null: ${message.data.isNotEmpty}");
      debugPrint("------ Message iUrl: ${message.data["iUrl"]}");

      if (message.data["title"] != null && message.data["title"].toString().isNotEmpty) {
        debugPrint("------ Message also contained a notification: ${message.data["title"]}");
        Utility.cacheUserRelatedContents();
        try {
          bool notifyUser = message.data["notifyUser"] == "true" ? true : false;
          if (notifyUser) {
            CompanyContentModel content = _getNotificationModel(message);
            _showNotificationDialog(content);
          }
        } catch (e) {
          debugPrint("------ Error showing notification dialog!");
        }
        try {
          bool markOnCalendar = message.data["markOnCalendar"] == "true" ? true : false;
          if (markOnCalendar) _saveLocalNotification(message);
        } catch (e) {
          debugPrint("------ Error saving payload to local notification!");
        }
      }
    });
  }

  _getToken() async {
    messaging.getToken().then((value) => debugPrint("FCM TOKEN: $value"));
  }

  _showNotificationDialog(CompanyContentModel content) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.title!),
            Text("(${content.companyName})", style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ///TODO: Change the flutter logo with image loading indicator or placeholder
              content.imageUrl == null ? const FlutterLogo() : Image(image: NetworkImage(content.imageUrl!)),
              Text(content.body!, overflow: TextOverflow.ellipsis, maxLines: 5),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.clear,
                      size: 32,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(true);
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) {
                              FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                              FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                              return ContentDetailPage(
                                companyContentModel: content,
                                index: 0,
                                inAppDialogSource: true,
                              );
                            },
                          ));
                    },
                    child: Icon(Icons.read_more, size: 32, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _saveLocalNotification(RemoteMessage message) {
    try {
      int messageId = int.parse(message.data["id"]);
      DateTime scheduleDate = DateTime.parse(message.data["markDate"]).toLocal();
      LocalDate etScheduleDate =
          MonthModel.toEc(year: scheduleDate.year, month: scheduleDate.month, day: scheduleDate.day)!;

      NotificationPayload payload = NotificationPayload(
          id: messageId,
          title: message.data["title"],
          body: message.data["body"],
          createdDateTime: DateTime.now(),
          scheduledDateTime: scheduleDate,
          eventTagOption: EventTagOption.values
              .firstWhere((e) => e.toString().split(".").last.toLowerCase() == message.data["tagColor"]),
          repeatOption: NotificationRepeatOption.values
              .firstWhere((e) => e.toString().split(".").last == message.data["repeatOption"]),
          scheduleOption: NotificationScheduleOption.onTime,
          gD: scheduleDate.day,
          gM: scheduleDate.month,
          gY: scheduleDate.year,
          eD: etScheduleDate.day,
          eM: etScheduleDate.month,
          eY: etScheduleDate.year,
          weekday: scheduleDate.weekday,
          contentSource:
              ContentSource.values.firstWhere((e) => e.toString().split(".").last == message.data["contentSource"]),
          topic: message.data["topic"],
          age: int.parse(message.data["age"]),
          icon: message.data["logo"],
          visible: "true");

      String stringJsonPayload = json.encode(payload);

      NotificationService().zonedScheduleNotification(
          id: messageId,
          date: scheduleDate,
          title: message.data["title"],
          body: message.data["body"],
          payload: stringJsonPayload,
          notificationSource: message.data["topic"]);
    } catch (e) {
      debugPrint("------ Error setting notification from fcm payload!");
      debugPrint(e.toString());
      throw Exception(e);
    }
  }

  _getNotificationModel(RemoteMessage message) {
    DateTime frD = DateTime.parse(message.data["frD"]).toLocal();
    DateTime toD = DateTime.parse(message.data["toD"]).toLocal();
    DateTime markDate = DateTime.parse(message.data["markDate"]).toLocal();

    CompanyContentModel modelObj = CompanyContentModel(
      id: message.data["id"],
      title: message.data["title"],
      body: message.data["body"],
      logoUrl: message.data["logoUrl"],
      imageUrl: message.data["iUrl"],
      webUrl: message.data["wUrl"],
      videoUrl: message.data["vUrl"],
      companyName: message.data["companyName"],
      frD: frD.toString(),
      toD: toD.toString(),
      category: message.data["category"],
      topic: message.data["topic"],
      source: message.data["source"],
      tagColor: message.data["tagColor"],
      ageRestriction: message.data["ageRestriction"],
      company: message.data["company"],
      markOnCalendar: message.data["markOnCalendar"] == 'true' ? true : false,
      markDate: markDate.toString(),
    );

    return modelObj;
  }

  static subscribeUserToTopic(String topicName) async {
    FirebaseMessaging.instance.subscribeToTopic(topicName).then((value) {
      debugPrint("------ Subscription result SUCCESS");
    }).onError((dynamic error, stackTrace) {
      debugPrint("------ Subscription result SUCCESS");
    });
  }

  static unSubscribeUserFromTopic(String topicName) async {
    FirebaseMessaging.instance.unsubscribeFromTopic(topicName).then((value) {
      debugPrint("------ Un-Subscription result SUCCESS");
    }).onError((dynamic error, stackTrace) {
      debugPrint("------ Un-Subscription result SUCCESS");
    });
  }
}

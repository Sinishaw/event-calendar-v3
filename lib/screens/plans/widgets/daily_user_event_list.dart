// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/company_content.dart';
import 'package:event_calendar_v2/screens/events/models/fixed_national_events_detail.dart';
import 'package:event_calendar_v2/screens/events/models/holiday_and_national_events.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DailyUserEventList extends StatelessWidget {
  DailyUserEventList({super.key, this.selectedEtDate});

  final LocalDate? selectedEtDate;

  // final Function swipeAndDeleteTaskCallback;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<NotificationPayload> allNotificationPayloadList = [];
  final List<NotificationPayload> filteredNotificationPayloadList = [];

  Future<void> _getAllNotifications() async {
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

      if (notificationPayload.visible == 'true') allNotificationPayloadList.add(notificationPayload);
    }
  }

  Future<void> _getSingleDayNotifications() async {
    await _getAllNotifications();
    _getNationalDaysOfTheDay();

    ///Convert the local Ethiopian day tapped/selected for view - to Gregorian for easy filter
    LocalDate gcDateLocal =
        MonthModel.toGc(year: selectedEtDate!.year!, month: selectedEtDate!.month!, day: selectedEtDate!.day!)!;
    DateTime selectedGcDate = DateTime(gcDateLocal.year!, gcDateLocal.month!, gcDateLocal.day!);

    if (allNotificationPayloadList.isNotEmpty) {
      ///Onetime notification filter
      filteredNotificationPayloadList.addAll(allNotificationPayloadList.where((element) =>
          element.visible == 'true' &&
          element.repeatOption == NotificationRepeatOption.noRecurrence &&
          (element.gY == selectedGcDate.year &&
              element.gM == selectedGcDate.month &&
              element.gD == selectedGcDate.day)));

      ///Daily notification filter
      filteredNotificationPayloadList.addAll(allNotificationPayloadList.where((element) =>
          element.visible == 'true' &&
          element.repeatOption == NotificationRepeatOption.daily &&

          ///Version 2 Update
          element.scheduledDateTime!.isBefore(selectedGcDate.add(const Duration(days: 1)))));

      ///Weekly notifications filter
      filteredNotificationPayloadList.addAll(allNotificationPayloadList.where((element) =>
          element.visible == 'true' &&
          element.repeatOption == NotificationRepeatOption.weekly &&
          element.weekday == selectedGcDate.weekday &&

          ///Version 2 Update
          element.scheduledDateTime!.isBefore(selectedGcDate.add(const Duration(days: 1)))));

      debugPrint("------ NOW: ${selectedGcDate.weekday}");
      debugPrint("------ SCHEDULE ${allNotificationPayloadList[0].weekday}");
    }
  }

  _getNationalDaysOfTheDay() {
    List<FixedNationalEventsDetail> nd =
        HolidayAndNationalEvents.getDailHolidays(selectedEtDate!.year!, selectedEtDate!.month, selectedEtDate!.day);
    for (var element in nd) {
      NotificationPayload payload = NotificationPayload(
        title: element.name,
        icon: element.imageLocation,
        topic: "national",
        age: 3,
        contentSource: ContentSource.NationalEvent,
        eD: element.ecLocalDate!.day,
        eM: element.ecLocalDate!.month,
        eY: element.ecLocalDate!.year,
        gD: element.gcDate!.day,
        gM: element.gcDate!.month,
        gY: element.gcDate!.year,
        weekday: element.gcDate!.weekday,
        eventTagOption: EventTagOption.national,
        repeatOption: NotificationRepeatOption.national,
        createdDateTime: element.gcDate,
        body: element.nationalDayRef,
      );
      filteredNotificationPayloadList.add(payload);
    }
  }

  _eventImportancePicker(BuildContext context, NotificationPayload payload) {
    payload.eM = Utility.getZeroOrNumber(payload.eM) - 1;
    Widget eventRow;
    if (payload.contentSource == ContentSource.UserTask || payload.contentSource == ContentSource.NationalEvent) {
      eventRow = _nationalAndPersonalContentBuilder(context, payload);
    } else {
      eventRow = _companyAndTopicContentBuilder(context, payload);
    }
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: payload.contentSource != ContentSource.NationalEvent
          ? Dismissible(
              key: UniqueKey(),
              confirmDismiss: (direction) {
                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const FaIcon(FontAwesomeIcons.circleInfo),
                          Center(child: Text(AppLocalizations.of(context)!.confirmDeletion)),
                        ],
                      ),
                      content: Text('${AppLocalizations.of(context)!.areYouSureYouWantToDelete} (${payload.title})?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(false);
                          },
                          child: const FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(true);
                          },
                          child: const FaIcon(
                            FontAwesomeIcons.check,
                            size: 30,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              behavior: HitTestBehavior.opaque,
              background: Container(
                color: Colors.redAccent,
                child: ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: Text(
                      "Deleting Task ( ${payload.title} )",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              direction: DismissDirection.endToStart,
              dismissThresholds: const {DismissDirection.startToEnd: 0.6, DismissDirection.endToStart: 0.6},
              onDismissed: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart) {
                  debugPrint("------ Cancellation ${payload.title}");
                  int notificationId = payload.id!;
                  int notificationEarlyAlertId = payload.id! + 1;
                  await NotificationService().cancelNotification(notificationId);
                  await NotificationService().cancelNotification(notificationEarlyAlertId);
                } else {
                  ///TODO: Implement update in the second version of the app
                  debugPrint("------ Update ${payload.title}");
                }
              },
              child: eventRow,
            )
          : _nationalAndPersonalContentBuilder(context, payload),
    );
  }

  _nationalAndPersonalContentBuilder(BuildContext context, NotificationPayload payload) {
    return Container(
      color: payload.eventTagOption == EventTagOption.national
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Globals.categoryColorList[payload.eventTagOption!.index].withOpacity(0.1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: payload.eventTagOption == EventTagOption.national
                  ? Icon(
                      Icons.celebration,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.label_important,
                          size: 40.0,
                          color: Globals.categoryColorList[payload.eventTagOption!.index],
                        ),
                        const Icon(
                          Icons.notifications,
                          size: 12.0,
                        ),
                        // Icon(
                        //   payload.scheduleOption != NotificationScheduleOption.noNotification
                        //       ? Icons.notifications
                        //       : Icons.notifications_off,
                        //   size: 12.0,
                        //   // color: Globals.categoryColorList[payload.eventTagOption.index],
                        // ),
                      ],
                    ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payload.title!,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    ),
                  ),
                  Text(
                    payload.body != null ? payload.body! : "",
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontStyle: FontStyle.italic),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "${_getEventDateTimeDetail(payload)}",
                            style: TextStyle(fontSize: Globals.deviceHeight! > 700 ? 10 : 8),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _companyAndTopicContentBuilder(BuildContext context, NotificationPayload payload) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
                child: payload.icon != null && payload.icon!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: payload.icon!,
                        placeholder: (context, url) => ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 200),
                          child: Container(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.broken_image)),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      payload.title!,
                      maxLines: 1,
                      style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
                    ),
                  ),
                  Text(
                    payload.body!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontStyle: FontStyle.italic),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_getEventDateTimeDetail(payload)}",
                          style: TextStyle(fontSize: Globals.deviceHeight! > 700 ? 10 : 8),
                          softWrap: true,
                        ),
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                debugPrint("------ Content is clicked");
                                if (payload.contentSource == ContentSource.CompanyEvent ||
                                    payload.contentSource == ContentSource.TopicEvent) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const CompanyContentPage();
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "more...",
                                style: TextStyle(
                                    fontSize: Globals.deviceHeight! > 700 ? 12 : 10,
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getEventDateTimeDetail(NotificationPayload payload) {
    bool isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    String timeDetail = "";
    String dateDetail = "";

    String weekDay = "${MonthGlobals.etWeekNamesLong[payload.weekday! - 1]}";
    dateDetail =
        "${MonthGlobals.etMonthsLong[payload.eM!]} ${isGeezNumbers ? GeezNumbers.geezNumbers[payload.eD! - 1] : payload.eD}, ${isGeezNumbers ? GeezNumbers.geezYears[payload.eY! - 1900] : payload.eY}";

    ///Time is not included in national days
    if (payload.eventTagOption != EventTagOption.national) {
      timeDetail = Globals.getEtTimeDetails(payload.scheduledDateTime);
    }

    String formattedDate = "$weekDay $dateDetail $timeDetail";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getSingleDayNotifications(),
      builder: (context, snapshot) {
        debugPrint("------ LENGTH Internal: ${filteredNotificationPayloadList.length}");
        return ListView.builder(
          itemCount: filteredNotificationPayloadList.length,
          itemBuilder: (context, index) {
            if (index != filteredNotificationPayloadList.length - 1) {
              return _eventImportancePicker(context, filteredNotificationPayloadList[index]);
            } else {
              return Padding(
                ///Give some extra relaxing scroll space
                padding: const EdgeInsets.only(bottom: 150.0),
                child: _eventImportancePicker(context, filteredNotificationPayloadList[index]),
              );
            }
          },
        );
      },
    );
  }
}

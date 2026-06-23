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


class DailyUserEventList extends StatelessWidget {
  DailyUserEventList({super.key, this.selectedEtDate});

  final LocalDate? selectedEtDate;

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
          element.scheduledDateTime!.isBefore(selectedGcDate.add(const Duration(days: 1)))));

      ///Weekly notifications filter
      filteredNotificationPayloadList.addAll(allNotificationPayloadList.where((element) =>
          element.visible == 'true' &&
          element.repeatOption == NotificationRepeatOption.weekly &&
          element.weekday == selectedGcDate.weekday &&
          element.scheduledDateTime!.isBefore(selectedGcDate.add(const Duration(days: 1)))));
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

    if (payload.contentSource == ContentSource.NationalEvent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: eventRow,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: UniqueKey(),
          confirmDismiss: (direction) {
            return showDialog<bool>(
              context: context,
              barrierColor: Colors.black54,
              builder: (context) {
                final theme = Theme.of(context);
                final primary = theme.primaryColor;
                final isDark = theme.brightness == Brightness.dark;
                final onSurface = theme.colorScheme.onSurface;

                return Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.18),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Gradient accent header ─────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.redAccent.withValues(alpha: isDark ? 0.45 : 0.15),
                                  Colors.redAccent.withValues(alpha: isDark ? 0.20 : 0.05),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                // Delete icon in circle
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.confirmDeletion,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ── Thin accent divider ────────────────────────
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent.withValues(alpha: 0.5),
                                  Colors.redAccent.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // ── Body text ──────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            child: Text(
                              '${AppLocalizations.of(context)!.areYouSureYouWantToDelete} "${payload.title}"?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: onSurface.withValues(alpha: 0.65),
                                height: 1.5,
                              ),
                            ),
                          ),
                          // ── Action buttons ─────────────────────────────
                          Container(
                            height: 1,
                            color: onSurface.withValues(alpha: 0.08),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                // Cancel
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(context, rootNavigator: true).pop(false),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: onSurface.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                ),
                                // Vertical divider
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: onSurface.withValues(alpha: 0.08),
                                ),
                                // Delete
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(context, rootNavigator: true).pop(true),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          AppLocalizations.of(context)!.delete,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          behavior: HitTestBehavior.opaque,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              debugPrint("------ Cancellation ${payload.title}");
              int notificationId = payload.id!;
              int notificationEarlyAlertId = payload.id! + 1;
              await NotificationService().cancelNotification(notificationId);
              await NotificationService().cancelNotification(notificationEarlyAlertId);
            }
          },
          child: eventRow,
        ),
      ),
    );
  }

  _nationalAndPersonalContentBuilder(BuildContext context, NotificationPayload payload) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    Color categoryColor;
    if (payload.eventTagOption == EventTagOption.national) {
      categoryColor = primaryColor;
    } else {
      categoryColor = Globals.categoryColorList[payload.eventTagOption!.index];
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payload.eventTagOption == EventTagOption.national
                  ? Icons.celebration_rounded
                  : Icons.label_important_rounded,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payload.title!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (payload.body != null && payload.body!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payload.body!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // DateTime Row
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getEventDateTimeDetail(payload),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _companyAndTopicContentBuilder(BuildContext context, NotificationPayload payload) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              color: primaryColor.withOpacity(0.08),
              child: payload.icon != null && payload.icon!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: payload.icon!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image_not_supported_rounded, color: primaryColor, size: 20),
                    )
                  : Icon(Icons.business_rounded, color: primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payload.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (payload.body != null && payload.body!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payload.body!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getEventDateTimeDetail(payload),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "more...",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                padding: const EdgeInsets.only(bottom: 120.0),
                child: _eventImportancePicker(context, filteredNotificationPayloadList[index]),
              );
            }
          },
        );
      },
    );
  }
}

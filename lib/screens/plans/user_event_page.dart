import 'dart:convert';
import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/widgets/date_picker_dialog_local.dart';
import 'package:event_calendar_v2/shared/widgets/time_picker_dialog_local.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/models/local_time_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

import 'widgets/daily_user_event_list.dart';
import 'widgets/event_category_picker.dart';
import 'widgets/notification_repeat_picker.dart';
import 'widgets/notification_schedule_picker.dart';

class UserEventPage extends StatefulWidget {
  static const String routeName = '/user_events';
  const UserEventPage({super.key, this.title, this.selectedEtDate, this.fetchLatestEventsCallback});

  final String? title;
  final LocalDate? selectedEtDate;
  final Function? fetchLatestEventsCallback;

  bool get didNotificationLaunchApp => Globals.notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<UserEventPage> createState() => _UserEventPageState();
}

class _UserEventPageState extends State<UserEventPage> {
  String? eventTitle, eventNote;
  DateTime? initGcDate;
  LocalDate? _selectedEtDate, selectedGcDate;

  LocalTime? selectedEtTime, selectedGcTime, selectedGcTime24;
  int? scheduleGc24Hour;
  int? selectedEventTag, selectedRepeatOption, selectedNotificationSchedule;

  final _titleTextController = TextEditingController();
  final _bodyTextController = TextEditingController();
  late bool isGeezNumbers;

  getSelectedDateCallBack(LocalDate etSelectedDate, LocalDate gcSelectedDate) {
    setState(() {
      _selectedEtDate = etSelectedDate;
      selectedGcDate = gcSelectedDate;
    });
  }

  getSelectedTimeCallBack(LocalTime etSelectedTime, LocalTime gcSelectedTime, LocalTime gcSelectedTime24) {
    debugPrint("------ ~ ET Time: ${etSelectedTime.hour}: ${etSelectedTime.minute}: ${etSelectedTime.period}");
    debugPrint("------ ~ GC Time: ${gcSelectedTime.hour}: ${gcSelectedTime.minute}: ${gcSelectedTime.period}");

    setState(() {
      selectedEtTime = etSelectedTime;
      selectedGcTime = gcSelectedTime;
      selectedGcTime24 = gcSelectedTime24;
    });
  }

  getSelectedCategoryCallBack(int index) {
    setState(() {
      selectedEventTag = index;
    });
  }

  getSelectedRecurrenceCallBack(int index) {
    setState(() {
      selectedRepeatOption = index;
    });
  }

  getSelectedNotificationScheduleCallBack(int index) {
    setState(() {
      selectedNotificationSchedule = index;
    });
  }

  _resetEntry() {
    ///Set title and note to empty
    _titleTextController.clear();
    _bodyTextController.clear();

    ///Initialize date and time picker to current date and time
    _selectedEtDate = LocalDate.date();
    selectedGcDate = LocalDate.date();
    selectedEtTime = LocalTime.hourMinute12();
    selectedGcTime = LocalTime.hourMinute12();
    selectedGcTime24 = LocalTime.hourMinute24();

    LocalDate? gcDateConverted;
    if (widget.selectedEtDate != null) {
      gcDateConverted = MonthModel.toGc(
          year: widget.selectedEtDate!.year!, month: widget.selectedEtDate!.month!, day: widget.selectedEtDate!.day!);
    }

    DateTime gcDate = DateTime.now();
    selectedGcTime24!.hour = gcDate.hour;
    selectedGcTime24!.minute = gcDate.minute;

    selectedGcTime =
        LocalTime.hourMinute12(gcDate.hour, gcDate.minute, gcDate.hour < 12 ? TimePeriod.AM : TimePeriod.PM);

    if (gcDateConverted != null) {
      gcDate = DateTime(gcDateConverted.year!, gcDateConverted.month!, gcDateConverted.day!);
    }

    selectedGcDate!.year = gcDate.year;
    selectedGcDate!.month = gcDate.month;
    selectedGcDate!.day = gcDate.day;
    selectedGcDate!.weekDay = gcDate.weekday;

    LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    LocalDate etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!)!;

    _selectedEtDate!.year = etNow.year;
    _selectedEtDate!.month = etNow.month;
    _selectedEtDate!.day = etNow.day;
    _selectedEtDate!.weekDay = gcDate.weekday;

    ///Initialize default category selection [Normal Category]
    selectedEventTag = EventTagOption.regular.index;

    ///Initialize default category selection [Normal Category]
    selectedRepeatOption = NotificationRepeatOption.noRecurrence.index;

    ///Initialize default category selection [Normal Category]
    selectedNotificationSchedule = NotificationScheduleOption.onTime.index;

    debugPrint("------ ET Selected ${_selectedEtDate!.year} -${_selectedEtDate!.month} -${_selectedEtDate!.day}");
    debugPrint("------ GC Selected ${selectedGcDate!.year} -${selectedGcDate!.month} -${selectedGcDate!.day}");
  }

  _getEtSelectedDateString() {
    if (_selectedEtDate == null) return null;
    return "${MonthGlobals.etMonthsLong[_selectedEtDate!.month! - 1]} ${isGeezNumbers ? GeezNumbers.geezNumbers[_selectedEtDate!.day! - 1] : _selectedEtDate!.day} , ${isGeezNumbers ? GeezNumbers.geezYears[_selectedEtDate!.year! - 1900] : _selectedEtDate!.year} ";
  }

  _getGcSelectedDateString() {
    if (selectedGcDate == null) return null;
    return "${MonthGlobals.gcMonthsLong[selectedGcDate!.month! - 1]} ${selectedGcDate!.day} , ${selectedGcDate!.year} ";
  }

  _getEtSelectedTimeString() {
    String result = "--:--Error";
    if (selectedEtTime!.hour == null) {
      result = MonthGlobals.getCurrentTimeEt(DateTime.now());
    } else {
      String hour = isGeezNumbers
          ? GeezNumbers.geezNumbers[selectedEtTime!.hour! - 1]
          : selectedEtTime!.hour! < 9
              ? "0${selectedEtTime!.hour}"
              : "${selectedEtTime!.hour}";

      ///Zero does not exist for geez and following is statement should support that to prevent exception
      String minute = isGeezNumbers
          ? selectedEtTime!.minute! != 0
              ? GeezNumbers.geezNumbers[selectedEtTime!.minute! - 1]
              : "00"
          : selectedEtTime!.minute! > 9
              ? "${selectedEtTime!.minute}"
              : "0${selectedEtTime!.minute}";
      result = "$hour : $minute : ${MonthGlobals.timePeriodEt[selectedEtTime!.period!.index]}";
    }
    return result;
  }

  _getGcSelectedTimeString() {
    String result = "--:--Error";
    if (selectedGcTime!.hour == null) {
      result = MonthGlobals.getCurrentTimeEt(DateTime.now());
    } else {
      selectedGcTime!.hour = selectedGcTime!.hour! > 12 ? selectedGcTime!.hour! - 12 : selectedGcTime!.hour;
      String hour = selectedGcTime!.hour! < 9 ? "0${selectedGcTime!.hour}" : "${selectedGcTime!.hour}";
      String minute = selectedGcTime!.minute! > 9 ? "${selectedGcTime!.minute}" : "0${selectedGcTime!.minute}";
      result = "$hour : $minute : ${MonthGlobals.timePeriodGc[selectedGcTime!.period!.index]}";
    }
    return result;
  }

  _dateTimePickerRow() {
    Color? bc = Theme.of(context).textTheme.bodyLarge!.color;
    TextStyle ts = TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(AppLocalizations.of(context)!.date),
            Card(
                elevation: 3,
                shadowColor: Theme.of(context).textTheme.bodyLarge!.color,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: TextButton(
                    style: const ButtonStyle(),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        builder: (_) => DatePickerDialogLocal(
                            callback: getSelectedDateCallBack,
                            selectedEtDate: _selectedEtDate,
                            selectedGcDate: selectedGcDate),
                      );
                      debugPrint("------ Date clicked ${MonthGlobals.getCurrentDateEt()}");
                    },
                    child: Column(
                      children: [
                        Text(_getEtSelectedDateString() ?? MonthGlobals.getCurrentDateEt(), style: ts),
                        Text(
                          _getGcSelectedDateString() ?? MonthGlobals.getCurrentDateGc(),
                          style: TextStyle(fontSize: 10, color: bc),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        Column(
          children: [
            Text(AppLocalizations.of(context)!.time),
            Card(
              elevation: 3,
              shadowColor: Theme.of(context).textTheme.bodyLarge!.color,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    showDialog(
                        context: context,
                        builder: (_) {
                          return TimePickerDialogLocal(
                              timeSetterCallback: getSelectedTimeCallBack, initialGcTime: selectedGcTime);
                        });
                  },
                  child: Column(
                    children: [
                      Text(_getEtSelectedTimeString(), style: ts),
                      Text(
                        _getGcSelectedTimeString(),
                        style: TextStyle(fontSize: 10, color: bc!),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  _eventImportancePicker() {
    return Card(
      elevation: 0,
      color: Globals.categoryColorList[selectedEventTag!].withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          Icons.label_important,
          size: 32.0,
          color: Globals.categoryColorList[selectedEventTag!],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.importanceTag,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              Globals.categoryList[selectedEventTag!],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          showDialog(
              context: context,
              builder: (_) {
                return EventCategoryPicker(
                  selectedOption: selectedEventTag,
                  callback: getSelectedCategoryCallBack,
                );
              });
        },
      ),
    );
  }

  _repeatNotificationPicker() {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.repeat, size: 32.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.repeatNotification,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              Globals.notificationRepeatOptionList[selectedRepeatOption!],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          showDialog(
              context: context,
              builder: (_) {
                return NotificationRepeatPicker(
                    selectedOption: selectedRepeatOption, callback: getSelectedRecurrenceCallBack);
              });
        },
      ),
    );
  }

  _notificationSchedulePicker() {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.notifications, size: 32.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.scheduleNotification,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              Globals.notificationScheduleOptionList[selectedNotificationSchedule!],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          showDialog(
              context: context,
              builder: (_) {
                return NotificationSchedulePicker(
                  selectedOption: selectedNotificationSchedule,
                  callback: getSelectedNotificationScheduleCallBack,
                );
              });
        },
      ),
    );
  }

  bool _isEntryValid(DateTime gcSelectedDateTime) {
    String? message;
    bool isValidEntry = true;

    debugPrint("------ Title Controller Value: ${_titleTextController.value}");

    ///Prevent from scheduling passed date
    if (gcSelectedDateTime.isBefore(DateTime.now())) {
      message = AppLocalizations.of(context)!.pleaseSelectFutureDateOnly;
      isValidEntry = false;
    }
    if (_titleTextController.text.isEmpty) {
      message = AppLocalizations.of(context)!.eventTitleIsRequired;
      isValidEntry = false;
    }
    if (!isValidEntry) {
      Globals.showSnack(
        context: context,
        type: SnackMessageType.warning,

        ///TODO: Get message from language config file
        message: message,
      );
    }

    return isValidEntry;
  }

  _saveEvent() async {
    List<int> minutesList = [0, 5, 10, 15, 30];

    debugPrint("------ SelectedNotificationScheduleMin: ${minutesList[selectedNotificationSchedule!]}");
    DateTime scheduleDate = DateTime(selectedGcDate!.year!, selectedGcDate!.month!, selectedGcDate!.day!,
        selectedGcTime24!.hour!, selectedGcTime24!.minute!);

    DateTime validationDate = DateTime(selectedGcDate!.year!, selectedGcDate!.month!, selectedGcDate!.day!,
            selectedGcTime24!.hour!, selectedGcTime24!.minute!)
        .subtract(Duration(minutes: minutesList[selectedNotificationSchedule!]));

    ///Validate entry and exit operation if entry is invalidated
    if (!_isEntryValid(validationDate)) return;

    bool alertOnly = false;

    for (int i = 0; i < 2; i++) {
      ///Get unique next sequence of event Id
      int? id = Globals.getNextEventNumber();

      if (i == 0) {
        alertOnly = false;
      } else {
        if (minutesList[selectedNotificationSchedule!] > 0) {
          alertOnly = true;
          selectedGcTime24!.hour = validationDate.hour;
          selectedGcTime24!.minute = validationDate.minute;
        } else {
          break;
        }

        ///To differentiate between same message by jumping one offset (helps to cancel alerts only)
        Globals.getNextEventNumber();
      }

      NotificationPayload payload = _getNotificationPayload(
          id: id, gcSelectedDateTime: alertOnly ? validationDate : scheduleDate, alertOnly: alertOnly);
      String stringJsonPayload = jsonEncode(payload);

      switch (payload.repeatOption) {
        case NotificationRepeatOption.noRecurrence:
          {
            ///TODO: These notifications automatically deleted after they are triggered, so preserve using local json
            ///Notification source is null to indicate it belongs to user and not from company or user interest/topic
            await NotificationService().zonedScheduleNotification(
                id: id!,
                title: eventTitle,
                body: eventNote,
                date: alertOnly ? validationDate : scheduleDate,
                payload: stringJsonPayload,
                notificationSource: null);

            ///Update slide up holiday at home page month view
            if (widget.fetchLatestEventsCallback != null) widget.fetchLatestEventsCallback!();
          }
          break;
        case NotificationRepeatOption.daily:
          {
            debugPrint('------ Setting Daily Notification... ');

            ///Notification source is null to indicate it belongs to user and not from company or user interest/topic
            await NotificationService().scheduleDailyNotification(
                id: id!,
                time: selectedGcTime24!,
                title: eventTitle,
                body: eventNote,
                payload: stringJsonPayload,
                notificationSource: null);
            if (widget.fetchLatestEventsCallback != null) widget.fetchLatestEventsCallback!();
            debugPrint('------ Daily Notification is Set');
          }
          break;
        case NotificationRepeatOption.weekly:
          {
            ///Notification source is null to indicate it belongs to user and not from company or user interest/topic
            await NotificationService().scheduleWeeklyNotification(
                id: id!,
                title: eventTitle,
                body: eventNote,
                date: alertOnly ? validationDate : scheduleDate,
                time: selectedGcTime24!,
                payload: stringJsonPayload,
                notificationSource: null);
            if (widget.fetchLatestEventsCallback != null) widget.fetchLatestEventsCallback!();
          }
          break;

        default:
          return;
      }
    }
    setState(() {
      Globals.showSaveResultMessage(
          context: context,
          type: SnackMessageType.success,
          message: "",
          gcDate: selectedGcDate!,
          gcTime: selectedGcTime24!,
          etDate: _selectedEtDate);
      _resetEntry();
    });
  }

  NotificationPayload _getNotificationPayload({int? id, required DateTime gcSelectedDateTime, bool alertOnly = false}) {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime now = DateTime.now();

    ///Construct the payload that would attach to local notification scheduler
    NotificationPayload payload = NotificationPayload(
        id: id,
        title: eventTitle,
        body: eventNote,
        createdDateTime: now,
        scheduledDateTime: gcSelectedDateTime,
        eventTagOption: EventTagOption.values[selectedEventTag!],
        scheduleOption: NotificationScheduleOption.values[selectedNotificationSchedule!],
        repeatOption: NotificationRepeatOption.values[selectedRepeatOption!],
        gD: gcSelectedDateTime.day,
        gM: gcSelectedDateTime.month,
        gY: gcSelectedDateTime.year,
        eD: _selectedEtDate!.day,
        eM: _selectedEtDate!.month,
        eY: _selectedEtDate!.year,
        weekday: gcSelectedDateTime.weekday,
        contentSource: ContentSource.UserTask,
        topic: "personal",
        age: 3,
        visible: alertOnly ? 'false' : 'true');
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    Color? tc = Theme.of(context).textTheme.bodyLarge!.color;
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    double height = queryData.size.height - AppBar().preferredSize.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addNewEventOrTask),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Card(
                child: TextButton.icon(
                    onPressed: () => _saveEvent(),
                    onLongPress: () => NotificationService().cancelAllNotifications(),
                    icon: Icon(
                      Icons.save,
                      color: tc,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: tc, fontSize: 10),
                    )),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.title),
              title: TextField(
                controller: _titleTextController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.titleRequired,
                  suffixIcon: IconButton(
                    onPressed: () => _titleTextController.clear(),
                    icon: const Icon(Icons.clear),
                  ),
                ),
                onChanged: (value) => eventTitle = value,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: TextField(
                controller: _bodyTextController,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.note,
                  suffixIcon: IconButton(
                    onPressed: () => _bodyTextController.clear(),
                    icon: const Icon(Icons.clear),
                  ),
                ),
                onChanged: (value) => eventNote = value,
              ),
            ),
            const Divider(),
            _dateTimePickerRow(),
            _eventImportancePicker(),
            _notificationSchedulePicker(),
            _repeatNotificationPicker(),
            Card(
                elevation: 3,
                shadowColor: Theme.of(context).textTheme.bodyLarge!.color,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                      isGeezNumbers
                          ? "${GeezNumbers.geezNumbers[_selectedEtDate!.day! - 1]} ${MonthGlobals.etWeekNamesLong[selectedGcDate!.weekDay! - 1]}"
                          : "${_selectedEtDate!.day! > 9 ? "${_selectedEtDate!.day}" : "0${_selectedEtDate!.day}"} ${MonthGlobals.etWeekNamesLong[selectedGcDate!.weekDay! - 1]}",
                      style: Theme.of(context).textTheme.headlineSmall),
                )),
            const Divider(),
            SizedBox(
              height: height / 3,
              child: DailyUserEventList(
                selectedEtDate: _selectedEtDate,
                // swipeAndDeleteTaskCallback: swipeAndDeleteTaskCallback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  isAndroidGranted() async {
    bool isNotificationEnabled = await NotificationService().isAndroidPermissionGranted();
    if (!isNotificationEnabled) {
      setState(
        () {
          //Not implemented
          /// TODO: Notify user that the notification is not enabled
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    ///TODO: It is important to add a page to inform user what notifications mean before poping the allow dialog
    // isAndroidGranted();
    NotificationService().requestPermissions();

    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _resetEntry();
  }

  @override
  void dispose() {
    ///TODO: Commented
    // LocalNotification.didReceiveLocalNotificationSubject.close();
    // LocalNotification.selectNotificationSubject.close();
    super.dispose();
  }
}

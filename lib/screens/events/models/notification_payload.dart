import 'package:event_calendar_v2/shared/enums.dart';

class NotificationPayload {
  int? id;
  String? title, body, topic, icon;
  DateTime? createdDateTime, scheduledDateTime;
  EventTagOption? eventTagOption;
  NotificationScheduleOption? scheduleOption;
  NotificationRepeatOption? repeatOption;
  ContentSource? contentSource;

  int? gD, gM, gY, eD, eM, eY, weekday, age;
  String? visible;

  NotificationPayload(
      {this.id,
      this.title,
      this.body,
      this.createdDateTime,
      this.scheduledDateTime,
      this.eventTagOption,
      this.scheduleOption,
      this.repeatOption,
      this.gD,
      this.gM,
      this.gY,
      this.eD,
      this.eM,
      this.eY,
      this.weekday,
      this.contentSource,
      this.topic,
      this.age,
      this.icon,
      this.visible});

  NotificationPayload.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        body = json['body'],
        createdDateTime = DateTime.parse(json['createdDateTime']),
        scheduledDateTime = DateTime.parse(json['scheduledDateTime']),
        eventTagOption = EventTagOption.values[json['eventTagOption']],
        scheduleOption = NotificationScheduleOption.values[json['scheduleOption']],
        repeatOption = NotificationRepeatOption.values[json['repeatOption']],
        gD = json['gD'],
        gM = json['gM'],
        gY = json['gY'],
        eD = json['eD'],
        eM = json['eM'],
        eY = json['eY'],
        weekday = json['weekday'],
        contentSource = ContentSource.values[json['contentSource']],
        topic = json['topic'],
        age = json['age'],
        icon = json['icon'],
        visible = json['visible'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdDateTime': createdDateTime!.toIso8601String(),
        'scheduledDateTime': scheduledDateTime!.toIso8601String(),
        'eventTagOption': eventTagOption!.index,
        'scheduleOption': scheduleOption!.index,
        'repeatOption': repeatOption!.index,
        'gD': gD,
        'gM': gM,
        'gY': gY,
        'eD': eD,
        'eM': eM,
        'eY': eY,
        'weekday': weekday,
        'contentSource': contentSource!.index,
        'topic': topic,
        'age': age,
        'icon': icon,
        'visible': visible,
      };
}

import 'package:event_calendar_v2/shared/enums.dart';

class LocalTime {
  int? hour, minute, second, microsecond;
  TimePeriod? period;

  LocalTime.hourMinute12([this.hour, this.minute, this.period]);

  LocalTime.hourMinuteSecond12([this.hour, this.minute, this.second, this.period]);

  LocalTime.hourMinute24({this.hour, this.minute});
}

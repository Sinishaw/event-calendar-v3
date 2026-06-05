import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';

class FixedNationalEventsDetail {
  FixedNationalEventsDetail(
      {this.nationalDayRef,
      this.name,
      this.description,
      this.gcDate,
      this.gcLocalDate,
      this.ecLocalDate,
      this.imageLocation,
      this.holidayType});

  String? nationalDayRef;
  String? name;
  String? description;
  DateTime? gcDate;
  LocalDate? gcLocalDate;
  LocalDate? ecLocalDate;
  String? imageLocation;
  HolidayType? holidayType;
}

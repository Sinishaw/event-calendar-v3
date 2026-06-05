class LocalDate {
  int? year, month, day, hour, minute, second, microSecond, weekDay;
  static int? yearSt;

  LocalDate.date([this.year, this.month, this.day]);

  LocalDate.datetime(this.year, this.month, this.day, this.hour, this.minute, this.second, this.microSecond);

  LocalDate.detailed(this.year, this.month, this.day, this.weekDay,
      [this.hour, this.minute, this.second, this.microSecond]);
}

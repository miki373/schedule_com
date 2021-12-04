extension SCDateTimeExtension on DateTime {
  DateTime setHour(int hour) => DateTime(year, month, day, hour);

  DateTime setMinute(int minute) => DateTime(year, month, day, hour, minute);

  DateTime setSecond(int second) => DateTime(year, month, day, hour, minute, second);

  DateTime setTime(String time) {
    List<int> hourMinute = time.split(':').map((e) => int.parse(e)).toList();
    return setHour(hourMinute[0]).setMinute(hourMinute[1]);
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
const int minutesInDay = 1440;
const int minutesInHour = 60;

class DateTimeHelper {
  late final DateTime dateTime;

  DateTimeHelper({required this.dateTime});

  // returns [TimeLeft] which contains detailed
  // information about how much time is left between dateTime and other [DateTime]
  TimeLeft timeLeftFrom(DateTime otherDate) {
    int totalMinutes = dateTime.difference(otherDate).inMinutes;
    bool isNegative = totalMinutes.isNegative;
    int minutes = 0;
    int hours = 0;
    int days = 0;
    if (totalMinutes > minutesInDay) {
      days = (totalMinutes / minutesInDay).floor();
      totalMinutes -= days * minutesInDay;
    }
    if (totalMinutes > minutesInHour) {
      hours = (totalMinutes / minutesInHour).floor();
      totalMinutes -= hours * minutesInHour;
    }
    minutes = totalMinutes;

    return TimeLeft(
      days: days,
      hours: hours,
      minutes: minutes,
      hasPassed: isNegative,
    );
  }

  // Returns [TimeLeft] from not to dateTime
  TimeLeft timeLeftFromNow() => timeLeftFrom(DateTime.now());

  String prettyPrint() => DateFormat('EEEE, MMM d').format(dateTime);

  String time(BuildContext context, {DateTime? otherDateTime}) => TimeOfDay.fromDateTime(otherDateTime ?? dateTime).format(context);
}

class TimeLeft {
  final int days;
  final int minutes;
  final int hours;
  final bool hasPassed;

  const TimeLeft(
      {required this.days,
      required this.minutes,
      required this.hours,
      required this.hasPassed});
}

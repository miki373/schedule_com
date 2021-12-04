import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:schedule_com/app/methods/date_time_extensions.dart';

const String _url = 'schedule.lehighhanson.com';
const String _apiAccessPoint = '/MyScheduleOndemand/api/Schedule';

class SCSchedule {
  final String pin;
  final String userId;
  bool hasError = false;

  final List<SCScheduleData> _scheduleData = [];
  late SCUserData _userData;

  SCSchedule({
    required this.pin,
    required this.userId,
  });

  Uri get _uri => Uri.https(
        _url,
        _apiAccessPoint,
        {'pin': pin, 'userId': userId},
      );

  Future<void> fetch() async {
    http.Response response = await http.get(_uri);
    _parse(response.body);
  }

  void _parse(String responseBody) {
    Map decoded = convert.jsonDecode(responseBody);
    List schedules = decoded['ScheduleInfo'];
    Map employeeInfo = decoded['EmployeeInfo'][0];

    _userData = SCUserData(
      name: employeeInfo['firstName'] + ' ' + employeeInfo['lastName'],
      pin: employeeInfo['pin'],
      userId: employeeInfo['userId'],
      employeeId: employeeInfo['employeeId'],
    );

    for (var schedule in schedules) {
      if (schedule['militaryStartTime'] == null) {
        _scheduleData.add(SCScheduleData(
            isScheduled: false,
            startDateTime: DateTime.parse(schedule['scheduleDate'])));
      } else {
        DateTime startDateTime = DateTime.parse(schedule['scheduleDate'])
            .setTime(schedule['militaryStartTime']);
        _scheduleData.add(SCScheduleData(
            isScheduled: true,
            startDateTime: startDateTime,
            vehicle: schedule['vehicle'].toString(),
            location: schedule['location']));
      }
    }
  }

  List<SCScheduleData> get scheduleData => _scheduleData;

  SCUserData get userData => _userData;
}

class SCScheduleData {
  final bool isScheduled;
  final DateTime? startDateTime;
  final String? vehicle;
  final String? location;

  const SCScheduleData(
      {required this.isScheduled,
      this.startDateTime,
      this.vehicle,
      this.location});
}

class SCUserData {
  final String name;
  final int employeeId;
  final int userId;
  final int pin;

  SCUserData({
    required this.name,
    required this.employeeId,
    required this.userId,
    required this.pin,
  });
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:schedule_com/app/methods/schedule_fetch.dart';
import 'package:schedule_com/app/methods/weather.dart';
import 'package:schedule_com/app/on_not_logged_in.dart';
import 'package:schedule_com/app/utilities/storage.dart';
import 'package:schedule_com/app/methods/temporal.dart';


class OnLoggedIn extends StatefulWidget {

  final String pin;
  final String userId;

  const OnLoggedIn({Key? key, required this.pin, required this.userId})
      : super(key: key);

  @override
  State<OnLoggedIn> createState() => _OnLoggedInState();
}

class _OnLoggedInState extends State<OnLoggedIn> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future getStartTime({required String userId, required String pin}) async {
    SCSchedule scSchedule = SCSchedule(pin: pin, userId: userId);
    try {
      Map parsedData = {'schedule': [], 'userData': null };
      await scSchedule.fetch();
      List<SCScheduleData> schedules = scSchedule.scheduleData;
      parsedData['userData'] = scSchedule.userData;
      for (SCScheduleData schedule in schedules) {
        if (schedule.isScheduled) {
          SCWeather scWeather = SCWeather(dateTime: schedule.startDateTime ?? DateTime.now());
          await scWeather.fetch();
          (parsedData['schedule'] as List).add({'scheduleData': schedule, 'weatherData': scWeather.weatherData});
        }else{
          (parsedData['schedule'] as List).add({'scheduleData': schedule});
        }
      }
      return parsedData; // schedules;
    } catch (e) {
      return e;
    }
  }

  Future _refresh() {
    return Future.delayed(
        const Duration(milliseconds: 0), () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          actions: [
            Center(
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                ),
                onPressed: () async {
                  await SCStorage().clearAll();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const OnNotLoggedIn(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        body: FutureBuilder(
          future: getStartTime(userId: widget.userId, pin: widget.pin),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                onRefresh: () => _refresh(),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          for (Map schedule in snapshot.data['schedule'])
                            ((schedule['scheduleData'] as SCScheduleData).isScheduled)?SCScheduleDisplay(
                              weatherData: schedule['weatherData'] as SCWeatherData,
                              scheduleData:  schedule['scheduleData'] as SCScheduleData,
                            ): SCNoScheduleDisplay(scheduleData:  schedule['scheduleData'] as SCScheduleData)
                        ],
                      ),
                    ),
                    SCUserInformationDisplay(userData: snapshot.data['userData'] as SCUserData,)
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return const SCError();
            } else {
              return const SCSpinner();
            }
          },
        ),
      ),
    );
  }
}



class SCError extends StatelessWidget {
  const SCError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('There was a network error'),
    );
  }
}

class SCSpinner extends StatelessWidget {
  const SCSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 60,
        width: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class SCUserInformationDisplay extends StatelessWidget {
  final SCUserData userData;
  const SCUserInformationDisplay({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${userData.name} (${userData.employeeId.toString()}) '),
          Text(userData.userId.toString())
        ],
      ),
    );
  }
}

class SCNoScheduleDisplay extends StatelessWidget {
  final SCScheduleData scheduleData;
  const SCNoScheduleDisplay({Key? key, required this.scheduleData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('You are not scheduled on ${scheduleData.startDateTime}'),
    );
  }
}



class SCScheduleDisplay extends StatefulWidget {
  final SCScheduleData scheduleData;
  final SCWeatherData weatherData;

  const SCScheduleDisplay(
      {Key? key,
        required this.scheduleData,
        required this.weatherData,

      })
      : super(key: key);

  @override
  _SCScheduleDisplayState createState() => _SCScheduleDisplayState();
}

class _SCScheduleDisplayState extends State<SCScheduleDisplay> {
  late DateTimeHelper _dateTimeHelper;
  late double _backgroundOpacity;
  late TimeLeft _timeLeft;

  @override
  void initState() {
    super.initState();
    _dateTimeHelper = DateTimeHelper(dateTime: widget.scheduleData.startDateTime ?? DateTime.now());
    _backgroundOpacity = Random().nextDouble();
    _timeLeft = _dateTimeHelper.timeLeftFromNow();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _timeLeft.hasPassed? .5: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        color: Colors.black.withOpacity(_backgroundOpacity),
        child: Column(
          children: [
            Text(
              _dateTimeHelper.prettyPrint(),
              style: const TextStyle(color: Colors.white54),
            ),
            const Divider(
              indent: 16.0,
              endIndent: 16.0,
            ),
            const Text(
              'Time',
              style: TextStyle(color: Colors.white38),
            ),
            Text(
              _dateTimeHelper.time(context),
              style: const TextStyle(fontSize: 36.0),
            ),
            const Divider(
              indent: 16.0,
              endIndent: 16.0,
            ),
            const Text(
              'Location',
              style: TextStyle(color: Colors.white38),
            ),
            Text(
              widget.scheduleData.location ?? '',
              style: const TextStyle(fontSize: 36.0),
            ),
            if (!_timeLeft.hasPassed) ...[
              const Divider(
                indent: 16.0,
                endIndent: 16.0,
              ),
              const Text(
                'Time Left',
                style: TextStyle(color: Colors.white38),
              ),
              Text(
                '${_timeLeft.days > 0 ? _timeLeft.days.toString() + 'd ' : ''}${_timeLeft.hours > 0 ? _timeLeft.hours.toString() + 'h ' : ''}${_timeLeft.minutes > 0 ? _timeLeft.minutes.toString() + 'm ' : ''}',
                style: const TextStyle(fontSize: 36.0),
              ),
            ],
            if (widget.scheduleData.vehicle != 'null') ...[
              const Divider(
                indent: 16.0,
                endIndent: 16.0,
              ),
              const Text('Vehicle'),
              Text(widget.scheduleData.vehicle ?? ''),
            ],
            const Divider(
              indent: 16.0,
              endIndent: 16.0,
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Sleep At',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(
                        _dateTimeHelper.time(
                          context,
                          otherDateTime: widget.scheduleData.startDateTime!
                              .subtract(const Duration(hours: 9)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Wake Up At',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(
                        _dateTimeHelper.time(
                          context,
                          otherDateTime: widget.scheduleData.startDateTime!
                              .subtract(const Duration(hours: 1)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Leave At',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(
                        _dateTimeHelper.time(
                          context,
                          otherDateTime: widget.scheduleData.startDateTime!
                              .subtract(const Duration(minutes: 15)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              indent: 16.0,
              endIndent: 16.0,
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Temp',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text('${widget.weatherData.temp}c')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Feels Like',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text('${widget.weatherData.feelsLike}c')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Wind Speed',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(
                          '${widget.weatherData.windSpeed}km/h'
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              indent: 16.0,
              endIndent: 16.0,
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Condition',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(widget.weatherData.condition)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Sunrise',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(
                          widget.weatherData.sunrise
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Is Dark',
                        style: TextStyle(color: Colors.white38),
                      ),
                      Text(
                          widget.weatherData.isDark? 'Yes': 'No'
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

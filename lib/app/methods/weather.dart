import 'dart:convert' as convert;
import 'package:http/http.dart' as http;


class SCWeather {
  static const String _apiKey = 'yourapikey';
  static const String _url = 'api.weatherapi.com';
  static const String _apiVersionSelector = 'v1/forecast.json';
  final DateTime dateTime;
  late final SCWeatherData _weatherData;

  SCWeather({required this.dateTime});

  Uri get _uri => Uri.https(
        _url,
        _apiVersionSelector,
        {
          'key': _apiKey,
          'q': 'S4V',
          'unixdt': dateTime.millisecondsSinceEpoch.toString(),
          'hour': '6',
        },
      );

  Future<void> fetch() async {
    http.Response _response = await http.get(_uri);
    if (_response.statusCode == 200) {
      try {
        _parse(_response.body);
      } catch (e) {
        rethrow;
      }
    } else {
      throw 'Unable to fetch weather data';
    }
  }

  void _parse(String responseBody) {
    Map weatherOnDate =
        convert.jsonDecode(responseBody)['forecast']['forecastday'][0];
    _weatherData = SCWeatherData(
      sunrise: weatherOnDate['astro']['sunrise'],
      temp: weatherOnDate['hour'][0]['temp_c'],
      feelsLike: weatherOnDate['hour'][0]['feelslike_c'],
      windSpeed: weatherOnDate['hour'][0]['wind_kph'],
      condition: weatherOnDate['hour'][0]['condition']['text'],
      isDark: weatherOnDate['hour'][0]['is_day'] == 0,
    );
  }

  SCWeatherData get weatherData => _weatherData;
}

class SCWeatherData {
  final String sunrise;
  final bool isDark;
  final String condition;
  final double temp;
  final double feelsLike;
  final double windSpeed;

  SCWeatherData({
    required this.sunrise,
    required this.isDark,
    required this.condition,
    required this.temp,
    required this.feelsLike,
    required this.windSpeed,
  });
}

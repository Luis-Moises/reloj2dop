import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherData {
  final double humidity;

  WeatherData({
    required this.humidity,
  });
}


//API_KEY: 7ee0d8256e7b4c16fbeeb3841b5d0919

class WeatherService {
  final _weather = WeatherFactory('7ee0d8256e7b4c16fbeeb3841b5d0919');

  Future<WeatherData> getWeather(String cityName) async {
    try {
      final weather = await _weather.currentWeatherByCityName('San Juan del Rio');
      return WeatherData(
        humidity: weather.humidity!,
      );
    } catch (e) {
      throw Exception('Error al obtener los datos del clima');
    }
  }
}

class RelojWidget extends StatefulWidget {
  final WeatherService weatherService;
  final WearMode mode;

  const RelojWidget(this.mode, {required this.weatherService});

  @override
  _RelojWidgetState createState() => _RelojWidgetState();
}

class _RelojWidgetState extends State<RelojWidget> {
  late WeatherData _weatherData;
  late String _hourString;
  late String _minuteString;
  late String _amPmString;

  @override
  void initState() {
    super.initState();
    _weatherData = WeatherData(
      humidity: 0,
    );
    _getTime();
    _getWeather();
  }

  void _getTime() {
    final now = DateTime.now();
    final hourFormatter = DateFormat('hh');
    final minuteFormatter = DateFormat('mm');
    final amPmFormatter = DateFormat('a');
    _hourString = hourFormatter.format(now);
    _minuteString = minuteFormatter.format(now);
    _amPmString = amPmFormatter.format(now);
    Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final hourFormatter = DateFormat('hh');
      final minuteFormatter = DateFormat('mm');
      final amPmFormatter = DateFormat('a');
      setState(() {
        _hourString = hourFormatter.format(now);
        _minuteString = minuteFormatter.format(now);
        _amPmString = amPmFormatter.format(now);
      });
    });
  }

  Future<void> _getWeather() async {
    try {
      final weatherData =
          await widget.weatherService.getWeather('San Juan del Rio');
      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.mode == WearMode.active
                ? Color.fromARGB(255, 247, 111, 43)
                : Colors.black,
            widget.mode == WearMode.active
                ? Color.fromARGB(255, 244, 247, 60)
                : Colors.black,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _hourString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text: ':',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: _minuteString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                ],
              ),
              
              Text(
                _amPmString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                DateFormat('d MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Humedad: ${_weatherData.humidity}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WatchScreen(),
  ));
}

class WatchScreen extends StatelessWidget {
  WatchScreen({Key? key});

  final WeatherService weatherService = WeatherService();

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return RelojWidget(mode, weatherService: weatherService);
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weatherapp_flutter/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  final _weatherService = WeatherService('ddb72d8d562e4702ebb279076491da1b');
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather();
      setState(() {
        _weather = weather;
      });
    }
    // any errors
    catch (e) {
      // ignore: avoid_print
      print('Error fetching weather: $e');
    }
  }

  // weather animations
  String getWeatherAnimation(String? description) {
    if (description == null) return 'assets/sunny.json';

    switch (description.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // init state
  @override
  void initState() {
    super.initState();
    // fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _weather == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // city name
                  Text(
                    _weather!.cityName,
                    style: const TextStyle(fontSize: 24),
                  ),

                  // animation
                  Lottie.asset(getWeatherAnimation(_weather!.description)),

                  // temperature
                  Text(
                    '${_weather!.temperature.round()}°C',
                    style: const TextStyle(fontSize: 40),
                  ),

                  // weather condition
                  Text(
                    _weather!.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}

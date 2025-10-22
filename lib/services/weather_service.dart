// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather']?[0]?['description'] ?? 'N/A',
      icon: json['weather']?[0]?['icon'] ?? '',
    );
  }
}

class WeatherService {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather() async {
    try {
      // make sure location permission is enabled
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }

      // get the user's location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 DEBUG POSITION: ${position.latitude}, ${position.longitude}');

      // convert coordinates to a city name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      String city =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea ??
          '';

      if (city.isEmpty) {
        throw Exception('City not found from coordinates');
      }

      print('🏙️ DEBUG CITY DETECTED: $city');

      // call the weather API based on the city name
      final url = Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric');
      final response = await http.get(url);

      print('🌐 DEBUG RESPONSE STATUS: ${response.statusCode}');
      print('🌐 DEBUG RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        // fallback to coordinates directly if the city name fails
        final coordUrl = Uri.parse(
          '$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
        );
        final coordResponse = await http.get(coordUrl);

        if (coordResponse.statusCode == 200) {
          return Weather.fromJson(jsonDecode(coordResponse.body));
        } else {
          throw Exception('Failed to load weather data');
        }
      }
    } catch (e) {
      print('🔥 ERROR getWeather(): $e');
      rethrow;
    }
  }

  // added to match WeatherPage usage
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric');
      final response = await http.get(url);

      print('🌐 DEBUG REQUEST CITY: $cityName');
      print('🌐 DEBUG RESPONSE STATUS: ${response.statusCode}');
      print('🌐 DEBUG RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data for $cityName');
      }
    } catch (e) {
      print('🔥 ERROR getWeatherByCity(): $e');
      rethrow;
    }
  }

  // added for current city name
  Future<String> getCurrentCity() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      String city =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea ??
          '';

      if (city.isEmpty) throw Exception('City not found');
      return city;
    } catch (e) {
      print('🔥 ERROR getCurrentCity(): $e');
      rethrow;
    }
  }
}

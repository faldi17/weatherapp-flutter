// ignore_for_file: avoid_print, constant_identifier_names

import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJSON(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    try {
      // get permission from user
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      // fetch the current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      // convert the location into a list of placemark objects
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // extract the city name from the first placemark
      Placemark placemark = placemarks.first;
      String? city = placemark.locality ?? placemark.subAdministrativeArea;

      print('Detected city: $city');

      // If still null or empty, fallback ke nama daerah/kabupaten
      if (city == null || city.isEmpty) {
        city = placemark.administrativeArea;
      }

      return city ?? "";
    } catch (e) {
      print('Error getting city: $e');
      return "";
    }
  }
}

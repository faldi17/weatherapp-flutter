class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      mainCondition: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['main']
          : 'Unknown',
    );
  }
}

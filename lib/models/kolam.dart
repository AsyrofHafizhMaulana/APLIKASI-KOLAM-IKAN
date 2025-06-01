import 'sensor_data.dart';

class Kolam {
  String name;
  SensorData data;
  Map<String, SensorThreshold> thresholds;

  Kolam({
    required this.name,
    required this.data,
    required this.thresholds,
  });

  // Untuk generate dummy kolam dengan data acak
  factory Kolam.generate(String name) {
    return Kolam(
      name: name,
      data: SensorData.generateRandom(),
      thresholds: {
        'suhu': SensorThreshold(
          normalMin: 20,
          normalMax: 30,
          criticalMin: 15,
          criticalMax: 35,
        ),
        'ph': SensorThreshold(
          normalMin: 6.5,
          normalMax: 8.0,
          criticalMin: 5.0,
          criticalMax: 9.0,
        ),
        'kekeruhan': SensorThreshold(
          normalMin: 10,
          normalMax: 30,
          criticalMin: 5,
          criticalMax: 50,
        ),
      },
    );
  }

  // Update data sensor kolam
  void updateSensorData(SensorData newData) {
    data = newData;
  }

  // Cek status semua sensor kolam
  Map<String, SensorStatus> getSensorStatuses() {
    return data.getStatusMap(thresholds);
  }
}

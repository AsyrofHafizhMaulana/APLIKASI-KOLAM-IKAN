import '../models/sensor_data.dart';

Map<String, SensorThreshold> defaultThresholds = {
  'suhu': SensorThreshold(
    normalMin: 20.0,
    normalMax: 30.0,
    criticalMin: 15.0,
    criticalMax: 35.0,
  ),
  'ph': SensorThreshold(
    normalMin: 6.5,
    normalMax: 8.5,
    criticalMin: 6.0,
    criticalMax: 9.0,
  ),
  'do': SensorThreshold(
    normalMin: 5.0,
    normalMax: 8.0,
    criticalMin: 4.0,
    criticalMax: 9.0,
  ),
  'berat': SensorThreshold(
    normalMin: 100.0,
    normalMax: 1000.0,
    criticalMin: 80.0,
    criticalMax: 1200.0,
  ),
  'tinggi_air': SensorThreshold(
    normalMin: 20.0,
    normalMax: 80.0,
    criticalMin: 15.0,
    criticalMax: 90.0,
  ),
};
//  ---- Fx 1 

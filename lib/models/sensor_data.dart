import 'dart:math';

class SensorData {
  final double suhu;
  final double ph;
  final double kekeruhan;

  SensorData({
    required this.suhu,
    required this.ph,
    required this.kekeruhan,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      suhu: (json['suhu'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      kekeruhan: (json['kekeruhan'] ?? 0).toDouble(),
    );
  }

  // Tambahkan fungsi untuk generate data dummy/random
  factory SensorData.generateRandom() {
    final rand = Random();
    return SensorData(
      suhu: 15 + rand.nextDouble() * 15,        // 15 - 30°C
      ph: 5 + rand.nextDouble() * 3,            // 5 - 8
      kekeruhan: 10 + rand.nextDouble() * 40,   // 10 - 50 NTU
    );
  }

  // Ambil status masing-masing sensor berdasarkan ambang batas
  Map<String, SensorStatus> getStatusMap(Map<String, SensorThreshold> thresholds) {
    return {
      'suhu': getStatus(suhu, thresholds['suhu']!),
      'ph': getStatus(ph, thresholds['ph']!),
      'kekeruhan': getStatus(kekeruhan, thresholds['kekeruhan']!),
    };
  }

  // Fungsi pembantu untuk menentukan status satu nilai sensor
  SensorStatus getStatus(double value, SensorThreshold threshold) {
    if (value >= threshold.normalMin && value <= threshold.normalMax) {
      return SensorStatus.normal;
    } else if (value >= threshold.criticalMin && value <= threshold.criticalMax) {
      return SensorStatus.kritis;
    } else {
      return SensorStatus.darurat;
    }
  }
}

enum SensorStatus {
  normal,
  kritis,
  darurat,
}

class SensorThreshold {
  final double normalMin;
  final double normalMax;
  final double criticalMin;
  final double criticalMax;

  SensorThreshold({
    required this.normalMin,
    required this.normalMax,
    required this.criticalMin,
    required this.criticalMax,
  });

  Map<String, dynamic> toJson() => {
        'normalMin': normalMin,
        'normalMax': normalMax,
        'criticalMin': criticalMin,
        'criticalMax': criticalMax,
      };

  factory SensorThreshold.fromJson(Map<String, dynamic> json) {
    return SensorThreshold(
      normalMin: (json['normalMin'] ?? 0).toDouble(),
      normalMax: (json['normalMax'] ?? 0).toDouble(),
      criticalMin: (json['criticalMin'] ?? 0).toDouble(),
      criticalMax: (json['criticalMax'] ?? 0).toDouble(),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mqtt_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, Map<String, String>> kolamData = {};
  Map<String, List<Map<String, dynamic>>> kolamHistory = {}; // New: History storage
  final MqttService mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    loadKolamData();
    loadKolamHistory(); // New: Load history
    mqttService.setConfiguration(
      broker: 'broker.emqx.io',
      port: 1883,
      topics: ['zio/lele/kolam'],
    );

    mqttService.onDataReceived = (topic, data) {
      if (topic == 'zio/lele/kolam') {
        setState(() {
          (data as Map<String, dynamic>).forEach((kolamKey, kolamValue) {
            // Initialize kolamData if not present
            kolamData.putIfAbsent(kolamKey, () => {
                  'location': '',
                  'temperature': '0 °C',
                  'do': '0 mg/L',
                  'ph': '0',
                  'feed': '0 gram',
                  'height': '0 m',
                });

            // Update current data
            kolamData[kolamKey] = {
              'location': kolamData[kolamKey]?['location'] ?? '',
              'temperature': '${kolamValue['temperature']} °C',
              'do': '${kolamValue['do']} mg/L',
              'ph': '${kolamValue['ph']}',
              'feed': '${kolamValue['feed']} gram',
              'height': '${kolamValue['height']} m',
            };

            // New: Add to history
            kolamHistory.putIfAbsent(kolamKey, () => []);
            kolamHistory[kolamKey]!.add({
              'timestamp': DateTime.now().toIso8601String(),
              'temperature': kolamValue['temperature'],
              'do': kolamValue['do'],
              'ph': kolamValue['ph'],
              'feed': kolamValue['feed'],
              'height': kolamValue['height'],
            });

            // Optional: Limit history to last 100 entries
            if (kolamHistory[kolamKey]!.length > 100) {
              kolamHistory[kolamKey]!.removeAt(0);
            }
          });
        });
        saveKolamData();
        saveKolamHistory(); // New: Save history
        sendAllDataToMQTT();
      }
    };

    mqttService.connect();
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  Future<void> loadKolamData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('kolamData');

    if (savedData != null) {
      setState(() {
        kolamData = Map<String, Map<String, String>>.from(
          (jsonDecode(savedData) as Map).map((k, v) => MapEntry(
            k,
            Map<String, String>.from(v),
          )),
        );
      });
    } else {
      kolamData = {
        'kolam1': defaultKolamData(),
        'kolam2': defaultKolamData(),
        'kolam3': defaultKolamData(),
      };
      saveKolamData();
    }
  }

  Future<void> loadKolamHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedHistory = prefs.getString('kolamHistory');

    if (savedHistory != null) {
      setState(() {
        kolamHistory = Map<String, List<Map<String, dynamic>>>.from(
          (jsonDecode(savedHistory) as Map).map((k, v) => MapEntry(
            k,
            List<Map<String, dynamic>>.from(v.map((item) => Map<String, dynamic>.from(item))),
          )),
        );
      });
    }
  }

  Map<String, String> defaultKolamData() {
    return {
      'location': '',
      'temperature': '0 °C',
      'do': '0 mg/L',
      'ph': '0',
      'feed': '0 gram',
      'height': '0 m',
    };
  }

  Future<void> saveKolamData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('kolamData', jsonEncode(kolamData));
  }

  Future<void> saveKolamHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('kolamHistory', jsonEncode(kolamHistory));
  }

  void addKolam(String kolamKey) {
    setState(() {
      kolamData[kolamKey] = defaultKolamData();
      kolamHistory[kolamKey] = []; // Initialize history for new pond
    });
    saveKolamData();
    saveKolamHistory();
    sendAllDataToMQTT();
  }

  void removeKolam(String kolamKey) {
    setState(() {
      kolamData.remove(kolamKey);
      kolamHistory.remove(kolamKey); // Remove history for deleted pond
    });
    saveKolamData();
    saveKolamHistory();
    sendAllDataToMQTT();
  }

  void sendAllDataToMQTT() {
    final dataToSend = Map<String, Map<String, dynamic>>.from(kolamData);
    String jsonString = jsonEncode(dataToSend);
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonString);

    mqttService.client.publishMessage(
      'zio/lele/kolam',
      MqttQos.atMostOnce,
      builder.payload!,
    );

    print('Sent to zio/lele/kolam: $jsonString');
  }

  void editLocation(String kolamKey) async {
    TextEditingController controller = TextEditingController(
      text: kolamData[kolamKey]?['location'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Lokasi Kolam'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Masukkan Lokasi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                kolamData[kolamKey]?['location'] = controller.text;
              });
              saveKolamData();
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void resetAllKolam() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Reset'),
        content: Text('Apakah kamu yakin ingin mereset semua data kolam dan riwayat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        kolamData.clear();
        kolamHistory.clear(); // Clear history
        kolamData = {
          'kolam1': defaultKolamData(),
          'kolam2': defaultKolamData(),
          'kolam3': defaultKolamData(),
        };
        kolamHistory = {
          'kolam1': [],
          'kolam2': [],
          'kolam3': [],
        };
      });
      await saveKolamData();
      await saveKolamHistory();
      sendAllDataToMQTT();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data kolam dan riwayat berhasil direset!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Monitoring Kolam'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reset Semua Kolam',
            onPressed: resetAllKolam,
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new),
            tooltip: 'Connect ke MQTT',
            onPressed: () {
              mqttService.connect();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Menghubungkan ke broker MQTT...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: kolamData.entries.map((entry) {
            String kolam = entry.key;
            Map<String, String> data = entry.value;
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Icon(Icons.pool, color: Colors.blueAccent),
                title: Text(
                  kolam.toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['location']?.isEmpty ?? true ? 'Belum ada lokasi' : data['location']!,
                  style: TextStyle(color: Colors.grey),
                ),
                children: [
                  buildCard(Icons.thermostat, 'Suhu Air', data['temperature']!, const Color.fromARGB(255, 255, 153, 0)),
                  buildCard(Icons.water_drop, 'Kadar DO', data['do']!, const Color.fromARGB(255, 0, 187, 212)),
                  buildCard(Icons.science, 'Nilai pH', data['ph']!, const Color.fromARGB(255, 76, 175, 79)),
                  buildCard(Icons.fastfood, 'Berat Pakan', data['feed']!, const Color.fromARGB(255, 255, 193, 7)),
                  buildCard(Icons.straighten, 'Ketinggian Air', data['height']!, const Color.fromARGB(255, 68, 137, 255)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => editLocation(kolam),
                        child: Text('Edit Lokasi'),
                      ),
                      TextButton(
                        onPressed: () => removeKolam(kolam),
                        child: Text('Hapus Kolam', style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(
                                kolamKey: kolam,
                                history: kolamHistory[kolam] ?? [],
                              ),
                            ),
                          );
                        },
                        child: Text('Lihat Riwayat'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addKolam('kolam${kolamData.length + 1}');
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Kolam',
      ),
    );
  }

  Widget buildCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.7),
              color.withOpacity(0.9),
              color,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// New: History Screen
class HistoryScreen extends StatelessWidget {
  final String kolamKey;
  final List<Map<String, dynamic>> history;

  const HistoryScreen({required this.kolamKey, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat ${kolamKey.toUpperCase()}'),
      ),
      body: history.isEmpty
          ? Center(child: Text('Belum ada data riwayat.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[history.length - 1 - index]; // Reverse to show newest first
                final timestamp = DateTime.parse(entry['timestamp']).toLocal();
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Suhu Air: ${entry['temperature']} °C'),
                        Text('Kadar DO: ${entry['do']} mg/L'),
                        Text('Nilai pH: ${entry['ph']}'),
                        Text('Berat Pakan: ${entry['feed']} gram'),
                        Text('Ketinggian Air: ${entry['height']} m'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
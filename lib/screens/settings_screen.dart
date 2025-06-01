import 'package:flutter/material.dart';
import '../services/mqtt_service.dart'; // Pastikan MqttService diimport

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = true;
  bool notificationsEnabled = true;
  String username = "Nama anda";
  TextEditingController brokerController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController clientIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values
    brokerController.text = 'broker.emqx.io';
    portController.text = '8083';
    topicController.text = '';
    clientIdController.text = 'flutter_kolam_ikan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pengaturan")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Broker", style: TextStyle(color: Colors.white)),
            subtitle: TextField(
              controller: brokerController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Masukkan alamat broker",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              cursorColor: Colors.white,
            ),
          ),
          ListTile(
            title: Text("Port", style: TextStyle(color: Colors.white)),
            subtitle: TextField(
              controller: portController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Masukkan port",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              cursorColor: Colors.white,
            ),
          ),
          ListTile(
            title: Text("Topik", style: TextStyle(color: Colors.white)),
            subtitle: TextField(
              controller: topicController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Masukkan topik (pisahkan dengan koma)",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              cursorColor: Colors.white,
            ),
          ),
          ListTile(
            title: Text("Client ID", style: TextStyle(color: Colors.white)),
            subtitle: TextField(
              controller: clientIdController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Masukkan Client ID",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String broker = brokerController.text;
              int port = int.tryParse(portController.text) ?? 8083;
              List<String> topics = topicController.text.split(',');
              String clientId = clientIdController.text;

              // Instansiasi MqttService
              MqttService mqttService = MqttService();
              mqttService.setConfiguration(broker: broker, port: port, topics: topics);

              // Coba untuk terkoneksi
              try {
                await mqttService.connect();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pengaturan disimpan dan terkoneksi ke broker!')),
                );
                Navigator.pop(context);
              } catch (e) {
                // Jika gagal terkoneksi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal terhubung ke broker: $e')),
                );
              }
            },
            child: Text("Simpan Pengaturan"),
          ),
        ],
      ),
    );
  }
}
//  ---- Fx 1 

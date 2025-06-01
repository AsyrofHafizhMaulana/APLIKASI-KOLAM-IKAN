import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  String broker = 'broker.emqx.io';
  int port = 8083; // WebSocket port
  List<String> topics = [];

  Function(String topic, Map<String, dynamic> data)? onDataReceived;

  void setConfiguration({
    required String broker,
    required int port,
    required List<String> topics,
  }) {
    this.broker = broker;
    this.port = port;
    this.topics = topics;
    print('Pengaturan baru: Broker - $broker, Port - $port, Topik - $topics');
    // Lakukan koneksi ulang atau update sesuai kebutuhan.
  }


  Future<void> connect() async {
    client = MqttServerClient('ws://broker.emqx.io/mqtt', 'flutter_kolam_ikan');
    client.useWebSocket = true;
    client.port = 8083;

    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_kolam_ikan')
        .startClean()
        .withWillTopic('willtopic')
        .withWillMessage('Connection Closed')
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT Connection Error: $e');
      disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT Connected via WebSocket');
      for (var topic in topics) {
        client.subscribe(topic, MqttQos.atMostOnce);
      }

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? event) {
        final recMess = event![0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final topic = event[0].topic;

        print('[$topic] Payload received: $payload');

        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            onDataReceived?.call(topic, decoded);
          }
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      });
    } else {
      print('MQTT Connection Failed - Status: ${client.connectionStatus}');
    }
  }

  void disconnect() {
    client.disconnect();
  }

  void onConnected() {
    print('Connected to MQTT broker');
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
//  ---- Fx 1 

#include <WiFi.h>
#include <PubSubClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <HX711.h>
#include <ArduinoJson.h>


//   KONFIGURASI WiFi      //

const char* ssid = "Wokwi-GUEST";
const char* password = "";


//   KONFIGURASI MQTT       //

const char* mqtt_server = "broker.emqx.io";
const int mqtt_port = 1883;
const char* mqtt_client_id = "esp32_kolam_ikan";
const char* mqtt_topic = "zio/lele/kolam";


//   PIN SENSOR             //


// DS18B20 (Suhu)
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);

// DO dan pH analog input
#define DO_PIN 34
#define PH_PIN 35

// Load Cell HX711
#define HX711_DT 25
#define HX711_SCK 26
HX711 scale;

// Ultrasonik HC-SR04
#define TRIG_PIN 13
#define ECHO_PIN 12


//   OBJEK WI-FI & MQTT     //

WiFiClient espClient;
PubSubClient client(espClient);


//       SETUP              //

void setup() {
  Serial.begin(115200);

  // Inisialisasi sensor
  tempSensor.begin();
  scale.begin(HX711_DT, HX711_SCK);
  scale.set_scale(2280.f); // Sesuaikan hasil kalibrasi
  scale.tare();            // Reset berat ke 0

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Koneksi WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Menghubungkan ke WiFi...");
  }
  Serial.println("✅ Terhubung ke WiFi");

  // Koneksi MQTT
  client.setServer(mqtt_server, mqtt_port);
  reconnect();
}

//      MAIN LOOP           //
void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  publishSensorData();  // Kirim data ke broker
  delay(60000);         // Delay 1 menit
}

//   FUNGSI RECONNECT MQTT  //
void reconnect() {
  while (!client.connected()) {
    Serial.println("🔁 Mencoba koneksi ke MQTT...");
    if (client.connect(mqtt_client_id)) {
      Serial.println("✅ Terhubung ke broker MQTT");
    } else {
      Serial.print("❌ Gagal, rc=");
      Serial.print(client.state());
      Serial.println(". Coba lagi 5 detik...");
      delay(5000);
    }
  }
}

//   FUNGSI BACA SENSOR     //
void publishSensorData() {
  StaticJsonDocument<512> doc;

  // ==== SUHU ====
  tempSensor.requestTemperatures();
  float temperature = tempSensor.getTempCByIndex(0);
  Serial.println("Suhu: " + String(temperature) + "°C");

  // ==== DO & pH ====
  int do_adc = analogRead(DO_PIN);
  int ph_adc = analogRead(PH_PIN);
  float do_value = ((float)do_adc / 4095.0) * 14.0;
  float ph_value = ((float)ph_adc / 4095.0) * 14.0;
  Serial.println("DO: " + String(do_value));
  Serial.println("pH: " + String(ph_value));

  // ==== Load Cell ====
  float feed_weight = scale.get_units(5); // ambil rata-rata 5 pembacaan
  Serial.println("Berat pakan: " + String(feed_weight) + " gram");

  // ==== Ultrasonik ====
  long duration;
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  duration = pulseIn(ECHO_PIN, HIGH);
  float distance = duration * 0.034 / 2; // cm
  float height = distance / 100.0;       // m
  Serial.println("Ketinggian air: " + String(height) + " m");

  // ==== Format JSON ====
  doc["kolam1"]["temperature"] = temperature;
  doc["kolam1"]["do"] = do_value;
  doc["kolam1"]["ph"] = ph_value;
  doc["kolam1"]["feed"] = feed_weight;
  doc["kolam1"]["height"] = height;

  char buffer[512];
  serializeJson(doc, buffer);

  // ==== Kirim ke MQTT ====
  if (client.publish(mqtt_topic, buffer)) {
    Serial.println("✅ Data terkirim: " + String(buffer));
  } else {
    Serial.println("❌ Gagal mengirim data!");
  }
}

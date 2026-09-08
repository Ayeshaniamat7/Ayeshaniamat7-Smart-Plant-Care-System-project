/*
 * =====================================================================================
 * Smart Plant Care System - 70% Prototype Phase
 * Microcontroller Hardware Code (ESP32 / ESP8266)
 * 
 * Target Microcontroller: ESP32 (or ESP8266 NodeMCU)
 * IDE: Arduino IDE
 * Sensors:
 *   - DHT11 / DHT22 (Temperature & Humidity) -> GPIO 4
 *   - Capacitive/Resistive Soil Moisture Sensor -> GPIO 34 (Analog ADC1)
 *   - LDR (Light Dependent Resistor) -> GPIO 35 (Analog ADC1)
 * 
 * Network Protocol: WiFi HTTP REST / Firebase Realtime Database REST API
 * Exclusions: Camera Module, Relay Module, Water Pump (Deferred to 100% Phase)
 * =====================================================================================
 */

#if defined(ESP32)
  #include <WiFi.h>
  #include <HTTPClient.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
  #include <ESP8266HTTPClient.h>
  #include <WiFiClientSecure.h>
#endif

#include <DHT.h>
#include <ArduinoJson.h> // Library: ArduinoJson by Benoit Blanchon (v6.x)

// ================= USER CONFIGURATION =================
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// Firebase Realtime Database Config
// Format: https://YOUR_PROJECT_ID.firebaseio.com or https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com
const char* FIREBASE_HOST = "https://smart-plant-care-default-rtdb.firebaseio.com";
const char* FIREBASE_AUTH = "YOUR_FIREBASE_DATABASE_SECRET_OR_ID_TOKEN";
const char* DEVICE_ID     = "plant_node_01"; // Unique Device ID linked to plant profile

// Pin Configuration
#define DHTPIN        4      // Digital pin connected to DHT sensor
#define DHTTYPE       DHT11  // DHT 11 (Change to DHT22 if using DHT22)
#define SOIL_PIN      34     // Analog pin connected to Soil Moisture sensor (ESP32 GPIO 34)
#define LDR_PIN       35     // Analog pin connected to LDR sensor (ESP32 GPIO 35)

// Sensor Calibration Parameters
const int SOIL_DRY_VAL = 3500; // ADC value when soil is completely dry
const int SOIL_WET_VAL = 1400; // ADC value when sensor is immersed in water
const int ADC_MAX_VAL  = 4095; // 12-bit ADC for ESP32 (1024 for ESP8266)

// Update Interval (in milliseconds)
const unsigned long UPDATE_INTERVAL = 5000; // 5 seconds interval for live monitoring
unsigned long lastUpdate = 0;

DHT dht(DHTPIN, DHTTYPE);

// ================= SETUP =================
void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("\n--- Smart Plant Care System: Initializing Hardware ---");

  // Initialize DHT Sensor
  dht.begin();
  Serial.println("[OK] DHT Sensor Initialized.");

  // Configure Analog Pins
  pinMode(SOIL_PIN, INPUT);
  pinMode(LDR_PIN, INPUT);

  // Connect to WiFi
  connectWiFi();
}

// ================= LOOP =================
void loop() {
  // Ensure WiFi connection remains active
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }

  // Periodically read sensors and push to Backend
  if (millis() - lastUpdate >= UPDATE_INTERVAL) {
    lastUpdate = millis();

    // 1. Read DHT Sensor
    float tempC = dht.readTemperature();
    float humidity = dht.readHumidity();

    // Validate DHT readings
    if (isnan(tempC) || isnan(humidity)) {
      Serial.println("[WARN] Failed to read from DHT sensor! Retrying next cycle...");
      tempC = 25.0; // Fallback value for testing if disconnected
      humidity = 60.0;
    }

    // 2. Read Soil Moisture Sensor
    int rawSoil = analogRead(SOIL_PIN);
    // Map raw ADC to percentage (0% = dry, 100% = wet)
    int soilMoisturePct = map(rawSoil, SOIL_DRY_VAL, SOIL_WET_VAL, 0, 100);
    soilMoisturePct = constrain(soilMoisturePct, 0, 100);

    // 3. Read LDR Sensor
    int rawLDR = analogRead(LDR_PIN);
    // Map raw ADC to light intensity percentage (0% = dark, 100% = bright daylight)
    int lightPct = map(rawLDR, 0, ADC_MAX_VAL, 0, 100);
    lightPct = constrain(lightPct, 0, 100);

    // Print to Serial Monitor
    Serial.println("\n--- Live Sensor Readings ---");
    Serial.printf("Temperature   : %.2f *C\n", tempC);
    Serial.printf("Humidity      : %.2f %%\n", humidity);
    Serial.printf("Soil Moisture : %d %% (Raw: %d)\n", soilMoisturePct, rawSoil);
    Serial.printf("Light Level   : %d %% (Raw: %d)\n", lightPct, rawLDR);

    // 4. Transmit Payload to Firebase Realtime Database
    sendDataToFirebase(tempC, humidity, soilMoisturePct, lightPct);
  }
}

// ================= HELPER FUNCTIONS =================
void connectWiFi() {
  Serial.printf("[WIFI] Connecting to SSID: %s ", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WIFI] Connected Successfully!");
    Serial.print("[WIFI] IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[WIFI] Connection Failed! Will retry...");
  }
}

void sendDataToFirebase(float temp, float hum, int soil, int light) {
  if (WiFi.status() != WL_CONNECTED) return;

#if defined(ESP32)
  HTTPClient http;
#elif defined(ESP8266)
  WiFiClientSecure client;
  client.setInsecure(); // Bypass SSL fingerprint verification for ease in prototype
  HTTPClient http;
#endif

  // Construct Firebase REST API URL
  // Node path: /devices/{DEVICE_ID}/live.json
  String url = String(FIREBASE_HOST) + "/devices/" + String(DEVICE_ID) + "/live.json";
  if (String(FIREBASE_AUTH).length() > 0 && String(FIREBASE_AUTH) != "YOUR_FIREBASE_DATABASE_SECRET_OR_ID_TOKEN") {
    url += "?auth=" + String(FIREBASE_AUTH);
  }

#if defined(ESP32)
  http.begin(url);
#elif defined(ESP8266)
  http.begin(client, url);
#endif

  http.addHeader("Content-Type", "application/json");

  // Create JSON Payload
  StaticJsonDocument<200> doc;
  doc["temperature"]  = temp;
  doc["humidity"]     = hum;
  doc["soilMoisture"] = soil;
  doc["lightLevel"]   = light;
  doc["timestamp"]    = millis(); // Or Unix epoch timestamp
  doc["status"]       = "online";

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  // Send PUT request to overwrite live readings node
  int httpResponseCode = http.PUT(jsonPayload);

  if (httpResponseCode > 0) {
    Serial.printf("[HTTP] Firebase Live Data Updated! Response Code: %d\n", httpResponseCode);
  } else {
    Serial.printf("[HTTP] Error updating Firebase! HTTP Code: %s\n", http.errorToString(httpResponseCode).c_str());
  }

  http.end();
}

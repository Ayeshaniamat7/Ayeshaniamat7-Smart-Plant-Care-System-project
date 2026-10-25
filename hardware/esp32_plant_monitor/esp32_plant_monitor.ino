#if defined(ESP32)
  #include <WiFi.h>
  #include <HTTPClient.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
  #include <ESP8266HTTPClient.h>
  #include <WiFiClientSecure.h>
#endif

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>
#include <ArduinoJson.h>

// ------------------ USER SETTINGS ------------------
const char* WIFI_SSID     = "Infinix SMART 9 HD";
const char* WIFI_PASSWORD = "210692525";
const char* FIREBASE_HOST = "https://smart-plant-care-95490-default-rtdb.firebaseio.com";
const char* FIREBASE_AUTH = "H8EaInbYEEQJVHBJ5xCOww8yYt3S7YgudKCWtb4x";
const char* DEVICE_ID     = "plant_node_01";
const char* CAM_STREAM_URL = "http://192.168.153.94:80/stream";

// ------------------ PIN CONFIG ------------------
#define DHTPIN        4
#define DHTTYPE       DHT11
#define SOIL_PIN      34
#define LDR_PIN       5
#define RELAY_PIN     26
#define OLED_SDA      21
#define OLED_SCL      22

// IMPORTANT: common relay module is ACTIVE-LOW
#define RELAY_ON      LOW
#define RELAY_OFF     HIGH

// ------------------ OLED ------------------
#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1
#define SCREEN_ADDR   0x3C

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
bool oledReady = false;

// ------------------ CALIBRATION ------------------
const int SOIL_DRY_VAL = 3500;
const int SOIL_WET_VAL = 1400;
const int ADC_MAX_VAL  = 4095;

int autoSoilThresholdLow  = 30;
int autoSoilThresholdHigh = 55;

// ------------------ PUMP STATE ------------------
bool manualOverride = false;
bool manualPumpCmd  = false;
bool isPumpRunning  = false;

// ------------------ TIMERS ------------------
const unsigned long UPDATE_INTERVAL  = 5000;
const unsigned long HISTORY_INTERVAL = 60000;
unsigned long lastUpdate  = 0;
unsigned long lastHistory = 0;

DHT dht(DHTPIN, DHTTYPE);

// ------------------ PROTOTYPES ------------------
void connectWiFi();
void fetchPumpControlFromFirebase();
void evaluatePumpLogic(int soilMoisturePct);
String generateAlertMessage(float temp, float hum, int soil, int light);
void updateOLED(float temp, float hum, int soil, int light);
void sendLiveDataToFirebase(float temp, float hum, int soil, int light, String alertMsg);
void logHistoryToFirebase(float temp, float hum, int soil, int light);

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("\n--- Smart Plant Care System ---");

  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, RELAY_OFF); // relay off at startup
  Serial.println("[OK] Relay initialized OFF.");

  dht.begin();
  pinMode(SOIL_PIN, INPUT);
  pinMode(LDR_PIN, INPUT);
  Serial.println("[OK] Sensors initialized.");

  Wire.begin(OLED_SDA, OLED_SCL);
  if (display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDR)) {
    oledReady = true;
    display.clearDisplay();
    display.setTextColor(SSD1306_WHITE);
    display.setTextSize(1);
    display.setCursor(10, 10);
    display.println("SMART PLANT CARE");
    display.setCursor(15, 30);
    display.println("Booting System...");
    display.display();
    Serial.println("[OK] OLED initialized.");
  } else {
    Serial.println("[WARN] OLED not detected!");
  }

  connectWiFi();
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }

  if (millis() - lastUpdate >= UPDATE_INTERVAL) {
    lastUpdate = millis();

    float tempC = dht.readTemperature();
    float humidity = dht.readHumidity();

    if (isnan(tempC) || isnan(humidity)) {
      Serial.println("[WARN] DHT failed, using fallback values.");
      tempC = 25.0;
      humidity = 60.0;
    }

    int rawSoil = analogRead(SOIL_PIN);
    int soilMoisturePct = map(rawSoil, SOIL_DRY_VAL, SOIL_WET_VAL, 0, 100);
    soilMoisturePct = constrain(soilMoisturePct, 0, 100);

    int rawLDR = digitalRead(LDR_PIN);
    int lightPct = (rawLDR == HIGH) ? 0 : 100;

    fetchPumpControlFromFirebase();
    evaluatePumpLogic(soilMoisturePct);

    String alertMsg = generateAlertMessage(tempC, humidity, soilMoisturePct, lightPct);
    updateOLED(tempC, humidity, soilMoisturePct, lightPct);

    Serial.println("\n--- Live Status ---");
    Serial.printf("Temp: %.1f C | Humidity: %.1f %%\n", tempC, humidity);
    Serial.printf("Soil: %d %% | Light: %d %%\n", soilMoisturePct, lightPct);
    Serial.printf("Pump: %s | Mode: %s\n", isPumpRunning ? "ON" : "OFF", manualOverride ? "MANUAL" : "AUTO");
    Serial.printf("Alert: %s\n", alertMsg.c_str());

    sendLiveDataToFirebase(tempC, humidity, soilMoisturePct, lightPct, alertMsg);

    if (millis() - lastHistory >= HISTORY_INTERVAL) {
      lastHistory = millis();
      logHistoryToFirebase(tempC, humidity, soilMoisturePct, lightPct);
    }
  }
}

void connectWiFi() {
  Serial.printf("[WIFI] Connecting to SSID: %s ", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  #if defined(ESP32)
    WiFi.setTxPower(WIFI_POWER_11dBm);
  #endif
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WIFI] Connected");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[WIFI] Failed, retrying...");
  }
}

void fetchPumpControlFromFirebase() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/devices/" + String(DEVICE_ID) + "/control.json";
  if (String(FIREBASE_AUTH).length() > 0 && String(FIREBASE_AUTH) != "YOUR_FIREBASE_DATABASE_SECRET_OR_ID_TOKEN") {
    url += "?auth=" + String(FIREBASE_AUTH);
  }

  http.begin(url);
  int httpCode = http.GET();

  if (httpCode == HTTP_CODE_OK) {
    String payload = http.getString();

    if (payload != "null" && payload.length() > 2) {
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);

      if (!error) {
        if (doc.containsKey("manualOverride")) {
          manualOverride = doc["manualOverride"].as<bool>();
        }
        if (doc.containsKey("pumpSwitch")) {
          manualPumpCmd = doc["pumpSwitch"].as<bool>();
        }
      }
    }
  }

  http.end();
}

void evaluatePumpLogic(int soilMoisturePct) {
  if (manualOverride) {
    isPumpRunning = manualPumpCmd;
  } else {
    if (soilMoisturePct < autoSoilThresholdLow) {
      isPumpRunning = true;
    } else if (soilMoisturePct >= autoSoilThresholdHigh) {
      isPumpRunning = false;
    }
  }

  digitalWrite(RELAY_PIN, isPumpRunning ? RELAY_ON : RELAY_OFF);
}

String generateAlertMessage(float temp, float hum, int soil, int light) {
  if (soil < 25) return "CRITICAL: Soil very dry!";
  if (temp > 38.0) return "WARNING: High temperature alert!";
  if (temp < 10.0) return "WARNING: Low temperature alert!";
  if (light == 0) return "INFO: Low light / night mode.";
  return "NORMAL: Plant conditions are optimal.";
}

void updateOLED(float temp, float hum, int soil, int light) {
  if (!oledReady) return;

  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print("PLANT CARE ");
  display.println(WiFi.status() == WL_CONNECTED ? "[WIFI OK]" : "[NO WIFI]");
  display.drawLine(0, 11, 128, 11, SSD1306_WHITE);

  display.setCursor(0, 15);
  display.printf("Temp: %.1fC  Hum:%d%%", temp, (int)hum);

  display.setCursor(0, 27);
  display.printf("Soil: %d%%   Light:%d%%", soil, light);

  display.setCursor(0, 39);
  display.printf("Pump: %s (%s)", isPumpRunning ? "ON " : "OFF", manualOverride ? "MANUAL" : "AUTO");

  display.setCursor(0, 52);
  if (soil < autoSoilThresholdLow) {
    display.print("Alert: SOIL DRY!");
  } else {
    display.print("Cam & System: ONLINE");
  }

  display.display();
}

void sendLiveDataToFirebase(float temp, float hum, int soil, int light, String alertMsg) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/devices/" + String(DEVICE_ID) + "/live.json";
  if (String(FIREBASE_AUTH).length() > 0 && String(FIREBASE_AUTH) != "YOUR_FIREBASE_DATABASE_SECRET_OR_ID_TOKEN") {
    url += "?auth=" + String(FIREBASE_AUTH);
  }

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<384> doc;
  doc["temperature"]     = temp;
  doc["humidity"]        = hum;
  doc["soilMoisture"]    = soil;
  doc["lightLevel"]      = light;
  doc["pumpStatus"]      = isPumpRunning ? "ON" : "OFF";
  doc["pumpMode"]        = manualOverride ? "MANUAL" : "AUTO";
  doc["cameraStreamUrl"] = CAM_STREAM_URL;
  doc["alert"]           = alertMsg;
  doc["timestamp"]       = millis();
  doc["status"]          = "online";

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  int httpResponseCode = http.PUT(jsonPayload);
  if (httpResponseCode > 0) {
    Serial.printf("[HTTP] Live data updated. Code: %d\n", httpResponseCode);
  } else {
    Serial.printf("[HTTP] Live error: %s\n", http.errorToString(httpResponseCode).c_str());
  }

  http.end();
}

void logHistoryToFirebase(float temp, float hum, int soil, int light) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/devices/" + String(DEVICE_ID) + "/history.json";
  if (String(FIREBASE_AUTH).length() > 0 && String(FIREBASE_AUTH) != "YOUR_FIREBASE_DATABASE_SECRET_OR_ID_TOKEN") {
    url += "?auth=" + String(FIREBASE_AUTH);
  }

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<200> doc;
  doc["temperature"]  = temp;
  doc["humidity"]     = hum;
  doc["soilMoisture"] = soil;
  doc["lightLevel"]   = light;
  doc["pumpRunning"]  = isPumpRunning;
  doc["timestamp"]    = millis();

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  int httpResponseCode = http.POST(jsonPayload);
  if (httpResponseCode > 0) {
    Serial.printf("[HTTP] History logged. Code: %d\n", httpResponseCode);
  }

  http.end();
}
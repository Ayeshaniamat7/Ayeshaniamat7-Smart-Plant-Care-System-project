# 🌿 Smart Plant Care System - 100% Complete Project

**AI-Powered IoT Monitoring, Smart Irrigation, and Plant Health Management System**

A complete smart agriculture and plant care solution that combines embedded hardware, cloud services, AI-based decision support, and a Flutter mobile app to monitor, diagnose, and improve plant health in real time.

This project is now delivered as a fully integrated system covering:

- ESP32-based environmental sensing
- Firebase backend for authentication and real-time data storage
- AI health diagnosis and irrigation prediction
- Live camera streaming for plant visual monitoring
- Manual and automated irrigation control
- Android/iOS mobile app for monitoring and plant management

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [System Features](#system-features)
- [Architecture Overview](#architecture-overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Hardware Setup](#hardware-setup)
- [AI Service Setup](#ai-service-setup)
- [Mobile App Setup](#mobile-app-setup)
- [Firebase Configuration](#firebase-configuration)
- [Data Flow](#data-flow)
- [API Endpoints](#api-endpoints)
- [Database Schema](#database-schema)
- [Development Status](#development-status)
- [Contribution](#contribution)

---

## 🎯 Project Overview

The Smart Plant Care System is designed to help plant owners keep their plants healthy by combining sensor data, cloud infrastructure, and intelligence into one easy-to-use platform.

The solution continuously tracks:

- Temperature
- Humidity
- Soil moisture
- Light intensity
- Plant condition and irrigation needs

It then provides a clear action plan to the user through the mobile app and AI-driven recommendations.

The final version of the project includes:

- Live telemetry monitoring
- AI health classification
- Smart watering predictions
- Pump activation control
- Camera-based plant observation
- User account management and plant profiles

---

## ✨ System Features

### Hardware Features
- ✅ ESP32 environmental sensing
- ✅ DHT-based temperature and humidity measurement
- ✅ Soil moisture monitoring using analog input
- ✅ LDR-based light monitoring
- ✅ Firebase real-time data upload
- ✅ ESP32 camera stream support
- ✅ Smart irrigation pump control via Firebase commands

### AI Features
- ✅ AI-based plant health prediction
- ✅ Smart irrigation recommendation engine
- ✅ Water amount estimation in mL
- ✅ Pump duration forecast
- ✅ Fallback rule-based logic when AI service is unavailable

### Mobile App Features
- ✅ Firebase authentication
- ✅ Live dashboard with real-time readings
- ✅ Plant profile management
- ✅ AI recommendations and alerts
- ✅ Manual plant watering control
- ✅ Sensor history charts
- ✅ Live camera view for plant monitoring
- ✅ Dark mode UI

### Backend Features
- ✅ Firebase Realtime Database integration
- ✅ Firestore data structure for plant/user records
- ✅ Authentication and user isolation
- ✅ Real-time device updates
- ✅ Trigger-based hardware controls

---

## 🏗️ Architecture Overview

```text
┌───────────────────────┐      ┌────────────────────────┐      ┌──────────────────────┐
│   ESP32 Sensor Node   │────▶│   Firebase Backend     │────▶│   Flutter Mobile App  │
│                       │      │                        │      │                      │
│ • Temperature         │      │ • Firebase Auth        │      │ • Login/Auth         │
│ • Humidity           │      │ • Realtime DB          │      │ • Dashboard          │
│ • Soil Moisture      │      │ • Firestore            │      │ • Plant Management   │
│ • Light Level        │      │ • Device control       │      │ • AI Insights        │
│ • WiFi Upload        │      │ • Sensor history       │      │ • Camera Feed        │
└───────────────────────┘      └────────────────────────┘      └──────────────────────┘
             │                                                        │
             │                                                        │
             ▼                                                        ▼
   ┌───────────────────────┐                              ┌────────────────────────┐
   │ ESP32 Camera Stream   │                              │ FastAPI AI Service     │
   │                       │                              │                        │
   │ • Live image stream   │                              │ • Health prediction    │
   │ • Plant monitoring    │                              │ • Watering estimate    │
   │ • Camera view access  │                              │ • ML inference APIs    │
   └───────────────────────┘                              └────────────────────────┘
```

---

## 🛠️ Technology Stack

### Hardware
- ESP32 Development Board
- DHT11 / DHT22 Sensor
- Capacitive Soil Moisture Sensor
- LDR Sensor
- WiFi connectivity
- Camera module support for ESP32-CAM

### Backend & Cloud
- Firebase Authentication
- Firebase Realtime Database
- Cloud Firestore
- Firebase security rules
- REST API communication

### AI & ML
- Python
- FastAPI
- Scikit-learn
- Joblib
- NumPy
- Predictive plant health analysis
- Watering optimization prediction

### Mobile App
- Flutter
- Dart
- Material Design 3
- Provider state management
- Firebase SDK
- HTTP-based AI communication

---

## 📁 Project Structure

```text
Smart-Plant-Care-System-project/
├── README.md
├── figma_ui_design_spec.md
├── github repository link.txt
├── ai_service/
│   ├── main.py
│   ├── train_models.py
│   ├── requirements.txt
│   ├── api_integration_guide.md
│   └── models/
│       ├── plant_health_classifier.joblib
│       └── watering_prediction_regressor.joblib
├── backend/
│   ├── firebase_schema.json
│   └── firestore_rules.rules
├── hardware/
│   ├── esp32_plant_monitor/
│   │   └── esp32_plant_monitor.ino
│   └── esp32_cam_stream/
│       └── esp32_cam_stream.ino
└── mobile_app/
    ├── android/
    ├── lib/
    │   ├── main.dart
    │   ├── firebase_options.dart
    │   ├── models/
    │   │   ├── ai_recommendation_model.dart
    │   │   ├── plant_model.dart
    │   │   ├── sensor_data_model.dart
    │   │   └── sensor_history_model.dart
    │   ├── services/
    │   │   ├── ai_service.dart
    │   │   ├── auth_service.dart
    │   │   ├── plant_service.dart
    │   │   ├── pump_control_service.dart
    │   │   └── sensor_service.dart
    │   └── views/
    │       ├── auth/
    │       ├── camera/
    │       │   └── live_camera_screen.dart
    │       ├── dashboard/
    │       │   └── live_dashboard_screen.dart
    │       ├── history/
    │       │   └── sensor_history_chart_screen.dart
    │       └── plants/
    │           └── plant_management_screen.dart
    ├── pubspec.yaml
    ├── firebase.json
    ├── analysis_options.yaml
    └── test/
```

---

## 🔄 How It Works

### 1. Sensor Collection
The ESP32 reads live environmental readings from connected sensors:

- temperature
- humidity
- soil moisture
- sunlight intensity

### 2. Data Transmission
The ESP32 sends the data to Firebase in real time through a network connection, making data available for both the app and cloud processing.

### 3. AI Analysis
The AI service receives telemetry and performs:

- plant health classification
- watering recommendation
- risk detection and suggested action

### 4. Control Logic
The mobile app can trigger irrigation actions and the ESP32 device can respond to Firebase control updates for pump activation.

### 5. User Experience
The app displays data in an easy-to-read format and allows users to:

- view live conditions
- manage plant profiles
- see historical charts
- monitor with the live camera feed
- apply AI recommendations

---

## ⚙️ Hardware Setup

### Required Components
1. ESP32 board
2. DHT11 or DHT22 sensor
3. Capacitive soil moisture sensor
4. LDR light sensor
5. ESP32-CAM module (optional for camera stream)
6. Water pump and relay (for irrigation control)
7. Jumper wires and breadboard

### ESP32 Pin Mapping
```text
GPIO 4   -> DHT Sensor
GPIO 34  -> Soil Moisture Sensor
GPIO 35  -> LDR Sensor
GND / 3.3V -> Power lines
```

### Firmware Upload
1. Open `hardware/esp32_plant_monitor/esp32_plant_monitor.ino` in Arduino IDE
2. Install required libraries
3. Set WiFi credentials
4. Configure Firebase endpoint or database path
5. Upload to ESP32

### Camera Module Setup
Use the ESP32-CAM firmware from:

```text
hardware/esp32_cam_stream/esp32_cam_stream.ino
```

This stream can be used for visual monitoring of the plant condition in the app.

---

## 🤖 AI Service Setup

### Prerequisites
```bash
cd ai_service
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Run AI API
```bash
python main.py
```

The service exposes endpoints such as:

- `POST /api/v1/predict-health`
- `POST /api/v1/predict-watering`
- `POST /api/v1/full-diagnosis`

### Model Behavior
The AI engine predicts:

- whether the plant is healthy or stressed
- whether irrigation is needed immediately
- how much water should be applied
- how many hours until the next watering cycle

---

## 📱 Mobile App Setup

### Prerequisites
```bash
cd mobile_app
flutter pub get
```

### Run the app
```bash
flutter run
```

### Build for release
```bash
flutter build apk
flutter build ios
```

The Flutter app includes:

- authentication
- dashboard
- plant management
- sensor history charts
- live camera feed
- AI-powered recommendations
- irrigation controls

---

## 🔐 Firebase Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication with Email/Password
3. Create a Realtime Database
4. Configure Firestore rules
5. Add Firebase configuration files to mobile app

### Firebase Structure
The project uses a structure similar to:

```yaml
users/
  {userId}/

plants/
  {plantId}/

devices/
  {deviceId}/
    live/
    control/
```

A complete reference is provided in:

```text
backend/firebase_schema.json
backend/firestore_rules.rules
```

---

## 📊 Data Flow

```text
1. ESP32 reads sensor values
2. Data is transmitted to Firebase
3. Mobile app listens to live updates
4. FastAPI AI service analyzes telemetry
5. Recommendations are shown in the app
6. User can trigger watering or monitor plant health
7. Camera stream provides plant visual confirmation
```

### Sample Telemetry Payload
```json
{
  "temperature": 24.5,
  "humidity": 58.2,
  "soilMoisture": 45,
  "lightLevel": 72,
  "timestamp": 1724123600000,
  "status": "online"
}
```

---

## 🔌 API Endpoints

### Firebase/Cloud Communication
```text
GET /devices/{deviceId}/live.json
PUT /devices/{deviceId}/live.json
GET /plants.json?orderByChild=userId&equalTo={userId}
POST /plants.json
```

### AI Service Endpoints
```text
POST /api/v1/predict-health
POST /api/v1/predict-watering
POST /api/v1/full-diagnosis
```

The AI API accepts sensor values and returns:

- health status
- confidence score
- recommendation
- alert level
- watering amount prediction
- pump duration suggestion

---

## 🗄️ Database Schema

### Firestore Collections
```yaml
users/
  ├── {userId}
  │   ├── uid
  │   ├── email
  │   ├── displayName
  │   └── createdAt

plants/
  ├── {plantId}
  │   ├── plantId
  │   ├── userId
  │   ├── name
  │   ├── species
  │   ├── deviceId
  │   ├── minSoilMoisture
  │   ├── maxSoilMoisture
  │   ├── minTemperature
  │   ├── maxTemperature
  │   ├── minLightLevel
  │   ├── maxLightLevel
  │   └── createdAt

devices/
  └── {deviceId}
      └── live/
          ├── temperature
          ├── humidity
          ├── soilMoisture
          ├── lightLevel
          ├── timestamp
          └── status
```

---

## 📈 Development Status

### Final Status: 100% Complete

**Completed Features:**
- ✅ Hardware sensing integration
- ✅ Real-time cloud synchronization
- ✅ Firebase authentication and app flow
- ✅ Plant management screens
- ✅ Live dashboard with sensor metrics
- ✅ AI health prediction model
- ✅ Smart watering engine
- ✅ Pump trigger and irrigation logic
- ✅ Camera stream implementation
- ✅ Historical data visualization
- ✅ Final mobile app integration

**Project State:**
- Active and functional
- Ready for demo, extension, or deployment
- Suitable as a complete IoT + AI plant care system prototype/final project

---

## 🤝 Contribution

### How to contribute
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Commit and push
5. Open a pull request

Example:
```bash
git checkout -b feature/your-feature-name
git add .
git commit -m "Add: description of your feature"
git push origin feature/your-feature-name
```

### Development Guidelines
- Keep code modular and readable
- Follow Flutter and Dart conventions
- Keep AI service and app integrations documented
- Validate Firebase rules and security behavior
- Test hardware and mobile flows before release

---

## 📚 Additional Resources

- Firebase Documentation: https://firebase.google.com/docs
- Flutter Documentation: https://flutter.dev/docs
- FastAPI Documentation: https://fastapi.tiangolo.com/
- ESP32 Documentation: https://docs.espressif.com/
- DHT Sensor Guide: https://learn.adafruit.com/dht

---

## 🌱 Final Project Message

The Smart Plant Care System has been developed as a complete, end-to-end solution for smart plant monitoring and care. It connects sensors, cloud intelligence, mobile app experience, and automated irrigation into a single unified system.

This repository now reflects the final project state, including AI-driven decision support and complete plant care workflow management.

---

**Project Phase:** 100% Complete  
**Status:** Production-ready prototype / final project version

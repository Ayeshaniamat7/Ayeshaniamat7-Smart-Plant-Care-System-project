# 🌿 Smart Plant Care System - 70% Prototype Phase

**AI-Based IoT Monitoring & Mobile App for Real-Time Plant Health Management**

A comprehensive IoT system that monitors plant health through multiple sensors, processes data in the cloud, and displays real-time insights via a beautiful mobile application.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [How It Works](#how-it-works)
- [System Architecture](#system-architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Hardware Setup](#hardware-setup)
- [Mobile App Setup](#mobile-app-setup)
- [Backend Configuration](#backend-configuration)
- [Data Flow](#data-flow)
- [API Endpoints](#api-endpoints)
- [Database Schema](#database-schema)
- [UI/UX Design](#uiux-design)
- [Development Phase](#development-phase)
- [Contributing](#contributing)

---

## 🎯 Project Overview

The **Smart Plant Care System** is an end-to-end IoT solution designed to help plant enthusiasts maintain optimal growing conditions. It combines:

- **Hardware Sensors** (ESP32 microcontroller)
- **Cloud Backend** (Firebase)
- **Mobile Application** (Flutter)
- **Real-Time Monitoring** (Live Dashboard)

The system monitors four critical plant health parameters and syncs data every 5 seconds for near real-time insights.

---

## 🔄 How It Works

### 1. **Hardware Sensor Reading**
The **ESP32 microcontroller** continuously reads environmental data from four sensors:

```
┌──────────────────────────────────────┐
│         ESP32 Microcontroller        │
├──────────────────────────────────────┤
│  ├─ DHT11/22 Sensor (GPIO 4)         │
│  │  └─ Temperature & Humidity        │
│  ├─ Soil Moisture Sensor (GPIO 34)   │
│  │  └─ Soil Moisture Level           │
│  ├─ LDR Sensor (GPIO 35)             │
│  │  └─ Light Intensity               │
│  └─ WiFi Module                      │
│     └─ Connects to WiFi Network      │
└──────────────────────────────────────┘
```

**Reading Cycle (Every 5 seconds):**
- Temperature: 18-32°C range
- Humidity: 30-90% range
- Soil Moisture: 0-100% (calibrated dry/wet values)
- Light Level: 0-100% (LDR ADC conversion)

### 2. **Data Transmission to Cloud**
The microcontroller sends sensor data to **Firebase Realtime Database** via REST API:

```
ESP32 → WiFi → Internet → Firebase
                          └─ /devices/{deviceId}/live
                             └─ temperature, humidity, soilMoisture, lightLevel, timestamp
```

### 3. **Cloud Processing**
Firebase stores and manages:
- **User profiles** (authentication via Firebase Auth)
- **Plant metadata** (species, thresholds, preferences)
- **Live sensor readings** (real-time data from devices)
- **Firestore Security Rules** (user data isolation)

### 4. **Mobile App Retrieval**
The Flutter app:
- Authenticates users (email/password via Firebase Auth)
- Fetches live sensor data
- Displays real-time metrics on dashboard
- Manages plant profiles and thresholds
- Provides visual alerts for out-of-range conditions

### 5. **Display & Alerts**
The mobile dashboard shows:
- Real-time sensor values
- Status indicators (Normal/Warning/Critical)
- Plant profiles and device status
- Historical trends (future phases)

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SMART PLANT CARE SYSTEM                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────┐         ┌─────────────────┐   ┌──────────────┐ │
│  │   HARDWARE     │         │     CLOUD       │   │    MOBILE    │ │
│  │   (IoT Layer)  │         │   (Backend)     │   │    (Frontend)│ │
│  ├────────────────┤         ├─────────────────┤   ├──────────────┤ │
│  │                │         │                 │   │              │ │
│  │ • ESP32        │ WiFi    │ • Firebase Auth │   │ • Flutter    │ │
│  │   Microcontrol │◄────────│ • Cloud Firestore   │ • Android/iOS│ │
│  │                │  REST   │ • RTDB          │   │              │ │
│  │ • DHT Sensor   │  API    │ • Security Rules│   │ • Provider   │ │
│  │   (Temp/Hum)   │         │                 │   │ • Navigation │ │
│  │                │         └─────────────────┘   │              │ │
│  │ • Soil Moisture│                               │ • Auth Screen│ │
│  │   Sensor       │         ┌─────────────────┐   │ • Dashboard  │ │
│  │                │         │   DATABASE      │   │ • Plant Mgmt │ │
│  │ • LDR Sensor   │         ├─────────────────┤   └──────────────┘ │
│  │   (Light)      │         │                 │                    │
│  │                │         │ • users/        │   ┌──────────────┐ │
│  └────────────────┘         │ • plants/       │   │   UI/UX      │ │
│                              │ • devices/      │   ├──────────────┤ │
│         Every 5 sec          │ • live/         │   │              │ │
│      Sensor Updates          │                 │   │ • Figma Design
│                              └─────────────────┘   │ • Material 3 │ │
│                                                    │ • Dark/Light │ │
│                                                    │   Modes      │ │
│                                                    └──────────────┘ │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

### Phase 70% (Current Prototype)

#### **Hardware**
- ✅ Real-time sensor data collection
- ✅ WiFi connectivity (ESP32/ESP8266)
- ✅ Firebase data transmission via REST API
- ✅ Calibrated sensor readings
- ⏳ Camera module (Deferred to 100%)
- ⏳ Relay/Water pump control (Deferred to 100%)

#### **Backend**
- ✅ Firebase Authentication (Email/Password)
- ✅ Cloud Firestore database
- ✅ Real-time Database (RTDB) integration
- ✅ Security rules for data isolation
- ✅ User profile management
- ✅ Plant profile CRUD operations
- ✅ Device registration and linking

#### **Mobile App**
- ✅ User authentication (Sign In/Register)
- ✅ Live sensor dashboard with 2x2 metric grid
- ✅ Real-time data streaming (5s sync)
- ✅ Plant profile management
- ✅ Customizable sensor thresholds
- ✅ Dark mode UI
- ✅ Hardware status indicator
- ✅ Multi-plant support
- ⏳ Push notifications (Deferred)
- ⏳ Historical charts (Deferred)

---

## 🛠️ Tech Stack

### **Hardware**
- **Microcontroller**: ESP32 / ESP8266
- **Sensors**: 
  - DHT11 / DHT22 (Temperature & Humidity)
  - Capacitive Soil Moisture Sensor
  - LDR (Light Dependent Resistor)
- **Libraries**: Arduino IDE, DHT, ArduinoJson, WiFi

### **Backend**
- **Database**: Firebase Realtime Database + Cloud Firestore
- **Authentication**: Firebase Authentication
- **Hosting**: Firebase Cloud
- **API**: Firebase REST API

### **Mobile**
- **Framework**: Flutter 3.0+
- **Languages**: Dart
- **State Management**: Provider
- **UI Libraries**: Material Design 3, Google Fonts
- **Firebase Packages**: 
  - `firebase_core: ^3.0.0`
  - `firebase_auth: ^5.0.0`
  - `firebase_database: ^11.0.0`
  - `cloud_firestore: ^5.0.0`

### **Design**
- **UI/UX**: Figma (70% Prototype Spec)
- **Design System**: Material Design 3, Custom Tokens
- **Colors**: Forest Green (#2E7D32), Emerald (#4CAF50)

---

## 📁 Project Structure

```
Smart-Plant-Care-System-project/
│
├── README.md                          # Project documentation
├── figma_ui_design_spec.md            # UI/UX design specification
│
├── hardware/
│   └── esp32_plant_monitor/
│       └── esp32_plant_monitor.ino    # ESP32 firmware & sensor reading logic
│
├── backend/
│   ├── firebase_schema.json           # Database structure & sample data
│   └── firestore_rules.rules          # Firestore security rules
│
└── mobile_app/
    ├── pubspec.yaml                   # Flutter dependencies
    ├── lib/
    │   ├── main.dart                  # App entry point & theme
    │   ├── models/                    # Data models (User, Plant, Device)
    │   ├── services/
    │   │   ├── auth_service.dart      # Firebase authentication
    │   │   ├── plant_service.dart     # Plant CRUD operations
    │   │   └── sensor_service.dart    # Real-time sensor data
    │   └── views/
    │       ├── auth/
    │       │   ├── login_screen.dart  # Login/Register UI
    │       │   └── auth_wrapper.dart
    │       └── dashboard/
    │           └── live_dashboard_screen.dart  # Main dashboard with metrics
    └── ...
```

---

## ⚙️ Hardware Setup

### **Components Required**
```
1. ESP32 Development Board (or ESP8266)
2. DHT11 or DHT22 Temperature/Humidity Sensor
3. Capacitive Soil Moisture Sensor
4. LDR (Light Dependent Resistor) with 10kΩ resistor
5. USB-C Cable (programming)
6. Jumper Wires
7. Breadboard (optional)
```

### **Pin Configuration**
```
ESP32 GPIO Mapping:
├── GPIO 4   → DHT Sensor (Temperature & Humidity)
├── GPIO 34  → Soil Moisture Sensor (Analog ADC)
├── GPIO 35  → LDR Sensor (Analog ADC)
└── GND/3.3V → Power distribution
```

### **Calibration Steps**

**Soil Moisture Sensor:**
```
1. Measure raw ADC value when sensor is in dry soil
   → Typically: 3500 (set as SOIL_DRY_VAL)

2. Measure raw ADC value when sensor is submerged in water
   → Typically: 1400 (set as SOIL_WET_VAL)

3. Update constants in esp32_plant_monitor.ino:
   const int SOIL_DRY_VAL = 3500;
   const int SOIL_WET_VAL = 1400;
```

**LDR Sensor:**
```
1. Measure raw ADC in complete darkness → ~4000
2. Measure raw ADC in bright daylight → ~100
3. Arduino map() function converts to 0-100% scale
```

### **Upload Firmware**
```bash
1. Install Arduino IDE
2. Add ESP32 board support (Boards Manager)
3. Install required libraries:
   - DHT by Adafruit
   - ArduinoJson by Benoit Blanchon (v6.x)
4. Configure WiFi credentials in code
5. Add Firebase credentials
6. Upload to ESP32 via USB
```

---

## 📱 Mobile App Setup

### **Prerequisites**
```bash
# Install Flutter SDK (v3.0+)
flutter --version

# Install dependencies
cd mobile_app
flutter pub get
```

### **Firebase Configuration**

**Android Setup:**
1. Create Firebase project at console.firebase.google.com
2. Register app as Android
3. Download `google-services.json`
4. Place in `android/app/`

**iOS Setup:**
1. Register app as iOS in Firebase
2. Download `GoogleService-Info.plist`
3. Add to Xcode project

### **Run App**
```bash
# Debug mode
flutter run

# Release build
flutter build apk        # Android
flutter build ios        # iOS
```

---

## 🔧 Backend Configuration

### **Firebase Realtime Database Setup**

1. **Create Database**
   - Firebase Console → Realtime Database → Create Database
   - Start in test mode (for development)

2. **Enable Firebase Authentication**
   - Authentication → Sign-in methods
   - Enable Email/Password

3. **Configure Security Rules**
   ```rules
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       function isAuthenticated() {
         return request.auth != null;
       }
       
       function isOwner(userId) {
         return isAuthenticated() && request.auth.uid == userId;
       }

       match /users/{userId} {
         allow read, write: if isOwner(userId);
       }

       match /plants/{plantId} {
         allow read, write: if isAuthenticated() && resource.data.userId == request.auth.uid;
       }

       match /devices/{deviceId}/live/{document=**} {
         allow read: if isAuthenticated();
         allow write: if true;  // IoT nodes write data
       }
     }
   }
   ```

4. **Initialize Database Structure**
   - Use `firebase_schema.json` as reference
   - Create collections: users, plants, devices

---

## 📊 Data Flow

### **Sensor Reading → Cloud → Mobile**

```
1. ESP32 Sensor Reading (Every 5 seconds)
   ├─ Read DHT sensor
   ├─ Read soil moisture ADC
   ├─ Read LDR ADC
   └─ Convert to human-readable units

2. WiFi Connection Check
   ├─ Reconnect if disconnected
   └─ Verify internet connectivity

3. Firebase REST API Call
   ├─ Construct JSON payload
   ├─ PUT request to /devices/{deviceId}/live.json
   └─ Include auth token

4. Firebase Database Update
   ├─ Store in Realtime Database
   ├─ Trigger listeners
   └─ Real-time sync

5. Mobile App Receives Update
   ├─ Listen to Firebase RTDB changes
   ├─ Update provider state
   └─ Re-render dashboard widgets

6. User Sees Live Metrics
   ├─ 2x2 metric grid updates
   ├─ Status indicators change
   └─ Timestamp shows sync time
```

### **Sample Payload**
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

### **Firebase REST API**

**Read Live Sensor Data:**
```
GET /devices/{deviceId}/live.json?auth={firebaseToken}
```

**Write Sensor Data (from ESP32):**
```
PUT /devices/{deviceId}/live.json?auth={firebaseToken}
Content-Type: application/json

{
  "temperature": 24.5,
  "humidity": 58.2,
  "soilMoisture": 45,
  "lightLevel": 72,
  "timestamp": 1724123600000,
  "status": "online"
}
```

**Get User Plants:**
```
GET /plants.json?orderByChild=userId&equalTo={userId}&auth={firebaseToken}
```

**Create Plant Profile:**
```
POST /plants.json?auth={firebaseToken}
Content-Type: application/json

{
  "plantId": "PLANT_001",
  "userId": "USR_123",
  "name": "Living Room Monstera",
  "species": "Monstera Deliciosa",
  "deviceId": "plant_node_01",
  "minSoilMoisture": 30,
  "maxSoilMoisture": 75,
  "minTemperature": 18.0,
  "maxTemperature": 30.0
}
```

---

## 🗄️ Database Schema

### **Firestore Collections**

```yaml
users/
  ├── {userId}
  │   ├── uid: string
  │   ├── email: string
  │   ├── displayName: string
  │   └── createdAt: timestamp

plants/
  ├── {plantId}
  │   ├── plantId: string
  │   ├── userId: string (foreign key)
  │   ├── name: string
  │   ├── species: string
  │   ├── deviceId: string
  │   ├── minSoilMoisture: number
  │   ├── maxSoilMoisture: number
  │   ├── minTemperature: number
  │   ├── maxTemperature: number
  │   ├── minLightLevel: number
  │   ├── maxLightLevel: number
  │   ├── imageUrl: string
  │   └── createdAt: timestamp

devices/
  ├── {deviceId}
  │   └── live/
  │       ├── temperature: number
  │       ├── humidity: number
  │       ├── soilMoisture: number
  │       ├── lightLevel: number
  │       ├── timestamp: number
  │       └── status: string ("online" / "offline")
```

---

## 🎨 UI/UX Design

### **Design Tokens**

**Color Palette:**
- **Primary Green**: `#2E7D32` (Headers, Primary Buttons)
- **Secondary Emerald**: `#4CAF50` (Status Badges, Progress)
- **Dark Background**: `#0F172A` (Dark Mode)
- **Light Background**: `#F8FAFC` (Light Mode)
- **Warning Accent**: `#FFB300` (Low Moisture Alert)

**Typography:**
- **Heading 1**: SemiBold 24px (Screen Titles)
- **Heading 2**: SemiBold 18px (Card Titles)
- **Metric Display**: Bold 32px (Sensor Numbers)
- **Body Text**: Regular 14px (Content)
- **Caption**: Medium 12px (Timestamps)

### **Screen Layouts**

**Screen 1: Authentication Flow**
```
┌─────────────────────────┐
│   FloraCare 🌿          │
│  Real-time Monitoring   │
├─────────────────────────┤
│                         │
│  ┌─────────────────────┐│
│  │ Email             │ ││
│  └─────────────────────┘│
│                         │
│  ┌─────────────────────┐│
│  │ Password          │ ││
│  └─────────────────────┘│
│                         │
│  ┌─────────────────────┐│
│  │    Sign In        │ ││
│  └─────────────────────┘│
│                         │
│  Don't have account?    │
│      Register →         │
└─────────────────────────┘
```

**Screen 2: Live Dashboard**
```
┌─────────────────────────────────────┐
│  Welcome back, Alex! 👋             │
│  Living Room Monstera ▼   ● ONLINE  │
├─────────────────────────────────────┤
│  ┌────────────────┐ ┌──────────────┐│
│  │ 🌡️ Temperature │ │ 💧 Humidity  ││
│  │    24.5 °C     │ │    58 %      ││
│  │  Normal Range  │ │  Optimal     ││
│  └────────────────┘ └──────────────┘│
│  ┌────────────────┐ ┌──────────────┐│
│  │🌱 Soil Moisture│ │ ☀️  Sunlight ││
│  │     45 %       │ │    72 %      ││
│  │  [========]    │ │  Bright      ││
│  └────────────────┘ └──────────────┘│
│  Real-time streaming • Syncs every 5s
└─────────────────────────────────────┘
```

**Screen 3: Plant Management**
```
┌─────────────────────────────────────┐
│  My Plant Collection          🔍     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ 🌿 Monstera Deliciosa         ││
│  │ Living Room Monstera           ││
│  │ Device: plant_node_01          ││
│  │ 30-75% Moisture • 18-30°C      ││
│  │             ⋮ Edit / Delete     ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 🌺 Fern Species               ││
│  │ Balcony Fern                   ││
│  │ Device: plant_node_02          ││
│  │ [More plants...]               ││
│  └─────────────────────────────────┘│
│                              [+ Add] │
└─────────────────────────────────────┘
```

For detailed Figma specifications, see `figma_ui_design_spec.md`

---

## 📈 Development Phase

### **Current Status: 70% Prototype**

**Completed:**
- ✅ Hardware sensor integration
- ✅ WiFi connectivity (ESP32)
- ✅ Firebase backend setup
- ✅ Mobile app authentication
- ✅ Live dashboard UI
- ✅ Real-time data sync
- ✅ Plant profile management
- ✅ Figma UI design spec

**In Progress:**
- 🔄 Full Flutter implementation
- 🔄 Advanced state management
- 🔄 Push notifications
- 🔄 Error handling & edge cases

**Deferred to 100% Phase:**
- ⏳ Camera module (Plant ID)
- ⏳ Relay & Water pump control
- ⏳ Historical data charts
- ⏳ AI-based plant recommendations
- ⏳ Multi-user sharing
- ⏳ iOS/Android optimization

---

## 🤝 Contributing

### **How to Contribute**

1. **Fork the Repository**
   ```bash
   git clone https://github.com/Ayeshaniamat7/Smart-Plant-Care-System-project.git
   cd Smart-Plant-Care-System-project
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes & Commit**
   ```bash
   git add .
   git commit -m "Add: description of changes"
   ```

4. **Push & Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

### **Development Guidelines**

- Follow Flutter & Dart naming conventions
- Add comments for complex logic
- Test on both Android & iOS
- Update documentation as needed
- Ensure Firebase security rules are followed

---

## 📚 Additional Resources

- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter Documentation**: https://flutter.dev/docs
- **ESP32 Guide**: https://docs.espressif.com/projects/esp-idf/en/stable/
- **DHT Sensor Guide**: https://learn.adafruit.com/dht
- **Figma Design File**: (Link to be added)

---

## 📄 License

This project is open-source. See LICENSE file for details.

---

## 👨‍💻 Author

**Ayeshaniamat7**  
Smart Plant Care System - IoT & Mobile Development

---

## 🌱 Let's Grow Plants Smarter!

Monitor your plants in real-time and keep them healthy with our AI-based Smart Plant Care System.

**Questions?** Open an issue or start a discussion in the repository!

---

**Last Updated**: August 2024  
**Phase**: 70% Prototype  
**Status**: Active Development

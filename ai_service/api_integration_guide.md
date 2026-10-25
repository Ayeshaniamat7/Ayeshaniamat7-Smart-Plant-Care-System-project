# AI Service REST API & Backend Integration Guide

This guide details how to run the FastAPI microservice and connect it to your mobile app and Firebase backend.

---

## 🚀 1. Running the FastAPI Service

```bash
# Navigate to ai_service directory
cd ai_service

# Install dependencies
pip install -r requirements.txt

# Step 1: Train & export Scikit-learn model binaries (.joblib)
python train_models.py

# Step 2: Start Uvicorn ASGI Server on Port 8000
python main.py
```
The API interactive docs will be available at `http://localhost:8000/docs`.

---

## 🌐 2. API Endpoints Specification

### 2.1 Predict Health & Diagnosis (`POST /api/v1/predict-health`)
**Request Body**:
```json
{
  "soil_moisture": 22.5,
  "temperature": 34.2,
  "humidity": 45.0,
  "light_level": 80.0
}
```
**Response Body**:
```json
{
  "health_status": "CRITICAL_UNDERWATERED_HEAT",
  "confidence": 98.4,
  "recommendation": "Critical water deficit & heat stress detected! Water immediately.",
  "alert_level": "CRITICAL"
}
```

### 2.2 Predict Irrigation / Watering (`POST /api/v1/predict-watering`)
**Request Body**:
```json
{
  "soil_moisture": 22.5,
  "temperature": 34.2,
  "humidity": 45.0,
  "light_level": 80.0
}
```
**Response Body**:
```json
{
  "water_amount_ml": 380.5,
  "recommended_pump_seconds": 38,
  "hours_until_next_water": 0.5,
  "should_water_now": true
}
```

---

## 🔄 3. Backend & Mobile Integration Architecture

```
┌─────────────────┐       GET Telemetry        ┌──────────────────┐
│  Mobile App /   │ ─────────────────────────► │ Firebase Realtime│
│  Flutter Client │                            │ Database         │
└────────┬────────┘                            └──────────────────┘
         │                                               ▲
         │ 1. POST Sensor Readings                       │ 3. Push AI Alert
         ▼                                               │
┌─────────────────┐    2. Predict Health/Watering     ┌──┴───────────────┐
│ FastAPI AI      │ ────────────────────────────────► │ Cloud Functions /│
│ Microservice    │                                   │ Backend Worker   │
└─────────────────┘                                   └──────────────────┘
```

1. **Direct App Consumption**: The Flutter app calls `AIService.getDiagnosis(sensorData)` directly via HTTP POST to display AI insights in real-time.
2. **Automated Server Trigger**: A Node.js backend worker or Firebase Cloud Function listens to new sensor writes on Realtime Database, posts them to FastAPI, and updates `/devices/{deviceId}/alerts` automatically if `alert_level == "CRITICAL"`.

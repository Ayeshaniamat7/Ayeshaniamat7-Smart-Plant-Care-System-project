"""
========================================================================================
Smart Plant Care System - 100% Final Phase
FastAPI AI & ML REST API Service
========================================================================================
Exposes endpoint APIs:
  1. POST /api/v1/predict-health   -> Predicts plant health condition & actionable advice
  2. POST /api/v1/predict-watering -> Predicts exact watering amount (mL) & hours until next watering
  3. POST /api/v1/full-diagnosis   -> Combined health & watering AI inference
========================================================================================
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import os

app = FastAPI(
    title="Smart Plant Care AI Engine",
    description="Scikit-Learn ML Recommendation & Predictive Irrigation Microservice",
    version="1.0.0"
)

# Enable CORS for Flutter App & Backend consumption
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global model pointers
health_classifier = None
watering_regressor = None

# Pydantic Schemas
class SensorTelemetryRequest(BaseModel):
    soil_moisture: float = Field(..., ge=0, le=100, description="Soil Moisture percentage (0-100)")
    temperature: float = Field(..., ge=-10, le=60, description="Ambient temperature in Celsius")
    humidity: float = Field(..., ge=0, le=100, description="Air Humidity percentage (0-100)")
    light_level: float = Field(..., ge=0, le=100, description="Light intensity percentage (0-100)")

class HealthPredictionResponse(BaseModel):
    health_status: str
    confidence: float
    recommendation: str
    alert_level: str # INFO, WARNING, CRITICAL

class WateringPredictionResponse(BaseModel):
    water_amount_ml: float
    recommended_pump_seconds: int
    hours_until_next_water: float
    should_water_now: bool

class FullDiagnosisResponse(BaseModel):
    telemetry: SensorTelemetryRequest
    health: HealthPredictionResponse
    watering: WateringPredictionResponse

@app.on_event("startup")
def load_models():
    global health_classifier, watering_regressor
    clf_path = "models/plant_health_classifier.joblib"
    reg_path = "models/watering_prediction_regressor.joblib"

    if os.path.exists(clf_path) and os.path.exists(reg_path):
        health_classifier = joblib.load(clf_path)
        watering_regressor = joblib.load(reg_path)
        print("✅ Trained AI models loaded successfully!")
    else:
        print("⚠️ Models not found on startup. Training fallback models inline...")
        from train_models import train_and_export_models
        train_and_export_models()
        health_classifier = joblib.load(clf_path)
        watering_regressor = joblib.load(reg_path)

@app.get("/")
def health_check():
    return {"status": "online", "service": "Smart Plant Care AI API Engine", "version": "1.0.0"}

@app.post("/api/v1/predict-health", response_model=HealthPredictionResponse)
def predict_health(data: SensorTelemetryRequest):
    if not health_classifier:
        raise HTTPException(status_code=500, detail="Health classification model unavailable.")
    
    features = np.array([[data.soil_moisture, data.temperature, data.humidity, data.light_level]])
    prediction = health_classifier.predict(features)[0]
    probabilities = health_classifier.predict_proba(features)[0]
    confidence = float(np.max(probabilities))

    # Map status to advice & alert severity
    advice_map = {
        "HEALTHY_OPTIMAL": ("Optimal soil & climate conditions. Plant is thriving!", "INFO"),
        "NEEDS_WATER": ("Soil moisture is low. Recommended to run water pump cycle.", "WARNING"),
        "CRITICAL_UNDERWATERED_HEAT": ("Critical water deficit & heat stress detected! Water immediately.", "CRITICAL"),
        "OVERWATERED_RISK": ("Soil is saturated. Pause watering to prevent root rot.", "WARNING"),
        "LOW_SUNLIGHT_STRESS": ("Light levels are too low. Relocate plant closer to indirect sunlight.", "WARNING"),
        "HIGH_TEMP_STRESS": ("High ambient temperature detected. Ensure adequate shade and moisture.", "WARNING")
    }

    rec, alert_level = advice_map.get(prediction, ("Conditions stable.", "INFO"))

    return HealthPredictionResponse(
        health_status=prediction,
        confidence=round(confidence * 100, 1),
        recommendation=rec,
        alert_level=alert_level
    )

@app.post("/api/v1/predict-watering", response_model=WateringPredictionResponse)
def predict_watering(data: SensorTelemetryRequest):
    if not watering_regressor:
        raise HTTPException(status_code=500, detail="Watering prediction model unavailable.")
    
    features = np.array([[data.soil_moisture, data.temperature, data.humidity, data.light_level]])
    water_ml = float(watering_regressor.predict(features)[0])
    water_ml = max(0.0, round(water_ml, 1))

    # Calculate pump pulse duration (assuming pump rate of ~50 mL / 5 seconds -> 10 mL/sec)
    pump_seconds = int(round(water_ml / 10.0))
    should_water = water_ml > 50.0 and data.soil_moisture < 30.0

    return WateringPredictionResponse(
        water_amount_ml=water_ml,
        recommended_pump_seconds=pump_seconds,
        hours_until_next_water=12.0 if should_water else 24.0,
        should_water_now=should_water
    )

@app.post("/api/v1/full-diagnosis", response_model=FullDiagnosisResponse)
def full_diagnosis(data: SensorTelemetryRequest):
    health_res = predict_health(data)
    watering_res = predict_watering(data)
    return FullDiagnosisResponse(
        telemetry=data,
        health=health_res,
        watering=watering_res
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

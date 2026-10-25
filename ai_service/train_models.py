"""
========================================================================================
Smart Plant Care System - 100% Final Phase
AI & Machine Learning Model Training Script (Scikit-Learn)
========================================================================================
Generates synthetic sensor telemetry dataset and trains two machine learning models:
  1. Plant Health Status Classifier (RandomForestClassifier)
  2. Irrigation / Watering Prediction Model (RandomForestRegressor)
Exports trained model binaries (.joblib) for production inference via FastAPI.
========================================================================================
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, mean_absolute_error
import joblib
import os

def generate_synthetic_agronomic_dataset(n_samples=2000, random_state=42):
    np.random.seed(random_state)
    
    soil_moisture = np.random.uniform(5, 95, n_samples)
    temperature = np.random.uniform(10, 42, n_samples)
    humidity = np.random.uniform(20, 95, n_samples)
    light_level = np.random.uniform(10, 100, n_samples)

    health_status = []
    water_needed_ml = []
    hours_to_next_water = []

    for sm, t, h, l in zip(soil_moisture, temperature, humidity, light_level):
        if sm < 25 and t > 30:
            status = "CRITICAL_UNDERWATERED_HEAT"
            ml = np.random.uniform(350, 500)
            hours = np.random.uniform(0.5, 2.0)
        elif sm < 30:
            status = "NEEDS_WATER"
            ml = np.random.uniform(200, 350)
            hours = np.random.uniform(1.0, 4.0)
        elif sm > 80:
            status = "OVERWATERED_RISK"
            ml = 0.0
            hours = np.random.uniform(36.0, 72.0)
        elif l < 25:
            status = "LOW_SUNLIGHT_STRESS"
            ml = np.random.uniform(50, 150)
            hours = np.random.uniform(12.0, 24.0)
        elif t > 35:
            status = "HIGH_TEMP_STRESS"
            ml = np.random.uniform(150, 300)
            hours = np.random.uniform(4.0, 8.0)
        else:
            status = "HEALTHY_OPTIMAL"
            ml = 0.0
            hours = np.random.uniform(18.0, 36.0)
            
        health_status.append(status)
        water_needed_ml.append(round(ml, 1))
        hours_to_next_water.append(round(hours, 1))

    df = pd.DataFrame({
        'soil_moisture': soil_moisture,
        'temperature': temperature,
        'humidity': humidity,
        'light_level': light_level,
        'health_status': health_status,
        'water_needed_ml': water_needed_ml,
        'hours_to_next_water': hours_to_next_water
    })
    return df

def train_and_export_models():
    print("--- Training Smart Plant Care AI Models ---")
    df = generate_synthetic_agronomic_dataset()
    
    X = df[['soil_moisture', 'temperature', 'humidity', 'light_level']]
    y_health = df['health_status']
    y_water = df['water_needed_ml']

    X_train, X_test, y_h_train, y_h_test, y_w_train, y_w_test = train_test_split(
        X, y_health, y_water, test_size=0.2, random_state=42
    )

    clf = RandomForestClassifier(n_estimators=100, max_depth=8, random_state=42)
    clf.fit(X_train, y_h_train)
    y_h_pred = clf.predict(X_test)
    print("\n[Classifier Evaluation Report]")
    print(classification_report(y_h_test, y_h_pred))

    reg = RandomForestRegressor(n_estimators=100, max_depth=8, random_state=42)
    reg.fit(X_train, y_w_train)
    y_w_pred = reg.predict(X_test)
    mae = mean_absolute_error(y_w_test, y_w_pred)
    print(f"\n[Regressor Evaluation] Mean Absolute Error for Water Volume: {mae:.2f} mL")

    os.makedirs("models", exist_ok=True)
    joblib.dump(clf, "models/plant_health_classifier.joblib")
    joblib.dump(reg, "models/watering_prediction_regressor.joblib")
    print("\n[SUCCESS] AI Models exported to models/ directory!")

if __name__ == "__main__":
    train_and_export_models()

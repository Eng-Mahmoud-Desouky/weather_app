#!/usr/bin/env python3
"""
Script to create and save a machine learning model for exercise suitability prediction.

This script creates a simple Decision Tree model that predicts whether weather conditions
are suitable for outdoor exercise based on 5 binary features:
- outlook_rainy (0/1)
- outlook_sunny (0/1) 
- temperature_hot (0/1)
- temperature_mild (0/1)
- humidity_normal (0/1)

The model is trained on synthetic data and saved as model.pkl
"""

import pickle
import numpy as np
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report

def create_training_data():
    """
    Creates synthetic training data for the weather exercise suitability model.

    Returns:
        tuple: (features, labels) where features is a 2D array of weather conditions
               and labels is a 1D array of exercise suitability (0=not suitable, 1=suitable)
    """
    # Define training data based on logical rules:
    # Good for training: Sunny + (Hot OR Mild) + Normal Humidity
    # Bad for training: Rainy OR (Cold + High/Low Humidity)
    
    training_data = [
        # [rainy, sunny, hot, mild, normal_humidity, suitable_for_training]
        [0, 1, 0, 1, 1, 1],  # Sunny, mild, normal humidity -> Good (1)
        [0, 1, 1, 0, 1, 1],  # Sunny, hot, normal humidity -> Good (1)
        [0, 1, 0, 1, 0, 1],  # Sunny, mild, extreme humidity -> OK (1)
        [0, 1, 1, 0, 0, 1],  # Sunny, hot, extreme humidity -> OK (1)
        [1, 0, 0, 1, 1, 0],  # Rainy, mild, normal humidity -> Bad (0)
        [1, 0, 1, 0, 1, 0],  # Rainy, hot, normal humidity -> Bad (0)
        [1, 0, 0, 1, 0, 0],  # Rainy, mild, extreme humidity -> Bad (0)
        [1, 0, 1, 0, 0, 0],  # Rainy, hot, extreme humidity -> Bad (0)
        [0, 0, 0, 1, 1, 1],  # Cloudy, mild, normal humidity -> OK (1)
        [0, 0, 1, 0, 1, 1],  # Cloudy, hot, normal humidity -> Good (1)
        [0, 0, 0, 1, 0, 0],  # Cloudy, mild, extreme humidity -> Bad (0)
        [0, 0, 1, 0, 0, 0],  # Cloudy, hot, extreme humidity -> Bad (0)
        [0, 0, 0, 0, 1, 0],  # Cloudy, cold, normal humidity -> Bad (0)
        [0, 0, 0, 0, 0, 0],  # Cloudy, cold, extreme humidity -> Bad (0)
        [0, 1, 0, 0, 1, 0],  # Sunny, cold, normal humidity -> Bad (0)
        [0, 1, 0, 0, 0, 0],  # Sunny, cold, extreme humidity -> Bad (0)
        [1, 0, 0, 0, 1, 0],  # Rainy, cold, normal humidity -> Bad (0)
        [1, 0, 0, 0, 0, 0],  # Rainy, cold, extreme humidity -> Bad (0)

        # Additional variations for better training
        [0, 1, 0, 1, 1, 1],  # Duplicate good conditions
        [0, 1, 1, 0, 1, 1],  # Duplicate good conditions
        [1, 0, 0, 1, 1, 0],  # Duplicate bad conditions (rainy)
        [1, 0, 1, 0, 1, 0],  # Duplicate bad conditions (rainy)
        [0, 0, 0, 0, 0, 0],  # Duplicate bad conditions (cold + extreme humidity)
        [0, 0, 0, 0, 1, 0],  # Duplicate bad conditions (cold)

        # More diverse training data
        [0, 1, 0, 1, 1, 1],  # More sunny mild normal
        [0, 1, 1, 0, 1, 1],  # More sunny hot normal
        [0, 0, 1, 0, 1, 1],  # More cloudy hot normal
        [1, 0, 0, 1, 1, 0],  # More rainy mild normal
        [1, 0, 1, 0, 1, 0],  # More rainy hot normal
        [0, 0, 0, 0, 0, 0],  # More cold extreme
    ]
    
    features = []
    labels = []
    
    for data_point in training_data:
        features.append(data_point[:-1])  # All except last element
        labels.append(data_point[-1])     # Last element is the label
    
    return np.array(features), np.array(labels)

def create_and_save_model():
    """
    Creates, trains, and saves the machine learning model.
    """
    print("Creating training data...")
    X, y = create_training_data()
    
    print(f"Training data shape: {X.shape}")
    print(f"Labels shape: {y.shape}")
    print(f"Positive samples (suitable): {np.sum(y)}")
    print(f"Negative samples (not suitable): {len(y) - np.sum(y)}")
    
    # Split data for training and testing
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.3, random_state=42, stratify=y
    )
    
    print("\nTraining Decision Tree model...")
    # Create and train the model
    model = DecisionTreeClassifier(
        random_state=42,
        max_depth=5,
        min_samples_split=2,
        min_samples_leaf=1
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate the model
    train_predictions = model.predict(X_train)
    test_predictions = model.predict(X_test)
    
    train_accuracy = accuracy_score(y_train, train_predictions)
    test_accuracy = accuracy_score(y_test, test_predictions)
    
    print(f"\nModel Performance:")
    print(f"Training Accuracy: {train_accuracy:.2f}")
    print(f"Testing Accuracy: {test_accuracy:.2f}")
    
    print(f"\nClassification Report:")
    print(classification_report(y_test, test_predictions, 
                              target_names=['Not Suitable', 'Suitable']))
    
    # Save the model
    model_path = 'model.pkl'
    with open(model_path, 'wb') as file:
        pickle.dump(model, file)
    
    print(f"\nModel saved successfully to: {model_path}")
    
    # Test the saved model
    print("\nTesting saved model...")
    test_saved_model(model_path)
    
    return model

def test_saved_model(model_path):
    """
    Tests the saved model with sample predictions.
    
    Args:
        model_path (str): Path to the saved model file
    """
    # Load the model
    with open(model_path, 'rb') as file:
        loaded_model = pickle.load(file)
    
    # Test cases
    test_cases = [
        ([0, 1, 0, 1, 1], "Sunny, mild, normal humidity"),
        ([0, 1, 1, 0, 1], "Sunny, hot, normal humidity"),
        ([1, 0, 0, 1, 1], "Rainy, mild, normal humidity"),
        ([0, 0, 0, 0, 0], "Cloudy, cold, extreme humidity"),
        ([0, 1, 0, 0, 1], "Sunny, cold, normal humidity"),
    ]
    
    print("Sample Predictions:")
    print("-" * 60)
    
    for features, description in test_cases:
        # Convert to 2D array as required by sklearn
        features_2d = np.array(features).reshape(1, -1)
        prediction = loaded_model.predict(features_2d)[0]
        probability = loaded_model.predict_proba(features_2d)[0]
        
        result = "Suitable" if prediction == 1 else "Not Suitable"
        confidence = max(probability) * 100
        
        print(f"Features: {features}")
        print(f"Condition: {description}")
        print(f"Prediction: {result} (Confidence: {confidence:.1f}%)")
        print("-" * 60)

if __name__ == "__main__":
    print("Weather Exercise Suitability Model Creator")
    print("=" * 50)
    
    try:
        model = create_and_save_model()
        print("\n✅ Model creation completed successfully!")
        
    except Exception as e:
        print(f"\n❌ Error creating model: {e}")
        raise

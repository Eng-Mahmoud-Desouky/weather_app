#!/usr/bin/env python3
"""
Test script for the machine learning model.

This script loads the trained model from the pickle file and tests it
with sample weather features to verify it's working correctly.
"""

import pickle
import numpy as np
import os

def test_model():
    """
    Load the model from the pickle file and test it with sample features.
    """
    # Path to the pickle file
    file_path = "model.pkl"
    
    # Check if the model file exists
    if not os.path.exists(file_path):
        print(f"❌ Error: Model file '{file_path}' not found!")
        print("Please run 'python create_model.py' first to create the model.")
        return
    
    try:
        # Load the model from the pickle file
        print(f"📁 Loading model from: {file_path}")
        with open(file_path, 'rb') as file:
            model = pickle.load(file)
        
        print("✅ Model loaded successfully!")
        print(f"📊 Model type: {type(model).__name__}")
        
        # Sample features: [outlook_rainy, outlook_sunny, temperature_hot, temperature_mild, humidity_normal]
        sample_features = [0, 1, 0, 1, 1]  # Sunny, mild temperature, normal humidity
        
        print(f"\n🧪 Testing with sample features: {sample_features}")
        print("   Features meaning:")
        print("   [0] outlook_rainy: 0 (No)")
        print("   [1] outlook_sunny: 1 (Yes)")
        print("   [2] temperature_hot: 0 (No)")
        print("   [3] temperature_mild: 1 (Yes)")
        print("   [4] humidity_normal: 1 (Yes)")
        print("   → Condition: Sunny, mild temperature, normal humidity")
        
        # Convert the sample features to a 2D array (required by sklearn)
        sample_features_2d = np.array(sample_features).reshape(1, -1)
        
        # Predict using the loaded model
        prediction = model.predict(sample_features_2d)
        
        # Get prediction probability if available
        try:
            probabilities = model.predict_proba(sample_features_2d)
            confidence = max(probabilities[0]) * 100
            print(f"\n🎯 Prediction: {prediction[0]}")
            print(f"📈 Confidence: {confidence:.1f}%")
            print(f"📊 Probabilities: [Not Suitable: {probabilities[0][0]:.3f}, Suitable: {probabilities[0][1]:.3f}]")
        except AttributeError:
            print(f"\n🎯 Prediction: {prediction[0]}")
            print("📈 Confidence: Not available (model doesn't support probabilities)")
        
        # Interpret the result
        if prediction[0] == 1:
            print("✅ Result: Suitable for training!")
        else:
            print("❌ Result: Not suitable for training!")
        
        # Test multiple scenarios
        print("\n" + "="*60)
        print("🧪 TESTING MULTIPLE SCENARIOS")
        print("="*60)
        
        test_scenarios = [
            ([0, 1, 0, 1, 1], "Sunny, mild, normal humidity"),
            ([0, 1, 1, 0, 1], "Sunny, hot, normal humidity"),
            ([1, 0, 0, 1, 1], "Rainy, mild, normal humidity"),
            ([1, 0, 1, 0, 1], "Rainy, hot, normal humidity"),
            ([0, 0, 0, 1, 1], "Cloudy, mild, normal humidity"),
            ([0, 0, 0, 0, 0], "Cloudy, cold, extreme humidity"),
            ([0, 1, 0, 0, 1], "Sunny, cold, normal humidity"),
        ]
        
        for i, (features, description) in enumerate(test_scenarios, 1):
            features_2d = np.array(features).reshape(1, -1)
            pred = model.predict(features_2d)[0]
            
            try:
                prob = model.predict_proba(features_2d)[0]
                conf = max(prob) * 100
                result = f"{'✅ Suitable' if pred == 1 else '❌ Not Suitable'} ({conf:.1f}%)"
            except AttributeError:
                result = f"{'✅ Suitable' if pred == 1 else '❌ Not Suitable'}"
            
            print(f"{i}. {description:<35} → {result}")
        
        print("\n✅ Model testing completed successfully!")
        
    except Exception as e:
        print(f"❌ Error loading or testing model: {e}")
        print("Please make sure the model file is valid and created properly.")
        raise

if __name__ == "__main__":
    print("🧠 Weather Training Suitability Model Tester")
    print("=" * 50)
    test_model()

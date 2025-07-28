#!/usr/bin/env python3
"""
Simple test to verify Flask and model work together.
"""

from flask import Flask, jsonify
import pickle
import numpy as np

app = Flask(__name__)

# Load model
print("Loading model...")
with open('model.pkl', 'rb') as file:
    model = pickle.load(file)
print("Model loaded successfully!")

@app.route('/test')
def test():
    # Test prediction
    sample_features = [0, 1, 0, 1, 1]  # Sunny, mild, normal humidity
    sample_features_2d = np.array(sample_features).reshape(1, -1)
    prediction = model.predict(sample_features_2d)[0]
    
    return jsonify({
        'status': 'success',
        'features': sample_features,
        'prediction': int(prediction),
        'message': 'Test successful!'
    })

if __name__ == '__main__':
    print("Starting simple test server...")
    app.run(host='127.0.0.1', port=5001, debug=False)

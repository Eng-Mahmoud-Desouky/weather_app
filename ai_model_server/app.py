"""
Flask AI Model Server for Weather Exercise Prediction

This server loads a pre-trained machine learning model and provides
a REST API endpoint for making predictions about exercise suitability
based on weather conditions.

The model expects 5 binary features:
- outlook is rainy (0/1)
- outlook is sunny (0/1)
- temperature is hot (0/1)
- temperature is mild (0/1)
- humidity is normal (0/1)

Returns: 0 (not suitable for exercise) or 1 (suitable for exercise)
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np
import os

# Initialize Flask application
app = Flask(__name__)

# Enable CORS for all routes to allow Flutter app to make requests
CORS(app)

# Global variable to store the loaded model
model = None

def load_model():
    """
    Load the machine learning model from the pickle file.
    This function uses the exact code provided by the user.
    """
    global model
    
    try:
        # Path to the model file (relative to this script)
        file_path = "model.pkl"  # Put here the path of the pkl file
        
        # Check if model file exists
        if not os.path.exists(file_path):
            print(f"Warning: Model file '{file_path}' not found!")
            print("Please place your model.pkl file in the ai_model_server directory")
            return False
            
        # Load the model from the pickle file (using provided code)
        with open(file_path, 'rb') as file:
            model = pickle.load(file)
            
        print("Model loaded successfully!")
        return True
        
    except Exception as e:
        print(f"Error loading model: {str(e)}")
        return False

def make_prediction(features):
    """
    Make a prediction using the loaded model.
    This function uses the exact prediction code provided by the user.
    
    Args:
        features (list): List of 5 binary values [0/1, 0/1, 0/1, 0/1, 0/1]
        
    Returns:
        int: Prediction result (0 or 1)
    """
    global model
    
    if model is None:
        raise Exception("Model not loaded")
    
    # Use the exact prediction code provided by the user
    sample_features = features
    
    # Convert the sample features to a 2D array 
    sample_features = np.array(sample_features).reshape(1, -1)
    
    # Predict using the loaded model
    prediction = model.predict(sample_features)
    
    # Return the prediction (convert numpy array to Python int)
    return int(prediction[0])

@app.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint to verify server is running.
    
    Returns:
        JSON response with server status
    """
    return jsonify({
        'status': 'healthy',
        'message': 'AI Model Server is running',
        'model_loaded': model is not None
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Main prediction endpoint that receives weather features and returns exercise suitability.

    Expected JSON payload:
    {
        "features": [0, 1, 0, 1, 1]  // 5 binary values
    }

    Returns:
        JSON response with prediction result
    """
    try:
        # Check if model is loaded
        if model is None:
            return jsonify({
                'error': 'Model not loaded',
                'message': 'Please ensure model.pkl file is available'
            }), 500
        
        # Get JSON data from request
        data = request.get_json()
        
        # Validate request data
        if not data or 'features' not in data:
            return jsonify({
                'error': 'Invalid request',
                'message': 'Request must contain "features" array'
            }), 400
        
        features = data['features']
        
        # Validate features array
        if not isinstance(features, list) or len(features) != 5:
            return jsonify({
                'error': 'Invalid features',
                'message': 'Features must be an array of exactly 5 values'
            }), 400
        
        # Validate that all features are binary (0 or 1)
        if not all(f in [0, 1] for f in features):
            return jsonify({
                'error': 'Invalid feature values',
                'message': 'All features must be binary (0 or 1)'
            }), 400
        
        # Make prediction using the provided code
        prediction = make_prediction(features)
        
        # Prepare response with detailed information
        response = {
            'prediction': prediction,
            'suitable_for_training': prediction == 1,
            'confidence': 'high',  # You can enhance this based on your model
            'input_features': {
                'outlook_rainy': features[0],
                'outlook_sunny': features[1],
                'temperature_hot': features[2],
                'temperature_mild': features[3],
                'humidity_normal': features[4]
            },
            'message': 'Suitable for exercise' if prediction == 1 else 'Not suitable for exercise'
        }
        
        return jsonify(response)
        
    except Exception as e:
        # Handle any errors during prediction
        return jsonify({
            'error': 'Prediction failed',
            'message': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors with helpful message."""
    return jsonify({
        'error': 'Endpoint not found',
        'message': 'Available endpoints: /health (GET), /predict (POST)'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors with helpful message."""
    return jsonify({
        'error': 'Internal server error',
        'message': 'Something went wrong on the server'
    }), 500

if __name__ == '__main__':
    print("Starting AI Model Server...")
    print("Loading machine learning model...")
    
    # Load the model on startup
    if load_model():
        print("Server ready to accept predictions!")
    else:
        print("Server starting without model - predictions will fail until model is loaded")
    
    # Start the Flask development server
    # Note: In production, use a proper WSGI server like Gunicorn
    app.run(
        host='127.0.0.1',  # Only accept local connections for security
        port=5000,         # Standard Flask port
        debug=True,        # Enable debug mode for development
        threaded=True      # Handle multiple requests concurrently
    )

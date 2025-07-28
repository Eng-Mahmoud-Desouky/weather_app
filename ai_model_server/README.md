# AI Model Server

This Flask server provides AI prediction capabilities for the weather training app.

## Setup Instructions

1. **Install Python dependencies:**
   ```bash
   cd ai_model_server
   pip install -r requirements.txt
   ```

2. **Add your model file:**
   - Place your trained model file as `model.pkl` in this directory
   - The model should accept 5 binary features and return 0 or 1

3. **Start the server:**
   ```bash
   python app.py
   ```

4. **Test the server:**
   ```bash
   curl http://127.0.0.1:5000/health
   ```

## API Endpoints

### Health Check
- **URL:** `GET /health`
- **Response:** Server status and model loading status

### Prediction
- **URL:** `POST /predict`
- **Body:** 
  ```json
  {
    "features": [0, 1, 0, 1, 1]
  }
  ```
- **Response:**
  ```json
  {
    "prediction": 1,
    "suitable_for_training": true,
    "input_features": {
      "outlook_rainy": 0,
      "outlook_sunny": 1,
      "temperature_hot": 0,
      "temperature_mild": 1,
      "humidity_normal": 1
    },
    "message": "Suitable for training"
  }
  ```

## Feature Mapping

The 5 input features represent:
1. **outlook_rainy** (0/1): Whether the outlook is rainy
2. **outlook_sunny** (0/1): Whether the outlook is sunny  
3. **temperature_hot** (0/1): Whether temperature is hot
4. **temperature_mild** (0/1): Whether temperature is mild
5. **humidity_normal** (0/1): Whether humidity is normal

## Notes

- Server runs on `http://127.0.0.1:5000` by default
- CORS is enabled for Flutter app integration
- Place your `model.pkl` file in this directory before starting

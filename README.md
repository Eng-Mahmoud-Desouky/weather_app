# 🌤️ Flutter Weather App

This is the implementation of the Home Page Feature for the summer internship task.  
It displays the current weather and a 3-day forecast using Clean Architecture, BLoC, and Weather API integration.

---

## 📽️ Demo Video  
Watch the app in action here: [Click to watch](https://youtube.com/shorts/29xjLpxyy0A?feature=share)

---

## ✨ Features

- Fetch and display current weather
- Show 3-day weather forecast
- Bloc state management
- AI prediction

---

## 📦 Technologies Used

- Flutter
- Dart
- Bloc (flutter_bloc)
- Clean Architecture
- HTTP + Weather API 
- Flask AI Model Server

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
gh repo clone Eng-Mahmoud-Desouky/weather_app
cd home_page_feature
2. Install dependencies
bash
Copy
Edit
flutter pub get
3. Run the app
bash
Copy
Edit
flutter run

---

🧠 AI Prediction Feature
This feature uses an AI model to predict if the current weather is suitable for physical training.

📌 Logic
Weather is converted into features for prediction:

Outlook Rainy → 0 or 1

Outlook Sunny → 0 or 1

Temperature Hot → >30°C

Temperature Mild → 15–30°C

Humidity Normal → 40–70%

These features are sent to a Flask server running an ML model.

📁 Project Structure
kotlin
Copy
Edit
lib/
└── features/
    ├── home_page/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── ai_prediction/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   ├── usecases/
        │   └── utils/
        └── presentation/
            ├── bloc/
            └── widgets/
🔌 Flask Server Setup (for AI Prediction)
1. Navigate to the server directory
bash
Copy
Edit
cd ai_model_server
2. Install Python dependencies
bash
Copy
Edit
pip install -r requirements.txt
3. Run the Flask server
bash
Copy
Edit
python app.py
Make sure the file model.pkl exists in the server directory.

🧪 Testing
bash
Copy
Edit
flutter test test/features/ai_prediction/
🛠️ Error Handling
Network/connection errors

Flask server errors

Invalid weather data

Model not loaded

Timeout (default: 10s)

🔮 Future Enhancements
Cache predictions

Offline support

User feedback-based learning

Dynamic thresholds

Multiple model versions

👤 Author
Mahmoud Desouky
Summer Internship 2025

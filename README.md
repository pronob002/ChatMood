# ChatMood

A Flutter-based mobile application with a Flask backend for analyzing WhatsApp chat data and generating mood insights through NLP-based processing.

## Overview

ChatMood is a cross-platform application designed to analyze exported WhatsApp chat data and provide users with mood-related insights through a simple and interactive interface. The project combines a **Flutter frontend** with a **Flask backend API**, integrating natural language processing to process conversation data and return analytical results.

This project demonstrates practical experience in mobile application development, backend API development, frontend-backend integration, and applied NLP in a real-world use case.

## Demo Video

A demo video of the project is available on YouTube:

**Project Demo:** [Watch ChatMood Demo Video on YouTube](https://youtube.com/shorts/oQkKyl94OWY)

> The demo video provides a walkthrough of the application's interface and the chat analysis workflow.

## Key Features

- Flutter-based mobile user interface
- Upload and process exported WhatsApp chat files
- Flask backend API for text processing
- NLP-based mood analysis workflow
- Visual and interactive presentation of analytical output
- End-to-end integration between frontend and backend

## Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- Python
- Flask
- Flask-CORS

### NLP / ML
- Hugging Face Transformers
- DistilBERT
- PyTorch

## Repository Structure

```text
ChatMood/
├── APP/                  # Flutter frontend
│   ├── android/
│   ├── asset/
│   ├── ios/
│   ├── lib/
│   ├── linux/
│   ├── macos/
│   ├── test/
│   ├── web/
│   ├── windows/
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   └── analysis_options.yaml
├── app.py                # Flask backend entry point
├── requirements.txt      # Python dependencies
└── README.md
How It Works
The user provides chat data through the Flutter application.
The Flutter frontend sends the input to the Flask backend API.
The backend processes the text using NLP components.
The backend returns the analysis result.
The frontend displays the result in a user-friendly way.
Installation and Setup
Prerequisites
Before running the project, make sure you have:

Frontend
Flutter 3.16.9
Dart 3.2.6
Java 17
Android Studio or Visual Studio Code
Android emulator or a physical Android device
Backend
Python 3.x
pip
Backend Setup
Clone the repository:


git clone https://github.com/pronob002/ChatMood.git
cd ChatMood
Create and activate a virtual environment:
Windows


python -m venv venv
venv\Scripts\activate
Linux / macOS


python3 -m venv venv
source venv/bin/activate
Install backend dependencies:


pip install -r requirements.txt
Run the Flask backend:


python app.py
The backend will start locally at:



http://127.0.0.1:8000
Frontend Setup
Move into the Flutter project directory:


cd APP
Install Flutter dependencies:


flutter pub get
Run the Flutter app:


flutter run
Important Emulator Note
If you are running the Flutter app on an Android emulator, the frontend should call:



http://10.0.2.2:8000
instead of:


http://127.0.0.1:8000
This is because 127.0.0.1 inside the emulator points to the emulator itself, not your local machine.

Recommended Working Environment
The project was successfully run using the following setup:

Flutter: 3.16.9
Dart: 3.2.6
Java: 17
Python: 3.x
Flask API Port: 8000
Common Setup Notes
Use Java 17 for Android builds
If you use FVM, Flutter 3.16.9 is recommended for this project
If backend requests fail on emulator, verify that the API base URL is set to http://10.0.2.2:8000
If using a physical Android device, use your computer’s local IP address instead of 127.0.0.1
Project Highlights
Built a Flutter application for mobile-based chat analysis
Developed a Flask backend for text processing and API integration
Applied NLP techniques using transformer-based models
Integrated frontend and backend into a complete end-to-end workflow
Improved project structure and UI with updated dependencies and Material 3 design updates
What I Learned
Through this project, I strengthened my skills in:

Flutter mobile application development
Flask-based backend API development
Frontend-backend communication
NLP model integration in real application workflows
Handling cross-environment setup, dependency issues, and emulator configuration
Future Improvements
Improve the quality and granularity of mood prediction
Add support for additional messaging platforms
Improve visual analytics and trend tracking
Deploy the backend to a public server for easier access
Add authentication and user-specific data history
Why This Project Matters
ChatMood reflects my ability to combine mobile development, backend engineering, and applied machine learning into a single end-to-end application. It highlights practical software development skills, integration capability, and a problem-solving approach to building usable technology.

Author
Pronob Saha
GitHub: pronob002

License
This project is shared for educational and portfolio purposes.

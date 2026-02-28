## 🪸 Coral Guard
Team Name: Fantastic Four

---
## 🌊 Project Overview

Coral Guard is an AI-powered web application that analyzes coral reef images and simulates short-term reef stress conditions using a micro digital twin approach.
The system integrates Google Cloud Vision API and Google Gemini to provide intelligent reef health assessments and actionable environmental conservation recommendations.

---
## ✨ Key Features

- AI-powered coral reef image analysis  
- Temperature-based reef stress simulation  
- Automated reef health score generation  
- Actionable conservation recommendations  
- Modular and scalable full-stack architecture

---
## 🎯 SDG Alignment

This project aligns with:

SDG 13 – Climate Action
SDG 14 – Life Below Water

Coral Guard helps monitor coral reef stress caused by rising sea temperatures and environmental changes, enabling faster and more accessible environmental assessment.

---
## 🤖 Google Technologies Used
1.	Google AI Technologies
•	Google Gemini (via Google AI Studio)
•	Google Cloud Vision API
2.	Google Developer Technologies
•	Flutter Web
•	FastAPI (Backend API)
•	Firebase (optional hosting configuration ready)
---
## 🧠 Why AI?

Coral reef stress analysis is contextual and multi-factor dependent.
Traditional rule-based systems cannot dynamically interpret visual reef indicators and environmental conditions together.

By integrating Google Vision API and Gemini, Coral Guard:
- Automates reef inspection
- Provides contextual environmental reasoning
- Generates adaptive conservation recommendations
---
## 🏗 System Architecture
User
↓
Flutter Web (Image Upload + Temperature Input)
↓
FastAPI Backend
↓
Google Vision API → Extract image features
↓
Google Gemini → Interpret & Generate Recommendations
↓
Backend formats response
↓
Flutter displays health assessment

---
## 📸 Application Preview

### Home Interface
<img width="1919" height="906" alt="image" src="https://github.com/user-attachments/assets/3ac761c0-1c4b-4078-89d6-dce925f36ddf" />

### AI Result Display
<img width="960" height="791" alt="image" src="https://github.com/user-attachments/assets/26da8baa-20e3-4380-b958-5f61a2df24a4" />

---
##  📁 Project Structure

```
root/
│
├── backend/                # FastAPI backend server
│   ├── main.py
│   ├── requirements.txt
│   └── .env (excluded via .gitignore)
│
├── coralguard/             # Flutter Web frontend
│   ├── lib/
│   ├── web/
│   ├── pubspec.yaml
│
├── .gitignore
└── README.md
```
---
## ⚙️ Prerequisites
Make sure you have installed:
•	Python 3.9+
•	Flutter SDK (3.x recommended)
•	Git
•	Google Cloud credentials (Vision API)
•	Gemini API Key (Google AI Studio)

---
## 🚀 Step-by-Step Setup Guide 
1.	Backend Setup (FastAPI)
Step 1: Navigate to backend folder
```
cd backend
```
---
Step 2: Create Visual Environment
Windows:
```
python -m venv venv
venv\Scripts\activate
```
OR
Mac/Linux:
```
python3 -m venv venv
source venv/bin/activate
```
---
Step 3: Install Dependencies
```
pip install -r requirements.txt
```
If requirements.txt encoding causes issues, reinstall manually:
pip install fastapi uvicorn python-dotenv google-cloud-vision google-generativeai

---
Step 4: Configure Environment Variables
Create a file named:
```
.env
```
Add:
```
GEMINI_API_KEY=your_gemini_api_key_here
```
---
Step 5: Set Google Vision Credentials
Download your Google Cloud Vision service account JSON file.
Set environment variable:

Windows:
```
set GOOGLE_APPLICATION_CREDENTIALS=path\to\your\service-account.json
```
OR
Mac/Linux:
```
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account.json"
```
---
Step 6: Run Backend Server
```
uvicorn main:app --reload
```
Server should run at:
```
http://127.0.0.1:8000
```
Test endpoint at:
```
http://127.0.0.1:8000/docs
```
---
2.	Frontend Setup (Flutter Web)
Step 1: Navigate to Flutter folder
Open a new terminal:
```
cd coralguard
```
---
Step 2: Get Dependencies
```
flutter pub get
```
---
Step 3: Run Flutter Web
```
flutter run -d chrome - -release
```
The app will open in browser.
---
## 🔄_How the Full System Works_
1.	User uploads coral reef image
2.	User sets water temperature
3.	Flutter sends POST request to backend
4.	Backend:
	Sends image to Google Vision API
	Extracts image properties
	Sends results + temperature to Gemini
	Generates health analysis & recommendations
5.	Backend returns structured JSON
6.	Flutter displays assessment card
---
## 🌐 API Endpoint

### POST `/analyze`

### Request
- Image file (multipart/form-data)
- Temperature value (float)

### Response
```json
{
  "health_score": 78,
  "action": "Coral reef shows mild stress due to elevated temperature.",
  "recommendations": [
    "Monitor water temperature closely",
    "Reduce local pollution impact",
    "Implement reef shading techniques"
  ]
}
```
---
🧪 Testing the Application
1.	Start backend
2.	Start Flutter frontend
3.	Upload any coral reef image
4.	Adjust temperature slider
5.	Click Analyze
6.	View AI-generated results
---
🛠 Troubleshooting

❌ CORS Error
Ensure FastAPI has CORS middleware enabled.

---

❌ Gemini API Error
Check:
•	Correct API key
•	.env file exists
•	Internet connection active

---
❌ Vision API Error
Check:
•	Service account JSON path correct
•	Google Cloud project has Vision API enabled

---
🔐 Security Notes
•	Never upload .env to GitHub
•	Never upload service-account JSON
•	Use .gitignore properly

---
## ☁ Deployment Readiness

The system is cloud-ready and can be deployed using:

- Firebase Hosting (Frontend)
- Google Cloud Run (Backend)
- Firestore for storing analysis history

The modular architecture supports horizontal scaling and future AI model integration.

---
## Future Improvements
-	Deploy backend on Google Cloud Run
-	Deploy frontend via Firebase Hosting
-	Store analysis history in Firestore
-	Improve digital twin simulation accuracy
-	Add real-time reef monitoring dashboard
---
## Technical Architecture

Coral Guard follows a modular full-stack architecture:

- **Frontend (Flutter Web)**  
  Handles user interaction including image upload and temperature input.

- **Backend (FastAPI)**  
  Manages API orchestration, request validation, AI integration, and response formatting.

- **Google Cloud Vision API**  
  Extracts structured visual features from coral reef images.

- **Google Gemini (AI Studio)**  
  Performs contextual reef stress reasoning and generates conservation recommendations.

The system follows a clear data flow:
User → Flutter → FastAPI → Vision API → Gemini → Backend → Frontend.

This separation of concerns ensures scalability, maintainability, and cloud readiness.

---
## Implementation Details

- Built frontend using **Flutter Web** with structured UI components.
- Developed backend using **FastAPI** with RESTful endpoint `/analyze`.
- Integrated **Google Vision API** for image feature extraction.
- Integrated **Google Gemini** for contextual AI reasoning.
- Implemented structured JSON response model for health score and recommendations.
- Applied secure API key handling using environment variables.
- Designed a simplified micro digital twin logic to simulate reef stress conditions based on temperature and visual indicators.

---
## Challenges Faced

- Handling image upload and multipart data transfer between Flutter and FastAPI.
- Managing API key security and environment variable configuration.
- Ensuring Vision API outputs were structured properly for Gemini input.
- Designing effective AI prompts to generate meaningful and actionable conservation recommendations.
- Improving UI clarity based on user feedback to reduce text-heavy output.

These challenges were resolved through iterative testing, prompt refinement, and modular architecture adjustments.

---
## Future Roadmap

- Deploy backend on Google Cloud Run.
- Deploy frontend via Firebase Hosting.
- Integrate Firestore to store historical reef assessments.
- Connect to real-time ocean temperature APIs.
- Enhance digital twin modeling with predictive analytics.
- Improve AI accuracy through dataset expansion and tuning.

The modular architecture allows seamless scaling and integration of additional AI services in the future.
---
## Contributors
Backend & AI Integration:
1.	Kishanea A/L Jeyakumar
2.	Liew Jia Xin
3.	Hang Xiu Jun

Frontend Development:
1.	Ng Guan Yik
---
## Demo Video
YouTube Link: 

---
## License
This project was developed for KitaHack 2026 and educational purposes.

---

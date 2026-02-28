Team Name: Fantastic Four
Project Name: Coral Guard
What is it for: AI-Powered Coral Reef Stress Assessment Using Google AI
Coral Guard is a Flutter-based web application that uses Google AI technologies to analyse coral reef images and simulate short-term reef stress conditions through a micro digital twin model.

The system integrates Google Vision API and Google Gemini to provide intelligent reef health analysis and actionable environmental recommendations.
________________________________________
SDG Alignment
This project aligns with:
SDG 13 – Climate Action
SDG 14 – Life Below Water
Coral Guard helps monitor coral reef stress caused by rising sea temperatures and environmental changes.
________________________________________
Google Technologies Used
1.	Google AI Technologies
•	Google Gemini (via Google AI Studio)
•	Google Cloud Vision API
2.	Google Developer Technologies
•	Flutter Web
•	FastAPI (Backend API)
•	Firebase (optional hosting configuration ready)
________________________________________
System Architecture
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
________________________________________
Project Structure 
root/
│
├── backend/              # FastAPI backend server
│   ├── main.py
│   ├── requirements.txt
│   └── .env (NOT uploaded to GitHub)
│
├── coralguard/           # Flutter Web frontend
│   ├── lib/
│   ├── web/
│   └── pubspec.yaml
│
└── README.md
________________________________________
Prerequisites
Make sure you have installed:
•	Python 3.9+
•	Flutter SDK (3.x recommended)
•	Git
•	Google Cloud credentials (Vision API)
•	Gemini API Key (Google AI Studio)
________________________________________
Step-by-Step Setup Guide 
1.	Backend Setup (FastAPI)
Step 1: Navigate to backend folder
cd backend
________________________________________
Step 2: Create Visual Environment
Windows:
python -m venv venv
venv\Scripts\activate
OR
Mac/Linux:
python3 -m venv venv
source venv/bin/activate
________________________________________
Step 3: Install Dependencies
pip install -r requirements.txt

If requirements.txt encoding causes issues, reinstall manually:
pip install fastapi uvicorn python-dotenv google-cloud-vision google-generativeai
________________________________________
Step 4: Configure Environment Variables
Create a file named:
.env

Add:
GEMINI_API_KEY=your_gemini_api_key_here
________________________________________
Step 5: Set Google Vision Credentials
Download your Google Cloud Vision service account JSON file.
Set environment variable:

Windows:
set GOOGLE_APPLICATION_CREDENTIALS=path\to\your\service-account.json

OR

Mac/Linux:
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account.json"
________________________________________
Step 6: Run Backend Server
uvicorn main:app --reload

Server should run at:
http://127.0.0.1:8000

Test endpoint at:
http://127.0.0.1:8000/docs
________________________________________
2.	Frontend Setup (Flutter Web)
Step 1: Navigate to Flutter folder
Open a new terminal:
cd coralguard
________________________________________
Step 2: Get Dependencies
flutter pub get
________________________________________
Step 3: Run Flutter Web
flutter run -d chrome - -release

The app will open in browser.
________________________________________
_How the Full System Works_
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
________________________________________
API Endpoint
POST /analyze

Request:
•	Image file
•	Temperature value

Response:
{
  "health_score": 78,
  "action": "Coral reef shows mild stress due to elevated temperature.",
  "recommendations": [
"Monitor water temperature closely",
    "Reduce local pollution impact",
    "Implement reef shading techniques"
  ]
}
________________________________________
Testing the Application
1.	Start backend
2.	Start Flutter frontend
3.	Upload any coral reef image
4.	Adjust temperature slider
5.	Click Analyze
6.	View AI-generated results
________________________________________
Troubleshooting
❌ CORS Error
Ensure FastAPI has CORS middleware enabled.
________________________________________
❌ Gemini API Error
Check:
•	Correct API key
•	.env file exists
•	Internet connection active
________________________________________
❌ Vision API Error
Check:
•	Service account JSON path correct
•	Google Cloud project has Vision API enabled
________________________________________
Security Notes
•	Never upload .env to GitHub
•	Never upload service-account JSON
•	Use .gitignore properly
________________________________________
Future Improvements
-	Deploy backend on Google Cloud Run
-	Deploy frontend via Firebase Hosting
-	Store analysis history in Firestore
-	Improve digital twin simulation accuracy
-	Add real-time reef monitoring dashboard
________________________________________Contributors
Backend & AI Integration:
1.	Kishanea A/L Jeyakumar
2.	Liew Jia Xin
3.	Hang Xiu Jun

Frontend Development:
1.	Ng Guan Yik

________________________________________
Demo Video
YouTube Link: 
________________________________________
License
This project was developed for KitaHack 2026 and educational purposes.
________________________________________

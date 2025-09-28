# Evalora Backend

<p align="center">
  <img src="../client/assets/logo.png" alt="Evalora Logo" width="200" />
</p>

**Evalora** is an AI-powered backend service that revolutionizes startup evaluation through document analysis, voice intake, and intelligent assessment. Built with **FastAPI** and **Google Cloud Platform**, it provides investors and evaluators with data-driven insights, automated scoring, and streamlined communication workflows.

---

## Overview

- Comprehensive **document analysis** (PDF, DOCX, PPTX, audio, video)
- Real-time **voice intake** and transcription
- Automated **evaluation scoring** (1-5 scale)
- Streamlined communication via **Gmail integration**
- Scalable cloud-native architecture on **Google Cloud**

---

## Architecture

Evalora combines multiple cutting-edge technologies:

1. **AI-Powered Analysis**: Uses Google Gemini AI for document evaluation and business plan generation  
2. **Voice Integration**: Real-time speech processing with Google Speech-to-Text and WebRTC  
3. **Cloud-Native Storage**: Google Cloud Storage and Firestore for scalable data management  
4. **Automated Communication**: Gmail service integration for notifications  

---

## Core Features

### 📄 Document Analysis & Evaluation
- Multi-format document processing
- AI-generated structured business plans
- Automated scoring system (1-5 scale)
- Support for founder checklists, pitch decks, and supplementary materials

### 🎙️ Voice Intake System
- Real-time voice recording and transcription
- Conversational AI assistant for interviews
- WebRTC-based audio streaming with TTS responses
- Session management and data persistence

### 🗃️ Data Management
- Firestore integration for users, startups, and evaluation requests
- Google Cloud Storage for file retention
- RESTful API endpoints for CRUD operations
- Request lifecycle tracking (submission → review → evaluation → scheduling)

### 📧 Communication & Notifications
- Gmail integration for automated notifications
- Evaluation status updates and progress tracking
- Founder and investor communication workflows

---

## Technology Stack

| Component        | Technology                  | Purpose                                     |
|-----------------|-----------------------------|---------------------------------------------|
| Framework        | FastAPI                     | High-performance web framework              |
| AI/ML            | Google Gemini               | Document analysis & content generation      |
| Speech           | Google Speech-to-Text       | Voice transcription                         |
| Storage          | Google Cloud Storage        | File storage and management                 |
| Database         | Firestore                   | NoSQL document database                      |
| Communication    | Gmail API                   | Email notifications                          |
| Real-time        | WebRTC, WebSockets          | Voice streaming and chat                     |
| File Processing  | PyMuPDF, python-docx, openpyxl | Multi-format document parsing           |
| Audio            | gTTS, aiortc                | Text-to-speech and audio handling           |

---

## Core Components

### Services
- `firestore_service.py` - Database operations  
- `gcs_service.py` - Google Cloud Storage management  
- `gmail_service.py` - Email communication  
- `gemini_client.py` - AI document analysis & plan generation  
- `speech_client.py` - Google Speech-to-Text integration  

### API Endpoints
- `database.py` - CRUD operations for users, startups, evaluations  
- `evaluate_documents.py` - Document upload and evaluation  
- `voice.py` - Voice intake with WebRTC  

### Models & Schemas
- `models.py` - Users, startups, evaluation requests, stages  
- `eval_prompts.py` - AI prompts and business plan templates  

### Utilities
- `doc_utils.py` - Multi-format document extraction  
- `audio_utils.py` - Base64 audio encoding/decoding  
- `session_utils.py` - Session management for voice intake  

---

## Installation & Setup

### Prerequisites
- Python 3.8+
- Google Cloud Platform account with enabled APIs:
  - Speech-to-Text
  - Cloud Storage
  - Firestore
- Gmail API credentials

### Quick Start
```bash
# Clone the repository
git clone <repository-url>
cd evalora-backend

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your configuration

# Set up Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=./secrets/service-account.json

# Launch the service
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Configuration

Configure your environment using a `.env` file. Key variables include:

### Google Cloud
```env
GOOGLE_APPLICATION_CREDENTIALS=./secrets/service-account.json
BUCKET_NAME=your-gcs-bucket
GEMINI_API_KEY=your-gemini-api-key
```

### Database
```env
FIRESTORE_PROJECT_ID=your-project-id
```

### Email
```env
GMAIL_USER=your-email@domain.com
GMAIL_APP_PASSWORD=<enter 16 character password here>
```

## Notes

- Replace placeholders with your project-specific values before running the service.

- Ensure the Google Cloud service account JSON file exists at the path specified in GOOGLE_APPLICATION_CREDENTIALS.

- The BUCKET_NAME must correspond to an existing Cloud Storage bucket in your project.

Keep your .env file secure; never commit it to version control.

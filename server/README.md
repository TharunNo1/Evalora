**#Overview**

We have designed an AI-powered backend service to revolutionize startup evaluation through comprehensive document analysis, voice intake, and intelligent assessment. Built with FastAPI and Google Cloud Platform, it provides investors and evaluators with data-driven insights, automated scoring, and streamlined communication workflows.



**#Architecture**

Evalora combines multiple cutting-edge technologies to deliver a seamless evaluation experience:

1. AI-Powered Analysis: Leverages Google's Gemini AI for comprehensive document evaluation and business plan generation
2. Voice Integration: Real-time speech processing using Google Speech-to-Text and WebRTC
3. Cloud-Native Storage: Google Cloud Storage and Firestore for scalable data management
4. Automated Communication Gmail service integration for stakeholder notifications



**#Core Features**

📄Document Analysis \& Evaluation

1. Multi-format document processing (PDF, DOCX, PPTX, audio, video)
2. AI-generated comprehensive business plans using structured templates
3. Automated scoring system (1-5 scale) based on completeness and quality
4. Support for founder checklists, pitch decks, and supporting materials



🎙️Voice Intake System

1. Real-time voice recording and transcription
2. Conversational AI assistant for founder interviews
3. WebRTC-based audio streaming with TTS responses
4. Session management and data persistence



🗃️Data Management

1. Firestore integration for user profiles, startups, and evaluation requests
2. Google Cloud Storage for file uploads and document retention
3. RESTful API endpoints for CRUD operations
4. Request lifecycle tracking (submission → review → evaluation → scheduling)



📧Communication \& Notifications

1. Gmail service integration for automated email notifications
2. Evaluation status updates and progress tracking
3. Founder and investor communication workflows



**#Technology Stack**

| Component | Technology | Purpose |

|-----------|------------|---------|

| Framework | FastAPI       | High-performance web framework |

| AI/ML     | Google Gemini | Document analysis and content generation |

| Speech    | Google Speech-to-Text | Voice transcription |

| Storage   | Google Cloud Storage | File storage and management |

| Database  | Firestore | NoSQL document database |

| Communication | Gmail API | Email notifications |

| Real-time | WebRTC, WebSockets | Voice streaming and chat |

| File Processing | PyMuPDF, python-docx, openpyxl | Multi-format document parsing |

| Audio | gTTS, aiortc | Text-to-speech and audio handling |



**#Core Components**

**##Services**

*`firestore\_service.py`* - Database operations for users, startups, and evaluation requests\[file:34]

*`gcs\_service.py`* - Google Cloud Storage file management with error handling\[file:40]

*`gmail\_service.py`*- Email communication and notification system

*`gemini\_client.py`* - AI document analysis and business plan generation\[file:41]

*`speech\_client.py`* - Google Speech-to-Text integration for voice processing\[file:43]



**##API Endpoints**

*`database.py`* - RESTful endpoints for data management (users, startups, evaluations)\[file:35]

*`evaluate\_documents.py`* - Document upload, processing, and evaluation workflows\[file:42]

*`voice.py`* - Voice intake system with WebRTC and real-time processing\[file:44]



**##Models \& Schemas**

*`models.py`* - Data models for users, startups, evaluation requests, and request stages

*`eval\_prompts.py`* - Comprehensive business plan templates and AI prompts\[file:33]



**##Utilities**

*`doc\_utils.py`* - Multi-format document text extraction utilities

*`audio\_utils.py`* - Base64 audio encoding/decoding functions\[file:39]

*`session\_utils.py`* - Session management for voice intake conversations



**#Installation \& Setup**

**##Prerequisites**

* Python 3.8+
* Google Cloud Platform account with enabled APIs:

&nbsp;    Speech-to-Text API

&nbsp;    Cloud Storage API

&nbsp;    Firestore API

* Gmail API credentials



**#Quick Start in bash**

1\. Clone and Navigate

&nbsp;  git clone <repository-url>

&nbsp;  cd evalora-backend

2\. Install Dependencies

&nbsp;  pip install -r requirements.txt

3\. Configure Environment

&nbsp;  cp .env.example .env

&nbsp;  #Edit .env with your configuration

4\. Set Up Google Cloud Credentials

&nbsp;  export GOOGLE\_APPLICATION\_CREDENTIALS=./secrets/service-account.json

5\. Launch the Service

&nbsp;  uvicorn main:app --reload --host 0.0.0.0 --port 8000



**#Configuration**

Key environment variables in `.env`:

1. Google Cloud

&nbsp;  GOOGLE\_APPLICATION\_CREDENTIALS=./secrets/service-account.json

&nbsp;  BUCKET\_NAME=your-gcs-bucket

&nbsp;  GEMINI\_API\_KEY=your-gemini-api-key



2\. Database

&nbsp;  FIRESTORE\_PROJECT\_ID=your-project-id



3\. Email

&nbsp;  GMAIL\_SENDER\_EMAIL=your-email@domain.com



**#Key Endpoints**

\##Document Evaluation

1. `POST /analyze-documents` - Submit documents for AI evaluation
2. `GET /export/{session\_id}/{format}` - Export evaluation data (JSON, Excel, Word, PDF)



\##Voice Intake

1. `POST /offer` - WebRTC offer/answer exchange for voice sessions
2. `POST /chat/{session\_id}` - Text-based conversation with AI assistant



\##Data Management

1. `POST /users` - Create user profiles
2. `GET /startups` - List startup profiles with filtering
3. `POST /evaluation-requests` - Submit evaluation requests
4. `PATCH /startups/{startup\_id}/status` - Update evaluation status



**#Development**

\##Project Structure

evalora-backend/

├── api/                    # API route handlers

│   ├── database.py

│   ├── evaluate\_documents.py

│   └── voice.py

├── services/               # External service integrations

│   ├── firestore\_service.py

│   ├── gcs\_service.py

│   ├── gmail\_service.py

├── models/                 # AI and data models

│   └── gemini\_client.py

├── schemas/                # Data schemas and models

│   └── models.py

├── utils/                  # Utility functions

│   ├── doc\_utils.py

│   ├── audio\_utils.py

│   └── session\_utils.py

├── config.py              # Configuration management

├── main.py                # FastAPI application entry point

└── requirements.txt       # Python dependencies



**#Adding New Features**

1\. New Service Integration: Add service files to `services/` directory

2\. API Endpoints: Create new routers in `api/` and register in `main.py`

3\. Data Models: Define schemas in `schemas/models.py`

4\. AI Prompts: Extend templates in `eval\_prompts.py`



**#Testing**

\##Run with test configuration

pytest



\##Manual API testing

curl -X POST "http://localhost:8000/users"

&nbsp;    -H "Content-Type: application/json"

&nbsp;    -d '{"id": "test-user", "name": "Test User", "email": "test@example.com"}'



**#Deployment**

\##Docker Deployment

1. docker build -t evalora-backend .
2. docker run -p 8000:8000 -e GOOGLE\_APPLICATION\_CREDENTIALS=/secrets/service-account.json evalora-backend



\##Cloud Run Deployment

1. gcloud run deploy evalora-backend \\
2. source . \\
3. platform managed \\
4. region us-central1 \\+
5. allow-unauthenticated



**#Monitoring \& Analytics**

The service provides comprehensive logging and monitoring:

1. Request/response logging for all API endpoints
2. Error tracking and exception handling
3. Performance metrics for AI processing
4. File upload and processing statistics



**#To contribute:**

1\. Fork the repository

2\. Create a feature branch (`feature/amazing-feature`)

3\. Implement your changes after validating

4\. Submit a pull request with detailed description



**#Security Considerations**

1. All file uploads are validated and scanned
2. API authentication using JWT tokens (when implemented)
3. Secure credential management via environment variables
4. Input validation and sanitization for all endpoints



**#License**

This project is licensed under the Apache 2.0 License. See the LICENSE file for details.



**#Support**

For technical support and questions:

1. Create an issue in this repository
2. Contact the development team
3. Review the API documentation at `/docs`

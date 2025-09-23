# Evalora

🌟 Evalora – AI-Driven Startup Evaluation Platform

Evalora is an AI-powered startup evaluation platform designed to help founders present their startup ideas, get AI-assisted insights, and receive human-in-the-loop (HITL) approvals before moving forward to investor meetings.
The platform leverages Google Cloud, Kafka, Gemini AI, and a multi-agent architecture to provide a scalable, production-ready system.

🚀 Key Features

- Founder Call Intake – Founders can submit their startup pitch via a Flutter mobile/web app.

- AI Multi-Agent Processing – Gemini-powered agents transcribe calls, summarize key points, and extract actionable insights.

- Human-in-the-Loop (HITL) Review – Human reviewers approve or reject AI evaluations for accuracy and fairness.

- Investor Scheduling – Approved startups are automatically scheduled for investor calls via the Google Calendar API.

- Event-Driven & Scalable – Powered by Kafka / PubSub, containerized with Docker, and deployed on GKE / Cloud Run.

🏗️ System Architecture

Evalora follows a modular, scalable, cloud-native design.
The system is divided into two main modules for ease of understanding and deployment.

Module 1: Founder Intake & AI Processing

- Frontend: Flutter (Mobile/Web) for founder intake & live updates.

- Backend: API Gateway with REST/gRPC endpoints.

- Messaging: Kafka / PubSub for event-driven communication.

- AI Layer: Multi-Agent Gemini AI for transcription, summarization, and idea evaluation.

- ➡️ Output: AI-generated evaluation and recommendation is published to the HITL Approval Queue.

Module 2: HITL Approval & Investor Scheduling

- HITL Workflow: Human reviewers approve or reject AI evaluations.

- Decision Processing: Approved startups trigger automated investor scheduling.

- Data Layer: Google Cloud Storage (GCS), BigQuery, Redis, and Firebase for analytics, caching, and hosting.

- Investor Integration: Google Calendar API for investor call scheduling.

🧩 Tech Stack
Layer	Technology
Frontend	Flutter (Mobile + Web), Firebase Hosting
Backend	Python / Node.js, API Gateway, gRPC
AI & Agents	Gemini AI, Custom LLM Agents
Messaging	Kafka, Google Pub/Sub
Storage	Google Cloud Storage (GCS), BigQuery
Cache	Redis / Memorystore
Human Review	Reviewer Dashboard (Flutter / Web)
Deployment	Docker, Kubernetes (GKE), Cloud Run
Monitoring	Google Cloud Logging & Monitoring
Integrations	Google Calendar API, Gmail API

🖼️ High-Level Flow

1️⃣ Founder Intake → Founders submit startup pitches via Flutter Web/Mobile.
2️⃣ AI Processing → Gemini AI agents process calls and generate evaluations.
3️⃣ Human Review → Human reviewers approve or reject the AI results.
4️⃣ Investor Scheduling → Approved startups are scheduled for investor calls.

📂 Project Structure
```bash
evalora/
│
├─ client/             # Flutter mobile & web app
├─ server/             # Backend service
├─ ventureSense/       # Multi agent architecture
```

🛠️ Deployment Steps
- Yet to be update
- 
📊 Monitoring & Analytics

- Google Cloud Monitoring – Service health and latency tracking.
- BigQuery – Investor engagement analytics and AI evaluation metrics.
- Cloud Logging – Centralized logs for AI agent performance.

🤝 Contributing

We welcome contributions to improve Evalora:

- Fork the repository.

- Create a feature branch (feature/amazing-idea).

- Submit a pull request.

📜 License

- Evalora is released under the Apache 2.0 License.
- See LICENSE for details.

🌱 Roadmap

 - Add support for multi-language transcription.

 - Integrate payment & subscription models for premium investors.

 - Build a mobile investor app for real-time pitch notifications.

 - Introduce founder rating scores with AI explainability.

💡 Inspiration

- Evalora aims to streamline startup discovery and evaluation by combining:

- AI Intelligence – Gemini-driven evaluation to reduce bias.

- Human Judgment – Human reviewers ensure fairness and trust.

- Investor Efficiency – Direct investor scheduling for promising startups.

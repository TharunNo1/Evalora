# Evalora

<p align="center">
  <img src="client/assets/logo.png" alt="Evalora Logo" width="200" />
</p>


**Evalora** is an advanced AI-powered platform designed to transform how founders connect with investors. By harnessing cutting-edge technologies—Google Cloud, Kafka, Gemini AI, and a dynamic multi-agent framework—Evalora delivers a seamless experience from pitch submission to investor engagement. The platform bridges artificial intelligence with essential human judgment, ensuring evaluations are thorough, transparent, and actionable.

---

## Features

- **Intuitive Pitch Intake**: Submit startup pitches via a responsive Flutter-based mobile or web interface for a streamlined user experience.  
- **AI-Driven Evaluation**: Multi-agent Gemini AI processes speech, extracts structured insights, and generates comprehensive recommendations for each pitch.  
- **Human-in-the-Loop Assurance**: Skilled reviewers verify AI-driven evaluations, maintaining fairness and reliability throughout the process.  
- **Automated Investor Coordination**: Approved pitches are scheduled with investors via Google Calendar integration, removing friction from networking.  
- **Cloud-Native & Scalable**: Kafka, Docker, and GKE/Cloud Run provide high availability, resilience, and scalability.  

---

## Architecture Overview

Evalora is built on a **modular, cloud-native architecture** with two primary modules:

<details>
<summary>1. Founder Intake & AI Processing</summary>

- **Frontend**: Flutter (mobile/web) for live pitch submission and progress updates.  
- **Backend**: API Gateway (REST/gRPC) in Python/Node.js manages communication and business logic.  
- **Messaging**: Kafka Pub/Sub ensures reliable, event-driven data flow.  
- **AI Processing**: Gemini-powered agents automate transcription, summarization, and evaluation.  
- **Queueing**: Recommendations are published to the HITL (Human-in-the-Loop) review queue for validation.

</details>

<details>
<summary>2. HITL Review & Investor Scheduling</summary>

- **Human Review Workflow**: Certified reviewers ensure quality and fairness.  
- **Automated Scheduling**: Approved startups are matched with investors using Google Calendar APIs.  
- **Data Backbone**: Google Cloud Storage, BigQuery, Redis, and Firebase support analytics, storage, and caching.

</details>

---

## Technology Stack

| Layer             | Technology                              |
|------------------|-----------------------------------------|
| Frontend          | Flutter (Mobile/Web), Firebase Hosting |
| Backend           | Python, Node.js, API Gateway, gRPC     |
| AI & Agents       | Gemini AI, Custom LLM Agents           |
| Messaging         | Kafka, Google Pub/Sub                   |
| Storage           | Google Cloud Storage, BigQuery         |
| Cache             | Redis, Memorystore                      |
| Human Review      | Reviewer Dashboard (Flutter/Web)       |
| Deployment        | Docker, Kubernetes (GKE), Cloud Run   |
| Monitoring        | Google Cloud Logging & Monitoring      |
| Integrations      | Google Calendar API, Gmail API         |

---

## Workflow Summary

1. **Pitch Submission**: Founders submit pitches via the Flutter app or website.  
2. **AI Evaluation**: AI pipeline generates structured assessments.  
3. **Human Review**: Experts validate AI output for quality and transparency.  
4. **Investor Scheduling**: Qualified startups are automatically connected to investors.

---

## Project Structure

```bash
evalora/
├─ client/        # Flutter mobile & web app
├─ server/        # Backend services
├─ ventureSense/  # Multi-agent architecture
```

## Monitoring & Analytics

- **Health Monitoring**: Google Cloud Monitoring tracks uptime and latency at every tier.  
- **Engagement Metrics**: BigQuery supports real-time analysis of investor and founder interactions.  
- **Central Logging**: Comprehensive logs centralize diagnostics for all AI and backend processes.  

---

## Contributing

We welcome contributions to Evalora!  

1. Fork the repository  
2. Create a feature branch (e.g., `feature/amazing-idea`)  
3. Submit a detailed Pull Request  

---

## License

Evalora is open-sourced under the **Apache 2.0 License**. For legal details, see the [LICENSE](LICENSE) file.

---

## Roadmap

- Multi-language pitch transcription  
- Premium investor tiers and subscription payment support  
- Mobile app for real-time investor notifications  
- Founder ratings incorporating AI explainability  

---

## Vision

Evalora reimagines the startup evaluation journey by uniting innovative AI, rigorous expert review, and efficient investor matchmaking. Our mission is to deliver **clarity, trust, and opportunity** in every founder’s journey.

### ✅ Notes:

1. **Badges**: You can add GitHub workflow, build, and license badges at the top for a more professional touch.  
2. **Collapsible Sections**: I added collapsible `<details>` sections for Architecture modules to reduce clutter.  
3. **Images**: Replace `assets/evalora_logo.png` with your actual logo path.  

---

If you want, I can also make a **version with a visually appealing table of features, workflow diagram placeholders, and colored section headers** for a **more “startup pitch” style README** suitable for investors or public GitHub.  

Do you want me to do that next?

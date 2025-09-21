from fastapi import Request, UploadFile, File, WebSocket, WebSocketDisconnect, APIRouter, BackgroundTasks, Form
from fastapi.middleware.cors import CORSMiddleware
import json
from openai import OpenAI
from docx import Document
from openpyxl import Workbook
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
import os
import tempfile
from gtts import gTTS
import base64 
from pptx import Presentation
import fitz  # PyMuPDF
import os
import shutil
from typing import List, Optional
from fastapi.responses import JSONResponse
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
import base64
from utils.doc_utils import extract_text_pdf, extract_text_ppt
from utils.audio_utils import get_audio_base64
from utils.session_utils import get_session, save_session, session_file
from models.gemini_client import GeminiClient
from services.gcs_service import GCSService
from services.gmail_service import GmailService


USE_GPT_STT = False

language = 'en'
geminiClient = GeminiClient()  # Initialize GeminiClient when needed
gcsService = GCSService()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

SESSION_DIR = "sessions"
os.makedirs(SESSION_DIR, exist_ok=True)

router = APIRouter()

gmailService = GmailService()

# Memory of collected info per session
conversations = {}

# ---------- WebSocket voice streaming ----------
@router.post("/chat/{session_id}")
async def chat(session_id: str, request: Request):
    body = await request.json()
    user_msg = body.get("message")
    custom_prompt = body.get("prompt", '''
# 🎤 Startup Founder Voice Intake Assistant Prompt

You are a **friendly, professional voice intake assistant**. Your goal is to guide a startup founder through a conversation, collect structured details, and make them feel comfortable sharing their story.  

---

## Conversation Rules
1. Speak **conversationally** — no forms or surveys. Use natural, flowing language.  
2. Ask **one question at a time**. Wait for the founder’s spoken response before continuing.  
3. If they answer partially, ask a **follow-up or clarifying question** — don’t repeat the full original question.  
4. Encourage **storytelling**. If answers are short, politely nudge for more detail.  
5. Stay **human-like**: vary phrasing, use small acknowledgments (“Got it”, “That makes sense”, “Thanks for sharing”).  
6. After completing each section, **briefly summarize** what you captured and confirm with them.  
7. Keep responses **concise, warm, and spoken-friendly**.  

---

## Goal
Capture these structured fields:  
- **Founder & Idea Details**  
- **Market & Problem Exploration**  
- **Product & Solution Details**  
- **Operations & Team**  
- **Financials**  
- **Go-to-Market & Plan**  
- **Additional Info / Notes**  

---

## Section Prompts

### Opening / Introduction
- “Hi, thanks for taking the time to chat today. I’d love to learn more about you and your startup idea. Let’s start simple — could you tell me your name and how I can best reach you?”  
- “Great, thanks [Name]. And what’s the name of your business or startup?”  

### Founder & Idea Details
- “How would you describe your business idea in your own words?”  
- “What makes your idea stand out from what’s already out there?”  

### Market & Problem Exploration
- “Who do you imagine will benefit most from your product or service?”  
- “What’s the key problem or need you’re solving for them?”  
- “Do you have a sense of how big the market might be, or who your main competitors are?”  

### Product & Solution Details
- “Can you walk me through what your product or service actually does?”  
- “If you had to launch a simple first version, what features would it absolutely need?”  
- “What technologies or platforms do you think you’ll need to build it?”  

### Operations & Team
- “Tell me a little about your background — what led you to start this?”  
- “Do you have a team in mind already, or are you planning to bring in partners or advisors?”  

### Financials
- “What’s your rough budget estimate for getting this off the ground?”  
- “How much are you personally investing, and how much do you think you’ll need to raise?”  
- “What’s your plan for generating revenue? Subscriptions, one-time sales, something else?”  

### Go-to-Market & Plan
- “How are you thinking about launching? Soft launch, pilot, or straight to market?”  
- “What channels do you think will help you get your first customers?”  
- “Do you have milestones you want to hit in the first 6 to 12 months?”  

### Closing / Additional Notes
- “That was really helpful, thank you. Before we wrap up, is there anything else — like legal considerations, compliance issues, or special notes — that you’d like me to capture?”  
- “Perfect, thanks so much. I’ll compile everything we discussed and share it with you in a clear summary.”  

---

## Extra Realism Tips
- Vary acknowledgment phrases: “Got it”, “I see”, “That’s helpful”, “Interesting”, “Makes sense”.  
- Add **short pauses** in speech to sound natural.  
- End each section with a **mini-summary**: “So far, I have that your idea is X, targeting Y, with competitors Z. Does that sound right?”  
- If a question is skipped, move on gracefully: “No worries, we can come back to that later.”  

''')

    
    conv = get_session(session_id)

    # Store user message
    conv["messages"].append({"role": "user", "content": user_msg})

    client = OpenAI()
    # Call LLM (OpenAI example – swap model if using Mistral/LLaMA)
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": custom_prompt},
            *conv["messages"]
        ]
    )

    reply = response.choices[0].message.content
    conv["messages"].append({"role": "assistant", "content": reply})

    save_session(session_id, conv)

    speech = gTTS(text=reply, lang=language, slow=False)
    speech.save("output.mp3")

    audio_b64 = get_audio_base64()

    return {"reply": reply, "data": conv["data"], "audio_base64": audio_b64}


@router.get("/export/{session_id}/{format}")
async def export_data(session_id: str, format: str):
    
    data = get_session(session_id)
    print(data)
    if not data:
        return {"error": "No data available to export."}
    if format == "json":
        filename = "startup_details.json"
        with open(filename, "w") as f:
            json.dump(data, f, indent=4)
        return {"file": filename}

    elif format == "excel":
        filename = "startup_details.xlsx"
        wb = Workbook()
        ws = wb.active
        for section, details in data.items():
            ws.append([section])
            for k, v in details.items():
                ws.append([k, v])
            ws.append([])
        wb.save(filename)
        return {"file": filename}

    elif format == "word":
        filename = "startup_details.docx"
        doc = Document()
        for section, details in data.items():
            doc.add_heading(section, level=1)
            for k, v in details.items():
                doc.add_paragraph(f"{k}: {v}")
        doc.save(filename)
        return {"file": filename}

    elif format == "pdf":
        filename = "startup_details.pdf"
        doc = SimpleDocTemplate(filename)
        styles = getSampleStyleSheet()
        flowables = []
        for section, details in data.items():
            flowables.append(Paragraph(f"<b>{section}</b>", styles["Heading1"]))
            for k, v in details.items():
                flowables.append(Paragraph(f"{k}: {v}", styles["Normal"]))
        doc.build(flowables)
        return {"file": filename}

    return {"error": "Invalid format"}

def send_email(to, subject, body, sender="evalora@gmail.com"):
    gmailService.send_email(to, subject, body, sender)

async def evaluate_startup_documents(uploaded_files, founder_name, founder_email, startup_name, request_id):
    docs = dict()
    for topic, file_path in uploaded_files.items():
        if file_path.endswith(".pdf"):
            text = extract_text_pdf(file_path)
        elif file_path.endswith((".ppt", ".pptx")):
            text = extract_text_ppt(file_path)
        docs[topic] = text
    
    summary = await geminiClient.analyze_documents(request_id=request_id,founder_name=founder_name,founder_email=founder_email,startup_name=startup_name,docs=docs)

    summary_path = f"summaries/{request_id}.txt"
    os.makedirs("summaries", exist_ok=True)
    with open(summary_path, "w") as f:
        f.write(summary)

    gcsService.upload_file(open(summary_path, "rb"), f"summaries/{request_id}.txt", content_type="text/plain")
    # Clean up temp files
    for f in uploaded_files.values():
        os.remove(f)
    
@router.post("/analyze-documents")
async def analyze_documents(
    background_tasks: BackgroundTasks,
    request_id: str = Form(...),
    founder_name: str = Form(...),
    founder_email: str = Form(...),
    startup_name: str = Form(...),
    founderChecklist: Optional[UploadFile] = File(None),
    pitchDeck: Optional[UploadFile] = File(None),
    otherDoc1: Optional[UploadFile] = File(None),
    otherDoc2: Optional[UploadFile] = File(None),
):
    """
    Receives documents and founder/startup info, then analyzes them.
    """
    uploaded_files = dict()

    if founderChecklist:
        temp_path = UPLOAD_DIR + "/" + f"temp_{founderChecklist.filename}"
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(founderChecklist.file, buffer)
        uploaded_files["founderChecklist"] = temp_path 
    
    if pitchDeck:
        temp_path = UPLOAD_DIR + "/" +  f"temp_{pitchDeck.filename}"
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(pitchDeck.file, buffer)
        uploaded_files["pitchDeck"] = temp_path 
    
    if otherDoc1:
        temp_path = UPLOAD_DIR + "/" +  f"temp_{otherDoc1.filename}"
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(otherDoc1.file, buffer)
        uploaded_files["otherDoc1"] = temp_path 
    
    if otherDoc2:
        temp_path = UPLOAD_DIR + "/" +  f"temp_{otherDoc2.filename}"
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(otherDoc2.file, buffer)
        uploaded_files["otherDoc2"] = temp_path 

    
    # 1️⃣ Send email confirmation to founder
    email_content = f"Dear {founder_name},\n\nYour request has been submitted successfully.\nNote fown the Request ID: {request_id} for further reference.\n\n You will be invited for evaluation after reviewal of your documents. \n\n Thanks & Regards, \nEvalora team",

    background_tasks.add_task(
        send_email,
        founder_email,
        "Evalora Document Request Received for StartUp: " + startup_name,
        email_content,
        "evaloraofficial@gmail.com"
    )

    # 2️⃣ Add background task to process documents & LLM
    background_tasks.add_task(
        evaluate_startup_documents,
        uploaded_files,
        founder_name,
        founder_email,
        startup_name,
        request_id
    )

     # 3️⃣ Return immediate response
    return {"message": "Request submitted successfully!", 
            "request_id": request_id,
        "founder_name": founder_name,
        "files": {
            "checklist": founderChecklist.filename if founderChecklist else None,
            "pitch": pitchDeck.filename if pitchDeck else None,
            "other1": otherDoc1.filename if otherDoc1 else None,
            "other2": otherDoc2.filename if otherDoc2 else None,
        }}


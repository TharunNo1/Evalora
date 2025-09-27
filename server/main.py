from fastapi import FastAPI
import os
from starlette.requests import Request
from starlette.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from google_auth_oauthlib.flow import Flow
from google.auth.transport.requests import Request as GoogleRequest
from googleapiclient.discovery import build
from dotenv import load_dotenv

load_dotenv()

# ---------- CONFIG ----------
CREDENTIALS_FILE = "secrets/gmail_credentials.json"
TOKEN_FILE = "secrets/gmail_token.json"
SCOPES = ["https://www.googleapis.com/auth/gmail.send"]
REDIRECT_URI = "https://evalora-service-158695644143.asia-south1.run.app/oauth2callback"

# Initialize FastAPI app
app = FastAPI(title="Evalora Assistant API")

# Allow frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Include API router
from api.voice import router as voice_router
# Include evaluate_documents router
from api.evaluate_documents import router as evaluate_documents_router  
# Include database router
from api.database import router as database_router

app.include_router(voice_router, prefix="/api")
app.include_router(evaluate_documents_router)
app.include_router(database_router)

# For email testing
@app.get("/oauth2callback")
def oauth2callback(request: Request):
    """Google redirects here with ?code=..."""
    code = request.query_params.get("code")
    if not code:
        return JSONResponse({"error": "Missing code"}, status_code=400)

    flow = Flow.from_client_secrets_file(
        CREDENTIALS_FILE, scopes=SCOPES, redirect_uri=REDIRECT_URI
    )
    flow.fetch_token(authorization_response=str(request.url))

    creds = flow.credentials
    os.makedirs(os.path.dirname(TOKEN_FILE), exist_ok=True)
    with open(TOKEN_FILE, "w") as f:
        f.write(creds.to_json())

    return {"message": "✅ Gmail connected successfully. You can now send emails."}
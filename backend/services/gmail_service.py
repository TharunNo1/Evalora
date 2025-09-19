import os
import json
import base64
from email.mime.text import MIMEText

from googleapiclient.discovery import build
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import Flow
from google.auth.transport.requests import Request


class GmailService:
    def __init__(self,
                 credentials_file="secrets/gmail_credentials.json",
                 token_file="secrets/gmail_token.json",
                 redirect_uri="http://localhost:8080/oauth2callback",
                 scopes=None):
        self.credentials_file = credentials_file
        self.token_file = token_file
        self.redirect_uri = redirect_uri
        self.scopes = scopes or ["https://www.googleapis.com/auth/gmail.send"]
        self.creds = None
        self.service = None
        self._authenticate()

    def _authenticate(self):
        """Handles OAuth2 with Flow and builds Gmail API service."""
        creds = None

        if os.path.exists(self.token_file):
            creds = Credentials.from_authorized_user_file(self.token_file, self.scopes)

        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = Flow.from_client_secrets_file(
                    self.credentials_file,
                    scopes=self.scopes,
                    redirect_uri=self.redirect_uri
                )
                # Generate URL and ask user to visit it
                auth_url, _ = flow.authorization_url(
                    access_type="offline",
                    include_granted_scopes="true"
                )
                print(f"Please visit this URL to authorize: {auth_url}")

                # User pastes the redirect URL after login
                auth_response = input("Paste the full redirect URL here: ")
                flow.fetch_token(authorization_response=auth_response)
                creds = flow.credentials

                # Save for future use
                with open(self.token_file, "w") as token:
                    token.write(creds.to_json())

        self.creds = creds
        self.service = build("gmail", "v1", credentials=self.creds)

    def send_email(self, to: str, subject: str, body: str, sender: str):
        """Send an email using Gmail API."""
        message = MIMEText(body)
        message["to"] = to
        message["from"] = sender
        message["subject"] = subject

        raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
        msg = {"raw": raw}

        try:
            sent_message = self.service.users().messages().send(userId="me", body=msg).execute()
            return {"id": sent_message["id"], "status": "sent"}
        except Exception as e:
            return {"error": str(e)}

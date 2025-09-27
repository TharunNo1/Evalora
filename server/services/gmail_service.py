import os
import base64
from email.mime.text import MIMEText
from fastapi.responses import RedirectResponse
from googleapiclient.discovery import build
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import Flow
from google.auth.transport.requests import Request as GoogleRequest
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

CREDENTIALS_FILE = "secrets/gmail_credentials.json"
TOKEN_FILE = "secrets/gmail_token.json"
SCOPES = ["https://www.googleapis.com/auth/gmail.send"]
REDIRECT_URI = "https://evalora-service-158695644143.asia-south1.run.app/oauth2callback"

class GmailService:
    """
    Gmail API wrapper to send emails using OAuth2.

    Usage:
        service = GmailService()
        service.send_email(
            to="recipient@example.com",
            subject="Hello",
            body="This is a test email",
            sender="youremail@gmail.com"
        )
    """

    def __init__(
        self,
        credentials_file="secrets/gmail_credentials.json",
        token_file="secrets/gmail_token.json",
        redirect_uri="https://evalora-service-158695644143.asia-south1.run.app/oauth2callback",
        scopes=None,
    ):
        self.credentials_file = credentials_file
        self.token_file = token_file
        self.redirect_uri = redirect_uri
        self.scopes = scopes or ["https://www.googleapis.com/auth/gmail.send"]
        self.creds = None
        self.service = None
        self._authenticate()

    def _oneTimeAuthenticate(self):
        flow = Flow.from_client_secrets_file(
        CREDENTIALS_FILE, scopes=SCOPES, redirect_uri=REDIRECT_URI
    )
        auth_url, _ = flow.authorization_url(
            access_type="offline",
            include_granted_scopes="true",
            prompt="consent",
        )
        return RedirectResponse(auth_url)


    def _authenticate(self):
        """Handles OAuth2 flow and builds the Gmail API service."""
        creds = None

        # Load existing token if available
        if os.path.exists(self.token_file):
            creds = Credentials.from_authorized_user_file(
                self.token_file, self.scopes
            )

        # Refresh or create new token if needed
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(GoogleRequest())
                # Save refreshed token
                with open(self.token_file, "w") as token:
                    token.write(creds.to_json())
            else:
                # Start a new OAuth flow
                flow = Flow.from_client_secrets_file(
                    self.credentials_file,
                    scopes=self.scopes,
                    redirect_uri=self.redirect_uri,
                )

                # Generate URL for user to authorize
                auth_url, _ = flow.authorization_url(
                    access_type="offline",
                    include_granted_scopes="true",
                    prompt="consent",  # ✅ ensures refresh_token is always returned
                )

                return RedirectResponse(auth_url)
                # print(f"Please visit this URL to authorize: {auth_url}")

                # # User pastes the redirect URL after login
                # auth_response = str(GoogleRequest)
                # flow.fetch_token(authorization_response=auth_response)
                # creds = flow.credentials

                # # Save the token for future use
                # os.makedirs(os.path.dirname(self.token_file), exist_ok=True)
                # with open(self.token_file, "w") as token:
                #     token.write(creds.to_json())

        self.creds = creds
        self.service = build("gmail", "v1", credentials=self.creds)

    def send_email(self, to: str, subject: str, body: str, sender: str):
        """Send an email using the Gmail API."""
        if not self.service:
            raise RuntimeError("Gmail service is not initialized.")

        # Prepare MIME message
        message = MIMEText(body, "plain", "utf-8")
        message["to"] = to
        message["from"] = sender
        message["subject"] = subject

        raw = base64.urlsafe_b64encode(message.as_bytes()).decode("utf-8")
        msg = {"raw": raw}

        try:
            sent_message = (
                self.service.users()
                .messages()
                .send(userId="me", body=msg)
                .execute()
            )
            return {"id": sent_message.get("id"), "status": "sent"}
        except Exception as e:
            return {"error": str(e)}

    def send_email_with_attachment(self, sender, to, subject, body, file_path):
        # Create a multipart message
        msg = MIMEMultipart()
        msg["to"] = to
        msg["from"] = sender
        msg["subject"] = subject

        # Add body text
        msg.attach(MIMEText(body, "plain"))

        # Attach the file
        with open(file_path, "rb") as f:
            part = MIMEBase("application", "octet-stream")
            part.set_payload(f.read())
        encoders.encode_base64(part)
        part.add_header(
            "Content-Disposition",
            f'attachment; filename="{os.path.basename(file_path)}"',
        )
        msg.attach(part)

        # Encode message
        raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
        message = {"raw": raw}

        # Send message
        sent_message = self.service.users().messages().send(userId="me", body=message).execute()
        return sent_message
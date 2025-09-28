import os
import smtplib
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

class GmailService:
    """
    Gmail service using SMTP and App Passwords.
    Works on Cloud Run using environment variables or secrets.

    Required environment variables:
        GMAIL_USER : your Gmail email
        GMAIL_APP_PASSWORD : 16-character app password
    """

    _instance = None

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = GmailService()
        return cls._instance

    def __init__(self):
        self.sender_email = os.environ.get("GMAIL_USER")
        self.app_password = os.environ.get("GMAIL_APP_PASSWORD")

        if not self.sender_email or not self.app_password:
            raise RuntimeError(
                "GMAIL_USER and GMAIL_APP_PASSWORD environment variables must be set"
            )

    def send_email(self, to: str, subject: str, body: str, sender: str = None):
        """Send a plain text email."""
        msg = MIMEText(body, "plain", "utf-8")
        msg["From"] = self.sender_email
        msg["To"] = to
        msg["Subject"] = subject

        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(self.sender_email, self.app_password)
            server.send_message(msg)

        return {"status": "sent", "to": to, "subject": subject}

    def send_email_with_attachment(self, sender: str, to: str, subject: str, body: str, file_path: str):
        """Send email with attachment."""
        msg = MIMEMultipart()
        msg["From"] = self.sender_email
        msg["To"] = to
        msg["Subject"] = subject

        # Add body
        msg.attach(MIMEText(body, "plain"))

        # Attach file
        with open(file_path, "rb") as f:
            part = MIMEBase("application", "octet-stream")
            part.set_payload(f.read())
        encoders.encode_base64(part)
        part.add_header(
            "Content-Disposition", f'attachment; filename="{os.path.basename(file_path)}"'
        )
        msg.attach(part)

        # Send via SMTP
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(self.sender_email, self.app_password)
            server.send_message(msg)

        return {"status": "sent", "to": to, "subject": subject, "attachment": os.path.basename(file_path)}

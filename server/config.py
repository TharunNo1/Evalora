from pathlib import Path
from dotenv import load_dotenv
import os

load_dotenv()

GOOGLE_APPLICATION_CREDENTIALS = Path(os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "./secrets/service-account.json"))
SPEECH_SCOPES = ["https://www.googleapis.com/auth/cloud-platform"]

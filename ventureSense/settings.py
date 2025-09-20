import os
from dotenv import load_dotenv

RECEIVE_SAMPLE_RATE = 24000 
SEND_SAMPLE_RATE = 16000     

load_dotenv()

PROJECT_ID = os.environ.get("PROJECT_ID")
LOCATION = os.environ.get("LOCATION")
MODEL = os.environ.get("MODEL")
VOICE_NAME = os.environ.get("VOICE_NAME")
GOOGLE_GENAI_USE_VERTEXAI = "FALSE"
MODEL_NAME = os.environ.get("MODEL_NAME")
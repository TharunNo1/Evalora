from google.cloud import speech
from google.oauth2 import service_account
from dotenv import load_dotenv
from pathlib import Path


class GoogleSpeechClient:
    """
    A class to handle Google Cloud Speech-to-Text operations using a service account.
    """

    def __init__(self, credentials_path: str, scopes=None):
        """
        Initialize the Speech Client with service account credentials.

        Args:
            credentials_path (str): Path to the service account JSON file.
            scopes (list, optional): OAuth scopes. Defaults to ["https://www.googleapis.com/auth/cloud-platform"].
        """
        load_dotenv()
        self.credentials_path = Path(credentials_path)
        self.scopes = scopes or ["https://www.googleapis.com/auth/cloud-platform"]
        self.credentials = self._load_credentials()
        self.client = speech.SpeechClient(credentials=self.credentials)
        print(f"✅ Using service account: {self.credentials.service_account_email}")

    def _load_credentials(self):
        """
        Load service account credentials with proper scopes.
        """
        return service_account.Credentials.from_service_account_file(
            self.credentials_path, scopes=self.scopes
        )

    def transcribe_audio(self, audio_file_path: str, output_file: str = "transcript.txt") -> str:
        """
        Transcribe the audio file to text using Google Cloud Speech-to-Text.

        Args:
            audio_file_path (str): Path to the audio file (.wav, LINEAR16)
            output_file (str, optional): Path to save the transcript. Defaults to "transcript.txt".

        Returns:
            str: The transcribed text.
        """
        audio_file_path = Path(audio_file_path)
        if not audio_file_path.exists():
            raise FileNotFoundError(f"Audio file not found: {audio_file_path}")

        with open(audio_file_path, "rb") as audio_file:
            content = audio_file.read()

        audio = speech.RecognitionAudio(content=content)
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
        )

        response = self.client.recognize(config=config, audio=audio)

        transcript = "\n".join(
            result.alternatives[0].transcript for result in response.results
        )

        with open(output_file, "w", encoding="utf-8") as file:
            file.write(transcript)

        return transcript
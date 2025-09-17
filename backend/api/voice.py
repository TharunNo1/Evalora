from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from models.speech_client import GoogleSpeechClient
from models.gemini_client import GeminiClient
from schemas.voice import GeminiResponse
from utils.audio import decode_audio_base64
from config import GOOGLE_APPLICATION_CREDENTIALS, SPEECH_SCOPES
import os

router = APIRouter()

# Initialize clients
speech_client = GoogleSpeechClient(GOOGLE_APPLICATION_CREDENTIALS, SPEECH_SCOPES)
gemini_client = GeminiClient(api_key=os.getenv("GEMINI_API_KEY", "DUMMY_KEY"))

@router.websocket("/ws/voice")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            audio_b64 = data.get("audio_chunk_base64")
            if not audio_b64:
                continue

            # Decode audio
            audio_bytes = decode_audio_base64(audio_b64)

            # STT
            transcript = speech_client.transcribe_bytes(audio_bytes)

            # LLM response
            llm_text = gemini_client.generate_response(transcript)

            # TTS
            audio_response_b64 = gemini_client.text_to_speech_base64(llm_text)

            # Send back
            await websocket.send_json(GeminiResponse(text=llm_text, audio_base64=audio_response_b64).dict())

    except WebSocketDisconnect:
        print("Client disconnected")

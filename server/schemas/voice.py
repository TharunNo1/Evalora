from pydantic import BaseModel

class AudioStreamRequest(BaseModel):
    audio_chunk_base64: str

class GeminiResponse(BaseModel):
    text: str
    audio_base64: str

# --- Request model for offer -->
class OfferRequest(BaseModel):
    sdp: str
    type: str
    session_id: str = None
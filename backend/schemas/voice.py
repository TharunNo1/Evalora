from pydantic import BaseModel

class AudioStreamRequest(BaseModel):
    audio_chunk_base64: str

class GeminiResponse(BaseModel):
    text: str
    audio_base64: str

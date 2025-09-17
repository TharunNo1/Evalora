import base64

def decode_audio_base64(b64_string: str) -> bytes:
    return base64.b64decode(b64_string)

def encode_audio_base64(audio_bytes: bytes) -> str:
    return base64.b64encode(audio_bytes).decode("utf-8")

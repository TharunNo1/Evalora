import os
import asyncio
import tempfile
import uuid
from typing import Dict
from fastapi import FastAPI, Request, APIRouter
from pydantic import BaseModel
from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
from aiortc.contrib.media import MediaPlayer, MediaRecorder
from gtts import gTTS
from schemas.voice import OfferRequest

router = APIRouter()

# --- Simple in-memory store to keep peer connections for debugging (optional) ---
PCS: Dict[str, RTCPeerConnection] = {}

# --- Helper: simple mock STT/LLM pipeline ---
async def mock_stt_process(audio_file_path: str) -> str:
    """
    Mock: takes a recorded audio file path and returns a transcribed text.
    Replace with real STT (Whisper / google speech-to-text etc).
    """
    # For demo, just return a fixed text or infer with an actual STT implementation.
    await asyncio.sleep(0.5)  # simulate processing
    return "Hello founder, I heard your message. I recommend focusing on product-market fit."

async def mock_llm_process(transcript: str) -> str:
    """
    Mock LLM: Takes transcript and returns agent reply text.
    Replace with Gemini/OpenAI call.
    """
    await asyncio.sleep(0.5)
    return "Thanks for the update — next steps: validate with 50 users and refine go-to-market."

async def tts_generate_audio(text: str) -> str:
    """
    Generate TTS audio using gTTS and return path to MP3.
    For production use higher-quality TTS APIs.
    """
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".mp3")
    tmp.close()
    gTTS(text=text, lang="en").save(tmp.name)
    return tmp.name



@router.post("/offer")
async def offer(req: OfferRequest):
    """
    Accepts SDP offer from client and returns SDP answer that includes
    server's audio (TTS) to be played back to client.
    This server will:
      - Receive remote audio and record it to a temporary file
      - Run mock STT+LLM on recorded audio
      - Generate TTS audio (mp3)
      - Play the TTS audio back to the client by adding it as a track
    """

    pc = RTCPeerConnection()
    pc_id = f"pc-{uuid.uuid4()}"
    PCS[pc_id] = pc

    # recorder will write incoming audio into a temporary wav/mp3 file
    incoming_audio_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    incoming_audio_file_path = incoming_audio_file.name
    incoming_audio_file.close()

    recorder = MediaRecorder(incoming_audio_file_path, format="wav")

    # event when track arrives -> record it
    @pc.on("track")
    def on_track(track):
        print("Track %s received" % track.kind)
        if track.kind == "audio":
            # record for a while; recorder will append incoming audio
            recorder.addTrack(track)
            # Keep recording until we will stop it later
            asyncio.ensure_future(recorder.start())

        @track.on("ended")
        async def on_ended():
            print("Track %s ended" % track.kind)
            try:
                await recorder.stop()
            except Exception as e:
                print("Recorder stop error:", e)

    # set remote description from client's offer
    offer = RTCSessionDescription(sdp=req.sdp, type=req.type)
    await pc.setRemoteDescription(offer)

    # Create an answer
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    # NOTE: we spawn a background task to periodically check recorded audio, process it,
    # and push generated TTS back to the client by adding a playback track.
    async def background_processing_loop():
        """
        Loop that:
         - waits for some audio to be recorded
         - processes it (STT -> LLM)
         - generates TTS
         - plays it back by creating a MediaPlayer and adding the audio track to the connection
        """
        # wait some time to accumulate audio; production logic should detect voice activity
        await asyncio.sleep(3)  # allow the client to stream some audio

        # if file still empty or tiny, wait longer
        # In production do Voice Activity Detection (VAD) or explicit signaling to end utterance
        try:
            # ensure recorded file exists and has content
            if os.path.getsize(incoming_audio_file_path) > 1000:
                transcript = await mock_stt_process(incoming_audio_file_path)
                agent_text = await mock_llm_process(transcript)

                # generate TTS audio (mp3) and stream back
                tts_path = await tts_generate_audio(agent_text)

                # Create media player from mp3 and add to pc as a track
                player = MediaPlayer(tts_path)
                # player.audio is an AudioStreamTrack
                if player.audio:
                    pc.addTrack(player.audio)

                    # renegotiate so the client receives the new outbound track
                    # create a new answer with updated localDescription
                    new_answer = await pc.createOffer()  # createOffer from server to client (re-offer)
                    # Note: aiortc supports creating an offer; some servers do re-offer; client must handle onnegotiationneeded
                    # Simpler approach: we already set localDescription earlier; adding tracks will be negotiated in many browsers automatically.
                    # For robust behavior, you should implement full signaling to re-negotiate.
                    print("Added TTS audio track; playing back to client.")
                else:
                    print("No audio track in player; skipping playback.")
            else:
                print("Recorded file too small; no processing.")
        except Exception as e:
            print("background processing error:", e)
        finally:
            # cleanup temporary files
            try:
                if os.path.exists(incoming_audio_file_path):
                    os.remove(incoming_audio_file_path)
            except Exception:
                pass

    # schedule background processing
    asyncio.ensure_future(background_processing_loop())

    # return answer to client
    return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type, "pc_id": pc_id}

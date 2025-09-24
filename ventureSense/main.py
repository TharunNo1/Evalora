import asyncio
import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse
from models.stream_service import StreamingService 
from vertexai import init
import os 
import firebase.functions as functions

from dotenv import load_dotenv

load_dotenv()

PROJECT_ID = os.environ.get("PROJECT_ID")
LOCATION = os.environ.get("LOCATION")
MODEL = os.environ.get("MODEL")
VOICE_NAME = os.environ.get("VOICE_NAME")
GOOGLE_GENAI_USE_VERTEXAI = "FALSE"

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

from google.genai import Client
genai_client = Client(api_key=GOOGLE_API_KEY)



app = FastAPI()
streaming_service = StreamingService(host="0.0.0.0", port=8080)  # port unused if embedded

@app.on_event("startup")
async def startup_event():
    """
    Start the internal ADK streaming server tasks when FastAPI boots.
    """
    init(project=PROJECT_ID, location=LOCATION)

@app.websocket("/ws/stream")
async def websocket_endpoint(websocket: WebSocket):
    """
    This endpoint will proxy audio/video/text streaming from client to Google ADK.
    """
    await websocket.accept()
    client_id = id(websocket)  # Unique ID per connection

    streaming_service = StreamingService()

    try:
        # Use the same handler as in your standalone service
        await streaming_service.handle_stream(websocket, client_id)
    except WebSocketDisconnect:
        print(f"Client {client_id} disconnected")
    except Exception as e:
        print(f"Error in streaming handler: {e}")
    finally:
        # Cleanup any session state if needed
        streaming_service.active_connections.pop(client_id, None)

@app.get("/")
async def index():
    return HTMLResponse(
        "<h2>Evalora Backend Service/h2>"
        "<p>Connect to Investors</p>"
    )

firebase_function = functions.https.on_request(app)

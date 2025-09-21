from models.base_stream_server import BaseStreamServer, stream_logger
from settings import SEND_SAMPLE_RATE, MODEL, VOICE_NAME, RECEIVE_SAMPLE_RATE
# from prompts.prompts import SYSTEM_INSTRUCTION
import asyncio
import json
import base64
import os
import traceback
from google.adk.agents import Agent, LiveRequestQueue
from google.adk.runners import Runner
from google.adk.agents.run_config import RunConfig, StreamingMode
from google.adk.sessions.in_memory_session_service import InMemorySessionService
from google.genai import types
# from google.genai.types import ResponseModality
from google.adk.tools import google_search
# from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters

# RECEIVE_SAMPLE_RATE = 24000 
# SEND_SAMPLE_RATE = 16000     

from settings import * 

from evalora.agent import orchestrator as Evalora_Agent


class StreamingService(BaseStreamServer):
    """Real-time streaming service for audio and video data."""

    def __init__(self, host="0.0.0.0", port=8080):
        super().__init__(host, port)

        # Initialize ADK components
        self.agent = Evalora_Agent

        # Create session service
        self.session_service = InMemorySessionService()

    # async def handle_stream(self, websocket, client_id):
    #     """Process real-time data streams from the client."""
    #     # Store client reference
    #     self.active_connections[client_id] = websocket

    #     # Create a new session for the client
    #     user_id = f"user_{client_id}"
    #     session_id = f"session_{client_id}"
    #     await self.session_service.create_session(
    #         app_name="Evalora-Assistant",
    #         user_id=user_id,
    #         session_id=session_id,
    #     )

    #     # Create runner
    #     runner = Runner(
    #         app_name="Evalora-Assistant",
    #         agent=self.agent,
    #         session_service=self.session_service,
    #     )

    #     # Create live request queue
    #     live_request_queue = LiveRequestQueue()

    #     # Create run config with audio settings
    #     run_config = RunConfig(
    #         streaming_mode=StreamingMode.BIDI,
    #         # speech_config=types.SpeechConfig(
    #         #     voice_config=types.VoiceConfig(
    #         #         prebuilt_voice_config=types.PrebuiltVoiceConfig(
    #         #             voice_name=VOICE_NAME
    #         #         )
    #         #     )
    #         # ),
    #         response_modalities=["AUDIO"],
    #         output_audio_transcription=types.AudioTranscriptionConfig(),
    #         input_audio_transcription=types.AudioTranscriptionConfig(),
    #     )

    #     # Queues for audio and video data from the client
    #     audio_queue = asyncio.Queue()
    #     video_queue = asyncio.Queue()
    #     stop_event = asyncio.Event()

    #     async with asyncio.TaskGroup() as tg:
    #         # Task to process incoming WebSocket messages
    #         async def receive_client_messages():
    #             try:
    #                 async for message in websocket:
    #                     try:
    #                         data = json.loads(message)
    #                         if data.get("type") == "audio":
    #                             audio_bytes = base64.b64decode(
    #                                 data.get("data", ""))
    #                             await audio_queue.put(audio_bytes)
    #                         elif data.get("type") == "video":
    #                             video_bytes = base64.b64decode(
    #                                 data.get("data", ""))
    #                             video_mode = data.get("mode", "webcam")
    #                             await video_queue.put({"data": video_bytes, "mode": video_mode})
    #                         elif data.get("type") == "end":
    #                             stream_logger.info(
    #                                 "Client has concluded data transmission for this turn.")
    #                             stop_event.set()
    #                             await websocket.send(json.dumps({
    #                                 "type": "interrupted",
    #                                 "data": "Conversation ended by client"
    #                             }))
    #                             break
    #                         elif data.get("type") == "text":
    #                             stream_logger.info(
    #                                 f"Received text from client: {data.get('data')}")
    #                     except json.JSONDecodeError:
    #                         stream_logger.error(
    #                             "Could not decode incoming JSON message.")
    #                     except Exception as e:
    #                         stream_logger.error(
    #                             f"Exception while processing client message: {e}")
    #             except Exception as e:
    #                 stream_logger.error(
    #                     f"WebSocket connection error: {e}")
    #                 print("WebSocket connection error:", e)

    #         async def send_audio_to_service():
    #             while True:
    #                 try:
    #                     data = await audio_queue.get()
    #                     live_request_queue.send_realtime(
    #                         types.Blob(
    #                             data=data, mime_type=f"audio/pcm;rate={SEND_SAMPLE_RATE}")
    #                     )
    #                     audio_queue.task_done()

    #                     if stop_event.is_set():
    #                         break
    #                 except Exception as e:
    #                     stream_logger.error(
    #                         f"Exception while sending audio to service: {e}")
    #                     print(e)

    #         async def send_video_to_service():
    #             while True:
    #                 video_data = await video_queue.get()
    #                 video_bytes = video_data.get("data")
    #                 video_mode = video_data.get("mode", "webcam")
    #                 stream_logger.info(
    #                     f"Transmitting video frame from source: {video_mode}")
    #                 live_request_queue.send_realtime(
    #                     types.Blob(data=video_bytes, mime_type="image/jpeg")
    #                 )
    #                 video_queue.task_done()

    #         async def receive_service_responses():
    #             # Track user and model outputs between turn completion events
    #             input_texts = []
    #             output_texts = []
    #             current_session_id = None

    #             # Flag to track if we've seen an interruption in the current turn
    #             interrupted = False

    #             try:

    #                 # Process responses from the agent
    #                 async for event in runner.run_live(
    #                     user_id=user_id,
    #                     session_id=session_id,
    #                     live_request_queue=live_request_queue,
    #                     run_config=run_config,
    #                 ):
                        
    #                     if stop_event.is_set():
    #                         await websocket.send(json.dumps({
    #                             "type": "interrupted",
    #                             "data": "Conversation ended by agent"
    #                         }))
    #                         stream_logger.info("Stopping runner due to stop_event.")
    #                         break
    #                     # Check for turn completion or interruption using string matching
    #                     # This is a fallback approach until a proper API exists
    #                     event_str = str(event)

    #                     # If there's a session resumption update, store the session ID
    #                     if hasattr(event, 'session_resumption_update') and event.session_resumption_update:
    #                         update = event.session_resumption_update
    #                         if update.resumable and update.new_handle:
    #                             current_session_id = update.new_handle
    #                             stream_logger.info(
    #                                 f"Established new session with handle: {current_session_id}")
    #                             # Send session ID to client
    #                             session_id_msg = json.dumps({
    #                                 "type": "session_id",
    #                                 "data": current_session_id
    #                             })
    #                             await websocket.send(session_id_msg)

    #                     # Handle content
    #                     if event.content and event.content.parts:
    #                         for part in event.content.parts:
    #                             # Process audio content
    #                             if hasattr(part, "inline_data") and part.inline_data:
    #                                 b64_audio = base64.b64encode(
    #                                     part.inline_data.data).decode("utf-8")
    #                                 await websocket.send(json.dumps({"type": "audio", "data": b64_audio}))

    #                             # Process text content
    #                             if hasattr(part, "text") and part.text:
    #                                 # Check if this is user or model text based on content role
    #                                 if hasattr(event.content, "role") and event.content.role == "user":
    #                                     # User text should be sent to the client
    #                                     if "partial=True" in event_str:
    #                                         await websocket.send(json.dumps({"type": "user_transcript", "data": part.text}))
    #                                     input_texts.append(part.text)
    #                                 else:
    #                                     # From the logs, we can see the duplicated text issue happens because
    #                                     # we get streaming chunks with "partial=True" followed by a final consolidated
    #                                     # response with "partial=None" containing the complete text

    #                                     # Check in the event string for the partial flag
    #                                     # Only process messages with "partial=True"
    #                                     if "partial=True" in event_str:
    #                                         await websocket.send(json.dumps({"type": "text", "data": part.text}))
    #                                         output_texts.append(part.text)
    #                                     # Skip messages with "partial=None" to avoid duplication

    #                     # Check for interruption
    #                     if event.interrupted and not interrupted:
    #                         stream_logger.warning(
    #                             "User has interrupted the stream.")
    #                         await websocket.send(json.dumps({
    #                             "type": "interrupted",
    #                             "data": "Response interrupted by user input"
    #                         }))
    #                         interrupted = True

    #                     # Check for turn completion
    #                     if event.turn_complete:
    #                         # Only send turn_complete if there was no interruption
    #                         if not interrupted:
    #                             stream_logger.info(
    #                                 "The model has completed its turn.")
    #                             await websocket.send(json.dumps({
    #                                 "type": "turn_complete",
    #                                 "session_id": current_session_id
    #                             }))

    #                         # Log collected transcriptions for debugging
    #                         if input_texts:
    #                             # Get unique texts to prevent duplication
    #                             unique_texts = list(dict.fromkeys(input_texts))
    #                             stream_logger.info(
    #                                 f"Transcribed user speech: {' '.join(unique_texts)}")

    #                         if output_texts:
    #                             # Get unique texts to prevent duplication
    #                             unique_texts = list(dict.fromkeys(output_texts))
    #                             stream_logger.info(
    #                                 f"Generated model response: {' '.join(unique_texts)}")

    #                         # Reset for next turn
    #                         input_texts = []
    #                         output_texts = []
    #                         interrupted = False
    #             except Exception as e:
    #                 stream_logger.error(
    #                     f"Exception while receiving service responses: {e}")
    #                 stream_logger.error(traceback.format_exc())
    #                 print("Exception in receive_service_responses:", e)

    #         # # Start all tasks
    #         # tg.create_task(receive_client_messages(),
    #         #                name="ClientMessageReceiver")
    #         # tg.create_task(send_audio_to_service(), name="AudioSender")
    #         # tg.create_task(send_video_to_service(), name="VideoSender")
    #         # tg.create_task(receive_service_responses(),
    #         #                name="ServiceResponseReceiver")

    #         try:
    #             tg.create_task(receive_client_messages(), name="ClientMessageReceiver")
    #             tg.create_task(send_audio_to_service(), name="AudioSender")
    #             tg.create_task(send_video_to_service(), name="VideoSender")
    #             tg.create_task(receive_service_responses(), name="ServiceResponseReceiver")
    #         except Exception as e:
    #             stream_logger.error(f"TaskGroup failed: {e}")
    #             print("TaskGroup failed:", e)
         
    async def handle_stream(self, websocket, client_id):
        """Process real-time data streams from the client."""
        self.active_connections[client_id] = websocket
        clienttask = audiotask = videotask = agenttask = None

        user_id = f"user_{client_id}"
        session_id = f"session_{client_id}"
        await self.session_service.create_session(
            app_name="Evalora-Assistant",
            user_id=user_id,
            session_id=session_id,
        )

        runner = Runner(
            app_name="Evalora-Assistant",
            agent=self.agent,
            session_service=self.session_service,
        )

        live_request_queue = LiveRequestQueue()

        run_config = RunConfig(
            streaming_mode=StreamingMode.BIDI,
            response_modalities=["AUDIO"],
            output_audio_transcription=types.AudioTranscriptionConfig(),
            input_audio_transcription=types.AudioTranscriptionConfig(),
        )

        audio_queue = asyncio.Queue(maxsize=64) # Limit to prevent memory bloat
        video_queue = asyncio.Queue()
        stop_event = asyncio.Event()

        # --- TASKS ---
        async def receive_client_messages():
            try:
                async for message in websocket:
                    try:
                        data = json.loads(message)
                        msg_type = data.get("type")
                        if msg_type == "audio":
                            audio_bytes = base64.b64decode(data.get("data", ""))
                            await audio_queue.put(audio_bytes)
                        elif msg_type == "video":
                            video_bytes = base64.b64decode(data.get("data", ""))
                            video_mode = data.get("mode", "webcam")
                            await video_queue.put({"data": video_bytes, "mode": video_mode})
                        elif msg_type == "text":
                            stream_logger.info(f"Received text: {data.get('data')}")
                        elif msg_type in ["end", "stop"]:
                            stream_logger.info("Client ended the conversation.")
                            stop_event.set()
                            await websocket.send(json.dumps({
                                "type": "end",
                                "data": "Conversation ended by client"
                            }))
                            break
                    except Exception as e:
                        stream_logger.error(f"Error processing client message: {e}")
            except Exception as e:
                stream_logger.error(f"WebSocket connection error: {e}")

        async def send_audio_to_service():
            try:
                while not stop_event.is_set():
                    data = await audio_queue.get()
                    try:
                        live_request_queue.send_realtime(
                            types.Blob(data=data, mime_type=f"audio/pcm;rate={SEND_SAMPLE_RATE}")
                        )
                    except Exception as e:
                        stream_logger.error(f"Error sending audio to service: {e}")
                    audio_queue.task_done()
            except Exception as e:
                stream_logger.error(f"send_audio_to_service crashed: {e}")
            finally:
                stream_logger.info("Audio sender task terminating.")
                while not audio_queue.empty():
                    audio_queue.get_nowait()
                    audio_queue.task_done()
            

        async def send_video_to_service():
            try:
                while not stop_event.is_set():
                    video_data = await video_queue.get()
                    try:
                        video_bytes = video_data.get("data")
                        video_mode = video_data.get("mode", "webcam")
                        stream_logger.info(f"Transmitting video frame from {video_mode}")
                        live_request_queue.send_realtime(
                            types.Blob(data=video_bytes, mime_type="image/jpeg")
                        )
                    except Exception as e:
                        stream_logger.error(f"Error sending video to service: {e}")
                    video_queue.task_done()
            except Exception as e:
                stream_logger.error(f"send_video_to_service crashed: {e}")

        async def receive_service_responses():
            input_texts = []
            output_texts = []
            current_session_id = None
            interrupted = False
            try:
                async for event in runner.run_live(
                    user_id=user_id,
                    session_id=session_id,
                    live_request_queue=live_request_queue,
                    run_config=run_config,
                ):
                    if stop_event.is_set():
                        await websocket.send(json.dumps({
                            "type": "interrupted",
                            "data": "Conversation ended by agent"
                        }))
                        stream_logger.info("Stopping runner due to stop_event.")
                        break

                    # Handle session resumption
                    if getattr(event, 'session_resumption_update', None):
                        update = event.session_resumption_update
                        if update.resumable and update.new_handle:
                            current_session_id = update.new_handle
                            stream_logger.info(f"New session handle: {current_session_id}")
                            await websocket.send(json.dumps({
                                "type": "session_id",
                                "data": current_session_id
                            }))

                    # Handle content parts
                    if getattr(event.content, 'parts', None):
                        for part in event.content.parts:
                            # Audio
                            if getattr(part, "inline_data", None):
                                b64_audio = base64.b64encode(part.inline_data.data).decode("utf-8")
                                await websocket.send(json.dumps({"type": "audio", "data": b64_audio}))
                            # Text
                            if getattr(part, "text", None):
                                event_role = getattr(event.content, "role", None)
                                event_str = str(event)
                                if event_role == "user" and "partial=True" in event_str:
                                    await websocket.send(json.dumps({"type": "user_transcript", "data": part.text}))
                                    input_texts.append(part.text)
                                elif "partial=True" in event_str:
                                    await websocket.send(json.dumps({"type": "text", "data": part.text}))
                                    output_texts.append(part.text)

                    # Check for interruption
                    if getattr(event, "interrupted", False) and not interrupted:
                        stream_logger.warning("Stream interrupted by user")
                        await websocket.send(json.dumps({
                            "type": "interrupted",
                            "data": "Response interrupted by user input"
                        }))
                        interrupted = True

                    # Check for turn completion
                    if getattr(event, "turn_complete", False):
                        if not interrupted:
                            stream_logger.info("Model completed its turn")
                            await websocket.send(json.dumps({
                                "type": "turn_complete",
                                "session_id": current_session_id
                            }))
                        # Log transcriptions
                        if input_texts:
                            stream_logger.info(f"User speech: {' '.join(dict.fromkeys(input_texts))}")
                        if output_texts:
                            stream_logger.info(f"Model output: {' '.join(dict.fromkeys(output_texts))}")
                        input_texts, output_texts = [], []
                        interrupted = False

            except Exception as e:
                stream_logger.error(f"receive_service_responses crashed: {e}")
                stream_logger.error(traceback.format_exc())

        # --- START TASKS ---
        try:
            async with asyncio.TaskGroup() as tg:
                clienttask = tg.create_task(receive_client_messages(), name="ClientMessageReceiver")
                audiotask = tg.create_task(send_audio_to_service(), name="AudioSender")
                videotask = tg.create_task(send_video_to_service(), name="VideoSender")
                agenttask = tg.create_task(receive_service_responses(), name="ServiceResponseReceiver")
        except Exception as e:
            stream_logger.error(f"TaskGroup failed: {e}")
            print("TaskGroup failed:", e)
        finally:
            if clienttask and not clienttask.done():
                clienttask.cancel()
                try:
                    await clienttask
                except asyncio.CancelledError:  
                    pass
            if audiotask and not audiotask.done():
                audiotask.cancel()
                try:
                    await audiotask
                except asyncio.CancelledError:  
                    pass
            if videotask and not videotask.done():
                videotask.cancel()
                try:
                    await videotask
                except asyncio.CancelledError:  
                    pass
            if agenttask and not agenttask.done(): 
                agenttask.cancel()
                try:
                    await agenttask
                except asyncio.CancelledError:  
                    pass
            # Try to gracefully close resources
            try:
                # If runner or live_request_queue expose close/stop, call them here.
                if hasattr(live_request_queue, "close"):
                    live_request_queue.close()
            except Exception:
                stream_logger.debug("live_request_queue close failed", exc_info=True)

            # Delete session (defensive)
            try:
                # If API expects only session_id, adapt this call.
                self.session_service.delete_session(user_id, session_id)
            except Exception as e:
                stream_logger.error(f"Failed to delete session: {e}")




from fastapi import FastAPI
from api.voice import router as voice_router

app = FastAPI(title="Evalora Assistant API")

# Include API router
app.include_router(voice_router, prefix="/api")

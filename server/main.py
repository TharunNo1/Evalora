from fastapi import FastAPI

from fastapi.middleware.cors import CORSMiddleware

from dotenv import load_dotenv

load_dotenv()

# Initialize FastAPI app
app = FastAPI(title="Evalora Assistant API")

# Allow frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Include API router
from api.voice import router as voice_router
# Include evaluate_documents router
from api.evaluate_documents import router as evaluate_documents_router  
# Include database router
from api.database import router as database_router

app.include_router(voice_router, prefix="/api")
app.include_router(evaluate_documents_router)
app.include_router(database_router)

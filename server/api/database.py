from fastapi import APIRouter
from typing import Optional, Union
from services.firestore_service import FirestoreService
from schemas.models import UserModel, EvaluationRequest, RequestStage, Startup, ReevaluationRequest
db = FirestoreService()

router = APIRouter()

@router.post("/users")
def create_user(user: UserModel):
    return {"success": db.create_user(user)}

@router.get("/users/{user_id}")
def get_user(user_id: str):
    return db.get_user(user_id)

@router.post("/startups")
def create_startup(startup: Startup):
    return {"success": db.create_startup(startup)}

@router.patch("/startups/{startup_id}/status")
def update_status(startup_id: str, status: RequestStage):
    return {"success": db.update_startup_status(startup_id, status)}

@router.get("/startups")
def list_startups(category: str = None):
    return db.list_startups(category)

@router.post("/evaluation-requests")
def create_eval_request(req: EvaluationRequest):
    request_id = db.create_evaluation_request(req)
    return {"updated": request_id}

@router.post("/reevaluation-requests")
def create_reeval_request(req: ReevaluationRequest):
    reeval_id = db.create_reevaluation_request(req)
    return {"updated": reeval_id}

@router.post("/reevaluation/getRequest")
def get_original_request_id(reeval_doc_id: str):
    """
    Given a re-evaluation request document ID, return the original evaluation request ID.
    """
    reqId = db.get_original_request_id(reeval_doc_id=reeval_doc_id)
    return {"requestId": str(reqId)}


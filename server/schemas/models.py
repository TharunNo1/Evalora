from pydantic import BaseModel
from enum import Enum
from typing import List, Dict, Optional


class RequestStage(str, Enum):
    submission = "submitted"
    prequalified = "prequalified"
    sessionScheduled = "sessionScheduled"
    approved = "approved"
    declined = "declined"
    reevaluation = "InReevaluation"
    funded = "Funded"


class UserModel(BaseModel):
    id: str
    name: str
    email: str
    password: str
    phone: str

class EvaluationRequest(BaseModel):
    startupId: str
    startupName: str 
    description: str
    founderName: str 
    founderEmail: str 
    docsList: Dict[str, List[str]]


class Startup(BaseModel):
    id: str
    name: str 
    description: str
    categories: List[str]
    subCategories: Dict[str, List[str]]
    founder: str
    founder_id: str
    score: float
    currentStatus: RequestStage
    approved: bool

class ReevaluationRequest(BaseModel):
    requestId: str
    startupId: str
    reevaluationId: str

class SessionDetails(BaseModel):
    sessionId: str
    startupId: str
    startupName: str
    evaluatorId: str
    evaluatorName: str
    scheduledAt: str
    sessionLink: Optional[str] = None
    notes: Optional[str] = None

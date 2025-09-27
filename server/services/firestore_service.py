from google.cloud import firestore
from google.api_core.exceptions import GoogleAPIError
from typing import List, Dict, Optional, Any
from schemas.models import (
    UserModel,
    Startup,
    EvaluationRequest,
    ReevaluationRequest,
    RequestStage
)
from datetime import datetime
import hashlib

class FirestoreService:
    def __init__(self):
        try:
            self.db = firestore.Client(project="evalorahosting")
        except GoogleAPIError as e:
            raise RuntimeError(f"❌ Firestore initialization failed: {e}")

    # ---------------- USERS ----------------
    def create_user(self, user: UserModel) -> bool:
        """⚠️ Hash the password before saving"""
        try:
            user_data = user.dict()
            user_data["password"] = hashlib.sha256(user.password.encode()).hexdigest()
            self.db.collection("users").document(user.id).set(user_data)
            return True
        except GoogleAPIError as e:
            print(f"❌ Failed to create user: {e}")
            return False

    def get_user(self, user_id: str) -> Optional[Dict[str, Any]]:
        doc = self.db.collection("users").document(user_id).get()
        return doc.to_dict() if doc.exists else None

    # ---------------- STARTUPS ----------------
    def create_startup(self, startup: Startup) -> bool:
        try:
            self.db.collection("startups").document(startup.id).set(startup.dict())
            print(f"✅ Startup {startup.name} created with ID: {startup.id}")
            return True
        except GoogleAPIError as e:
            print(f"❌ Failed to create startup: {e}")
            return False

    def update_startup_status(self, startup_id: str, new_status: RequestStage) -> bool:
        try:
            self.db.collection("startups").document(startup_id).update({
                "currentStatus": new_status.value
            })
            return True
        except GoogleAPIError as e:
            print(f"❌ Failed to update startup status: {e}")
            return False

    def list_startups(self, category: Optional[str] = None) -> List[Dict[str, Any]]:
        try:
            query = self.db.collection("startups")
            if category:
                query = query.where("categories", "array_contains", category)
            return [doc.to_dict() for doc in query.stream()]
        except GoogleAPIError as e:
            print(f"❌ Failed to list startups: {e}")
            return []

    # ---------------- EVALUATION REQUESTS ----------------
    def create_evaluation_request(self, req: EvaluationRequest) -> str:
        try:
            doc_ref = self.db.collection("evaluation_requests").document()
            req_data = req.dict()
            req_data["created_at"] = datetime.utcnow()
            doc_ref.set(req_data)
            print(f"✅ Evaluation request created with ID: {doc_ref.id}")
            return doc_ref.id
        except GoogleAPIError as e:
            print(f"❌ Failed to create evaluation request: {e}")
            return ""

    # ---------------- REEVALUATION REQUESTS ----------------
    def create_reevaluation_request(self, req: ReevaluationRequest) -> str:
        try:
            doc_ref = self.db.collection("reevaluation_requests").document()
            doc_ref.set(req.dict())
            return doc_ref.id
        except GoogleAPIError as e:
            print(f"❌ Failed to create reevaluation request: {e}")
            return ""
    
    def get_original_request_id(self, reeval_doc_id: str) -> str | None:
        docs = (
            self.db.collection("reevaluation_requests")
            .where("reevaluationId", "==", reeval_doc_id)
            .limit(1)
            .stream()
        )

        for doc in docs:
            data = doc.to_dict()
            return data.get("requestId")  # ✅ Original request ID
        return None  # Not found
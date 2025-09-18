import os 
import json

SESSION_DIR = "sessions"
os.makedirs(SESSION_DIR, exist_ok=True)

def session_file(session_id):
    return os.path.join(SESSION_DIR, f"{session_id}.json")

def get_session(session_id):
    try:
        with open(session_file(session_id), "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return {"messages": [], "data": {}}

def save_session(session_id, session_data):
    with open(session_file(session_id), "w") as f:
        json.dump(session_data, f, indent=4)
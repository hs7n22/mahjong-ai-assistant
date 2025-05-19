from typing import Dict, List
from models.message import Message

# 临时对话储存： session_id -> List[Message]
chat_sessions: Dict[str, List[Message]] = {}

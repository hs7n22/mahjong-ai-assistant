from fastapi import APIRouter, Depends, HTTPException
from utils.auth import get_current_user
from models.message import Message
from state import chat_sessions
from models.llm_utils import build_prompt_from_messages, call_llm_api, clean_response
import time

router = APIRouter()


@router.post("/chat/{session_id}")
def chat(session_id: str, message: Message, user=Depends(get_current_user)):
    # 1. 鉴权
    user_id = user["sub"]
    if not session_id.startswith(user_id):
        raise HTTPException(status_code=403, detail="禁止访问他人会话")
    # 2.如果没有时间戳，自动补充
    if message.timestamp is None:
        message.timestamp = int(time.time() * 1000)

    # 3. 初始化或追加消息
    if session_id not in chat_sessions:
        chat_sessions[session_id] = []
    chat_sessions[session_id].append(message)

    # 4. 生成Prompt（根据上下文）
    constext_messages = chat_sessions[session_id][-6:]

    # 从metadata中回复hand_tiles
    for msg in reversed(constext_messages):
        if msg.role == "assistant" and msg.metadata and msg.metadata.hand_tiles:
            current_tiles = msg.metadata.hand_tiles
            break
        else:
            current_tiles = []  # 如果没有就空
    messages = build_prompt_from_messages(constext_messages, current_tiles)

    # 5. 调用LLM
    raw_response = call_llm_api(messages=messages)
    clean_reply = clean_response(raw_response)

    # 6. 封装恢复消息
    assistant_msg = Message(
        role="assistant",
        type="text",
        content=clean_reply,
        timestamp=int(time.time() * 1000),
    )
    chat_sessions[session_id].append(assistant_msg)

    # 7. 返回真个会话历史（也可以仅返回 reply)
    return chat_sessions[session_id]


@router.get("/chat/{session_id}")
def get_chat_history(session_id: str, user=Depends(get_current_user)):
    user_id = user["sub"]
    if not session_id.startswith(user_id):
        raise HTTPException(status_code=403, detail="禁止访问他人会话")

    history = chat_sessions.get(session_id)
    if not history:
        raise HTTPException(status_code=404, detail="无历史记录")

    return history

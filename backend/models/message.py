from typing import List, Optional, Literal
from pydantic import BaseModel


class Metadata(BaseModel):
    hand_tiles: Optional[List[str]] = None
    suggestion: Optional[str] = None
    waiting_tiles: Optional[List[str]] = None
    is_ting: Optional[bool] = None
    gang: Optional[List[str]] = None
    peng: Optional[List[str]] = None


class Message(BaseModel):
    role: Literal["user", "assistant", "system"]
    type: Literal["text", "image", "suggestion"]
    content: str
    metadata: Optional[Metadata] = None
    timestamp: Optional[int] = None  # 前端可传入，后端也可以默认生成

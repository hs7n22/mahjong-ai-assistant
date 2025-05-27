import os
import time
from datetime import datetime
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from tiles_infer import predict_hand_tiles
from tile_classifier import find_all_combinations_filtered
from tile_utils import organize_tiles, normalize_tiles_to_chinese
from tiles_waiting import get_waiting_tiles, get_gang_tiles, get_peng_tiles
from models.llm_utils import call_llm_api, build_prompt, clean_response
from models.message import Message, Metadata
from state import chat_sessions
from routes import chat
from utils.auth import get_current_user
from routes import payment
from utils.supabase_client import get_supabase

load_dotenv()


UPLOAD_LIMIT_PER_DAY = 3

app = FastAPI()
app.include_router(chat.router, tags=["Chat"])
app.include_router(payment.router, tags=["支付"])
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


async def check_upload_permission(user_id: str) -> bool:
    today = datetime.now().date()
    supabase = await get_supabase()
    response = await supabase.table("profiles").select("*").eq("id", user_id).execute()
    if not response.data:
        await (
            supabase.table("profiles")
            .insert(
                {
                    "id": user_id,
                    "is_vip": False,
                    "upload_count": 0,
                    "last_upload_date": today.isoformat(),
                }
            )
            .execute()
        )
        return True

    profile = response.data[0]
    if profile["last_upload_date"] != today.isoformat():
        await (
            supabase.table("profiles")
            .update(
                {
                    "upload_count": 0,
                    "last_upload_date": today.isoformat(),
                }
            )
            .eq("id", user_id)
            .execute()
        )
        return True

    if profile["is_vip"]:
        return True

    return profile["upload_count"] < UPLOAD_LIMIT_PER_DAY


async def record_upload(user_id: str):
    supabase = await get_supabase()
    response = (
        await supabase.table("profiles")
        .select("upload_count")
        .eq("id", user_id)
        .execute()
    )
    profile = response.data[0]
    new_count = profile["upload_count"] + 1
    await (
        supabase.table("profiles")
        .update({"upload_count": new_count})
        .eq("id", user_id)
        .execute()
    )


@app.get("/protected")
def protected_route(user=Depends(get_current_user)):
    return {
        "msg": "你已经成功通过身份验证!",
        "email": user.get("email"),
        "user_id": user.get("sub"),
        "role": user.get("role"),
    }


@app.post("/upload")
async def upload_file(user=Depends(get_current_user), file: UploadFile = File(...)):
    user_id = user["sub"]

    if not await check_upload_permission(user_id):
        raise HTTPException(
            status_code=403, detail="已超出今日上传次数，升级会员享受不限量上传。"
        )

    save_dir = "uploads"
    os.makedirs(save_dir, exist_ok=True)
    file_location = os.path.join(save_dir, f"{user_id}_{file.filename}")
    with open(file_location, "wb") as f:
        f.write(file.file.read())

    await record_upload(user_id)

    raw_hand_tiles = predict_hand_tiles(file_location)
    hand_tiles = normalize_tiles_to_chinese(raw_hand_tiles)
    grouped = organize_tiles(hand_tiles)
    sorted_tiles = grouped["万"] + grouped["筒"] + grouped["条"] + grouped["字"]
    gang_tiles, trimmed_tiles = get_gang_tiles(sorted_tiles)
    peng_candidates = get_peng_tiles(trimmed_tiles)
    waiting_tiles = get_waiting_tiles(trimmed_tiles)

    is_ting = bool(waiting_tiles)
    combinations = find_all_combinations_filtered(
        trimmed_tiles,
        max_guzhang=2 if is_ting else 4,
        min_used_tiles=10 if is_ting else 7,
    )

    prompt = build_prompt(
        trimmed_tiles, grouped, combinations, waiting_tiles, gang_tiles, peng_candidates
    )
    raw_suggestion = call_llm_api(prompt=prompt)
    suggestion = clean_response(raw_suggestion)

    session_id = f"{user_id}-upload"
    print("✅ 后端生成的 session_id:", session_id)
    user_msg = Message(
        role="user",
        type="text",
        content="请根据我的上传图片给出出牌建议",
        timestamp=int(time.time() * 1000),
    )
    assistant_msg = Message(
        role="assistant",
        type="text",
        content=suggestion,
        metadata=Metadata(hand_tiles=trimmed_tiles),
        timestamp=int(time.time() * 1000),
    )
    chat_sessions[session_id] = [user_msg, assistant_msg]

    return {
        "detected_tiles": raw_hand_tiles,
        "classified": sorted_tiles,
        "gangpai": gang_tiles,
        "peng_candidates": peng_candidates,
        "combinations": combinations,
        "is_ting": is_ting,
        "suggestion": suggestion,
        "session_id": session_id,
        "chat_sessions": chat_sessions,
    }


@app.post("/upgrade")
async def upgrade_to_vip(user=Depends(get_current_user)):
    supabase = await get_supabase()
    user_id = user["sub"]
    await (
        supabase.table("profiles").update({"is_vip": True}).eq("id", user_id).execute()
    )
    return {"message": "🎉 开通会员成功！"}

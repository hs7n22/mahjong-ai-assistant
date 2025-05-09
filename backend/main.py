import os
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, File, HTTPException, Request, UploadFile, status
from jose import jwt, JWSError
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from tiles_infer import predict_hand_tiles
from tile_classifier import find_all_combinations_filtered
from models.llm_utils import call_llm_api, build_prompt, clean_response
from tile_utils import organize_tiles, normalize_tiles_to_chinese
from tiles_waiting import get_waiting_tiles, get_gang_tiles, get_peng_tiles

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SUPABASE_JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")
SUPABASE_PROJECT_ID = os.getenv("SUPABASE_PROJECT_ID")


def get_current_user(request: Request):
    auth = request.headers.get("Authorization")
    if not auth or not auth.startswith("Bearer"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing token"
        )

    token = auth.split(" ")[1]

    try:
        payload = jwt.decode(
            token, SUPABASE_JWT_SECRET, algorithms=["HS256"], audience="authenticated"
        )
        return payload  # 可提取email，sub，role等字段
    except JWSError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        )


# 模拟用户数据库
user_upload_record = {}

UPLOAD_LIMIT_PER_DAY = 3  # 普通用户每天最多上传3次


def check_upload_permission(user_id):
    today = datetime.now().strftime("%Y-%m-%d")

    # 如果这个用户没有记录，初始化
    if user_id not in user_upload_record:
        user_upload_record[user_id] = {
            "last_upload_date": today,
            "upload_count": 0,
            "is_vip": False,  # 默认非会员，后续可以通过设置会员
        }
    record = user_upload_record[user_id]

    # 如果是新的一天，重制计数
    if record["last_upload_date"] != today:
        record["upload_count"] = 0
        record["last_upload_date"] = today

    # 如果是会员，永远允许上传
    if record["is_vip"]:
        return True

    # 如果不是会员，检查今日上传次数
    if record["upload_count"] < UPLOAD_LIMIT_PER_DAY:
        return True
    else:
        return False


def record_upload(user_id):
    if user_id in user_upload_record:
        user_upload_record[user_id]["upload_count"] += 1


@app.get("/protected")
def protected_route(user=Depends(get_current_user)):
    return {
        "msg": "你已经成功通过身份验证!",
        "email": user.get("email"),
        "user_id": user.get("sub"),
        "role": user.get("role"),
    }


@app.post("/upload")
def upload_file(user=Depends(get_current_user), file: UploadFile = File(...)):
    user_id = user["sub"]

    if not check_upload_permission(user_id):
        raise HTTPException(
            status_code=403, detail="已超出今日上传次数，升级会员享受不限量上传。"
        )

    save_dir = "uploads"
    os.makedirs(save_dir, exist_ok=True)

    file_location = os.path.join(save_dir, f"{user['sub']}_{file.filename}")
    with open(file_location, "wb") as f:
        f.write(file.file.read())

    record_upload(user_id)

    # 1.识别原始牌型
    raw_hand_tiles = predict_hand_tiles(file_location)
    hand_tiles = normalize_tiles_to_chinese(raw_hand_tiles)

    # 2.分类
    grouped = organize_tiles(hand_tiles)
    sorted_tiles = grouped["万"] + grouped["筒"] + grouped["条"] + grouped["字"]
    # 3.检查是否有杠和潜在的碰
    gang_tiles, trimmed_tiles = get_gang_tiles(sorted_tiles)
    peng_candidates = get_peng_tiles(trimmed_tiles)

    # 4.判断是否胡牌
    waiting_tiles = get_waiting_tiles(trimmed_tiles)

    # 5通过是否听牌来判断动态调整排列组合的策略
    is_ting = bool(waiting_tiles)
    if is_ting:
        print("已进入听牌阶段，使用严格组合模式（strict=True）")
        combinations = find_all_combinations_filtered(
            trimmed_tiles, max_guzhang=2, min_used_tiles=10
        )
    else:
        print("处于开局/非听牌阶段，使用宽松组合模式（strict=False）")
        combinations = find_all_combinations_filtered(
            trimmed_tiles, max_guzhang=4, min_used_tiles=7
        )

    # 3.构造LLM Prompt
    prompt = build_prompt(
        trimmed_tiles,
        grouped,
        combinations,
        waiting_tiles,
        gang_tiles,
        peng_candidates,
    )
    raw_suggestion = call_llm_api(prompt)
    suggestion = clean_response(raw_suggestion)

    # 4.返回结构化数据
    return {
        "detected_tiles": raw_hand_tiles,
        "classified": sorted_tiles,
        "gangpai": gang_tiles,
        "peng_candidates": peng_candidates,
        "combinations": combinations,
        "is_ting": is_ting,
        "suggestion": suggestion,
    }


@app.post("/upgrade")
def upgrade_to_vip(user=Depends(get_current_user)):
    user_id = user["sub"]

    if user_id not in user_upload_record:
        # 初始化用户记录
        today = datetime.now().strftime("%Y-%m-%d")
        user_upload_record[user_id] = {
            "last_upload_date": today,
            "upload_count": 0,
            "is_vip": False,
        }
    user_upload_record[user_id]["is_vip"] = True

    return {"message": "开通会员成功"}

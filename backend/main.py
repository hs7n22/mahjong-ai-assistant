import os
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, File, HTTPException, Request, UploadFile, status
from jose import jwt, JWSError
from fastapi.middleware.cors import CORSMiddleware

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
    save_dir = "uploads"
    os.makedirs(save_dir, exist_ok=True)

    file_location = os.path.join(save_dir, f"{user['sub']}_{file.filename}")
    with open(file_location, "wb") as f:
        f.write(file.file.read())

    return {
        "message": "上传成功!",
        "saved_as": file_location,
        "uploaded_by": user.get("email"),
    }

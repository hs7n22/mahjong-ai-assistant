from supabase import create_async_client, Client
import os
from dotenv import load_dotenv

load_dotenv()
_supabase: Client = None


async def get_supabase() -> Client:
    global _supabase
    if _supabase is None:
        url = os.getenv("SUPABASE_URL")
        key = os.getenv("SUPABASE_KEY")  # Service Role key 权限更高，用于后台更新
        _supabase = await create_async_client(url, key)
    return _supabase

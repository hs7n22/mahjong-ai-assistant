import os
import traceback
import stripe
from fastapi import APIRouter, Request, HTTPException, Depends
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from utils.auth import get_current_user


load_dotenv()

router = APIRouter()
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
FRONTEND_URL = os.getenv("FRONTEND_URL")


@router.post("/create-checkout-session")
async def create_checkout_session(user=Depends(get_current_user)):
    try:
        checkout_session = stripe.checkout.Session.create(
            success_url=f"{FRONTEND_URL}/payment-success",
            cancel_url=f"{FRONTEND_URL}/payment-cancel",
            payment_method_types=["card"],
            mode="payment",
            customer_email=user["email"],
            line_items=[
                {
                    "price_data": {
                        "currency": "hkd",
                        "product_data": {
                            "name": "川麻AI助手会员订阅",
                        },
                        "unit_amount": 1990,  # 价格，单位为分（19.90港币）
                    },
                    "quantity": 1,
                },
            ],
            metadata={"user_id": user["sub"]},
        )
        return {"url": checkout_session.url}
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/stripe-webhook")
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")
    endpoint_secret = os.getenv("STRIPE_WEBHOOK_SECRET")

    try:
        event = stripe.Webhook.construct_event(payload, sig_header, endpoint_secret)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Webhook 验证失败: {str(e)}")

    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]
        user_id = session["metadata"]["user_id"]

        from supabase import create_async_client

        supabase = await create_async_client(
            os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY")
        )
        await (
            supabase.table("profiles")
            .update({"is_vip": True})
            .eq("id", user_id)
            .execute()
        )
        print(f"✅ 用户 {user_id} 成功升级为 VIP")
    return JSONResponse(content={"status": "success"}, status_code=200)

import json
import requests
import os
import re
from dotenv import load_dotenv
from typing import List, Dict
from models.message import Message

load_dotenv()


def build_prompt(
    trimmed_tiles: list,
    classfied: dict,
    combinations: list,
    waiting_tiles: list,
    gang_tiles: list = None,
    peng_candidates: list = None,
) -> str:
    phase = "摸牌阶段（共13张）" if len(trimmed_tiles) == 13 else "出牌阶段（共14张）"
    combination_intro = "当前最推荐的组合如下: \n"

    def combo_to_str(combo):
        return (
            f"顺子: {combo['shunzi']},"
            f"刻子: {combo['kezi']},"
            f"对子: {combo['duizi']}"
            f"孤张: {combo['guzhang']}"
        )

    if combinations:
        best = combinations[0]
        others = combinations[1:]
        combination_intro += "- 当前牌组中的最优组合: " + combo_to_str(best) + "\n"
        if others:
            combination_intro += (
                "-其他组合：\n" + "\n".join([combo_to_str(c) for c in others]) + "\n"
            )
    else:
        combination_intro += "未识别出有效组合，请检查牌组。"

    gang_info = ""
    if gang_tiles:
        gang_info = f"\n你当前手牌中有一下暗杠（即4张相同的牌）：{','.join(gang_tiles)}。请注意，暗杠属于一种刻子结构，但第4张多余的牌不计入胡牌组合中，仅供参考。"

    peng_info = ""
    if peng_candidates:
        peng_info = f"\n你当前手牌中可碰的对子包括：{','.join(peng_candidates)}"

    waiting_info = ""
    if len(trimmed_tiles) == 13 and waiting_tiles:
        combination_intro += f"你已经听牌，可胡的牌有： {', '.join(waiting_tiles)}。 \n"

    return f"""
    你是一位麻将指导顾问，你的任务是帮助普通玩家根据当前手牌提供清晰简明的出牌或摸牌建议。
    当前阶段： {phase}
    识别到并处理杠牌后的当前有效手牌如下（ 共{len(trimmed_tiles)} 张）：
    {",".join(trimmed_tiles)}

    根据本地算法分类结果如下：
    - 万字牌： {",".join(classfied.get("万", []))}
    - 筒字牌： {",".join(classfied.get("筒", []))}
    - 条字牌： {",".join(classfied.get("条", []))}
    - 字牌： {",".join(classfied.get("字", []))}

    {combination_intro}{gang_info}{peng_info}{waiting_info}

    麻将术语说明（请务必遵循）：
    - 刻子：三张相同牌，如 8筒 8筒 8筒
    - 顺子：同花色连续三张牌，如 3筒 4筒 5筒
    - 对子：两张相同牌，如 1筒 1筒
    - 胡牌要求是四组（刻子或顺子） + 一组对子，合计14张牌。
    请在分析时避免将对子误认为刻子，或将顺子与刻子混淆。

    请根据以下麻将基本规则给出判断：
    注意：请仅基于同一组合结构判断能否胡牌，不要将多个组合混合使用。每个胡牌组合必须包含4组完整的顺子或刻子（共12张）加1对将（2张），共计14张，不能多也不能少。也不能为了胡牌打乱已有的将。
    1. 若当前手牌已经胡牌，请明确告诉用户 “你已经胡了” 并停止建议。
    2. 若当前处于听牌状态（即差一张胡牌）， 请提示“你已经听牌”， 并说明有哪些牌可以胡。
    3. 若为摸牌阶段（13张）， 请建议“保留哪些摸到的牌最利于胡牌”，避免建议打牌。
    4. 若为出牌阶段（14张）， 请建议“打哪一张牌，并简要说明理由哦。

    要求：
    - 回答不使用 Markdown、 不使用\n、不加粗、 不重复。
    - 语言清晰，面向初学者，不知用麻将术语（如面子、搭子、雀头等）。
    - 总字数尽量控制在100字以内。

    要求：
    - 语言通俗易懂，避免使用专业术语
    - 不使用**加醋**、 不要使用Markdown、不要出现 “\\n”、多余换行、花哨格式
    - 不要重复说同一件事,控制在100字以内
    
    """


def build_prompt_from_messages(
    messages: List[Message], current_tiles: List[str]
) -> List[Dict[str, str]]:
    # 初始化 prompt 结构
    chat_prompt = [
        {
            "role": "system",
            "content": (
                "你是一名经验丰富的麻将指导专家。"
                "请用简洁简明的语言帮助用户理解当前的出来建议或解释他们的疑问，避免使用专业术语。"
                "请根据用户提供的上下文、牌面信息、出牌建议等，给出准确但简洁的回复。"
            ),
        }
    ]
    # 拼接当前有效手牌
    tile_summary = f"当前玩家的有效手牌为:{','.join(current_tiles)}。"

    # 将手牌信息插入为新的user消息
    chat_prompt.append({"role": "user", "content": tile_summary})

    # 拼接已有对话
    for msg in messages:
        chat_prompt.append({"role": msg.role, "content": msg.content})

    return chat_prompt


def clean_response(text: str) -> str:
    text = re.sub(r"\*\*", "", text)
    text = text.replace("\\n", "\n").replace("\n", "")
    text = text.replace("}", "")
    return text.strip()


def call_llm_api(prompt: str = None, messages: List[Dict[str, str]] = None) -> str:
    url = "https://api.siliconflow.cn/v1/chat/completions"
    api_key = os.getenv("SILICONFLOW_API_KEY")

    if not api_key:
        raise ValueError("API 密钥未设置，请问子.env中设置SILICONFLOW_API_KEY")

    if messages is None and prompt is not None:
        messages = [
            {
                "role": "system",
                "content": "你是一名资深的麻将指导专家，请针对普通玩家提供清晰的出牌建议。",
            },
            {"role": "user", "content": prompt},
        ]
    elif messages is None:
        raise ValueError("必须提供prompt或者messages 之一")

    headers = {
        "Authorization": "Bearer sk-ecoxfnqfuttlpjadebylmlgxcvjrgeunjgaalalzyrjnlzdk",
        "Content-Type": "application/json",
    }
    payload = {
        "model": "Qwen/QwQ-32B",
        "messages": messages,  # 改为直接使用外部传入的多轮消息
        "stream": False,
        "max_tokens": 512,
        "enable_thinking": False,
        "thinking_budget": 512,
        "min_p": 0.1,
        "stop": None,
        "temperature": 0.5,
        "top_p": 0.9,
        "top_k": 20,
        "frequency_penalty": 0.0,
        "n": 1,
        "response_format": {"type": "text"},
    }

    print("Payload:", json.dumps(payload, ensure_ascii=False, indent=2))

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        return f"调用LLM失败: {str(e)}"

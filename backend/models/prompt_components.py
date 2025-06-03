# def build_prompt_content用于整理LLM理解当前的手牌所需的原始上下文信息
def build_prompt_content(
    trimmed_tiles: list[str],
    classfied: dict,
    gang_tiles: list[str] = None,
    peng_candidates: list[str] = None,
) -> str:
    """
    构建LLM理解的手牌的提示词内容区，包含阶段、手牌、分类、杠、碰等信息。
    """

    phase = "摸牌阶段（共13张）" if len(trimmed_tiles) == 13 else "出牌阶段（共14张）"

    # 手牌部分
    tiles_info = f"当前阶段: {phase}。 \当前有效手牌如下（共{len(trimmed_tiles)}张）: {','.join(trimmed_tiles)}。"

    # 分类信息部分
    classfied_info = (
        f"\n根据花色分类如下: \n"
        f"- 万字牌: {','.join(classfied.get('万', [])) or '无'}\n"
        f"- 筒字牌: {','.join(classfied.get('筒', [])) or '无'}\n"
        f"- 条字牌: {','.join(classfied.get('条', [])) or '无'}\n"
        f"- 字牌: {','.join(classfied.get('字', [])) or '无'}\n"
    )

    # 暗杠信息
    gang_info = ""
    if gang_tiles:
        gang_info = f"\n你当前有以下暗杠（4张相同的牌）: {','.join(gang_tiles)}。 请注意，暗杠属于刻子结构，第4张不计入胡牌组合，仅供参考。"

    # 可碰对子信息
    peng_info = ""
    if peng_candidates:
        peng_info = (
            f"\n你手中可碰的对子包括: {','.join(peng_candidates)}（每张均为2张）。"
        )

    general_info = "\n请仅根据上述数量进行判断，不允许自行想象其他数量。"

    return tiles_info + classfied_info + gang_info + peng_info + general_info


# build_prompt_structure_analysis用于描述当前牌组中已识别出的顺子、刻字、故张等组合结构
def build_prompt_structre_analysis(
    combinations: list[dict], waiting_tiles: list[str] = None
) -> str:
    """
    根据本地算法输出的组合结果和听牌状态构建结构分析提示词段落。
    """

    def combo_to_str(combo):
        return (
            f"顺子： {','.join(combo['shunzi']) or '无'},"
            f"刻字：{','.join(combo['kezi']) or '无'}"
            f"对子：{','.join(combo['duizi']) or '无'}"
            f"孤张: {','.join(combo['guzhang']) or '无'}"
        )

    result = "当前牌型结构分析如下: \n"

    if combinations:
        best = combinations[0]
        others = combinations[1:]
        result += "- 最优组合: \n " + combo_to_str(best) + "\n"
        if others:
            result += (
                "- 其他可行组合: \n"
                + "\n + \n".join([" " + combo_to_str(c) for c in others])
                + "\n"
            )
    else:
        result += "未识别出有效组合。"
    # 听牌信息（仅在13张时有效）
    if waiting_tiles:
        result += f"\n你已经听牌，可胡的牌有：{', '.join(waiting_tiles)}。"

    return result


# build_prompt_rules是将四川麻将的核心胡牌规则和出牌判断标准准确传达给LLM
def build_prompt_rules() -> str:
    return """"
    麻将术语说明（请务必遵循）
    - 刻子： 三张相同的牌， 例如： 8筒 8筒 8筒
    - 顺子： 同花色连续三张牌， 例如： 3筒 4筒 5筒
    - 对子： 两张相同牌，例如： 1筒 1筒
    - 胡牌结构： 4组刻子/顺子 + 1组对子， 共14张牌
    - 四川麻将不带风牌， 无花牌， 不算七对， 不能吃牌， 仅碰/杠

    四川麻将技巧补充（供参考）：
    - 中张（4～6）价值较高，容易组成顺子，建议优先保留。
    - 重读牌可构成对子或刻子，优先留两张以上的牌。
    - 若有对子，建议保留，作为将或未来刻子发展基础。
    - 若以听牌， 尽量不打出对方可能碰或杠的牌（如风牌、红中），防止放炮。
    - 如果手牌结构混乱，优先打出即不成顺子也不成刻子的孤张。
    - 出若无明显组合，建议凑搭子（如相邻的两张牌）作为听牌预备。

    出牌建议规则判断：
    1. 若手牌符合胡牌结构， 请回复”你已经胡了“， 并终止建议。
    2. 若出于听牌状态（差一张胡牌），请回复”你已经听牌“，并列出可胡的牌。
    3. 若是摸牌阶段（13张），请分析当前组合并建议”哪些牌应保留最利于听牌或胡牌“，不要建议打牌。
    4. 若是出牌阶段（14张），请判断”打出哪张牌最能提升胡牌机会“，并简明说明理由。

    格式与风格要求：
    - 不使用 MarkDown（例如不要 **加醋**、不要 \\n）
    - 语言简洁通俗，避免使用专业术语（如打字、雀头、面子）
    - 控制在100字以内，避免重复和无效建议
"""

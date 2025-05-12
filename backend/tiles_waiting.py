from tile_classifier import find_all_combinations_filtered
from collections import Counter
from typing import List
import copy

ALL_TILES = [f"{i}{suit}" for suit in ["万", "筒", "条"] for i in range(1, 10)] + [
    "东",
    "南",
    "西",
    "北",
    "中",
    "发",
    "白",
]


def is_valid_hu(tiles: List[str]) -> bool:
    combos = find_all_combinations_filtered(tiles)
    for combo in combos:
        shunzi = combo["shunzi"]
        kezi = combo["kezi"]
        duizi = combo["duizi"]
        if len(shunzi) + len(kezi) == 4 and len(duizi) == 1:
            return True
    return False


def get_waiting_tiles(hand_tiles: List[str]) -> List[str]:
    if len(hand_tiles) != 13:
        return []  # 只对摸牌阶段有效

    counter = Counter(hand_tiles)
    candidates = []

    for tile in ALL_TILES:
        if counter[tile] >= 4:
            continue  # 超过4张的牌不能再摸
        test_hand = copy.deepcopy(hand_tiles)
        test_hand.append(tile)
        if is_valid_hu(test_hand):
            candidates.append(tile)
    return sorted(candidates)

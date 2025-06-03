# # tile_classifier.py
# from collections import Counter
# from typing import List, Dict
# import copy


# def organize_tiles(tiles: List[str]) -> Dict[str, List[str]]:
#     result = {"万": [], "筒": [], "条": [], "字": []}
#     for tile in tiles:
#         if tile.endswith("万"):
#             result["万"].append(tile)
#         elif tile.endswith("筒"):
#             result["筒"].append(tile)
#         elif tile.endswith("条"):
#             result["条"].append(tile)
#         else:
#             result["字"].append(tile)
#     return result


# def parse_number(tile: str) -> int:
#     try:
#         return int(tile[0])
#     except ValueError:
#         return -1


# def get_structure_signature(combo: Dict[str, List]) -> str:
#     def sorted_nested(lst):
#         return sorted([tuple(sorted(inner)) for inner in lst])

#     shunzi_sig = sorted_nested(combo["shunzi"])
#     kezi_sig = sorted_nested(combo["kezi"])
#     duizi_sig = sorted_nested(combo["duizi"])
#     guz_sig = tuple(sorted(combo["guzhang"]))

#     return str((tuple(shunzi_sig), tuple(kezi_sig), tuple(duizi_sig), guz_sig))


# def deduplicate_combinations(combos: List[Dict[str, List]]) -> List[Dict[str, List]]:
#     seen = set()
#     deduped = []
#     for combo in combos:
#         sig = get_structure_signature(combo)
#         if sig not in seen:
#             seen.add(sig)
#             deduped.append(combo)
#     return deduped


# def find_all_combinations_filtered(
#     tiles: List[str],
#     min_used_tiles: int = 9,
#     max_guzhang: int = 3,
#     min_structures: int = 1,
# ) -> List[Dict[str, List]]:
#     all_combinations = []

#     def dfs(remaining: List[str], shunzi, kezi, duizi, guz):
#         if not remaining:
#             used_count = len(tiles) - len(guz)
#             if used_count >= min_used_tiles and len(guz) <= max_guzhang:
#                 structure_count = int(bool(shunzi)) + int(bool(kezi)) + int(bool(duizi))
#                 if structure_count >= min_structures:
#                     all_combinations.append(
#                         {
#                             "shunzi": copy.deepcopy(shunzi),
#                             "kezi": copy.deepcopy(kezi),
#                             "duizi": copy.deepcopy(duizi),
#                             "guzhang": copy.deepcopy(guz),
#                         }
#                     )
#             return

#         counter = Counter(remaining)
#         used = set()

#         for tile in sorted(remaining):
#             if tile in used or counter[tile] == 0:
#                 continue
#             used.add(tile)
#             num = parse_number(tile)
#             suit = tile[-1]

#             # 刻子
#             if counter[tile] >= 3:
#                 new_remain = remaining.copy()
#                 for _ in range(3):
#                     new_remain.remove(tile)
#                 dfs(new_remain, shunzi, kezi + [[tile] * 3], duizi, guz)

#             # 顺子
#             if suit in ["万", "筒", "条"]:
#                 t2 = f"{num + 1}{suit}"
#                 t3 = f"{num + 2}{suit}"
#                 if counter[t2] > 0 and counter[t3] > 0:
#                     new_remain = remaining.copy()
#                     new_remain.remove(tile)
#                     new_remain.remove(t2)
#                     new_remain.remove(t3)
#                     dfs(new_remain, shunzi + [[tile, t2, t3]], kezi, duizi, guz)

#             # 对子
#             if counter[tile] >= 2:
#                 new_remain = remaining.copy()
#                 for _ in range(2):
#                     new_remain.remove(tile)
#                 dfs(new_remain, shunzi, kezi, duizi + [[tile] * 2], guz)

#         # 孤张
#         new_remain = remaining.copy()
#         new_remain.remove(tile)
#         dfs(new_remain, shunzi, kezi, duizi, guz + [tile])

#     dfs(tiles, [], [], [], [])
#     return deduplicate_combinations(all_combinations)
from backend.logic.tiles_waiting import get_waiting_tiles

test_hand = [
    "9万",
    "9万",
    "6万",
    "6万",
    "4万",
    "3万",
    "3万",
    "2万",
    "2万",
    "1万",
    "8万",
    "8万",
    "8万",
]
result = get_waiting_tiles(test_hand)
print("听牌候选张：", result)

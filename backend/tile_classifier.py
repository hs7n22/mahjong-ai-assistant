from typing import List, Dict
from collections import Counter
import copy
from tile_utils import (
    parse_number,
    deduplicate_combinations,
)


def find_all_combinations_filtered(
    tiles: List[str],
    min_used_tiles: int = 9,
    max_guzhang: int = 3,
    min_structures: int = 1,
) -> List[Dict[str, List]]:
    all_combinations = []

    def dfs(remaining: List[str], shunzi, kezi, duizi, guz):
        if not remaining:
            used_count = len(tiles) - len(guz)
            if used_count >= min_used_tiles and len(guz) <= max_guzhang:
                structure_count = int(bool(shunzi)) + int(bool(kezi)) + int(bool(duizi))
                if structure_count >= min_structures:
                    all_combinations.append(
                        {
                            "shunzi": copy.deepcopy(shunzi),
                            "kezi": copy.deepcopy(kezi),
                            "duizi": copy.deepcopy(duizi),
                            "guzhang": copy.deepcopy(guz),
                        }
                    )
            return

        counter = Counter(remaining)
        used = set()

        for tile in sorted(remaining):
            if tile in used or counter[tile] == 0:
                continue
            used.add(tile)
            num = parse_number(tile)
            suit = tile[-1]

            # 刻子
            if counter[tile] >= 3:
                new_remain = remaining.copy()
                for _ in range(3):
                    new_remain.remove(tile)
                dfs(new_remain, shunzi, kezi + [[tile] * 3], duizi, guz)

            # 顺子
            if suit in ["万", "筒", "条"]:
                t2 = f"{num + 1}{suit}"
                t3 = f"{num + 2}{suit}"
                if counter[t2] > 0 and counter[t3] > 0:
                    new_remain = remaining.copy()
                    new_remain.remove(tile)
                    new_remain.remove(t2)
                    new_remain.remove(t3)
                    dfs(new_remain, shunzi + [[tile, t2, t3]], kezi, duizi, guz)

            # 对子
            if counter[tile] >= 2:
                new_remain = remaining.copy()
                for _ in range(2):
                    new_remain.remove(tile)
                dfs(new_remain, shunzi, kezi, duizi + [[tile] * 2], guz)

        # 孤张
        new_remain = remaining.copy()
        new_remain.remove(tile)
        dfs(new_remain, shunzi, kezi, duizi, guz + [tile])

    dfs(tiles, [], [], [], [])
    return deduplicate_combinations(all_combinations)

from typing import List, Dict


def organize_tiles(tiles: List[str]) -> Dict[str, List[str]]:
    result = {"万": [], "条": [], "筒": [], "字": []}

    for tile in tiles:
        if tile.endswith("wan"):
            result["万"].append(tile)
        elif tile.endswith("tiao"):
            result["条"].append(tile)
        elif tile.endswith("tong"):
            result["筒"].append(tile)
        else:
            result["字"].append(tile)
    return result


def parse_number(tile: str) -> int:
    try:
        return int(tile[0])
    except ValueError:
        return -1


def get_structure_signature(combo: Dict[str, List]) -> str:
    def sorted_nested(lst):
        return sorted([tuple(sorted(inner)) for inner in lst])

    shunzi_sig = sorted_nested(combo["shunzi"])
    kezi_sig = sorted_nested(combo["kezi"])
    duizi_sig = sorted_nested(combo["duizi"])
    guz_sig = tuple(sorted(combo["guzhang"]))

    return str((tuple(shunzi_sig), tuple(kezi_sig), tuple(duizi_sig), guz_sig))


def deduplicate_combinations(combos: List[Dict[str, List]]) -> List[Dict[str, List]]:
    seen = set()
    deduped = []
    for combo in combos:
        sig = get_structure_signature(combo)
        if sig not in seen:
            seen.add(sig)
            deduped.append(combo)
    return deduped


def normalize_tiles_to_chinese(tiles: List[str]) -> List[str]:
    return [
        t.replace("wan", "万")
        .replace("tong", "筒")
        .replace("tiao", "条")
        .replace("dong", "东")
        .replace("nan", "南")
        .replace("xi", "西")
        .replace("bei", "北")
        .replace("zhong", "中")
        .replace("fa", "发")
        .replace("bai", "白")
        for t in tiles
    ]

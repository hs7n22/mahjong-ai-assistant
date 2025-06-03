from typing import List, Dict


def organize_tiles(tiles: List[str]) -> Dict[str, List[str]]:
    result = {"万": [], "条": [], "筒": [], "字": []}

    for tile in tiles:
        if tile.endswith("万"):
            result["万"].append(tile)
        elif tile.endswith("条"):
            result["条"].append(tile)
        elif tile.endswith("筒"):
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
        .replace("dong", "东风")
        .replace("nanfeng", "南风")
        .replace("xi", "西风")
        .replace("bei", "北风")
        .replace("hongzhong", "红中")
        .replace("fa", "发财")
        .replace("bai", "白版")
        for t in tiles
    ]


def get_all_possible_tiles() -> List[str]:
    all_tiles = []

    # 数字牌：1~9 万、筒、条
    suits = ["万", "筒", "条"]
    for suit in suits:
        for suit in suits:
            for num in range(1, 10):
                all_tiles.append(f"{num}{suit}")

    # 字牌：东南西北中发白
    honors = ["东", "南", "西", "北", "中", "发", "白"]
    all_tiles.append(honors)

    return all_tiles

"""Rebuild VanillaIDs.lua so ForeverTweaks auto-handles exactly the quests Forever Quest Tint leaves untinted.

Source: ForeverQuestTint\\VanillaQuests.lua (original Classic quests, from Questie's database).
Falls back to wago.tools (Classic Era QuestV2 IDs that also exist in Forever) if Quest Tint is not installed.

Run with: python -I update_ids.py   (after Quest Tint updates; game closed, or /reload after)
"""
import csv
import io
import json
import re
import sys
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "VanillaIDs.lua"
# The live addon folder is a junction to this repo, so look in the real AddOns folder first.
ADDONS = Path(r"C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns")
FQT = next((p for p in (ADDONS / "ForeverQuestTint" / "VanillaQuests.lua", HERE.parent / "ForeverQuestTint" / "VanillaQuests.lua") if p.exists()), HERE.parent / "ForeverQuestTint" / "VanillaQuests.lua")
UA = {"User-Agent": "ForeverTweaks-updater"}


def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
        return r.read().decode("utf-8")


def quest_ids(build):
    rows = csv.DictReader(io.StringIO(get(f"https://wago.tools/db2/QuestV2/csv?build={build}")))
    ids = {int(r["ID"]) for r in rows}
    if not ids:
        sys.exit(f"No quest rows for build {build}")
    return ids


if FQT.exists():
    vanilla = set()
    for a, b in re.findall(r"\{(\d+),(\d+)\}", FQT.read_text(encoding="utf-8")):
        vanilla.update(range(int(a), int(b) + 1))
    if not vanilla:
        sys.exit(f"No ranges found in {FQT}")
    source = "ForeverQuestTint VanillaQuests.lua (Questie Classic database)"
else:
    builds = json.loads(get("https://wago.tools/api/builds/latest"))
    forever, era = builds["wowf"]["version"], builds["wow_classic_era"]["version"]
    vanilla = quest_ids(forever) & quest_ids(era)
    source = f"Classic Era {era} QuestV2 that also exist in Forever {forever} (wago.tools)"

vanilla = sorted(vanilla)
old = set()
if OUT.exists():
    old = {int(x) for x in re.findall(r"\[(\d+)\]=true", OUT.read_text())}

lines = [f"-- Vanilla quest IDs from {source}", "ForeverTweaksVanilla = {"]
lines += ["".join(f"[{i}]=true," for i in vanilla[k:k + 20]) for k in range(0, len(vanilla), 20)]
lines.append("}")
OUT.write_text("\n".join(lines) + "\n")

print(f"Source: {source}")
print(f"Vanilla (auto): {len(vanilla)}")
print(f"Change vs previous list: +{len(set(vanilla) - old)} / -{len(old - set(vanilla))}")

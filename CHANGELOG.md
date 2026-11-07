# Changelog

## 1.0.1 - 2026-11-07

- Fixed a Lua error, "secret number value ... tainted by ForeverTweaks", in the party frames:
  - `/ftparty` now writes the Edit Mode layout directly instead of opening and closing Edit Mode.
  - Dropped the custom "you last" sort. Blizzard's Sort by Role is used instead.
- Player frame health and mana are shown as numbers.

## 1.0.0 - 2026-11-07

- Renamed QuestFilter to **ForeverTweaks**:
  - The saved variables `QuestFilterDB` became `ForeverTweaksDB`, with all one-time flags carried over.
  - The vanilla quest table `QuestFilterVanilla` became `ForeverTweaksVanilla`.
- New commands: `/ft` (help), `/ftquests`, `/ftlayout`, `/ftparty` and `/ftdump`. The old `/qf*` commands still work.
- `update_ids.py` reads Forever Quest Tint from the real AddOns folder, because the addon folder is now a junction to this repository.

## History as QuestFilter

- 2026-11-07: Party frames are raid-style class-colored squares beside the portrait, sorted tank > healer > dps > you (`/qfparty`). LootGoblin's minimap button is moved into the hover icon group.
- 2026-11-06:
  - One-time setups: Waypoint UI navigator distance, the Platynator Jamestone import and the Details! Forever theme.
  - Removed the Tempo button and the Fish Button steps.
- 2026-11-05:
  - `/qflayout` and `/qfdump` for the HUD layout by code.
  - Action bar stacking.
  - One Key Fishing keys (K and Shift-K).
  - Minimap icon wrapping for Widsith, Pally Seal Cooldowns and One Key Fishing.
- 2026-11-04: Macro restore with icons (Attack uses Ashbringer, HS Downrank uses Crusader Strike).
- Earlier: vanilla quest auto accept and turn-in, with new Forever quests left alone; `update_ids.py`.

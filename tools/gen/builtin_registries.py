#!/usr/bin/env python3
"""Generates content/src/builtin-registry-text.cob: the strict JSON text of the built-in registry entries of the
cobolcraft set that are written in docs/design/cobolcraft-standard-core.md (the code blocks of sections 3.1 to 3.7),
as COBOL statements that fill a text area. The converter (builtin-registry.cob) turns each text into the entry's
network NBT. Usage: python3 tools/gen/builtin_registries.py (from the repository root)."""
import re, sys, textwrap

DOC = "docs/design/cobolcraft-standard-core.md"
OUT = "content/src/builtin-registry-text.cob"

doc = open(DOC, encoding="utf-8").read()

def block_after(marker):
    i = doc.index(marker)
    j = doc.index("```json", i)
    k = doc.index("```", j + 7)
    lines = [l for l in doc[j + 7:k].split("\n") if not l.strip().startswith("//")]
    text = "".join(l.strip() for l in lines)       # one line, no insignificant blanks outside strings is not needed
    return text

def compact(text):
    out, instr, esc = [], False, False
    for c in text:
        if instr:
            out.append(c)
            if esc: esc = False
            elif c == "\\": esc = True
            elif c == '"': instr = False
        elif c == '"':
            instr = True; out.append(c)
        elif c not in " \t\n":
            out.append(c)
    return "".join(out)

entries = [
    ("timeline", 0, "minecraft:day", compact(block_after("**`data/minecraft/timeline/day.json`**"))),
    ("timeline", 1, "minecraft:moon", compact(block_after("**`data/minecraft/timeline/moon.json`**"))),
    ("enchantment", 0, "minecraft:efficiency", compact(block_after("// data/minecraft/enchantment/efficiency.json".replace("// ", "### 3.7 `enchantment`")) if False else block_after("### 3.7 `enchantment`"))),
    ("world_clock", 0, "minecraft:overworld", "{}"),
]
# the enchantment block starts after the second heading line of section 3.7: take the block that holds efficiency
i = doc.index("// data/minecraft/enchantment/efficiency.json")
j = doc.rindex("```json", 0, i)
k = doc.index("```", i)
body = [l for l in doc[j + 7:k].split("\n") if not l.strip().startswith("//")]
entries[2] = ("enchantment", 0, "minecraft:efficiency", compact("".join(body)))

import json

def jdump(obj):
    return json.dumps(obj, separators=(",", ":"), ensure_ascii=False)

# --- biomes (3.4): the three JSON lines after the heading, comments stripped
i = doc.index("### 3.4 `worldgen/biome`")
j = doc.index("```json", i)
k = doc.index("```", j + 7)
biome_text = [l.strip() for l in doc[j + 7:k].split("\n")]
biome_objs, cur, key = [], [], None
for l in biome_text:
    if l.startswith("//"):
        m = re.search(r"data/(\w+)/worldgen/biome/(\w+)\.json", l)
        if cur:
            biome_objs.append((key, "".join(cur))); cur = []
        key = m.group(1) + ":" + m.group(2)
    elif l:
        cur.append(l)
biome_objs.append((key, "".join(cur)))
for n, (key, text) in enumerate(biome_objs):
    entries.append(("worldgen/biome", n, key, compact(text)))

# --- chat types (3.5): the table rows
i = doc.index("### 3.5 `chat_type`")
rows = [l for l in doc[i:doc.index("For the team rows", i)].split("\n") if re.match(r"\| \d+ \|", l)]
for l in rows:
    cells = [c.strip() for c in l.strip().strip("|").split("|")]
    eid, key = int(cells[0]), cells[1].strip("`")
    def deco(cell, with_style):
        tk = re.search(r"`([^`]+)`", cell).group(1)
        params = [p.strip() for p in re.search(r"\[([^\]]*)\]", cell).group(1).split(",")]
        o = {"translation_key": tk, "parameters": params}
        m = re.search(r"style `(\{.*\})`", cell)
        if m and with_style:
            o["style"] = json.loads(m.group(1))
        return o
    obj = {"chat": deco(cells[2], True), "narration": deco(cells[3], False)}
    entries.append(("chat_type", eid, key, jdump(obj)))

# --- damage types (3.6): the table rows
i = doc.index("### 3.6 `damage_type`")
rows = [l for l in doc[i:doc.index("**Decision CORE-10", i)].split("\n") if re.match(r"\| \d+ \|", l)]
for l in rows:
    cells = [c.strip() for c in l.strip().strip("|").split("|")]
    eid, key = int(cells[0]), cells[1].strip("`")
    mid = re.match(r"`([^`]+)`", cells[3]).group(1)
    scaling = "always" if cells[4] == "always" else "when_caused_by_living_non_player"
    obj = {"message_id": mid, "scaling": scaling}
    obj["exhaustion"] = float(cells[5])
    eff = cells[6].split(" ")[0]
    if eff != "hurt":
        obj["effects"] = eff
    if cells[7] != "default":
        obj["death_message_type"] = cells[7]
    text = jdump(obj)
    # json.dumps writes 0.0 as 0.0 and 0.1 as 0.1: a float literal, as the converter needs
    entries.append(("damage_type", eid, key, text))

# --- dimension types (3.3)
def attr_block(heading):
    i = doc.index(heading)
    j = doc.index("```json", i)
    k = doc.index("```", j + 7)
    return json.loads("{" + doc[j + 7:k].replace('"attributes": ', '"attributes":', 1).strip() + "}")["attributes"]
surface_attrs = attr_block("**`cobolcraft:surface` attributes**")
sunless_attrs = attr_block("**`cobolcraft:sunless` attributes:**")
spawn = {"type": "minecraft:uniform", "min_inclusive": 0, "max_inclusive": 7}
surface = {"has_skylight": True, "has_ceiling": False, "has_ender_dragon_fight": False, "coordinate_scale": 1.0,
           "min_y": 0, "height": 256, "logical_height": 256, "infiniburn": [], "ambient_light": 0.0,
           "monster_spawn_light_level": spawn, "monster_spawn_block_light_limit": 0,
           "attributes": surface_attrs, "timelines": ["minecraft:day", "minecraft:moon"],
           "default_clock": "minecraft:overworld"}
sunless = {"has_fixed_time": True, "has_skylight": False, "has_ceiling": False, "has_ender_dragon_fight": False,
           "coordinate_scale": 1.0, "min_y": 0, "height": 128, "logical_height": 128, "infiniburn": [],
           "ambient_light": 0.0, "monster_spawn_light_level": spawn, "monster_spawn_block_light_limit": 0,
           "skybox": "none", "attributes": sunless_attrs}
entries.append(("dimension_type", 0, "cobolcraft:surface", jdump(surface)))
entries.append(("dimension_type", 1, "cobolcraft:sunless", jdump(sunless)))

# --- the 13 mandatory variant registries (standin 4.5; core 3.8)
T = "cobolcraft:entity/placeholder"
S = {"sound_id": "cobolcraft:silent"}
def sounds(names):
    return {n: S for n in names}
variants = [
    ("wolf_variant", {"assets": {"wild": T, "tame": T, "angry": T}, "baby_assets": {"wild": T, "tame": T, "angry": T}}),
    ("wolf_sound_variant", {"adult_sounds": sounds(["ambient_sound", "death_sound", "growl_sound", "hurt_sound", "pant_sound", "whine_sound", "step_sound"]),
                            "baby_sounds": sounds(["ambient_sound", "death_sound", "growl_sound", "hurt_sound", "pant_sound", "whine_sound", "step_sound"])}),
    ("pig_variant", {"model": "normal", "asset_id": T, "baby_asset_id": T}),
    ("pig_sound_variant", {"adult_sounds": sounds(["ambient_sound", "hurt_sound", "death_sound", "step_sound", "eat_sound"]),
                           "baby_sounds": sounds(["ambient_sound", "hurt_sound", "death_sound", "step_sound", "eat_sound"])}),
    ("frog_variant", {"asset_id": T}),
    ("cat_variant", {"asset_id": T, "baby_asset_id": T}),
    ("cat_sound_variant", {"adult_sounds": sounds(["ambient_sound", "stray_ambient_sound", "hiss_sound", "hurt_sound", "death_sound", "eat_sound", "beg_for_food_sound", "purr_sound", "purreow_sound"]),
                           "baby_sounds": sounds(["ambient_sound", "stray_ambient_sound", "hiss_sound", "hurt_sound", "death_sound", "eat_sound", "beg_for_food_sound", "purr_sound", "purreow_sound"])}),
    ("cow_sound_variant", sounds(["ambient_sound", "hurt_sound", "death_sound", "step_sound"])),
    ("cow_variant", {"model": "normal", "asset_id": T, "baby_asset_id": T}),
    ("chicken_sound_variant", {"adult_sounds": sounds(["ambient_sound", "hurt_sound", "death_sound", "step_sound"]),
                               "baby_sounds": sounds(["ambient_sound", "hurt_sound", "death_sound", "step_sound"])}),
    ("chicken_variant", {"model": "normal", "asset_id": T, "baby_asset_id": T}),
    ("zombie_nautilus_variant", {"model": "normal", "asset_id": T}),
    ("painting_variant", {"width": 1, "height": 1, "asset_id": "cobolcraft:placeholder", "title": "Placeholder"}),
]
for name, obj in variants:
    entries.append((name, 0, "cobolcraft:placeholder", jdump(obj)))

lines = []
w = lines.append
w("*> GENERATED by tools/gen/builtin_registries.py from docs/design/cobolcraft-standard-core.md; do not edit.")
w("*> The strict JSON text of the built-in registry entries that section 3 of the document writes out (timeline day and")
w("*> moon, enchantment efficiency, world clock), filled into a text area by BUILTIN-REGISTRY-TEXT.")
w("")
w(" IDENTIFICATION DIVISION.")
w(" PROGRAM-ID. BUILTIN-REGISTRY-TEXT.")
w("*> USING registry (PIC X(48)), entry id (BINARY-LONG), key out (PIC X(112)), text out (PIC X(4096)), text length out")
w("*> (BINARY-LONG): the key and JSON text of the built-in entry; length 0 when the registry has no built-in text here.")
w(" DATA DIVISION.")
w(" LINKAGE SECTION.")
w(" 01 L-REGISTRY             PIC X(48).")
w(" 01 L-ID                   BINARY-LONG.")
w(" 01 L-KEY                  PIC X(112).")
w(" 01 L-TEXT                 PIC X(4096).")
w(" 01 L-LENGTH               BINARY-LONG.")
w(" PROCEDURE DIVISION USING L-REGISTRY L-ID L-KEY L-TEXT L-LENGTH.")
w("     MOVE 0 TO L-LENGTH")
w("     MOVE SPACES TO L-TEXT")
for reg, eid, key, text in entries:
    assert len(text) <= 4096, (key, len(text))
    assert "'" not in text
    w(f'     IF L-REGISTRY = "{reg}" AND L-ID = {eid}')
    w(f'         MOVE "{key}" TO L-KEY')
    pos = 1
    for chunk in textwrap.wrap(text, 120, break_long_words=True, break_on_hyphens=False, drop_whitespace=False):
        assert "'" not in chunk
        w(f"         MOVE '{chunk}' TO L-TEXT({pos}:{len(chunk)})")
        pos += len(chunk)
    w(f"         MOVE {len(text)} TO L-LENGTH")
    w("     END-IF")
w("     GOBACK.")
w(" END PROGRAM BUILTIN-REGISTRY-TEXT.")
open(OUT, "w").write("\n".join(lines) + "\n")
print("wrote", OUT, [(e[2], len(e[3])) for e in entries])

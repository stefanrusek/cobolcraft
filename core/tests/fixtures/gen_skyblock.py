#!/usr/bin/env python3
"""Writes the small worlds of the skyblock tests (lane bugskyblock): a 26.3 level.dat as a real game wrote it for a modded
skyblock world (the key set of one: Data with Version, version_history, ServerBrands vanilla and fabric, WasModded, DataPacks;
synthetic values) and the world_gen_settings.dat that declares the overworld generator:
  skyblock-flat      minecraft:flat with no layers and the_void biome (a void world made with the Superflat Void preset)
  skyblock-modgen    a generator type this game does not know (skyblock:void_island, what a mod registers)
  skyblock-modnoise  minecraft:noise whose settings are another namespace's (skyblock:void_noise)
  skyblock-noisecomp minecraft:noise whose settings are an inline compound (noise settings written out in the file)
  skyblock-noise     the ordinary minecraft:noise overworld (control: a standard world)
  skyblock-debug     minecraft:debug
  skyblock-bare      no dimensions map at all; skyblock-notype  an overworld generator with no type member
The nether and the end stems are the ordinary ones in every file."""
import gzip, os, struct

def name(s):
    b = s.encode()
    return struct.pack(">H", len(b)) + b

def tag(t, n, payload): return bytes([t]) + name(n) + payload
def string(n, v): return tag(8, n, name(v))
def integer(n, v): return tag(3, n, struct.pack(">i", v))
def long_(n, v): return tag(4, n, struct.pack(">q", v))
def flt(n, v): return tag(5, n, struct.pack(">f", v))
def byte(n, v): return tag(1, n, bytes([v]))
def ints(n, vs): return tag(11, n, struct.pack(">i", len(vs)) + b"".join(struct.pack(">i", v) for v in vs))
def comp(n, *children): return tag(10, n, b"".join(children) + b"\x00")
def strlist(n, vs): return tag(9, n, bytes([8]) + struct.pack(">i", len(vs)) + b"".join(name(v) for v in vs))
def intlist(n, vs): return tag(9, n, bytes([3]) + struct.pack(">i", len(vs)) + b"".join(struct.pack(">i", v) for v in vs))
def emptylist(n, t): return tag(9, n, bytes([t]) + struct.pack(">i", 0))

def level():
    return comp("", comp("Data",
        integer("DataVersion", 5023), integer("GameType", 0),
        comp("spawn", string("dimension", "minecraft:overworld"), ints("pos", [8, 65, 8]), flt("yaw", 0.0), flt("pitch", 0.0)),
        long_("Time", 24612), long_("LastPlayed", 1795126175000), string("LevelName", "Skyblock Fixture"),
        comp("Version", string("Name", "26.3"), integer("Id", 5023), byte("Snapshot", 0), string("Series", "main")),
        intlist("version_history", [5015, 5023]),
        comp("difficulty_settings", string("difficulty", "normal"), byte("hardcore", 0), byte("locked", 0)),
        ints("singleplayer_uuid", [1, 2, 3, 4]),
        strlist("ServerBrands", ["vanilla", "fabric"]),
        integer("version", 19133), byte("initialized", 1), byte("WasModded", 1), byte("allowCommands", 1),
        comp("DataPacks", strlist("Enabled", ["vanilla", "fabric-convention-tags-v2"]),
             strlist("Disabled", ["minecraft_improvements", "redstone_experiments", "trade_rebalance"]))))

def stem(dim, generator):
    return comp(dim, comp("generator", *generator), string("type", dim))

def noise(settings, preset):
    return [string("settings", settings), comp("biome_source", string("preset", preset), string("type", "minecraft:multi_noise")),
            string("type", "minecraft:noise")]

def overworld(variant):
    dim = "minecraft:overworld"
    if variant == "flat":
        return stem(dim, [comp("settings", emptylist("layers", 10), string("biome", "minecraft:the_void"), byte("lakes", 0),
                               byte("features", 1)), string("type", "minecraft:flat")])
    if variant == "modgen":
        return stem(dim, [comp("settings", string("island", "skyblock:oak_island")), string("type", "skyblock:void_island")])
    if variant == "modnoise":
        return stem(dim, noise("skyblock:void_noise", "minecraft:overworld"))
    if variant == "noisecomp":
        return stem(dim, [comp("settings", string("sea_level_block", "minecraft:water"), byte("aquifers_enabled", 0)),
                          comp("biome_source", string("preset", "minecraft:overworld"), string("type", "minecraft:multi_noise")),
                          string("type", "minecraft:noise")])
    if variant == "notype":
        return stem(dim, [string("settings", "minecraft:overworld")])
    if variant == "debug":
        return stem(dim, [string("type", "minecraft:debug")])
    return stem(dim, noise("minecraft:overworld", "minecraft:overworld"))

def settings(variant):
    nether = stem("minecraft:the_nether", noise("minecraft:nether", "minecraft:nether"))
    end = stem("minecraft:the_end", [string("settings", "minecraft:end"), comp("biome_source", string("type", "minecraft:the_end")),
                                      string("type", "minecraft:noise")])
    if variant == "bare":
        return comp("", comp("data", long_("seed", -1637685763277496456), byte("bonus_chest", 0)), integer("DataVersion", 5023))
    return comp("", comp("data", long_("seed", -1637685763277496456), byte("generate_structures", 1), byte("bonus_chest", 0),
                         comp("dimensions", overworld(variant), nether, end)), integer("DataVersion", 5023))

here = os.path.dirname(os.path.abspath(__file__))
for variant in ("flat", "modgen", "modnoise", "noisecomp", "noise", "debug", "bare", "notype"):
    out = os.path.join(here, "skyblock-" + variant)
    os.makedirs(os.path.join(out, "data", "minecraft"), exist_ok=True)
    for path, data in (("level.dat", level()), ("data/minecraft/world_gen_settings.dat", settings(variant))):
        with gzip.GzipFile(os.path.join(out, path), "wb", mtime=0) as f:
            f.write(data)

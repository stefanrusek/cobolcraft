#!/usr/bin/env python3
"""Writes a small world folder in the 26.3 layout (docs/protocol/07 section 10): level.dat with the compound `Data`
(known keys and keys the core does not model), data/minecraft/{weather,world_clocks,game_rules,world_gen_settings}.dat.
Synthetic values; the game rule minecraft:future_rule and the clock minecraft:the_end are unknown to the core."""
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
def strings(n, vs): return tag(9, n, bytes([8]) + struct.pack(">i", len(vs)) + b"".join(name(v) for v in vs))
def intlist(n, vs): return tag(9, n, bytes([3]) + struct.pack(">i", len(vs)) + b"".join(struct.pack(">i", v) for v in vs))
def comp(n, *c): return tag(10, n, b"".join(c) + b"\x00")

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "vanfmt")
os.makedirs(os.path.join(out, "data/minecraft"), exist_ok=True)
files = {
 "level.dat": comp("", comp("Data",
    strings("ServerBrands", ["vanilla"]), byte("WasModded", 0),
    comp("Version", integer("Id", 5023), string("Name", "26.3"), string("Series", "main"), byte("Snapshot", 0)),
    intlist("version_history", [4900, 5023]), integer("DataVersion", 5023), integer("GameType", 1),
    comp("spawn", string("dimension", "minecraft:overworld"), flt("pitch", 0.0), ints("pos", [12, 70, -34]), flt("yaw", 90.0)),
    long_("Time", 76520), long_("LastPlayed", 1700000000000), string("LevelName", "Vanfmt Fixture"),
    integer("version", 19133), byte("allowCommands", 1), byte("initialized", 1),
    comp("difficulty_settings", string("difficulty", "hard"), byte("hardcore", 0), byte("locked", 1)),
    ints("singleplayer_uuid", [1, 2, 3, 4]),
    comp("DataPacks", strings("Enabled", ["vanilla"]), strings("Disabled", [])),
    strings("enabled_features", ["minecraft:vanilla"]),
    comp("UnknownBlock", integer("keep", 77)))),
 "data/minecraft/weather.dat": comp("", integer("DataVersion", 5023), comp("data",
    integer("clear_weather_time", 11), integer("rain_time", 22), integer("thunder_time", 33), byte("raining", 1), byte("thundering", 1), integer("extra", 9))),
 "data/minecraft/world_clocks.dat": comp("", integer("DataVersion", 5023), comp("data",
    comp("minecraft:overworld", long_("total_ticks", 50000), flt("partial_tick", 0.0), flt("rate", 1.0), byte("paused", 0)),
    comp("minecraft:the_end", long_("total_ticks", 999)))),
 "data/minecraft/game_rules.dat": comp("", integer("DataVersion", 5023), comp("data",
    byte("minecraft:advance_time", 0), byte("minecraft:fall_damage", 1), integer("minecraft:random_tick_speed", 7), byte("minecraft:future_rule", 1))),
 "data/minecraft/world_gen_settings.dat": comp("", integer("DataVersion", 5023), comp("data", byte("bonus_chest", 0), long_("seed", 123456789))),
}
for path, data in files.items():
    with gzip.GzipFile(os.path.join(out, path), "wb", mtime=0) as f:
        f.write(data)

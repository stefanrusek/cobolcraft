#!/usr/bin/env python3
"""Generator of the client option fixtures of contract/fixtures/client (T0058). Test infrastructure, stdlib only.

usage: make_client_fixtures.py [--out DIR] [--check]

Writes, default DIR contract/fixtures/client:
  options-default.txt       version line and every saved option at its default, in the stored forms of
                            docs/protocol/13 sections 7.2 and 7.4 (fov as (fov - 70) / 40, enums quoted, the
                            integer-coded enums as integers, key bindings as key_<mapping>:<key name>)
  options-full.txt          the same keys, every value changed (inside its range), the resource-pack lists filled
                            and a last fullscreenResolution line (13 section 7.1)
  options-corrupt.txt       no version line, a line without ':', unparsable integer, float, enum and JSON values,
                            an unknown key, and good lines around them (13 section 7.1: bad lines are skipped,
                            unparsable values keep the default)
  options-out-of-range.txt  values outside the range of 13 section 7.2 and 7.4 (rejected: the default is kept)
  expected.txt              `<file> <key> <kept default>` for the corrupt and out-of-range files
  options.dat               the LEGACY file. 13 section 7 and builtin-ui-art.md Open question 36 give no format
                            (the artifact has no reader); the format below is the one the 001 client wrote
                            (client/src/game-dir.cob OPTIONS-SAVE, specs/002-client-polish/data-model.md section 6):
                            a gzip-compressed NBT file whose unnamed root Compound holds one List "EnabledPacks" of
                            String (pack ids, top first). options-extra-tags.dat adds tags the reader skips and
                            options-empty.dat has an empty list. This is the documented best effort for the legacy
                            format; nothing else about options.dat is known.
With --check it compares a fresh generation with DIR (`<path>: differs|missing`, then
`make_client_fixtures: <n> differences`; exit 1 if any).
"""
import gzip
import os
import struct
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DEFAULT = os.path.join(REPO, "contract", "fixtures", "client")

# (key, default, full) in the order of 13 section 7.2. Values are the stored file forms (7.4).
OPTIONS = [
    ("resourcePacks", "[]", '["vanilla","file/Faithful 32x - 26.3.zip"]'),
    ("incompatibleResourcePacks", "[]", '["file/Old Pack.zip"]'),
    ("graphicsPreset", '"fancy"', '"fabulous"'),
    ("preferredGraphicsBackend", '"default"', '"vulkan"'),
    ("renderDistance", "12", "16"),
    ("simulationDistance", "12", "8"),
    ("entityDistanceScaling", "1.0", "2.5"),
    ("maxFps", "120", "60"),
    ("enableVsync", "true", "false"),
    ("inactivityFpsLimit", '"afk"', '"minimized"'),
    ("fullscreen", "false", "true"),
    ("exclusiveFullscreen", "false", "true"),
    ("guiScale", "0", "2"),
    ("gamma", "0.5", "0.8"),
    ("fov", "0.0", "1.0"),
    ("ao", "true", "false"),
    ("biomeBlendRadius", "2", "4"),
    ("renderClouds", '"true"', '"fast"'),
    ("cloudRange", "128", "64"),
    ("weatherRadius", "10", "6"),
    ("cutoutLeaves", "true", "false"),
    ("vignette", "true", "false"),
    ("improvedTransparency", "false", "true"),
    ("particles", "0", "2"),
    ("entityShadows", "true", "false"),
    ("chunkSectionFadeInTime", "0.75", "1.5"),
    ("prioritizeChunkUpdates", "0", "2"),
    ("mipmapLevels", "4", "2"),
    ("textureFiltering", "0", "2"),
    ("maxAnisotropyBit", "2", "3"),
    ("bobView", "true", "false"),
    ("attackIndicator", "1", "2"),
    ("glintSpeed", "0.5", "0.25"),
    ("glintStrength", "0.75", "0.5"),
    ("showAutosaveIndicator", "true", "false"),
    ("overrideWidth", "0", "1280"),
    ("overrideHeight", "0", "720"),
    ("mouseSensitivity", "0.5", "0.75"),
    ("invertXMouse", "false", "true"),
    ("invertYMouse", "false", "true"),
    ("discrete_mouse_scroll", "false", "true"),
    ("mouseWheelSensitivity", "1.0", "2.5"),
    ("allowCursorChanges", "true", "false"),
    ("quitShortcuts", "true", "false"),
    ("ctrlClickEmulatesRightClick", "false", "true"),
    ("autoJump", "false", "true"),
    ("rotateWithMinecart", "false", "true"),
    ("operatorItemsTab", "false", "true"),
    ("toggleCrouch", "false", "true"),
    ("toggleSprint", "false", "true"),
    ("toggleAttack", "false", "true"),
    ("toggleUse", "false", "true"),
    ("sprintWindow", "7", "3"),
    ("mainHand", '"right"', '"left"'),
]

# 13 section 7.3 default mappings; the full file rebinds each to another key of 7.5 (names: key.keyboard.<name>).
KEYS = [
    ("key.forward", "w", "up"), ("key.left", "a", "left"), ("key.back", "s", "down"), ("key.right", "d", "right"),
    ("key.jump", "space", "enter"), ("key.sneak", "left.shift", "z"), ("key.sprint", "left.control", "r"),
    ("key.inventory", "e", "i"), ("key.swapOffhand", "f", "g"), ("key.drop", "q", "y"),
] + [("key.hotbar.%d" % n, str(n), "keypad.%d" % n) for n in range(1, 10)] + [
    ("key.saveToolbarActivator", "c", "k"), ("key.loadToolbarActivator", "x", "j"),
    ("key.use", "@mouse.right", "@mouse.4"), ("key.attack", "@mouse.left", "@mouse.5"),
    ("key.pickItem", "@mouse.middle", "@mouse.6"),
    ("key.chat", "t", "b"), ("key.playerlist", "tab", "caps.lock"), ("key.command", "slash", "backslash"),
    ("key.socialInteractions", "p", "o"), ("key.screenshot", "f2", "f12"), ("key.togglePerspective", "f5", "f6"),
    ("key.smoothCamera", "unknown", "m"), ("key.fullscreen", "f11", "f10"), ("key.advancements", "l", "n"),
    ("key.quickActions", "g", "h"), ("key.toggleGui", "f1", "f9"), ("key.toggleSpectatorShaderEffects", "f4", "f8"),
    ("key.spectatorOutlines", "unknown", "u"),
]

SOUND = "master music record weather block hostile neutral player ambient voice ui".split()
PARTS = "cape jacket left_sleeve right_sleeve left_pants_leg right_pants_leg hat".split()

OTHER = [
    ("soundDevice", "", "Built-in Output"),
    ("showSubtitles", "false", "true"),
    ("directionalAudio", "false", "true"),
    ("musicToast", '"never"', '"pause_and_toast"'),
    ("musicFrequency", '"DEFAULT"', '"CONSTANT"'),
    ("chatVisibility", "0", "1"),
    ("chatColors", "true", "false"),
    ("chatLinks", "true", "false"),
    ("chatLinksPrompt", "true", "false"),
    ("chatOpacity", "1.0", "0.6"),
    ("chatLineSpacing", "0.0", "0.5"),
    ("textBackgroundOpacity", "0.5", "0.25"),
    ("backgroundForChatOnly", "true", "false"),
    ("chatScale", "1.0", "0.5"),
    ("chatWidth", "1.0", "0.5"),
    ("chatHeightFocused", "1.0", "0.5"),
    ("chatHeightUnfocused", "0.4375", "0.2"),
    ("chatDelay", "0.0", "1.5"),
    ("autoSuggestions", "true", "false"),
    ("hideMatchedNames", "true", "false"),
    ("onlyShowSecureChat", "false", "true"),
    ("saveChatDrafts", "false", "true"),
    ("notificationDisplayTime", "1.0", "4.0"),
    ("hideServerAddress", "false", "true"),
    ("advancedItemTooltips", "false", "true"),
    ("narrator", "0", "2"),
    ("narratorHotkey", "true", "false"),
    ("highContrast", "false", "true"),
    ("highContrastBlockOutline", "false", "true"),
    ("screenEffectScale", "1.0", "0.5"),
    ("fovEffectScale", "1.0", "0.25"),
    ("darknessEffectScale", "1.0", "0.25"),
    ("damageTiltStrength", "1.0", "0.5"),
    ("darkMojangStudiosBackground", "false", "true"),
    ("hideLightningFlashes", "false", "true"),
    ("hideSplashTexts", "false", "true"),
    ("menuBackgroundBlurriness", "5", "8"),
    ("panoramaScrollSpeed", "1.0", "0.5"),
    ("reducedDebugInfo", "false", "true"),
    ("lang", "en_us", "de_de"),
    ("lastServer", "", "play.example.org:25565"),
    ("pauseOnLostFocus", "true", "false"),
    ("useNativeTransport", "true", "false"),
    ("joinedFirstServer", "false", "true"),
    ("skipMultiplayerWarning", "false", "true"),
    ("onboardAccessibility", "true", "false"),
    ("startedCleanly", "true", "false"),
    ("syncChunkWrites", "false", "true"),
    ("realmsNotifications", "true", "false"),
    ("allowServerListing", "true", "false"),
    ("inGameNotification", "false", "true"),
    ("telemetryOptInExtra", "false", "true"),
    ("forceUnicodeFont", "false", "true"),
]


def key_name(text):
    return "key.mouse." + text[7:] if text.startswith("@mouse.") else "key.keyboard." + text


def rows(column):
    """[(key, value)] of the whole file body for column 1 (default) or 2 (full)."""
    out = [(k, v[column - 1]) for k, *v in [(o[0], o[1], o[2]) for o in OPTIONS]]
    out += [("key_" + m, key_name(d if column == 1 else f)) for m, d, f in KEYS]
    out += [("soundCategory_" + c, "1.0" if column == 1 else "%.2f" % (0.3 + 0.05 * i)) for i, c in enumerate(SOUND)]
    out += [("modelPart_" + p, "true" if column == 1 else "false") for p in PARTS]
    out += [(k, v[column - 1]) for k, *v in [(o[0], o[1], o[2]) for o in OTHER]]
    return out


def text(lines):
    return ("\n".join(lines) + "\n").encode("utf-8")


# Values outside the range of 13 section 7.2 and 7.4 (stored file values); the loader keeps the default.
OUT_OF_RANGE = [
    ("renderDistance", "99"), ("simulationDistance", "40"), ("entityDistanceScaling", "9.0"), ("maxFps", "5"),
    ("fov", "2.0"), ("biomeBlendRadius", "9"), ("cloudRange", "500"), ("weatherRadius", "1"),
    ("chunkSectionFadeInTime", "3.0"), ("mipmapLevels", "7"), ("maxAnisotropyBit", "0"), ("glintSpeed", "1.5"),
    ("mouseSensitivity", "1.5"), ("mouseWheelSensitivity", "100.0"), ("sprintWindow", "20"), ("gamma", "-0.5"),
    ("chatOpacity", "2.0"), ("chatDelay", "9.0"), ("notificationDisplayTime", "0.1"), ("menuBackgroundBlurriness", "11"),
    ("soundCategory_master", "2.0"), ("guiScale", "-1"),
]
DEFAULTS = dict(rows(1))
DEFAULTS["fov"] = "70"  # the in-memory default (stored 0.0)


def corrupt_lines():
    return [
        "renderDistance:far",                      # unparsable integer: default kept
        "this line has no colon",                  # skipped with a warning
        "gamma:bright",                            # unparsable float: default kept
        "graphicsPreset:\"turbo\"",                # unknown enum name: default kept
        "resourcePacks:[\"vanilla\"",              # unterminated JSON array: default kept
        "unknownOption:42",                        # tolerated, ignored
        "",                                        # an empty line has no colon either
        "mouseSensitivity:0.25",                   # good line after the bad ones
        "key_key.forward:key.keyboard.w",
        "key_key.jump:key.keyboard.nosuchkey",     # unknown key name
        "soundCategory_music:0.5",
        "modelPart_hat:maybe",                     # not a boolean
        "chatVisibility:\"full\"",                 # integer-coded enum given as a name: default kept
        "fov:abc",
    ]


def expected():
    lines = ["# file key value-kept (the in-memory default; fov in degrees)"]
    for key in ("renderDistance", "gamma", "graphicsPreset", "resourcePacks", "modelPart_hat", "chatVisibility", "fov"):
        value = DEFAULTS[key]
        lines.append("options-corrupt.txt %s %s" % (key, value))
    lines.append("options-corrupt.txt mouseSensitivity 0.25 (loaded)")
    for key, _ in OUT_OF_RANGE:
        lines.append("options-out-of-range.txt %s %s" % (key, DEFAULTS[key]))
    return lines


def nbt_string(s):
    raw = s.encode("utf-8")
    return struct.pack(">H", len(raw)) + raw


def legacy(packs, extra=False):
    body = bytearray(b"\x0a" + nbt_string(""))
    if extra:
        body += b"\x03" + nbt_string("Unrelated") + struct.pack(">i", 7)
    body += b"\x09" + nbt_string("EnabledPacks") + struct.pack(">bi", 8, len(packs))
    for p in packs:
        body += nbt_string(p)
    body += b"\x00"
    return gzip.compress(bytes(body), 9, mtime=0)


def generate():
    files = {
        "options-default.txt": text(["version:5023"] + ["%s:%s" % kv for kv in rows(1)]),
        "options-full.txt": text(["version:5023"] + ["%s:%s" % kv for kv in rows(2)] + ["fullscreenResolution:1920x1080@60 (24bit)"]),
        "options-corrupt.txt": text(corrupt_lines()),
        "options-out-of-range.txt": text(["version:5023"] + ["%s:%s" % kv for kv in OUT_OF_RANGE]),
        "expected.txt": text(expected()),
        "options.dat": legacy(["vanilla", "file/Faithful 32x - 26.3.zip"]),
        "options-extra-tags.dat": legacy(["vanilla"], extra=True),
        "options-empty.dat": legacy([]),
    }
    return files


def write(out):
    os.makedirs(out, exist_ok=True)
    for name, data in generate().items():
        with open(os.path.join(out, name), "wb") as handle:
            handle.write(data)


def check(out):
    problems = []
    for name, data in sorted(generate().items()):
        path = os.path.join(out, name)
        if not os.path.exists(path):
            problems.append("%s: missing" % name)
        else:
            with open(path, "rb") as handle:
                if handle.read() != data:
                    problems.append("%s: differs" % name)
    return problems


def main(argv):
    out, do_check, args = OUT_DEFAULT, False, list(argv)
    while args:
        arg = args.pop(0)
        if arg == "--out" and args:
            out = args.pop(0)
        elif arg == "--check":
            do_check = True
        else:
            print("usage: make_client_fixtures.py [--out DIR] [--check]")
            return 2
    if do_check:
        problems = check(out)
        for problem in problems:
            print(problem)
        print("make_client_fixtures: %d differences" % len(problems))
        return 1 if problems else 0
    write(out)
    print("make_client_fixtures: wrote %d files under %s" % (len(generate()), out))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

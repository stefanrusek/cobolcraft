# Default player skin and skin handling

| Item | Value |
|---|---|
| Covers | The `PlayerSkin` value; the 18 built-in default skins and how one is chosen from a UUID (wide and slim); the skin texture layout and the legacy 64 x 32 conversion (refines 12 section 7.4); the skin-parts flags (`PlayerModelPart`) on the wire, in options and in rendering; the cape, elytra and ears layers (conditions, geometry, animation); how skins are obtained (game profile `textures` property, URLs, signatures, the secure rule, cache); what an offline or missing skin looks like; what our client must do with no network |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files inside the jar (`unzip -p`, `unzip -Z1`, PNG headers), with no execution. Facts about the JDK (`UUID.hashCode`, `Math.floorMod`, `Long.hashCode`, `UUID.nameUUIDFromBytes`) were read from the local JDK class files with `javap`. The authlib library (game profile and session service) is not in the jar (0 entries under `com/mojang/authlib`), so the property format and signature verification are not read (Open questions 1 and 2). |
| Status | Written by the reader for round RS31 (GAP-20 of `docs/design/README.md`) |

Class names in backticks say where a fact was read; they are not the design. Cross-references: "00" data types
(GameProfile, PropertyMap, ResolvableProfile, PlayerSkinPatch), "02" login (offline UUID), "03" Client Information,
"05a" Player Info Update, "12 section 7" player model, "13 section 7" options, "21" entity data indices, "22" the
asset and data extraction tool (22 §6, What is extracted). The texture files themselves (18 default skins, the elytra texture) are
DATA and come from the vanilla resource pack that the tool extracts; this document specifies the engine that selects and
interprets them.

## Contents

1. [The PlayerSkin value](#1-the-playerskin-value)
2. [Default skins](#2-default-skins)
3. [Where a skin comes from](#3-where-a-skin-comes-from)
4. [Texture format and legacy conversion](#4-texture-format-and-legacy-conversion)
5. [Skin parts](#5-skin-parts)
6. [Player render layers, cape, elytra, ears](#6-player-render-layers-cape-elytra-ears)
7. [Heads and faces outside the world](#7-heads-and-faces-outside-the-world)
8. [Offline, missing and no-network behaviour](#8-offline-missing-and-no-network-behaviour)
9. [Worked examples](#9-worked-examples)
10. [Validation](#10-validation)
11. [Open questions](#11-open-questions)

## 1. The PlayerSkin value

`PlayerSkin` (a record) has five fields:

| Field | Meaning |
|---|---|
| body | Texture of the 64 x 64 skin (`ClientAsset$Texture`). Never absent. |
| cape | Texture of the cape, or absent. |
| elytra | Texture used on elytra wings, or absent. |
| model | `PlayerModelType`: `SLIM` (serialized name `slim`, legacy services name `slim`) or `WIDE` (`wide`, legacy name `default`). |
| secure | True if the textures came from a profile whose signature state is SIGNED. Built-in defaults have secure = true; a skin built by `PlayerSkin.insecure` or by applying a patch has secure = false. |

A `Texture` is either a **resource texture** (an asset id; its file is `textures/<id path>.png` in the resource packs,
so a resource pack can replace it) or a **downloaded texture** (a texture path plus the source URL). On the wire
(00 section 13.3, PlayerSkinPatch) the three texture fields of a patch are resource textures, so a patch can never
name a URL. `PlayerModelType`'s stream codec is a Boolean: true = SLIM, false = WIDE (read from the codec lambdas;
this settles the "inferred" note in 00 section 13.3 for the model flag). The patch field order is body, cape, elytra,
model (three texture codecs then the model codec). The field names were read from `PlayerSkin$Patch.MAP_CODEC`, so the
slot mapping is read, not inferred; the **data-component form** (JSON or NBT, used by items and mannequins) is a
compound with four optional keys, in record order:

| Key | Value | Fills |
|---|---|---|
| `texture` | resource texture: an identifier (`ResourceTexture.CODEC` is the identifier codec) | body |
| `cape` | resource texture identifier | cape |
| `elytra` | resource texture identifier | elytra |
| `model` | `PlayerModelType.CODEC` (names `slim` and `wide`, section 1 table) | model |

The stream form is body, cape, elytra, model with no key names. 00 section 13.3 still marks the cape and elytra slot
meaning inferred; that is now stale (Open question 10).

`PlayerSkin.with(patch)`: an empty patch returns the skin unchanged; otherwise each present patch field replaces the
corresponding field, absent fields keep the old value, and the result is insecure.

## 2. Default skins

### 2.1 The table

`DefaultPlayerSkin` holds an array of **18** entries, built in this order. Every entry is a resource texture with the id
shown (namespace `minecraft`, file `textures/<id>.png`, all 64 x 64, checked from the PNG headers) and is secure.

| Index | Id | Model | Index | Id | Model |
|---|---|---|---|---|---|
| 0 | `entity/player/slim/alex` | SLIM | 9 | `entity/player/wide/alex` | WIDE |
| 1 | `entity/player/slim/ari` | SLIM | 10 | `entity/player/wide/ari` | WIDE |
| 2 | `entity/player/slim/efe` | SLIM | 11 | `entity/player/wide/efe` | WIDE |
| 3 | `entity/player/slim/kai` | SLIM | 12 | `entity/player/wide/kai` | WIDE |
| 4 | `entity/player/slim/makena` | SLIM | 13 | `entity/player/wide/makena` | WIDE |
| 5 | `entity/player/slim/noor` | SLIM | 14 | `entity/player/wide/noor` | WIDE |
| 6 | `entity/player/slim/steve` | SLIM | 15 | `entity/player/wide/steve` | WIDE |
| 7 | `entity/player/slim/sunny` | SLIM | 16 | `entity/player/wide/sunny` | WIDE |
| 8 | `entity/player/slim/zuri` | SLIM | 17 | `entity/player/wide/zuri` | WIDE |

The jar contains exactly 18 files under `assets/minecraft/textures/entity/player/` (counted with
`unzip -Z1 | grep -v '/$'`), the nine names under `slim/` and the same nine under `wide/`. The skin pixels are data.

### 2.2 Selection by UUID

`DefaultPlayerSkin.get(uuid)`:

1. `h = uuid.hashCode()` (Java `UUID.hashCode`: `x = mostSigBits XOR leastSigBits` as 64-bit values;
   `h = (int)(x XOR (x >>> 32))`, the low 32 bits of that, as a signed 32-bit integer).
2. `index = floorMod(h, 18)`, always in 0..17: `r = h rem 18` (truncated); if `r != 0` and `h` is negative, `r = r + 18`.
3. The result is entry `index` of the table; its body texture and model are used.

The profile form `get(GameProfile)` uses `profile.id()`. So the wide/slim variant and the character both follow from the
UUID alone: indices 0 to 8 give a slim arm, 9 to 17 a wide arm.

`getDefaultSkin()` (no UUID) always returns entry **6** (`slim/steve`). `getDefaultTexture()` is that entry's texture id.
It is used by three places, and by nothing in the player lookup chain:

- the static default render type of heads with no profile (`PlayerSkinRenderCache.DEFAULT_PLAYER_SKIN_RENDER_TYPE`);
- the initial value of the skin field of `AvatarRenderState` (set in its constructor), so a render state that has not yet
  been filled by an extraction shows `slim/steve`;
- `SkullBlockRenderer`, which registers `getDefaultTexture()` as the default texture of the PLAYER skull type, so a
  player-head block with no profile draws entry 6's body texture.

A debug constant `SharedConstants.DEBUG_DEFAULT_SKIN_OVERRIDE` (a debug flag, off in normal use; value not evaluated
here) is tested in `SkinManager.get` and `SkinManager.createLookup`, not inside `DefaultPlayerSkin.get`. When set it makes
those two forward the UUID-derived default skin (`DefaultPlayerSkin.get(uuid)`), not entry 6. Our client has no such switch.

### 2.3 The UUIDs that occur

| Source of the UUID | UUID | Notes |
|---|---|---|
| Online-mode profile | the Mojang account UUID | Not predictable; hash decides. |
| Offline-mode server | `UUID.nameUUIDFromBytes("OfflinePlayer:" + name, UTF-8)` (`UUIDUtil.createOfflinePlayerUUID`; 02 "Offline mode") | MD5 of the bytes, then version nibble set to 3 and variant bits set to 10 (JDK behaviour). The profile built from it carries no properties. |
| Unresolved head profile with no id | `Util.NIL_UUID` (all zero) | `hashCode` 0, so entry 0 (`slim/alex`). |
| Entity without player info | the entity's own UUID | `AbstractClientPlayer.getSkin`. |

## 3. Where a skin comes from

### 3.1 The chain for a player entity

1. The server sends Player Info Update with action ADD_PLAYER (05a): UUID, name, GameProfileProperties (max 16
   properties; each: name String(64), value String(32767), optional signature String(1024); 00 section 11).
2. `ClientPacketListener.handlePlayerInfoUpdate` creates one `PlayerInfo(profile, enforcesSecureChat)` per new
   entry with `putIfAbsent` by UUID: a second ADD_PLAYER for a known UUID does not replace the profile, so a skin is
   fixed from the first ADD_PLAYER until the entry is removed.
3. `AbstractClientPlayer.getSkin()` looks the `PlayerInfo` up by the entity's UUID. If there is none, the result is
   `DefaultPlayerSkin.get(entity UUID)`. Otherwise `PlayerInfo.getSkin()` creates (once) a **skin lookup**
   (`SkinManager.createLookup(profile, requireSecure)`) and returns its current value.
4. `requireSecure = !Minecraft.isLocalPlayer(uuid)`, where the local player is the one whose UUID equals the launcher
   user's profile id (`User.getProfileId`). **The local player may use insecure skins; every other player must have a
   secure skin.**
5. Render dispatch: `EntityRenderDispatcher` holds two avatar renderers keyed by `PlayerModelType` and picks one with
   `skin.model()` (falling back to WIDE if the key is missing). SLIM selects the baked slim model (3-pixel arms,
   12 section 7.4); WIDE the 4-pixel arm model. The renderer's texture is `skin.body().texturePath()`.

### 3.2 The skin lookup (`SkinManager.createLookup`)

The lookup returns a supplier. Let `D = DefaultPlayerSkin.get(profile)`.

1. Ask `SkinManager.get(profile)` for a future of `Optional<PlayerSkin>` (cached, 3.3).
2. Value now: if the future is complete, take its optional, keep the skin only if `!requireSecure || skin.secure()`,
   else use `D`. The supplier then always returns that constant.
3. If the future is not yet complete: the supplier is polled on every call, returning the same filtered result when the
   future has completed by then and `D` until then.

So the default skin is what is drawn until the real skin has downloaded, and for the whole session if the download or
validation fails or the skin is insecure and the player is not the local player.

### 3.3 `SkinManager.get(profile)`

1. Ask the session service for the **packed textures property** of the profile (`getPackedTextures`: the property
   named `textures`; authlib, not read; Open question 1).
2. Cache key = (profile UUID, that property or none). Cache entries expire 15 seconds after last access (Guava
   `expireAfterAccess`); a new load starts when an entry has expired.
3. Load, on a background executor: if the property is absent the textures are `MinecraftProfileTextures.EMPTY`;
   otherwise `unpackTextures(property)` yields skin, cape, elytra (each a texture with URL, hash and metadata) and a
   **signature state** (SIGNED, UNSIGNED or INVALID). INVALID logs a warning "Profile contained invalid signature for
   textures property (profile id: {})" (the profile UUID fills the placeholder) and the textures are still used (but see secure below).
4. Back on the main thread, `registerTextures(uuid, textures)`:
   - skin: if present, load it (3.4) and take the model from the texture metadata key `model`
     (`PlayerModelType.byLegacyServicesName`: `slim` gives SLIM, anything else including a missing key gives WIDE);
     if absent, body and model come from `DefaultPlayerSkin.get(uuid)` (note: from the **UUID**, so the same default as
     for a missing profile);
   - cape and elytra: load if present, else absent;
   - when all three futures complete, build `PlayerSkin(body, cape, elytra, model, secure)` with
     `secure = (signature state == SIGNED)`.
5. Any failure (exception in any future) logs "Failed to load texture for profile {uuid}" and the result is an empty
   optional, which the lookup turns into the default skin `D`.

Consequences for a server: a profile without a `textures` property gives EMPTY textures, a default body and an
insecure result (inferred: the signature state of EMPTY was not read, Open question 2); remote players then show `D`, which equals the same default entry. A properly signed property from the
Mojang session service is the only way to have another player's custom skin shown. For the local player an unsigned
property is accepted.

### 3.4 Loading one texture (`SkinManager$TextureCache`, `SkinTextureDownloader`)

Three caches (skin, cape, elytra) are keyed by the texture's hash string. Each is a plain hash map from hash string
to a future of the registered texture, with no size limit and no expiry or removal in the class (only `get` and `put`
were found on it), unlike the 15-second `CacheKey` cache of 3.3 step 2. A texture stays registered for the session.

- Local name: `sha1 = SHA-1 of the hash string hashed as UTF-16 chars (Guava hashUnencodedChars), lowercase hex`.
  Texture id = `minecraft:skins/<sha1>`, `minecraft:capes/<sha1>` or `minecraft:elytra/<sha1>` by type.
- Disk cache file: `<game assets directory>/skins/<first 2 hex chars of sha1>/<sha1>` (a name of 2 characters or
  fewer would use the folder `xx`; sha1 hex is 40 characters so not reached).
- Download (`downloadSkin`): if the cache file is a regular file, read the image from it. Otherwise open the URL
  (through the configured proxy), require an HTTP status of the form 2xx (status / 100 == 2, else an `IOException` whose message is built from the URL and
  the integer status code), read all bytes, try to write them to the cache file (a write failure only logs "Failed to cache
  texture"), and decode the bytes as a PNG image.
- For the **skin type only**, the legacy conversion of section 4 is applied; capes and elytra images are used as
  downloaded.
- The image is uploaded as a dynamic texture on the main thread under the texture id.

There is no size limit, retry or timeout in this code (Open question 3).

## 4. Texture format and legacy conversion

`SkinTextureDownloader.processLegacySkin(image)` (skin type only):

1. Accept only width 64 with height 32 or 64. Any other size closes the image and fails with an
   `IllegalStateException` (message with the width, height and URL), which ends in the default skin (3.3 step 5).
   High-resolution skins are therefore not supported.
2. `legacy = (height == 32)`. Only the hat hack (step 4b) and the 64 x 64 expansion with its copies (step 3) depend on
   `legacy`. The alpha fix-ups 4a, 4c and 4d run for **every accepted skin, including 64 x 64 downloads** (checked: the
   three `setNoAlpha` calls are outside the height test; only the `doNotchTransparencyHack` call is inside it).
3. If legacy, make a new 64 x 64 image, copy the old image into its top-left corner (rows 0..31), then set the pixel
   rectangle x 0..63, y 32..63 to 0 (fully transparent black). Then copy twelve rectangles inside the new image,
   each **mirrored horizontally** (the columns of each source rectangle are reversed): source (x, y), destination
   (x + dx, y + dy), size (w, h):

| # | Source x, y | Offset dx, dy | w x h | Destination x, y | What it fills |
|---|---|---|---|---|---|
| 1 | 4, 16 | 16, 32 | 4 x 4 | 20, 48 | left leg top, from the right leg top |
| 2 | 8, 16 | 16, 32 | 4 x 4 | 24, 48 | left leg bottom, from the right leg bottom |
| 3 | 0, 20 | 24, 32 | 4 x 12 | 24, 52 | left leg left side (+x side), from the right leg right side (-x side) |
| 4 | 4, 20 | 16, 32 | 4 x 12 | 20, 52 | left leg front, from the right leg front |
| 5 | 8, 20 | 8, 32 | 4 x 12 | 16, 52 | left leg right side (-x side), from the right leg left side (+x side) |
| 6 | 12, 20 | 16, 32 | 4 x 12 | 28, 52 | left leg back, from the right leg back |
| 7 | 44, 16 | -8, 32 | 4 x 4 | 36, 48 | left arm top, from the right arm top |
| 8 | 48, 16 | -8, 32 | 4 x 4 | 40, 48 | left arm bottom, from the right arm bottom |
| 9 | 40, 20 | 0, 32 | 4 x 12 | 40, 52 | left arm left side (+x side), from the right arm right side (-x side) |
| 10 | 44, 20 | -8, 32 | 4 x 12 | 36, 52 | left arm front, from the right arm front |
| 11 | 48, 20 | -16, 32 | 4 x 12 | 32, 52 | left arm right side (-x side), from the right arm left side (+x side) |
| 12 | 52, 20 | -8, 32 | 4 x 12 | 44, 52 | left arm back, from the right arm back |

   Rows 1 to 6 copy the right leg block (0,16)-(15,31) into the left leg block (16,48); rows 7 to 12 copy the right arm
   block (40,16)-(55,31) into the left arm block (32,48). The destination column of a face is its source column plus dx;
   the mirroring means the face's pixels are reversed left to right, and the side faces swap places (row 3 and row 5
   exchange the two side faces, rows 9 and 11 likewise). The last column uses the face labels of 12 section 7.4
   (right side = the part's -x side, left side = its +x side); the labels are inferred from the geometry, while the
   numeric columns were re-checked against the jar.
4. Opacity fix-ups, in this order (the rectangles are x from x0 inclusive to x1 exclusive, y likewise):
   a. force alpha to 255 on x 0..31, y 0..15 (head base layer);
   b. if legacy: the **hat transparency hack** on x 32..63, y 0..31: if any pixel in that rectangle has alpha below 128
      the rectangle is left as is; if all pixels have alpha 128 or more, every pixel of it is read back and ANDed with 0x00FFFFFF (16777215) before being
      written, which clears alpha to 0 and keeps the 24 colour bits (the review finding that the constant itself is
      written, making the colour white, does not match the bytecode: the pixel read-back precedes the mask) (a skin that
      painted a solid background in the hat area gets no hat);
   c. force alpha 255 on x 0..63, y 16..31 (body, right leg, right arm base);
   d. force alpha 255 on x 16..47, y 48..63 (left leg and left arm base).
   Overlay regions (hat at 32..63 x 0..15, jacket, sleeves and pants rows 32..47 and the left overlays at 0..15 x 48..63
   and 48..63 x 48..63) keep their own alpha.
5. Colour is untouched except alpha (the hat hack keeps the colour bits and clears alpha; the 64 x 32 to 64 x 64
   expansion fills the new rows with 0, transparent black, before the copies).

The converted image is the final texture; models read it as 64 x 64 (UV = pixel / 64). The default skins are already
64 x 64 and are used as stored, with no fix-ups (they are resource textures, not downloaded images).

Model texture offsets for a 64 x 64 skin (cuboids, slim differences, overlays) are in 12 section 7.4. Additional facts
read here: the slim arm cuboids are 3 wide at the same texture offsets as the wide ones (right arm origin x -2, left
arm origin x -1; right sleeve at (40,32), left sleeve at (48,48)); the wide right arm origin is x -3 and the wide left
arm origin x -1. Face layout for a cuboid with size (w, h, d) at (u, v) follows 12 section 7.4 (for a slim arm,
w = 3, d = 4: top (u+4..u+7, v..v+3), front (u+4..u+7, v+4..v+15)).

## 5. Skin parts

### 5.1 The seven flags

`PlayerModelPart` (enum, ordinal = bit index, `mask = 1 << bit`):

| Ordinal / bit | Mask | Id (`getId`, option key suffix) | Language key | English (en_us in the jar) |
|---|---|---|---|---|
| 0 CAPE | 0x01 | `cape` | `options.modelPart.cape` | Cape |
| 1 JACKET | 0x02 | `jacket` | `options.modelPart.jacket` | Jacket |
| 2 LEFT_SLEEVE | 0x04 | `left_sleeve` | `options.modelPart.left_sleeve` | Left Sleeve |
| 3 RIGHT_SLEEVE | 0x08 | `right_sleeve` | `options.modelPart.right_sleeve` | Right Sleeve |
| 4 LEFT_PANTS_LEG | 0x10 | `left_pants_leg` | `options.modelPart.left_pants_leg` | Left Pant Leg |
| 5 RIGHT_PANTS_LEG | 0x20 | `right_pants_leg` | `options.modelPart.right_pants_leg` | Right Pant Leg |
| 6 HAT | 0x40 | `hat` | `options.modelPart.hat` | Hat |

Bit 7 (0x80) is unused. There are 7 flags; the mask is one byte.

### 5.2 Client side (options)

- `Options.modelParts` is a set, **all seven on by default** (`EnumSet.allOf`). The options file keys are
  `modelPart_<id>:<true|false>` (13 section 7).
- Closing: `SkinCustomizationScreen` extends `OptionsSubScreen`, whose `removed()` calls `Options.save()`. So closing the
  screen triggers save, then `broadcastOptions`, then (if changed) the Client Information packet. `Options.setModelPart`
  itself only edits the set.
- The Skin Customization screen (title key `options.skinCustomisation.title`, "Skin Customization"; the options entry
  `options.skinCustomisation`, "Skin Customization...") shows, in `PlayerModelPart.values()` order, one on/off cycle
  button per part labelled with the part's language key, followed by the Main Hand option (`options.mainHand`: Left,
  Right), all in a two-column small-button list. A button calls `Options.setModelPart`.
- `Options.save()` calls `broadcastOptions()`; with a player present it builds the Client Information and
  `broadcastClientInformation` sends the packet only when it differs from the last one sent (`remoteClientInformation`).
  `buildPlayerInformation` ORs the masks of the enabled parts into the customisation integer; with all parts on it is
  0x7F (127).
- The server sends nothing back for this except the entity data below.

### 5.3 Wire and server side

- Client Information (03, serverbound) carries "Model customisation" as an unsigned byte (the OR above).
- `ServerPlayer.updateOptions` stores that integer, truncated to a byte, into the player's entity data
  `DATA_PLAYER_MODE_CUSTOMISATION` (BYTE; index 16 on the `player` type, 21 table). The default is 0. The main hand is
  written separately into index 15, which is a HUMANOID_ARM entity-data value (0 left, 1 right; 21 section 8.16), not a byte.
- Hat change rule: `ServerGamePacketListenerImpl.handleClientInformation` reads `isModelPartShown(HAT)` before and after
  `ServerPlayer.updateOptions`. If the hat bit changed, it broadcasts Player Info Update with the single action UPDATE_HAT
  (the changed player, new boolean) to all players. The ADD_PLAYER entry also carries the player's current hat bit
  (`Entry.showHat`). Without this broadcast the tab-list hat never updates.
- Every client reads `Avatar.isModelPartShown(part)` as `(byte & mask) == mask` from that entity data, **including for
  the local player** (no client-side override was found). Consequently an implementation that never sets the entity
  data leaves all overlay layers and capes **hidden** on every player, because the default is 0. The server must copy
  Client Information into the entity data and send it in Set Entity Data (21 for the metadata wire form).
- `AvatarRenderer.extractRenderState` reads the seven flags into the render state: hat, jacket, left and right pants,
  left and right sleeve, cape (`showCape`). The same method also stores `skin` (from `ClientAvatarEntity.getSkin()`, so
  3.1 step 3 is evaluated each time the state is extracted) and `showExtraEars` (from `ClientAvatarEntity.showExtraEars()`, 6.4). The model draws each overlay mesh only when its flag is set (12 section 7.4).
- The Player Info action UPDATE_HAT (05a, ordinal 7, Boolean) sets `PlayerInfo.showHat` (default true). It is used only
  for the face drawn in the tab list (section 7), not for the world model.

## 6. Player render layers, cape, elytra, ears

### 6.1 Layers and order

`AvatarRenderer` (players and mannequins) adds layers in this order: humanoid armour, held items, stuck arrows,
**deadmau5 ears**, **cape**, custom head, **wings (elytra)**, shoulder parrots, spin attack effect, bee stingers.
Layers are skipped entirely for spectators (`shouldRenderLayers = !isSpectator`). `AvatarRenderer.scale()` applies the
constant 0.9375 to the pose stack. A crouching player is offset by `(0, s * -2 / 16, 0)` (12 section 7.3), where `s` is the
render-state `scale` field read by `getRenderOffset`, which is `entity.getScale()` and not the 0.9375 constant. At entity
scale 1 the offset is y = -2/16 = **-0.125**, not -0.1171875 (which would result from wrongly using 0.9375).

### 6.2 Cape layer (`CapeLayer`)

Drawn only when ALL hold: the player is not invisible; the cape flag (bit 0) is set; `skin.cape()` is present; the
chest equipment has no equippable asset with a WINGS layer (an elytra hides the cape; the elytra layer may then reuse
the cape texture, 6.3).

Rendering: push pose; if the chest equipment's asset has a HUMANOID layer (a chest armour piece with a humanoid armour
layer) translate by (0, -0.053125, 0.06875), otherwise no translation; submit the cape model with the cape texture as
an opaque entity render type, the entity's light, no overlay colour, then pop.

Cape model (`PlayerCapeModel`, built from the player mesh with every part removed except the cape): a child of the
body, pivot (0, 0, 2), rotation about Y of pi (180 degrees), one cuboid with texture offset (0, 0), origin (-5, 0, -1),
size (10, 16, 1), no growth, and **texture scale (1, 0.5)**: the model texture size is 64 x 64 but this cuboid's UVs use
a 64 x 32 basis (u / 64, v / 32). So the cape image is 64 x 32 (22 x 17 pixels used). Face regions in cape texture
pixels, by the layout rule of 12 section 7.4 with (w, h, d) = (10, 16, 1): top (1..11, 0..1), bottom (11..21, 0..1),
side (0..1, 1..17), "front" (1..11, 1..17), other side (11..12, 1..17), "back" (12..22, 1..17). Because of the pi
rotation the "front" region is the outer face (seen from behind the player) and the "back" region faces the body
(inferred from the face labels and the rotation).

Cape pose each frame (`PlayerCapeModel.setupAnim`, after the normal player pose): rotate the cape part by the
quaternion obtained by composing, in this order, rotation about Y by -pi, about X by
`(6 + capeLean / 2 + capeFlap)` degrees, about Z by `capeLean2 / 2` degrees, about Y by `(180 - capeLean2 / 2)` degrees
(all degrees converted with 0.017453292).

Render-state inputs (`AvatarRenderer.extractCapeState`), with partial tick `pt`:

1. `(dx, dy, dz) = interpolatedCloakPosition(pt) - lerp(pt, previousEntityPosition, entityPosition)`.
2. `yaw = rotLerp(pt, yBodyRotPrevious, yBodyRot)` in degrees (interpolating along the shortest angle), `s = sin(yaw *
   0.017453292)`, `c = -cos(yaw * 0.017453292)` using the game's sine and cosine (`Mth.sin`/`Mth.cos`, lookup tables
   read as follows: `sin(x)` converts `x * 10430.378350470453` (double) to a 64-bit integer by truncation, ANDs it with the
   64-bit value 65535 and narrows to int as the index into a 65536-entry float table; `cos(x)` does the same with
   `x * 10430.378350470453 + 16384.0`; table entry `i` is the double sine of `i / 10430.378350470453` cast to float
   (read from the static initialiser's fill lambda), which equals the sine of `i * 2 pi / 65536` only to within
   rounding).
3. `capeFlap = clamp(dy * 10, -6, 32)`.
4. `capeLean = (dx * s + dz * c) * 100`; then `capeLean *= (1 - fallFlyingScale)`; then clamp to 0..150.
   `fallFlyingScale = clamp(t * t / 100, 0, 1)` with `t = fallFlyingTicks + pt`.
5. `capeLean2 = clamp((dx * c - dz * s) * 100, -20, 20)`.
6. `capeFlap += sin(interpolatedWalkDistance(pt) * 6) * 32 * interpolatedBob(pt)`.

Client avatar state (`ClientAvatarState`, one per player entity, updated every client tick in
`AbstractClientPlayer.tick` before the normal tick, using the position and delta movement at that time):

| Quantity | Update |
|---|---|
| Cloak position (x, y, z) | Previous = current. For each axis separately: `d = position - cloak`; if `d > 10` or `d < -10` then cloak = position and previous = position (snap), otherwise `cloak += d * 0.25`. |
| Walk distance | Previous = current at the start of the tick; the entity adds the distance walked this tick (`addWalkedDistance`). Interpolated value = `lerp(pt, previous, current)`. |
| Bob | Once per `aiStep`: `target = 0` if the entity is not on the ground, is dead or dying, or is swimming, otherwise `min(0.1, horizontal speed of the delta movement)`; previous bob = bob; `bob += (target - bob) * 0.4`. While riding (`rideTick`) bob is reset to 0 (previous = old bob). Interpolated value = `lerp(pt, previous, current)`. |
| Delta movement on previous tick | The delta movement stored at the start of the tick (used for the flight orientation, not for the cape). |

`RemotePlayer` also calls `updateBob` in its `aiStep` and `calculateEntityAnimation` in its tick; remote players'
movement comes from the entity movement packets.

### 6.3 Wings (elytra) layer (`WingsLayer`, `ElytraModel`, `ElytraAnimationState`)

Drawn when the chest equipment has an Equippable component whose asset id is present (the elytra item); the model is
the standard one for adults and a half-scale one for babies. The player's wings texture is chosen by
`getPlayerElytraTexture`: if `skin.elytra()` is present use it; else if `skin.cape()` is present **and the cape flag
is set** use the cape texture; else none, and the equipment asset's own texture applies (for the elytra item the
equipment file `assets/minecraft/equipment/elytra.json` has one `wings` layer: texture `minecraft:elytra`,
`use_player_texture: true`; the file in the jar is `textures/entity/equipment/wings/elytra.png`, 64 x 32; the id to
path mapping is inferred from that listing). Pose: translate (0, 0, 0.125) before the model.

Geometry (texture size 64 x 32, both wings grown by 1.0):

| Wing | Pivot | Rest rotation (x, y, z) | Texture offset | Cuboid origin | Size | Mirror |
|---|---|---|---|---|---|---|
| left_wing | (5, 0, 0) | (0.2617994, 0, -0.2617994) | (22, 0) | (-10, 0, 0) | (10, 20, 2) | no |
| right_wing | (-5, 0, 0) | (0.2617994, 0, 0.2617994) | (22, 0) | (0, 0, 0) | (10, 20, 2) | yes |

Per frame: left wing `y = 3` if crouching else 0, rotation (x, y, z) = (elytraRotX, elytraRotY, elytraRotZ) from the
render state; the right wing copies x and y-offset and gets `yRot = -left.yRot`, `zRot = -left.zRot`.

Animation state (`ElytraAnimationState.tick`, once per client tick per living entity that has one): save the old
values; choose targets (x, y, z):

| Condition | Target rotX | Target rotY | Target rotZ |
|---|---|---|---|
| Fall flying | `lerp(t, 0.2617994, 0.34906584)` | 0 | `lerp(t, -0.2617994, -1.5707964)` |
| Crouching (not fall flying) | 0.6981317 | 0.08726646 | -0.7853982 |
| Otherwise | 0.2617994 | 0 | -0.2617994 |

where for fall flying `t = 1`, except when the delta movement's y is negative: `t = 1 - (-n_y)^1.5` with `n` the
normalised delta movement. Then each of rotX, rotY, rotZ moves 30 percent of the way to its target:
`v += (target - v) * 0.3`. The render state reads `lerp(pt, old, current)` of each.

### 6.4 Deadmau5 ears layer

Active only when the player name is exactly `deadmau5` (`AbstractClientPlayer.showExtraEars`, set at construction)
and the player is not invisible. It draws the ears model (mesh of the player with everything removed but two ears) with
the player's **body skin texture**. Each ear: child of the head, texture offset (24, 0), cuboid origin (-3, -6, -1),
size (6, 6, 1), grown by 1.0; pivots left ear (-6, -6, 0) and right ear (6, -6, 0); texture 64 x 64 (the ear pixels are
inside the skin image). The pose is the head's pose (inferred from the model being built on the player mesh). Unlike the cape (no overlay colour),
the ears are submitted with `LivingEntityRenderer.getOverlayCoords(state, 0)`, so the red hurt / white overlay applies to
them. The exact name comparison `deadmau5` and the geometry above were re-verified.

## 7. Heads and faces outside the world

### 7.1 Tab list and similar faces (`PlayerFaceExtractor`)

A face is two blits of the body texture, size s (8 pixels in the tab list; the tab list draws it before the name and
advances by 9): the head front from source (8, 8), 8 x 8 pixels, scaled to s x s; then, if the hat flag is on (tab
list: `PlayerInfo.showHat`), the hat front from source (40, 8), 8 x 8, also scaled to s x s. If the player is "upside
down" (see below), the face and hat are drawn with source v advanced by 8 and a negative source height (flipped vertically).
Texture size 64 x 64.

Upside-down rule: `LivingEntityRenderer.isUpsideDownName` is an exact string `equals` against `Dinnerbone` or `Grumm`;
`AvatarRenderer.isPlayerUpsideDown` applies it to the player's **game-profile name** (not a name tag). In the world,
`AvatarRenderer.isEntityUpsideDown` additionally requires the CAPE model-part flag to be shown: with the cape bit off a
Dinnerbone is not flipped. For a Player entity it then uses the profile-name rule; non-player avatars (mannequins) fall
back to `LivingEntityRenderer`'s own check. The tab list calls `isPlayerUpsideDown` only when `ClientLevel.getPlayerByUUID`
finds a Player entity with that UUID (otherwise not upside down), and does **not** test the cape flag.

### 7.2 Resolvable profiles (player heads, mannequins)

Items and blocks (00 section 13.3 `ResolvableProfile`) carry a profile in one of three forms: **Static** (a complete
game profile, resolved immediately), **Partial** (optional name, optional UUID, properties) and **Dynamic** (a name or
a UUID to be looked up with the profile resolver on a background thread). `PlayerSkinRenderCache` keeps two caches per
resolvable profile, each expiring 5 minutes after last access: the resolved skin (profile resolver then
`SkinManager.get`, then apply the profile's skin patch) and the **default** (immediate) skin, which is
`DefaultPlayerSkin.get(partialProfile)` with the patch applied (the partial profile's UUID is the supplied one, or the
nil UUID). Use rule (`getOrDefault`, `createLookup`): the resolved render info once the future is complete and present,
otherwise the default render info. The profile resolution needs network access (Open question 4).

### 7.3 Mannequins

`AvatarRenderer` also serves mannequins: `EntityRenderDispatcher` keeps a separate `mannequinRenderers` map, keyed by model
type like the player one. `ClientMannequin.DEFAULT_SKIN` is `DefaultPlayerSkin.get(Mannequin.DEFAULT_PROFILE.partialProfile())`;
`DEFAULT_PROFILE` is `ResolvableProfile.Static.EMPTY`, whose UUID is the nil UUID, so the default mannequin skin is entry 0
(`slim/alex`), not entry 6. The mannequin's skin otherwise comes from its resolvable profile (entity data PROFILE, 21
section 8.16) through `PlayerSkinRenderCache` (7.2). Its model-part byte defaults to **127** (21 section 8.16), unlike a
player's default 0 (5.3), so the "no overlays when the byte is 0" rule of 5.3 must not be applied to mannequins.

### 7.4 Skin preview widget and first-person hands

`PlayerSkinWidget` (a GUI widget given a width, height, the entity model set and a supplier of `PlayerSkin`) draws a
turnable model preview: it bakes both the wide and the slim player model, and each frame picks the slim one when the
supplied skin's model is SLIM, else the wide one, and draws it with the skin's body texture. Constants (read): scale
`0.97 * widgetHeight / 2.125`; the draw call also passes the constant -1.0625 (a vertical offset in model units; its
use is inside the GUI renderer, not read); initial rotation x = -5, y = 30 (the unit, degrees, is inferred; not read); dragging by (dx, dy) pixels
subtracts `dy * 2.5` from rotation x (clamped to -50..50) and adds `dx * 2.5` to rotation y (not clamped); clicking
plays no sound.

First-person hands: `AvatarRenderer.renderRightHand` and `renderLeftHand` take (pose stack, collector, light, skin texture
id, boolean) and share one routine: reset the chosen arm part's pose and make it visible; set both sleeve meshes visible
to the boolean; set the left arm's z rotation to -0.1 and the right arm's to +0.1 (radians); submit that arm part alone
with the skin texture as a translucent entity render type and no overlay colour (Open question 9).

### 7.5 Other consumers of a skin

All of these take the body texture of a `PlayerSkin` (or a resolvable profile through `PlayerSkinRenderCache`, 7.2) and need no network beyond what 3 and 7.2 already say; with no network they show the default skin. Read: the class uses `PlayerFaceExtractor` (7.1) or the cache; not read: any rectangle other than the face and hat of 7.1.

| Consumer | Uses | Source rectangle / size |
|---|---|---|
| `PlayerFaceWidget` | `PlayerFaceExtractor.extractRenderState` for a resolvable profile | face and hat of 7.1 |
| Spectator `PlayerMenuItem` | `PlayerFaceExtractor` with a skin, size 12 | face and hat of 7.1 at 12 x 12 |
| `PlayerGlyphProvider` (player-head glyph in text components) | `PlayerSkinRenderCache`; glyph advance constant 8.0 | face (rectangle not read) |
| Player-head item model (`ModelManager`, `ModelBakery`) | `PlayerSkinRenderCache` | whole body texture on the head model |
| Social `PlayerEntry`, `SocialInteractionsPlayerList`, `FriendToast`, `ClientActivePlayersTooltip`, `ChatSelectionScreen` heading entry, team-selection spectator item | listed in the jar; skin use not traced | presumed face of 7.1 (inferred) |
| `HumanoidMobRenderer`, `CopperGolemRenderer` | wings layer on non-player bodies | not traced |

Open question 13 lists what was not traced. An implementation may treat the unread rows as out of scope and draw the 7.1 face.

## 8. Offline, missing and no-network behaviour

What the vanilla client does:

| Situation | Result |
|---|---|
| Offline-mode server (no properties on any profile) | Every player, including the local one, shows `DefaultPlayerSkin.get(uuid)` with its model. |
| Profile has a `textures` property but no network | The download fails (or the cache file is missing); the optional is empty; the default skin is shown (3.3). A previously cached file in `<assets>/skins/xx/<sha1>` is used even offline, as long as the property can be unpacked (inferred: depends on authlib `unpackTextures`, not read; Open question 11). |
| Texture URL returns non-2xx, wrong image size, or cannot be decoded | Default skin. |
| Remote player's property is unsigned or invalid | Default skin (secure rule). |
| Local player's property unsigned | The skin is used. |
| Cape or elytra download fails | The whole lookup fails (all three futures are joined), so the body skin also falls back to the default. |
| Entity with no player info entry | `DefaultPlayerSkin.get(entity uuid)`. |
| Head with no resolvable profile | `getDefaultSkin()` (entry 6, `slim/steve`). |

What our client must do (derived from the above and from the operator decision that the client works with no network):

1. Ship the 18 default skin textures as part of the vanilla resource pack produced by the extraction tool (22 §6) and
   look them up through the normal resource-pack chain so packs can retheme them. The built-in cobolcraft pack (08
   section 10) must also provide something for the same 18 ids or the client must fall back to one of its own textures
   (Open question 5). **Fallback with no network and no usable pack:** if neither the vanilla pack nor the built-in pack supplies a requested id, use any one bundled 64 x 64 skin (its model matching the id's slim or wide half where possible), and if no skin is bundled at all draw a flat opaque 64 x 64 placeholder; never fail the connection or frame (item 5).
2. Choose the skin of every player from the UUID by section 2.2 (`floorMod(hashCode, 18)`), SLIM for 0..8 and WIDE for
   9..17, and render with the matching model. This is the only skin path that needs to work offline. The server's
   offline UUID derivation (02) therefore decides each player's default look.
3. Implement the model-part mask as in section 5: send Client Information with the customisation byte, store it in the
   entity data, hide overlays when it is 0.
4. Network skin download, caching, the signature check and cape loading are optional extras. If implemented they
   must follow section 3, and a client without authlib-equivalent signature verification must treat every property as
   unsigned, which makes remote players always use the default skin and the local player accept the property.
5. Never fail a connection or a frame because of a skin: every failure maps to the default skin.
6. A server running in offline mode sends empty property lists (GameProfileProperties with count 0); the client must
   accept a profile with no properties.
7. The cape, elytra and ears layers need no network: the elytra texture is a resource-pack file; a cape needs a
   downloaded texture, so without network no player has a cape, and the elytra uses the pack's elytra texture.

## 9. Worked examples

Offline UUIDs below were computed with the stated algorithm (MD5 of `OfflinePlayer:<name>`, version 3, variant 10) and
the hash of section 2.2; they are test data, not read from the jar.

| Input UUID | `hashCode` | `floorMod(h, 18)` | Skin | Model |
|---|---|---|---|---|
| `00000000-0000-0000-0000-000000000000` | 0 | 0 | `slim/alex` | SLIM |
| `00000000-0000-0001-0000-000000000000` | 1 | 1 | `slim/ari` | SLIM |
| `ffffffff-ffff-ffff-ffff-ffffffffffff` | 0 (the two halves cancel) | 0 | `slim/alex` | SLIM |
| `069a79f4-44e9-4726-a5be-fca90e38aaf5` | -369792882 | 0 (-369792882 = -20544049 x 18 + 0) | `slim/alex` | SLIM |
| `853c80ef-3c37-49fd-aa49-938b674adae6` | 1946714239 | 1 | `slim/ari` | SLIM |
| `12345678-1234-5678-9abc-def012345678` | -2004318072 | 0 | `slim/alex` | SLIM |
| offline `Steve` = `5627dd98-e6be-3c21-b8a8-e92344183641` | 1277771483 | 11 | `wide/efe` | WIDE |
| offline `Alex` = `36532b5e-c442-3dbb-a24c-c7e55d0f979a` | 223495834 | 4 | `slim/makena` | SLIM |
| offline `Notch` = `b50ad385-829d-3141-a216-7e7d7539ba7f` | -524802362 | 4 | `slim/makena` | SLIM |
| offline `Player` = `a01e3843-e521-3998-958a-f459800e4d11` | 1354479763 | 13 | `wide/makena` | WIDE |
| offline `jeb_` = `a762f560-4fce-3236-812a-b80efff0b62b` | -1770600077 | 1 | `slim/ari` | SLIM |
| offline `CobolCraft` = `f26b062b-3d36-360f-ae4b-690a437fcddf` | 577344753 | 9 | `wide/alex` | WIDE |
| offline `Dinnerbone` = `4d258a81-2358-3084-8166-05b9faccad80` | 366416444 | 2 | `slim/efe` | SLIM |

Hash walk-through for `12345678-1234-5678-9abc-def012345678`: `x = 0x1234567812345678 XOR 0x9abcdef012345678 =
0x88888888_00000000`; `(int)(x XOR (x >>> 32))` = low 32 bits of `0x88888888_00000000 XOR 0x00000000_88888888` =
`0x88888888` = -2004318072; `floorMod(-2004318072, 18)`: truncated remainder is 0 so the result is 0.

Legacy conversion example: in a 64 x 32 skin the pixel at (5, 21) is on the right leg front face. Step 3 row 4 copies
source columns 4..7 of rows 20..31 mirrored to destination columns 20..23 of rows 52..63: source (4 + i, 20 + j) goes to
(20 + (3 - i), 52 + j). Pixel (5, 21) has i = 1, j = 1, so it lands at (22, 53).

Hat hack example: a legacy skin that is fully opaque in x 32..63, y 0..31 (every alpha 255): all alpha in the
rectangle becomes 0 with colour bits kept, then fix-up c re-opaques x 0..63, y 16..31, so the hat area (y 0..15) is transparent and the arm
and body area (y 16..31) stays opaque.

Cape lean example: a player at rest after turning has `dx = dy = dz = 0`: `capeFlap = 0 + sin(walk * 6) * 32 * bob`
with bob 0, so 0; `capeLean = 0`, `capeLean2 = 0`; the cape rotation is X by 6 degrees (`6 + 0 + 0`), Y by -pi then
Y by 180 degrees: the cape hangs 6 degrees away from the body. Walking forward at 0.2 blocks per tick with the cloak
lagging by `dz` along the facing (so `dx * s + dz * c = 0.2`, hypothetical lag): `capeLean = 20`, clamped to 0..150
unchanged; the X angle is `6 + 10 + capeFlap`.

Elytra animation example: standing (not fall flying, not crouching), starting from rotX = 0 and target 0.2617994:
after tick 1 rotX = 0.07853982, after tick 2 = 0.13352 (`0.07853982 + 0.3 * (0.2617994 - 0.07853982)` =
0.0785398 + 0.0549779 = 0.1335177), converging to 0.2617994.

Default-skin flow example: an offline server, client connected, player `Steve`: Player Info ADD_PLAYER carries UUID
`5627dd98-...` and zero properties; no `textures` property so the packed property is absent; textures are EMPTY;
`registerTextures` takes the body and model from `DefaultPlayerSkin.get(uuid)` = `wide/efe`; secure is false (inferred, Open question 2); for
the local player that is accepted, for a remote player it is filtered and the lookup's own default
`DefaultPlayerSkin.get(profile)` (the same entry) is used. Result: wide model, `textures/entity/player/wide/efe.png`.

## 10. Validation

An implementation is conformant to this document when:

1. The table of 2.1 is reproduced: 18 entries, 9 slim then 9 wide, in alphabetical name order, and `floorMod(hashCode,
   18)` selects the entry; all rows of section 9 hold, including negative hashes.
2. A profile with no properties, and one whose texture cannot be loaded, show the same default skin as the UUID rule.
3. `getDefaultSkin` equivalent (heads without profile) is `slim/steve`.
4. A 64 x 32 test image converts to 64 x 64 with the twelve mirrored copies of 4 and the alpha rules; a test pattern in
   which every pixel encodes its own (x, y) shows: destination (36, 48) equals source (47, 16); destination (47, 63)
   equals source (52, 31) (row 12, i = 3, j = 11); for the left-arm back face (row 12) destination (44 + i, 52 + j) equals source
   (55 - i, 20 + j) for i 0..3, j 0..11; images that are not 64 x 32 or 64 x 64 are rejected; a 64 x 64 test image with alpha 0 in the base regions comes out
   with alpha 255 in x 0..31 y 0..15, x 0..63 y 16..31 and x 16..47 y 48..63, with no copies and no hat hack, and the
   overlay regions (x 32..63 y 0..15, rows 32..47, x 0..15 y 48..63, x 48..63 y 48..63) unchanged.
5. Sending Client Information with all parts yields customisation 0x7F; toggling a part flips only its bit; with the
   entity byte 0 no overlay and no cape is drawn; with the byte 0x7F all seven are drawn.
6. A cape is drawn only under the four conditions of 6.2; the wings layer uses the elytra texture, else the cape
   texture when the cape flag is set, else the pack's elytra texture.
7. The cloak smoothing constants (0.25, snap at 10), bob (0.4, cap 0.1), elytra smoothing (0.3) and the clamp ranges of
   6.2 reproduce the example of section 9 within float rounding.
8. Remote players with an unsigned property get the default skin, the local player gets its property skin.
9. No code path blocks or throws on a network error.

## 11. Open questions

1. **The `textures` property format.** The property value is, from recall (not verified), a Base64 JSON document
   with a `textures` object holding `SKIN` (with `url` and optionally `metadata.model = "slim"`), `CAPE` and `ELYTRA`
   entries; the texture hash used for the cache name is, from recall, the last path segment of the URL. authlib is not in
   the jar, so none of this was read. The jar does show the property name is looked up through
   `SessionService.getPackedTextures`, the metadata key `model`, and the types SKIN, CAPE and ELYTRA.
2. **Signature verification.** `SignatureState` SIGNED, UNSIGNED, INVALID and the check against Mojang's public key are
   authlib code, not read. Whether an absent signature gives UNSIGNED (assumed) and what `MinecraftProfileTextures.EMPTY`
   reports are not verified; "EMPTY is insecure" (3.3, 9) is inferred from the behaviour that the default body is
   returned anyway.
3. **Network limits.** No timeout, maximum size, redirect handling or retry was found in `SkinTextureDownloader`;
   they may be in the connection defaults of the JDK (not read).
4. **Profile resolution.** `ProfileResolver.fetchByNameOrId` (online lookups for head items by name or UUID) and the
   resolver's offline behaviour are not read.
5. **Built-in cobolcraft pack.** Whether the cobolcraft world type's built-in pack (08 §10) carries its own default skins is
   a design decision outside this artifact; section 8 states the fallback an implementation uses meanwhile. The reference to
   08 §10 was not re-checked here.
6. **Equipment asset path mapping.** The mapping from the equipment asset's texture id `minecraft:elytra` to
   `textures/entity/equipment/wings/elytra.png` is inferred from the file listing; `EquipmentLayerRenderer` was not read.
7. **Flight orientation.** `extractFlightData` (body orientation while fall flying, `flyingYRot`) and how the humanoid
   pose uses `fallFlyingScale` outside the cape are not traced; they belong with the pose animation (12 §7.5).
8. **Cape and ears head pose.** That the ears follow the head pose and that the cape's outer face is the "front" region
   are inferred from the model construction, not from rendered output.
9. **Hand rendering outside the world.** `AvatarRenderer.renderRightHand` and `renderLeftHand` (7.4) take the
   skin texture id and a boolean that sets both sleeve meshes visible or not; which value the first-person item renderer
   passes, and where it takes the model type from, was not traced.
10. **Stale text in other documents (for another pass; not edited here).** 12 §7.4 (near line 967) still says the legacy
    conversion is untraced and names `wide/steve.png` and `slim/alex.png` as default; 12 §7.6 says capes and elytra are
    "Not covered"; 12 open question 15 and item 7 are stale; each should point to 47 (form "47 §N"). 00 §13.3 still marks
    the cape, elytra and model-flag slots as inferred (read in 1). `README.md` has no row for 47 and its scope sentence is
    not updated.
11. **Offline use of a cached skin file.** That a cached file is used offline "as long as the property can be unpacked"
    depends on authlib `unpackTextures`, not read (inferred).
12. **Skin preview widget units.** The rotation units of `PlayerSkinWidget` (degrees) were not read from the artifact (inferred).
13. **Other skin consumers.** The source rectangles and network behaviour of the glyph provider, the head item model,
    social `PlayerEntry`, `FriendToast`, `ClientActivePlayersTooltip`, the chat-report heading, the team-selection item, the
    wings-layer use in `HumanoidMobRenderer` and `CopperGolemRenderer` were not traced (7.5).

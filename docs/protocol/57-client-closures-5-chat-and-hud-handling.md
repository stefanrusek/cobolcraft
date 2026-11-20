# 57-5. Client closures, part 5: chat, title, action bar, boss bar and scoreboard handling

| Item | Value |
|---|---|
| Covers | The client-side behaviour of the play packets that feed the chat window, the title overlay, the action bar, the boss bars and the scoreboard, as the vanilla 26.3 client receives and renders them: the receive path and the HUD layer order (§1); System Chat, Player Chat, Disguised Chat and Delete Message, with the chat type decoration, the secure-chat validator and its fallback, trust levels and message tags, the 100-message history, wrapping, fade timing and the chat options (§2); Set Title Text, Set Subtitle Text, Set Titles Animation, Clear Titles and Set Action Bar Text, with the state machine, the fade formulas, the layout and the rainbow "now playing" overlay (§3); the Boss Event packet, its sprites, layout, limits and its effect on sky, fog and music (§4); Set Display Objective, Set Objective, Set Score, Reset Score and Set Player Team, with the sidebar, below-name and tab-list score rendering (§5) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data and language files (`unzip -p`), with no execution; clean-room reader round "57-5" (reader only; a reviewer follows) |
| Extends or corrects | 05a (Boss Event, Clear Titles, Disguised Chat, Player Chat, composite types), 05b (Set Action Bar Text, Set Display Objective, Set Objective, Set Score, Reset Score, Set Player Team, Set Subtitle Text, Set Title Text, Set Titles Animation, System Chat; several "(inferred)" notes are confirmed or closed in §2.1, §3.1, §5.2), 12 §1.8, §3.3 (boss darkening ramp and fog, §4.4), 25-7 Open question 5 (the "now playing" display, §3.5), 38 §11 (end flash and boss fog), 57-3 Open question 11 (`enforcesSecureChat` consumers, §2.2) |

All numbers are Java `float` unless stated (the chat fade of §2.7 and the pushable test arithmetic are computed in `double`; the stated values are unchanged). Integer division truncates toward zero. Each section starts with a "Gap closed" line. Artifact class names are cited in backticks only to say where a fact was read. GUI coordinates are in GUI pixels (after the GUI scale of 12 §5). Text drawn "with shadow" follows 12 §5.10 (shadow offset +1, +1, colour x 0.25).

**Already documented elsewhere (not repeated):** the wire layouts of every packet named here are in 05a and 05b (Boss Event 05a 0x09, Clear Titles 05a 0x0E, Disguised Chat 05a 0x21, Player Chat 05a 0x42, Delete Chat 05a 0x1F, Set Action Bar Text 05b 0x59, Set Display Objective 05b 0x64, Set Objective 05b 0x6C, Set Player Team 05b 0x6F, Set Score 05b 0x70, Reset Score 05b 0x50, Set Subtitle Text 05b 0x72, Set Title Text 05b 0x74, Set Titles Animation 05b 0x75, System Chat 05b 0x7C) and in the composite types (ChatTypeBound, FilterMask, NumberFormat, TeamParameters). The server side of chat (what CobolCraft sends) is 09 §3.5.1 and 16 §8. The `chat_type` registry schema is in 04 (registry data, `chat_type`) and the seven vanilla entries are listed in §2.3. The use of the boss-bar flags by the light map and the fog is 12 §1.8 and §3.3 (this document adds the darkening ramp constants) and 38 §11 (end flash).

---

## 1. Receive path and HUD layer order

**Gap closed:** which handler each packet reaches, what stops a bad packet, in which order the HUD layers are drawn, and what stops them (F1, pause).

### 1.1 Handlers

| Packet | Handler (`ClientPacketListener`) | Effect in one line |
|---|---|---|
| System Chat | `handleSystemChat` | overlay flag true: action bar text; false: a server system line in the chat (§2.1) |
| Player Chat | `handlePlayerChat` | index check, signature unpack, validator, chat line (§2.2) |
| Disguised Chat | `handleDisguisedChat` | an unsigned chat line from a chat type (§2.5) |
| Delete Chat (Delete Message) | `handleDeleteChat` | replace a signed line by a marker (§2.6) |
| Set Action Bar Text | `setActionBarText` | `Hud.setOverlayMessage(text, false)` (§3.4) |
| Set Title Text, Set Subtitle Text, Set Titles Animation, Clear Titles | `setTitleText`, `setSubtitleText`, `setTitlesAnimation`, `handleTitlesClear` | the title state machine (§3.1) |
| Boss Event | `handleBossUpdate` | `BossHealthOverlay.update` (§4) |
| Set Objective, Set Score, Reset Score, Set Display Objective, Set Player Team | `handleAddObjective`, `handleSetScore`, `handleResetScore`, `handleSetDisplayObjective`, `handleSetPlayerTeamPacket` | edit the client `Scoreboard` (§5) |

Every handler first re-schedules itself onto the main thread. **A handler that throws is not skipped:** `PacketProcessor` passes the exception to `onPacketError`, which logs "Failed to handle packet {}, disconnecting" and disconnects with the translation `disconnect.packetError` ("Network Protocol Error"). Several malformed-but-wire-valid packets in §4 and §5 end that way; each such case says so. `ClientPacketListener` has no `onPacketError` override, so this common path always applies on the client. `Packet.isSkippable` (true for System Chat, Player Chat, Disguised Chat and Tag Query) is read only by `PacketEncoder` (outbound) and by `PacketUtils` for crash-report detail, never on the receive path.

### 1.2 HUD layer order (`Hud.extractRenderState`)

1. If the open screen is the level-loading screen (50), nothing is drawn.
2. If the HUD is not hidden (F1 toggles `Hud.isHidden`): camera overlays, crosshair, hotbar and decorations, the effect icons (49), the **boss bars**.
3. The sleep overlay (drawn even when the HUD is hidden).
4. If the HUD is not hidden: demo overlay, the **scoreboard sidebar**, the **action bar** (`extractOverlayMessage`), the **title and subtitle** (`extractTitle`), the **chat** (`extractChat`), the **tab list** (`extractTabList`), then the closed-caption overlay.

So later layers are drawn over earlier ones: chat over the title over the action bar over the sidebar over the boss bars. With F1 on, boss bars, sidebar, action bar, title, chat and tab list are all hidden but their state keeps advancing.

### 1.3 Clocks

`Gui.tick` calls `ChatListener.tick` and then `Hud.tick(paused)`. `Hud.tick` always runs the autosave indicator and runs the rest only when the game is **not paused** (the single-player pause, `Minecraft.isPaused`). That rest decrements the action bar timer, decrements the title timer, increments `tickCount` (the "GUI ticks" counter that stamps chat lines) and ticks the chat (delayed deletions, §2.6). So title, action bar and chat fades freeze while the game is paused. Frame interpolation uses the partial tick of the game-time delta (`getGameTimeDeltaPartialTick(false)`), a value in [0, 1).

`Hud.onDisconnected` (called when the connection ends) resets the tab list, **clears the boss bars**, clears the toasts, clears all chat messages and the recent-chat list, clears the title and subtitle and resets the title times to their defaults. No boss-bar reset was found in the Respawn or dimension-change handling (`ClientPacketListener` refers to the boss overlay only in `handleBossUpdate`), so boss bars survive a respawn and a dimension change.

---

## 2. Chat

**Gap closed:** what the client does with System Chat, Player Chat, Disguised Chat and Delete Message: validation, which line is added with which decoration and tag, what is hidden, how the window draws and fades, and the options that change it.

### 2.1 System Chat (`handleSystemChat`)

- **overlay = true:** `ChatListener.handleOverlay` calls `Hud.setOverlayMessage(content, false)` (the action bar of §3.4) and queues the text for the narrator. The chat window is not touched and the chat-visibility option (§2.8) is not consulted. (Confirms the "(inferred)" in 05b System Chat.)
- **overlay = false:** `ChatListener.handleSystemMessage(content, true)`:
  1. A sender guess: the plain text of the content is searched for text between the first `<` and the next `>`; if present it is looked up as a player name in `PlayerSocialManager.getDiscoveredUUID` (a map from names to UUIDs, default nil UUID; the map is filled from the player-info list: when the Player Info Update handler creates a new entry it calls `PlayerSocialManager.addPlayer`, which stores the profile name against the profile UUID); no match or no brackets gives the nil UUID.
  2. If the option `hideMatchedNames` (default true) is on and that UUID is blocked, the message is dropped. If the UUID is not nil and the player is friend-only restricted, dropped. (CobolCraft has no block list, so neither fires.)
  3. If the local player's chat abilities cannot receive system messages (chat visibility "Hidden", §2.8) the message is dropped.
  4. Otherwise `ChatComponent.addServerSystemMessage(content)` adds a line with source SYSTEM_SERVER and the tag `systemSinglePlayer` (§2.4), logs it to the report chat log, and queues it for the narrator.
- The text is displayed as sent; there is no chat type decoration for System Chat.

### 2.2 Player Chat (`handlePlayerChat`)

The steps, in order. A step that fails ends the handling of the packet.

1. **Global index.** The client keeps `nextChatIndex`, set to 0 in `handleLogin` (read). The packet's Global Index must equal it; the counter is incremented either way. A mismatch logs "Missing or out-of-order chat message from server" and **disconnects** with `multiplayer.disconnect.bad_chat_index` ("Detected a missed or reordered chat message from the server"). So a server must number its Player Chat packets 0, 1, 2, ... per connection (09 §3.5.1 does).
2. **Body unpack.** `SignedMessageBody.Packed.unpack` resolves the packed last-seen entries against the signature cache. A failure disconnects with `multiplayer.disconnect.invalid_packet`. An empty last-seen list always resolves.
3. **Signature cache.** The (optional) signature is pushed into the cache together with the body's last-seen entries; an absent signature adds nothing.
4. **Sender lookup.** The sender UUID is looked up in the client's player-info list (the tab-list entries from Player Info Update). If it is unknown the packet is shown as an **error line** (§2.4) and handling ends. So the sender must already be in the player-info list.
5. **Message link.** If the sender's player info has a chat session the link is (index, sender, session id); otherwise an "unsigned" link with only the sender.
6. **Validator.** The message (link, signature, body, unsigned content, filter mask) goes to the sender's message validator. If the validator returns nothing, the packet is shown as an error line.
7. Otherwise `ChatListener.handlePlayerChatMessage(message, senderProfile, chatTypeBound)` (§2.4).

**Which validator a sender has** (`PlayerInfo`): with no chat session (the CobolCraft case; 09 §3.2 sends Player Info Update with the ADD_PLAYER action only, so no entry has chat-session data) the validator is fixed when the `PlayerInfo` is created (`PlayerInfo(profile, boolean)` called with `ClientPacketListener.enforcesSecureChat()`) and is chosen by that value (`PlayerInfo.fallbackMessageValidator`) = (the client's services can validate profile keys) AND (the Login packet's `enforcesSecureChat` flag, 05a Login). If that is true the validator is **reject-all**: every message is dropped to an error line (and the server log line "no chat session initialized and secure chat is enforced"). If it is false the validator is **accept-unsigned**: it strips the signature (the signed body content is kept, the link becomes unsigned, the signature absent) and accepts. With a chat session a key-based validator would check the signature, the chain and the key expiry; CobolCraft never sends sessions (Open question 3 for the key-based details).

Consumers of `enforcesSecureChat` (closing 57-3 Open question 11): (a) the validator choice above, also used when a session is missing, fails validation or the services lack the public key; (b) a one-time toast `multiplayer.unsecureserver.toast.title` ("Chat messages can't be verified") with body "Messages sent on this server may be modified and might not reflect the original message", shown at join when the connection has a `ServerData` (taken to mean a server-list or direct-connect entry; inferred), the warning has not yet been shown and the effective flag is false. CobolCraft sends the flag false (09 §1), so unsigned player chat is accepted and the toast appears for list-based connections.

**Acknowledgement.** After a Player Chat line is shown or dropped the client calls `markMessageAsProcessed(signature, shown)` only when the message still has a signature at that point. A message that arrives unsigned creates no pending acknowledgement.

**Signed packet under accept-unsigned.** With the accept-unsigned validator (§2.2 above) even a packet that carries a signature is stripped before display: the step 3 cache push still happens with the packet's signature, but the message handed to the chat listener has no signature, so its line is NOT_SECURE, no acknowledgement is queued and the stored line has no signature, which also means it can never be deleted (§2.6).

### 2.3 Chat type decoration

A Player Chat or Disguised Chat packet carries a ChatTypeBound (05a): a chat type (inline decoration pair), the sender name component and an optional target name component. The client builds the displayed component as follows (`ChatTypeDecoration.decorate`):

1. For each entry of the decoration's `parameters` list, in order, take one component: `sender` = the bound sender name, `target` = the bound target name or an empty component when absent, `content` = the message component being decorated.
2. Make a translatable component from `translation_key` with those components as the arguments, in the list's order, and apply the decoration's `style` (empty style when absent).

The narration text is built the same way from the `narration` decoration (`ChatType.Bound.decorateNarration`); it only feeds the narrator and has no visual effect.

The seven chat types in the jar (`data/minecraft/chat_type/*.json`, read), with the English text of the key:

| Chat type | `chat` key (text) | `chat` parameters | `chat` style | `narration` key (text), parameters |
|---|---|---|---|---|
| `chat` | `chat.type.text` (`<%s> %s`) | sender, content | none | `chat.type.text.narrate` (`%s says %s`), sender, content |
| `emote_command` | `chat.type.emote` (`* %s %s`) | sender, content | none | `chat.type.emote`, sender, content |
| `say_command` | `chat.type.announcement` (`[%s] %s`) | sender, content | none | `chat.type.text.narrate`, sender, content |
| `msg_command_incoming` | `commands.message.display.incoming` (`%s whispers to you: %s`) | sender, content | gray, italic | `chat.type.text.narrate`, sender, content |
| `msg_command_outgoing` | `commands.message.display.outgoing` (`You whisper to %s: %s`) | target, content | gray, italic | `chat.type.text.narrate`, sender, content |
| `team_msg_command_incoming` | `chat.type.team.text` (`%s <%s> %s`) | target, sender, content | none | `chat.type.text.narrate`, sender, content |
| `team_msg_command_outgoing` | `chat.type.team.sent` (`-> %s <%s> %s`) | target, sender, content | none | `chat.type.text.narrate`, sender, content |

Worked example: chat type `chat`, sender name "Steve", content "hello": the translation `<%s> %s` with ("Steve", "hello") gives the line `<Steve> hello`. For `team_msg_command_incoming` with target "Red", sender "Steve", content "hi": `Red <Steve> hi`.

### 2.4 Showing a Player Chat message, trust level and tags

`handlePlayerChatMessage`:

1. If the option `onlyShowSecureChat` (default false) is on, the message's unsigned content is discarded. The displayed component is `decorate(message.decoratedContent)`, where `decoratedContent` is the unsigned content when the packet had one (and it was not discarded), else a literal component of the signed body content.
2. The message is queued (§2.9) and, when run, `showMessageToPlayer` applies, in order, and returns "not shown" at the first failing test:
   1. **Trust level** (`ChatTrustLevel`): SECURE when the sender is the local player on a local (integrated) server; else `evaluate`: NOT_SECURE when the message has no signature (or the signature has passed the client expiry); MODIFIED when the displayed text does not contain the signed content, or when the unsigned content uses a font other than the default; else SECURE. With `onlyShowSecureChat` on, NOT_SECURE messages are dropped here. Every message from CobolCraft (unsigned) is NOT_SECURE.
   2. Dropped when the sender is blocked or the message is fully filtered (filter mask kind FULLY_FILTERED).
   3. Dropped when the sender is friend-only restricted.
   4. Dropped when the local player cannot receive player messages (chat visibility "Commands Only" or "Hidden", or the restrictions of §2.8).
   5. The line is added with `addPlayerMessage(component, signature, tag)` where the tag comes from the trust level (table below). With an empty filter mask (PASS_THROUGH) the full decorated component is added. With a PARTIALLY_FILTERED mask the signed content is rewritten (each run of masked characters becomes a run of `#` of the same length with a "filtered" style whose hover text is `chat.filtered`, "Filtered by the server."; the style's colour was not read) and then decorated and added.
   6. The narrator is queued with the narration decoration.
   7. The report chat log gets an entry and `previousMessageTime` is set to now.

| Source of a chat line | Tag (indicator colour, tooltip key and English text) |
|---|---|
| Player chat, trust SECURE | none |
| Player chat, trust NOT_SECURE | `#D0D0D0` (13684944), `chat.tag.not_secure`, "Unverified message. Cannot be reported." |
| Player chat, trust MODIFIED | `#606060` (6316128), the icon `icon/chat_modified` (9 x 9), tooltip = `chat.tag.modified` ("Message modified by the server. Original:"), a new line, then the signed content in gray |
| Error line (validator rejected, sender unknown) | `#FF5555` (16733525), `chat.tag.error`, "Server sent invalid message." |
| Disguised chat | `chat.tag.system` tag: `#D0D0D0`, "Server message. Cannot be reported." |
| System chat (server) and client system lines | `chat.tag.system_single_player`: `#D0D0D0`, "Server message." (both `addServerSystemMessage` and `addClientSystemMessage` use this tag as read) |
| Deleted-message marker | the `chat.tag.system` tag |

**Error line.** `handleChatMessageError` shows `decorate(Chat validation error)` where the content is the translation `chat.validation_error` ("Chat validation error") in red italic, added with no signature and the error tag. When it has a signature it first calls `markMessageAsProcessed(signature, false)`, before any other test, so the acknowledgement happens even if the line is then dropped. Then the blocked, friend-only and "can receive player messages" tests apply (not the secure and filter tests); a failing test drops the line.

**Worked example (the CobolCraft case).** Login `enforcesSecureChat` = false; a Player Chat packet with global index 0, an absent signature, chat type `chat`, sender "Steve" whose UUID is in the player-info list. Result: the validator is accept-unsigned; the message is NOT_SECURE; the chat gets the line `<Steve> hello` with a 2-pixel `#D0D0D0` bar to its left and the tooltip "Unverified message. Cannot be reported." If the same server had sent `enforcesSecureChat` = true to a client that can validate profile keys, the same packet would give the red italic line `<Steve> Chat validation error` with the `#FF5555` bar.

### 2.5 Disguised Chat (`handleDisguisedChat`)

Always unsigned. The handler queues (§2.9) one action: if the local player can receive player messages (the same chat-visibility test, so "Commands Only" hides it too), add `decorate(message)` with `addPlayerMessage(component, no signature, tag system)`, queue the narration, log it as a system message and set `previousMessageTime`. No trust level, no block test, no filter, no `onlyShowSecureChat` test. There is no acknowledgement.

### 2.6 Delete Message (`handleDeleteChat`)

The packet carries a packed message signature (a cache index, or a full 256-byte signature, 05a). The client unpacks it against the signature cache (failure: disconnect with `multiplayer.disconnect.invalid_packet`), tells the last-seen tracker to ignore the pending signature, and then: if a message with that signature is still waiting in the chat-delay queue (§2.9) it is removed from the queue, otherwise `ChatComponent.deleteMessage(signature)` runs:

- The newest line-record in `allMessages` whose signature equals the given one is found. **A message with no signature can never be found**, so unsigned chat (all of CobolCraft's) cannot be deleted by this packet. This includes messages that arrived signed but were stripped by the accept-unsigned validator (§2.2): the stored line has no signature.
- If the current GUI tick is at least (the message's added tick + 60), the record is replaced at once by a **deleted marker**: the same added tick, no signature, source SYSTEM_SERVER, tag `chat.tag.system`, text `chat.deleted_marker` ("This chat message has been deleted by the server.") in gray italic, and the displayed lines are rebuilt.
- Otherwise a delayed deletion is queued with "deletable after" = added tick + 60; each GUI tick the queue is retried and an entry is dropped once the deletion has happened.

### 2.7 History, wrapping and the HUD window

**History.** Two lists of newest-first entries: `allMessages` (message records, capped at **100**) and `trimmedMessages` (display lines, capped at **100 lines**; oldest removed first). A message that wraps to several lines uses several of the 100 line slots, so the visible history can hold fewer than 100 messages. A message is added only if the visible-message filter accepts its source (§2.8). `clearMessages` empties both.

**Wrapping.** The wrap width in chat units is `floor(chatWidth / scale)` where `chatWidth = floor(widthOption x 280 + 40)` (default option 1.0 gives 320) and `scale` is the Chat Text Size option. A message whose tag has an icon (only the MODIFIED icon) wraps at `width - (icon width 9 + 4 + 2)` = width - 15. The component is split by the font's word-splitting rule (`StringSplitter.splitLines`) at that width. **Every continuation line begins with one space character** (a plain space with the empty style). When the option Colors (`chatColors`) is off, formatting codes are stripped from the text before splitting. An empty component yields one empty line. Changing the width, scale or line spacing re-wraps all stored messages (`rescaleChat`, which also resets the scroll).

**HUD drawing (`Hud.extractChat`, only when the chat screen is not open).** All coordinates are in "chat units", i.e. after the pose `scale(s)` and `translate(4, 0)`, where `s` is the Chat Text Size option (default 1.0); screen x = s x (4 + x), screen y = s x y.

| Quantity | Value |
|---|---|
| Bottom of the window | `chatBottom = floor((guiHeight - 40) / s)` |
| Line height (`entryHeight`) | `trunc(9 x (lineSpacing + 1))` (default spacing 0: 9) |
| Text offset (`entryBottomToMessageY`) | `round(8 x (lineSpacing + 1) - 4 x lineSpacing)` (default 8) |
| Lines shown | `linesPerPage = floor(heightPx / entryHeight)` with `heightPx = floor(heightOption x 160 + 20)`; the HUD (unfocused) uses the Unfocused Height option, default `70 / 160 = 0.4375` which gives 90 px and **10 lines**; the open chat window uses the Focused Height, default 1.0: 180 px, 20 lines. The newest line is drawn at the bottom; with no scroll the newest `linesPerPage` lines are visible |
| Line i from the bottom (0 = newest) | bottom `b = chatBottom - i x entryHeight`, top `b - entryHeight` |
| Line background | fill from x = -4 to `ceil(chatWidth / s) + 4 + 4`, from top to bottom, black with alpha `floor(lineAlpha x textBackgroundOpacity x 255)` (option default 0.5) |
| Text | left-aligned at x = 0, top y = `b - entryBottomToMessageY`, opacity `lineAlpha x textOpacity` where `textOpacity = chatOpacity x 0.9 + 0.1` (option default 1.0: 1.0); with shadow (the default text path) |
| Tag indicator | for every line of a message that has a tag: a fill x = -4 to -2, from the line top to its bottom, in the tag's indicator colour with alpha `floor(lineAlpha x textOpacity x 255)`. The tag icon is not drawn in the HUD window (it appears only in the open chat window, on hover) |
| Pending marker | when the chat delay queue (§2.9) is non-empty: a text `chat.queue` ("[+%s pending line(s)]", gray, click style) drawn with half the text opacity below the window, and a black strip behind it |

**Fade.** A line's `lineAlpha` is a function of its age in GUI ticks `a = guiTicks - addedTick` (the whole message shares the added tick): `lineAlpha = (clamp(10 x (1 - a / 200), 0, 1))^2`. So it is 1.0 for `a <= 180` (9 s), then falls quadratically to 0 at `a = 200` (10 s). A line is skipped when `lineAlpha <= 1.0e-5`. The open chat window ignores age (alpha 1). The HUD uses the integer GUI tick, not a partial tick, for this formula. The age arithmetic and the clamp are done in `double` and the result is narrowed to `float`.

Worked values (defaults): age 180: 1.0; 185: `(10 x 0.075)^2 = 0.5625`; 190: `(10 x 0.05)^2 = 0.25`, background alpha `floor(0.25 x 0.5 x 255) = 31` (`0x1F000000`); 195: `0.0625`; 200: not drawn.

### 2.8 Options that change chat (defaults read from `Options`)

| Option (key) | Default | Effect |
|---|---|---|
| `chatVisibility` (`options.chat.visibility`) | FULL ("Shown") | SYSTEM ("Commands Only") adds the restriction CHAT_DISABLED_BY_OPTIONS: player-message sending and receiving removed. HIDDEN adds CHAT_AND_COMMANDS_DISABLED_BY_OPTIONS: the same plus command sending and system-message receiving removed. Further restrictions on a multiplayer server (launcher chat disabled, profile chat not allowed) remove player-message permissions only |
| `chatOpacity` | 1.0 | `textOpacity = value x 0.9 + 0.1` |
| `textBackgroundOpacity` | 0.5 | alpha of the line background |
| `chatScale` | 1.0 | scale `s` |
| `chatLineSpacing` | 0.0 | line height and text offset |
| `chatWidth` | 1.0 | `floor(v x 280 + 40)` |
| `chatHeightFocused` | 1.0 | `floor(v x 160 + 20)` |
| `chatHeightUnfocused` | 0.4375 | the same formula |
| `chatDelay` | 0.0 (seconds; slider 0 to 6) | §2.9 |
| `chatColors` | on | off strips formatting codes |
| `onlyShowSecureChat` | off | §2.4 |
| `hideMatchedNames` | on | §2.1 |
| `backgroundForChatOnly` (`options.accessibility.text_background`: "Chat" or "Everywhere") | on ("Chat") | the backdrop behind title, action bar and sidebar text (§3.2, §5.3) |

A visible-message filter on the chat component keeps the records of the sources allowed by the abilities: SYSTEM_CLIENT always, PLAYER when player messages can be received, SYSTEM_SERVER when system messages can be received. Because disguised chat is added as a PLAYER message and gated by the player-message permission, "Commands Only" hides `say`, `me` and `msg` output sent as Disguised Chat, while it keeps System Chat lines.

### 2.9 Chat delay queue

`ChatListener` runs player, disguised and error handling through `handleMessage`: with `messageDelay` = 0 the action runs at once. With a positive delay (the Chat Delay option x 1000 ms) the action is queued, and each `tick` (while not paused) runs the next queued action once `now >= previousMessageTime + delay`, repeating while an action returns false (a dropped message does not consume the delay). `previousMessageTime` is set to now by every shown line. Setting the delay to 0 flushes the queue only if the old delay was above 0 and the game is not paused at that moment; `tick` also flushes a non-empty queue on any unpaused tick while the delay is 0. `flushQueue` runs every queued action, empties the queue and sets `previousMessageTime` to 0. While the game is paused and the delay is above 0, `previousMessageTime` advances by 50 ms per tick so the delay does not elapse; with delay 0 nothing advances. The default (0) is the immediate path; the pending-line marker of §2.7 is only seen with a delay.

---

## 3. Title, subtitle and action bar

**Gap closed:** the packets' effect on the title state, defaults, the order-of-arrival rules, the fade formulas, position, scale and colour of the title, subtitle and action bar, the rainbow of the "now playing" overlay, and the action bar's duration and fade.

### 3.1 State and the five packets (`Hud`)

State: `title` and `subtitle` (each a component or none), `titleTime` (int, 0 at start), and the three times `titleFadeInTime`, `titleStayTime`, `titleFadeOutTime` (ticks), **defaults 10, 70, 20** (`resetTitleTimes`).

| Packet | Effect |
|---|---|
| Set Title Text | `title` = text; `titleTime` = fade-in + stay + fade-out (restarts the whole timer; `subtitle` is kept) |
| Set Subtitle Text | `subtitle` = text only; no timer change, nothing is drawn by it alone |
| Set Titles Animation (fade in, stay, fade out; three 4-byte Ints) | each of the three that is `>= 0` replaces its stored time (a negative value leaves that one unchanged); then, if `titleTime > 0`, `titleTime` = the new fade-in + stay + fade-out (the running title restarts with the new total). It does not start or stop a title |
| Clear Titles (Boolean reset) | `title` and `subtitle` = none, `titleTime` = 0; **only when reset is true** are the three times set back to 10, 70, 20 |
| tick (not paused) | if `titleTime > 0`: decrement it; when it reaches 0 (or less), `title` and `subtitle` = none. The times are not reset by expiry |

Consequences (read from the above):
- The usual server order is: Titles Animation, Set Subtitle, Set Title. The title packet is what starts the display; a subtitle sent after the title appears at the next frame without restarting the timer; a subtitle sent alone is never shown until a title arrives (it is also cleared when that title expires).
- A subtitle set earlier stays attached to the next Set Title Text if nothing cleared it.
- The times persist across titles until another Titles Animation or a reset-clear. `/title ... times` therefore affects all later titles.
- With a total of 0 ticks, `titleTime` is 0 and nothing is drawn; the title stays stored (no tick clears it) until the next packet.
- A title is drawable while `titleTime > 0`, so its life is exactly fade-in + stay + fade-out ticks of unpaused game time.

### 3.2 Drawing (`Hud.extractTitle`)

Drawn only when `title` exists and `titleTime > 0`, with `t = titleTime - partialTick` (float).

**Alpha** (0 to 255, integer): start at 255. If the integer `titleTime > fadeOut + stay`: `alpha = trunc((fadeIn + stay + fadeOut - t) x 255 / fadeIn)`. If the integer `titleTime <= fadeOut`: `alpha = trunc(t x 255 / fadeOut)`. Then clamp to 0..255. (The two conditions cannot both hold, since the stay time is never negative.) If `alpha <= 0` nothing is drawn. When fade-in is 0 the first branch is never reached: the timer starts at fade-in + stay + fade-out = stay + fade-out, which is not greater than fade-out + stay (Set Title Text and Set Titles Animation both reset `titleTime` to that total), so no division by zero happens and the title is at full alpha from its first frame.

**Layout.** The pose is translated to the screen centre (guiWidth / 2, guiHeight / 2), each an integer division converted to float.
- Title: scale 4 x 4; text width `w` = the font width of the title; x = `-w / 2` (integer, truncating), y = **-10** (in scaled units: 40 px above the centre, text 36 px high); colour white with the computed alpha (`0xAARRGGBB` = alpha << 24 | `0xFFFFFF`); drawn with a backdrop (below) and with shadow.
- Subtitle (only if present): a new pose with scale 2 x 2 at the same centre; x = `-w2 / 2`, y = **5** (10 px below the centre); same colour and alpha as the title.

**Backdrop** (`GuiGraphicsExtractor.textWithBackdrop`, used by title, subtitle and action bar): the backdrop colour is `Options.getBackgroundColor(0)`: black with alpha `floor(255 x opacity)` where `opacity` is 0 when the option `backgroundForChatOnly` is on (the default, so **no backdrop**) and `textBackgroundOpacity` (default 0.5: alpha 127) when the option is "Everywhere". When the colour is not fully transparent a rectangle from (x - 2, y - 2) to (x + w + 2, y + 9 + 2) is filled with the backdrop colour multiplied component-wise (`ARGB.multiply`) by the text colour, then the text is drawn.

**Worked sequence** (bytes use the uncompressed framing of 01 §2: a VarInt length, then the VarInt packet id, then the fields; text components are bare String tags for plain literals, 09 §1):

| Step | Packet | Bytes |
|---|---|---|
| 1 | Set Titles Animation (0x75), fade-in 5, stay 40, fade-out 10 | `0D 75 00 00 00 05 00 00 00 28 00 00 00 0A` |
| 2 | Set Subtitle Text (0x72), "Sub" | `07 72 08 00 03 53 75 62` |
| 3 | Set Title Text (0x74), "Hi" | `06 74 08 00 02 48 69` |
| 4 | Clear Titles (0x0E), reset false (later) | `02 0E 00` |

After step 3: `titleTime` = 55. With partial tick 0 the alpha by `titleTime` is: 55: 0 (not drawn); 54: 51; 53: 102; 52: 153; 51: 204; 50 down to 11: 255; 10: 255; 9: 229; 8: 204; 7: 178; 6: 153; 5: 127; 4: 102; 3: 76; 2: 51; 1: 25. After the tick that brings `titleTime` to 0 the title and subtitle are cleared; the stored times stay 5, 40, 10. With partial tick 0.5 at `titleTime` 53: `t` = 52.5, `55 - 52.5 = 2.5`, `alpha = trunc(2.5 x 255 / 5)` = 127. Title position example (the width 14 is an invented input chosen to show the arithmetic, not a default-font measurement): guiWidth 427, guiHeight 240, title width 14: the centre is (427 / 2, 240 / 2) = (213, 120) with integer division, x = -7, so the text starts at screen (213 - 28, 120 - 40) = (185, 80) at scale 4. If step 4 arrives instead of expiry, the screen is cleared at once and the times stay 5, 40, 10 (a reset-clear with Boolean true, `02 0E 01`, would restore 10, 70, 20).

### 3.3 Subtitle versus closed captions

Not related: the closed-caption overlay is the sound subtitle overlay (`SubtitleOverlay`, option `showSubtitles`, 13); the "subtitle" of this section is only the second line of the title.

### 3.4 Action bar (`Hud.setOverlayMessage`, `extractOverlayMessage`)

Two sources call `setOverlayMessage(component, animate)`: Set Action Bar Text and System Chat with overlay true use **animate = false**; the "now playing" display (§3.5) uses **animate = true**.

State: `overlayMessageString`, `overlayMessageTime` (int), `animateOverlayMessageColor`.
- Setting: string = component, time = **60**, animate = the flag. A new message replaces the old at once and restarts the 60 ticks.
- Tick (not paused): if time > 0, decrement. The string is not cleared on expiry.
- Drawing: only when the string exists and `time > 0`. `t = time - partialTick`; `alpha = min(255, trunc(t x 255 / 20))`; nothing is drawn when `alpha <= 0`.
  So the text is fully opaque while `t >= 20` (40 ticks), then fades linearly over the last 20 ticks (3 s total). Alpha by integer time (partial 0): 60 to 20: 255; 19: 242; 15: 191; 10: 127; 5: 63; 1: 12.
- Position: the pose is translated to (guiWidth / 2, **guiHeight - 68**); the text is drawn at x = `-w / 2` (truncating), y = **-4** (so its top is 72 px above the bottom edge), scale 1, with the backdrop rule of §3.2 and with shadow.
- Colour: when animate is false, white with the alpha (`alpha << 24 | 0xFFFFFF`). The component's own styles (colours) still apply on top of that base colour as for any text.

### 3.5 Rainbow of the "now playing" overlay (closes 25-7 Open question 5)

`Hud.setNowPlaying(description)` builds the translation `record.nowPlaying` ("Now Playing: %s") with the song description as its argument, calls `setOverlayMessage(thatComponent, true)` (so the 60-tick display of §3.4) and queues it for the narrator. It is called by `LevelEventHandler.playJukeboxSong`, i.e. by **Level Event 1010** (05a) whose data is the `jukebox_song` registry id; Level Event 1011 stops the song and does not touch the overlay.

With animate = true the base colour is `hsvToArgb(h, s, v, alpha)` with `h = t / 50` (`t = time - partialTick`, so `h` runs from 1.2 down to 0 over the 60 ticks), `s = 0.7`, `v = 0.6`, and the alpha of §3.4. `Mth.hsvToArgb` (read):

1. `i = trunc(h x 6) mod 6` (integer remainder), `f = h x 6 - i` (note: `f` uses the **reduced** `i` but the unreduced product).
2. `p = v x (1 - s)`, `q = v x (1 - f x s)`, `t' = v x (1 - (1 - f) x s)`.
3. (r, g, b) by `i`: 0: (v, t', p); 1: (q, v, p); 2: (p, v, t'); 3: (p, q, v); 4: (t', p, v); 5: (v, p, q).
4. Each channel = `clamp(trunc(channel x 255), 0, 255)`; the colour is `alpha << 24 | r << 16 | g << 8 | b`.

For `h < 1` (the last 50 ticks) this is the usual hue wheel at saturation 0.7 and value 0.6: `p` = 45, `v` = 153 as channel values. For `h` in [1, 1.2] (the first 10 ticks) `h x 6` is in [6, 7.2] and `f` is in [6, 7.2), so `t'` and `q` leave [0, 1] and clamp. (Inferred arithmetic from the read formula, not observed.) Worked values (alpha 255): `t` = 25 (`h` = 0.5, `i` = 3, `f` = 0): (45, 153, 153); `t` = 0 (`h` = 0, `i` = 0, `f` = 0): (153, 45, 45); `t` in (50, 58.33] (`i` = 0, `f` >= 6): (153, 255, 45); `t` in (58.33, 60] (`i` = 1): (0, 153, 45); just below `t` = 50 (`i` = 5, `f` near 1): (153, 45, 45).

---

## 4. Boss bars

**Gap closed:** the Boss Event wire layout with a byte-level example, per-action effects, the flags, colour and style ids with sprite names and sizes, the bar layout and the cap per screen height, and the effect on the sky, fog and music.

### 4.1 Wire layout (confirms 05a 0x09)

`UUID` (16 bytes: most-significant Long then least-significant Long), the operation as a **VarInt** (`readEnum`: the ordinal; ids below), then the operation's fields:

| Id | Operation | Fields after the VarInt |
|---|---|---|
| 0 | ADD | TextComponent (trusted codec) title, Float progress, VarInt color, VarInt overlay, UByte flags |
| 1 | REMOVE | none |
| 2 | UPDATE_PROGRESS | Float progress |
| 3 | UPDATE_NAME | TextComponent title |
| 4 | UPDATE_STYLE | VarInt color, VarInt overlay |
| 5 | UPDATE_PROPERTIES | UByte flags |

Flag bits: **0x01** darken the sky (screen), **0x02** play boss music, **0x04** create world fog. Colour ids: 0 pink, 1 blue, 2 red, 3 green, 4 yellow, 5 purple, 6 white. Overlay (style) ids: 0 progress (solid), 1 notched_6, 2 notched_10, 3 notched_12, 4 notched_20.

**Worked example (ADD).** Bar UUID `12345678-9abc-def0-1122-334455667788`, title "Boss" (a bare String tag `08 00 04 42 6F 73 73`), progress 0.5 (`3F 00 00 00`), color red (2), overlay notched_10 (2), flags 0x05 (darken and fog, no music). Payload: packet id `09` (1 byte), UUID (16), action `00`, the 7-byte title, 4-byte float, `02`, `02`, `05` = 32 bytes (0x20). With the uncompressed framing:

`20 09 12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 00 08 00 04 42 6F 73 73 3F 00 00 00 02 02 05`

Effect: a bar named "Boss", red, notched-10 overlay, progress width 91 px (§4.3), `shouldDarkenScreen` and `shouldCreateWorldFog` true, `shouldPlayMusic` false. A later UPDATE_PROGRESS to 1.0 is `16 09 <the 16 UUID bytes> 02 3F 80 00 00` (length 0x16 = 22).

### 4.2 Per-action effects (`BossHealthOverlay`, `LerpingBossEvent`)

The overlay keeps a `LinkedHashMap<UUID, LerpingBossEvent>` (insertion order).
- **ADD:** constructs a new event (progress = target = the packet's value, the lerp clock set to now, the three flags set) and `put`s it. Adding an existing UUID replaces the event but keeps its **original position** in the order; removing and re-adding moves it to the end.
- **REMOVE:** removes the entry (no effect if absent).
- **UPDATE_PROGRESS:** `setProgress(p)`: the displayed value so far becomes the new lerp start, `p` the target, and the clock restarts. The displayed progress is `lerp(clamp((nowMillis - setTime) / 100, 0, 1), start, target)`, a **100 ms real-time** linear glide (not game ticks). The target is not clamped to [0, 1].
- **UPDATE_NAME / UPDATE_STYLE / UPDATE_PROPERTIES:** replace the name, the colour and overlay, or all three flags (a cleared bit clears the flag).
- **An update for an unknown UUID** has no null check: the lookup returns nothing and the call throws, which disconnects with "Network Protocol Error" (§1.1; inferred from the handler having no guard). A server must send ADD first.

### 4.3 Drawing (`BossHealthOverlay.extractRenderState`)

Nothing is drawn when there are no bars. Otherwise, in map order, with `W` = guiWidth, `H` = guiHeight:

| Item | Value |
|---|---|
| Bar left x | `W / 2 - 91` (integer division); every bar is 182 x 5 |
| First bar top y | 12; each next bar is **19 px lower** (the 10 px gap after the text line plus the 9-px line: `y += 10 + 9`) |
| Title text | the bar's name, white (`-1`), **with shadow**, at x = `W / 2 - width / 2` (integer), y = `barTop - 9` |
| Background | the colour background sprite `boss_bar/<colour>_background`, 182 x 5; if the overlay is not "progress", the overlay background `boss_bar/notched_<n>_background` is drawn over it, full width |
| Progress | width `w = floor(progress x 181) + (progress > 0 ? 1 : 0)` (`Mth.lerpDiscrete(progress, 0, 182)`: 0 gives 0, 1.0 gives 182, 0.5 gives 91); when `w > 0`: `boss_bar/<colour>_progress` then, if notched, `boss_bar/notched_<n>_progress`, each drawn as the left `w` columns of the 182 x 5 sprite (cropped, not scaled) at the same position. A progress above 1 gives `w` > 182 with no clamp read; a progress at or below 0 draws no fill |
| How many bars | the first bar is always drawn; after drawing a bar `y` becomes `y + 19`, and drawing stops when that `y >= floor(H / 3)`. So the count is `max(1, ceil((floor(H / 3) - 12) / 19))`; for `H` = 240 it is 4 bars (tops 12, 31, 50, 69), for `H` = 270 it is 5, for `H` = 90 it is 1 |

Sprites (all 182 x 5 PNG, read from the jar's `assets/minecraft/textures/gui/sprites/boss_bar/`, no `.mcmeta`): `pink|blue|red|green|yellow|purple|white` x `_background|_progress`, and `notched_6|notched_10|notched_12|notched_20` x `_background|_progress` (22 files). The overlay sprite for overlay id `k` (1 to 4) is index `k - 1` of the notched list. Sprites are drawn through the sprite mechanism of 12 §5.9.

Worked example (the name width 20 is an invented input chosen to show the arithmetic, not a default-font measurement): `W` = 427, one bar, progress 0.5, red, notched_10, name width 20: left = 213 - 91 = 122, top = 12, name at x = 213 - 10 = 203, y = 3; the progress width is `floor(0.5 x 181) + 1` = 91.

### 4.4 Effect on the world

Computed over all bars (a flag set on any bar counts):
- **Darkening** (`shouldDarkenScreen`): `GameRenderer` keeps a value `d` and its previous-tick value. Each tick (only while the tick-rate manager runs normally): the previous value is saved; if any bar has the darken flag, `d` increases by **0.05**, capped at 1; otherwise, if `d > 0`, it decreases by **0.0125** (no lower clamp was read, so a residue above 0 from float rounding would be followed by one more step to about -0.0125; inferred, Open question 7). The value used for drawing is `lerp(partialTick, previous, current)`. It is the `BossOverlayWorldDarkeningFactor` of the light map (12 §1.8, step 5) and the darkening term of the fog colour (12 §3.3, fog colour step 3). From 0 the ramp up takes 20 ticks and the ramp down from 1 takes 80 ticks.
- **Fog** (`shouldCreateWorldFog`): read by the atmospheric fog (12 §3: `envStart = min(envStart, 10)`, `envEnd = min(envEnd, 96)`), by the level renderer's fog switch in `GameRenderer.renderLevel` and by the light map, where the end-flash term added to the sky factor is divided by 3 (38 §11).
- **Music** (`shouldPlayBossMusic`): `Minecraft.getSituationalMusic` returns the boss track only when the local player is in the **End** dimension and some bar has the music flag. The open screen's own music (if the screen defines one) takes priority; otherwise, in the End with a music bar, the track `Musics.END_BOSS` is chosen: sound event `music.dragon`, min delay 0, max delay 0, replace the current music true. In any other dimension the flag has no effect.

---

## 5. Scoreboard

**Gap closed:** what each scoreboard packet does to the client scoreboard, with defaults and the failure cases, and how the sidebar, the below-name text and the tab-list scores are drawn.

### 5.1 Model and defaults

The client scoreboard (one per connection, kept across respawns) holds objectives by name, per-owner scores, a display-slot map and teams.

- **Display slots** (VarInt id, an out-of-range id reads as 0): 0 `list`, 1 `sidebar`, 2 `below_name`, 3 to 18 the team sidebars `sidebar.team.<colour>` in the TeamColor order black, dark_blue, dark_green, dark_aqua, dark_red, dark_purple, gold, gray, dark_gray, blue, green, aqua, red, light_purple, yellow, white (05b).
- **Objective:** name, criteria (always the dummy criteria on the client), display name (component), render type (0 integer, 1 hearts), number format (optional), display-auto-update (always false).
- **Score** (per owner string and objective): value (int), optional display component, optional number-format override.
- **Team** defaults: display name = the team name as text, prefix and suffix empty, name tag visibility ALWAYS, collision rule ALWAYS, friendly fire allowed true, see friendly invisibles true, no colour, no players.

### 5.2 The five packets

**Set Objective (0x6C), `handleAddObjective`** by Method byte:
- 0 (add): the objective is created with the dummy criteria, the packet's display name, render type and optional number format. **Adding a name that already exists throws** (`IllegalArgumentException`), so the client disconnects (§1.1; inferred path). A server must remove before re-adding.
- 1 (remove): if the objective exists it is removed: **every display slot that showed it is cleared**, and **all its scores are deleted**. Unknown name: ignored.
- 2 (change): if the objective exists its render type, display name and number format (an absent format clears it) are replaced. Unknown name: ignored.
- Other method values are ignored.

**Set Display Objective (0x64):** the slot is read as above. The objective name is read as a String; **an empty string means "no objective"** (read in the packet class; this closes the "(inferred)" in 05b). The handler looks the name up: no name or an unknown name gives none, and `setDisplayObjective(slot, none)` clears the slot.

**Set Score (0x70):** the owner is a name-only score holder; if the objective exists the score is created if missing and **value, display component and number-format override are all assigned from the packet** (absent display and absent format clear them). An unknown objective is ignored with a warning.

**Reset Score (0x50):** with no objective name, all scores of the owner are removed (confirms the "(inferred)" in 05b); with a name of a known objective, only that score is removed, and an owner left with no scores is forgotten; with an unknown objective name: ignored with a warning.

**Set Player Team (0x6F), `handleSetPlayerTeamPacket`.** The Method byte selects the team action and the player action:

| Method | Team action | Player action | Fields after Method (05b) |
|---|---|---|---|
| 0 add | add team | add players | parameters, players |
| 1 remove | remove team | none | none |
| 2 change | none | none | parameters |
| 3 join | none | add players | players |
| 4 leave | none | remove players | players |

Steps: for method 0 the team is created (`addPlayerTeam`: if a team of that name already exists a warning is logged and the existing team is used); for every other method the team must exist, else the packet is ignored with a warning ("unknown team"). If parameters are present they are applied: display name, colour (an absent colour clears it), options byte (bit 0 = friendly fire allowed, bit 1 = see friendly invisibles, both assigned from the bits), name tag visibility, collision rule, prefix, suffix. Then the players: **add** moves each name into the team (it is first removed from its previous team, if any); **remove** takes each name out of that team and **throws** (`IllegalStateException`, so a disconnect, §1.1 inferred path) if the name is not in that team. Method 1 removes the team and the memberships of its players. The visibility ids are 0 always, 1 never, 2 hide for other teams, 3 hide for own team; the collision ids 0 always, 1 never, 2 push other teams, 3 push own team (05b).

### 5.3 How team data is used on the client

- **Name formatting** (`PlayerTeam.formatNameForTeam`): with no team the name is a copy; with a team it is `prefix + name + suffix` with the team colour (if any) applied as the colour of the whole component (parts with their own colour keep it). The sidebar (§5.4) and the tab list (§5.6) use it; whether `Entity.getDisplayName` does (the name tag) was not read (Open question 4).
- **Name tag visibility** (`LivingEntityRenderer.shouldShowName`, for a living entity other than the local player that has a team T; L = the local player's team; `visible` = the entity is not invisible to the local player; "allied" = T and L are the same team object):
  - ALWAYS: `visible`. NEVER: false.
  - HIDE_FOR_OTHER_TEAMS: if L is none, `visible`; else true when allied and (T allows seeing friendly invisibles or `visible`), else false.
  - HIDE_FOR_OWN_TEAM: if L is none, `visible`; else false when allied, otherwise `visible`.
  For an entity that is not living, the base `EntityRenderer` rule applies: `Entity.shouldShowName()`, or a custom name while it is the crosshair-picked entity. An entity with no team, or the local player, uses the default rule: the HUD is not hidden, the entity is not the camera entity, it is `visible` and it is not a vehicle. A crouching ("discrete") entity at 32 blocks or more (squared distance >= 1024) never shows its name. (Subclass overrides, for example for players, were not traced, Open question 4.)
- **Collision rule** (`EntitySelector.pushableBy`): for entity E with team T (rule R_E, ALWAYS when no team) and another entity O with team T_O (rule R_O, ALWAYS when none), O can be pushed by E only if all hold. First, if R_E is NEVER, `pushableBy` returns a predicate that is always false (nothing is pushable by E). Otherwise the predicate is the conjunction of the **no-spectators** filter (a spectator O is never pushed) and the following: O is pushable; on the client only the **local player** can be the pushed O; R_O is not NEVER; `allied` = (T is not none and T is the same team as T_O); not ((R_E or R_O is PUSH_OWN_TEAM) and allied); not ((R_E or R_O is PUSH_OTHER_TEAMS) and not allied). (Polarity read from the bytecode as stated.)
- **Friendly fire and see-friendly-invisibles** bits are stored; the see-friendly-invisibles bit is read by the name tag rule above.

### 5.4 Sidebar (`Hud.extractScoreboardSidebar`, `displayScoreboardSidebar`)

1. **Which objective:** if the local player is on a team that has a colour, the objective in that colour's `sidebar.team.<colour>` slot is tried first; if there is none (or no colour) the `sidebar` slot's objective is used. If no objective results, nothing is drawn.
2. **Entries:** all scores of the objective except **hidden** ones (owner names that start with `#`), **sorted by value descending, ties by owner name ascending ignoring case** (`String.CASE_INSENSITIVE_ORDER` on the owner string), then **limited to the first 15** (so the lowest scores are the ones cut).
3. **Entry name:** the score's display component if it has one, else a literal of the owner name, then `formatNameForTeam` with the owner's team. **Entry score text:** the score's number format override, else the objective's number format, else the **sidebar default: red** (`StyledFormat.SIDEBAR_DEFAULT`, the colour `ChatFormatting.RED`) applied to the number's decimal text. Number format types (05b, ids in registration order 0 blank, 1 styled, 2 fixed, confirmed): blank gives an empty component (width 0), styled gives the decimal text with the given style, fixed gives a copy of the given component (the number is not shown).
4. **Width:** `maxW` = the width of the objective's display name (`getDisplayName`, not the formatted one); for each entry `maxW = max(maxW, nameWidth + (scoreWidth > 0 ? colonWidth + scoreWidth : 0))` where `colonWidth` is the font width of the string ":" (the colon is not drawn; it only supplies the gap).
5. **Geometry**, with `n` entries, `H` = guiHeight, `W` = guiWidth, line height 9: `totalH = n x 9`; `bottom = H / 2 + totalH / 3` (integer divisions); `top = bottom - totalH`; `left = W - maxW - 3`; `right = W - 3 + 2`.
6. **Backgrounds:** the title strip is filled from (left - 2, top - 10) to (right, top - 1) and the body from (left - 2, top - 1) to (right, bottom). Colours: `Options.getBackgroundColor(0.4)` for the strip and `getBackgroundColor(0.3)` for the body: black with alpha `floor(255 x opacity)` where the opacity is the given fallback (0.4 gives 102, `0x66000000`; 0.3 gives 76, `0x4C000000`) when `backgroundForChatOnly` is on (the default), or the Text Background Opacity option (0.5: alpha 127) for both when it is off.
7. **Text** (all colour `-1`, **no shadow**): the title at x = `left + maxW / 2 - titleWidth / 2`, y = `top - 9`; entry i (0 = first after sorting) at y = `bottom - (n - i) x 9`: the name at x = `left`, the score text at x = `right - scoreWidth`. The first sorted entry (highest score) is the top line. The red of the numbers comes only from the default number format; names are white unless their components or the team colour say otherwise.

Worked example. The widths below are **invented inputs chosen only to show the arithmetic**; they are not measurements of the default font (the glyph advances of the default font were not read, Open question 10): ":" is 2 wide, the title is 30 wide; guiWidth 427, guiHeight 240; entries Bob 12 (name width 18, score width 12), Alice 7 (28, 6), Cy 6 (12, 6). `maxW = max(30, 18+2+12, 28+2+6, 12+2+6) = 36`, `n` = 3, `totalH` = 27, `bottom = 120 + 9 = 129`, `top = 102`, `left = 427 - 36 - 3 = 388`, `right = 426`. Title strip fill (386, 92) to (426, 101), body fill (386, 101) to (426, 129). Title text at x = 388 + 18 - 15 = 391, y = 93. Lines: Bob at y = 102 (name x 388, score x 414), Alice at y = 111 (score x 420), Cy at y = 120 (score x 420).

### 5.5 Below-name score (`Entity.belowNameDisplay`, `EntityRenderer.extractNameTags`)

`EntityRenderer.extractNameTags` takes two distances. For living entities (`LivingEntityRenderer.extractNameTags`) they are read from the entity's attributes `NAME_TAG_DISTANCE` (default **64**, range up to 512) and `BELOW_NAME_DISTANCE` (default **10**, range up to 512); every other renderer uses the constants 64.0 and 10.0. When the render dispatcher has no camera, the whole pass is skipped (neither text is set). Otherwise `distanceToCameraSq` is computed, then:

- **Name tag:** shown when `distanceToCameraSq < nameDistance^2` **and** the renderer's `shouldShowName` (§5.3 for living entities) is true; the name text is `getNameTag` (the entity display name) and the attachment point is read from the entity's NAME_TAG attachment; otherwise the name is none.
- **Below-name score:** when `distanceToCameraSq < belowNameDistance^2` the score text is computed (`Entity.belowNameDisplay`), else none. The text: the objective in the `below_name` slot and the entity's score in it (the score holder is the player's name for players, the entity's UUID string otherwise); if both exist the text is `format(value)` + a space + the objective's display name, where `format` uses the objective's number format or the default with **no style** (so plain white unless styled). Otherwise no text.

The score text is submitted as a name tag at the entity's name-tag attachment point, and the entity's own name tag (when shown) is submitted above it, translated up by `9 x 1.15 x 0.025 = 0.25875` world units. The render type (hearts) is not used for the below-name display. Whether the score line can be submitted when the name is not shown (the attachment point is only set when the name is shown) was not traced (Open question 5).

### 5.6 Tab-list scores (`PlayerTabOverlay`)

The LIST objective is passed to the tab list. Only the score columns are specified here; the rest of the tab-list layout is outside this scope (Open question 6).

- For every listed player the score holder is its game profile; the value is its score in the objective, 0 when none.
- **Integer render type:** if a score exists, the text is the objective's number format (default **yellow**, `StyledFormat.PLAYER_LIST_DEFAULT`) applied to the number, `scoreWidth` its width; the column width is `max over players of (scoreWidth > 0 ? width(" ") + scoreWidth : 0)`.
- **Hearts render type:** the column width is a fixed **90**.
- A player's score is drawn only when the column is wider than 5 px and the player is **not in spectator mode**; the column starts at the player's name column right edge + 1 (`x0 = nameX + maxNameWidth + 1`) and ends at `x1 = x0 + columnWidth`.
- **Text:** the formatted score at x = `x1 - scoreWidth`, colour `-1`, with shadow.
- **Hearts** (`extractTablistHearts(y, x0, x1, uuid, graphics, score)`; the score counts half-hearts):
  - Per player a state keeps `displayedValue` and `lastValue`: when the score changes the state blinks for **20 ticks** if it dropped and **10 ticks** if it rose, and `displayedValue` is set to the score only on a tick where more than 20 ticks (strictly greater) have passed since the last change. A heart blinks while `(blinkUntil - guiTicks) mod 6 >= 3` and the blink has not ended.
  - `filled = ceil(max(score, displayedValue) / 2)`; `total = max(score, max(displayedValue, 20)) / 2` (integer, at least 10); nothing is drawn when `filled <= 0`.
  - `spacing = floor(min((x1 - x0 - 4) / total, 9))`. If `spacing <= 3` the hearts are replaced by text: the translation `multiplayer.player.list.hp` ("%shp") with the argument `score / 2` as a float, coloured from red to green by `f = clamp(score / 20, 0, 1)` as `((1 - f) x 255) << 16 | (f x 255) << 8` (opaque), centred in [x0, x1] at x = `(x0 + x1 - width) / 2`; if the translated text does not fit (`x1 - width < x0`) the plain float text of `score / 2` is used instead.
  - Otherwise each heart is a 9 x 9 sprite at `x0 + i x spacing`: first the container sprites (`hud/heart/container`, or `container_blinking` while blinking) for `i` from `filled` to `total - 1`; then for `i` from 0 to `filled - 1` a container, then (while blinking) `full_blinking` where `2i + 1 < displayedValue` and `half_blinking` where `2i + 1 = displayedValue`, then `hud/heart/full` where `2i + 1 < score` and `hud/heart/half` where `2i + 1 = score`; for `i >= 10` the full and half sprites are the `absorbing_full_blinking` and `absorbing_half_blinking` ones. (Sprite names read; sizes are the 9 x 9 draw size.)

---

## Open questions

1. **(Closed.)** Skippable packets: `ClientPacketListener` has no `onPacketError` override and `isSkippable` is not consumed on receive (§1.1); a throwing handler always disconnects.
2. **Filtered-run style and narrator.** The style of the `#` runs of a partially filtered message (colour and hover) was not read beyond the hover text `chat.filtered`; the narrator output and its mode default were not read (narration has no visual effect).
3. **Key-based validator.** The behaviour with a chat session (signature check, chain order, key-expiry window, `MESSAGE_EXPIRES_AFTER_CLIENT` value, the profile-key services) was read only as far as its failure messages; CobolCraft sends no sessions, so it does not matter for the server, but a client or a different server profile would need it.
4. **Team formatting of entity display names and subclass overrides of `shouldShowName`.** `Entity.getDisplayName` (name tags) and the player renderer's `shouldShowName` override were not traced; §5.3 gives the `LivingEntityRenderer` rule only. For entities that are not living, the base `EntityRenderer.shouldShowName` (read) is: true when `Entity.shouldShowName()` is true, or when the entity has a custom name and is the entity under the crosshair (`crosshairPickEntity`); otherwise false.
5. **Below-name score without a visible name.** `EntityRenderer.extractNameTags` computes the score text from the distance test alone, but the attachment point is only set when the name is shown; how `submitNameTag` copes with a missing attachment was not read. The name tag glyph layout (background, colours, seethrough) is the name-tag renderer's and is not in this document.
6. **Tab-list layout.** Only the score columns of the tab list are specified (§5.6); the player-list layout (columns, head, ping icon, header and footer, ordering, `PlayerTabOverlay`) is not documented anywhere in 12, 13 or 49 and was outside this scope.
7. **Boss darkening below zero.** The darkening value drops by 0.0125 per tick while it is above 0, with no lower clamp read; float rounding could leave a residue just above 0 and the next step would take it to about -0.0125. The effect of a negative factor in 12 §1.8 and §3.3 was not examined.
8. **Chat window when focused.** The open chat screen's behaviour (scrolling, hover tooltips, click handling, the draft, the pending-line expansion) lives in `ChatScreen` and the focused display modes and was not read here; only the HUD (unfocused) window is specified.
9. **Server-side numbering.** §2.2 step 1 requires Player Chat global indices 0, 1, 2, ... per connection; whether Disguised Chat or System Chat advance the counter was read as "no" (only `handlePlayerChat` touches it), which matches 09.
10. **Font advances.** The §5.4 example uses invented text widths. The advance of each glyph of the default font (needed to turn a string into a width for any layout in this document) is not in this document and was not read.

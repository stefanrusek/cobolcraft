*> Per-instance state of the client program (data-model §13; plan "Project Structure": passed BY
*> REFERENCE to every client program, so two clients can run in one process, Convergence). Constants
*> and limits: CLCONST.cpy. Large areas (chunk cells, meshes, atlas pixels) are ALLOCATEd and held
*> here by address; everything else lives in the record.
*>
*> Groups: start-up (name, game directory), run control, input state, screen model, server list,
*> connections, single-player hosting and the world list, local player and world settings, world replica (chunk rows and their section
*> meshes), entity replica and player list, the target and block controls, chat, command tree and
*> suggestions, recipe book, packs (stack, language, font), local packs and options.dat, server
*> packs, atlases and item icons, baked block
*> models, sky, render list.
 01 CLIENT-STATE.
*>  ---- start-up (client-surface §1, §2) ----
    05 CL-NAME               PIC X(16).
    05 CL-NAME-LENGTH        BINARY-LONG.
    05 CL-GAME-DIR           PIC X(1024).
    05 CL-GAME-DIR-LENGTH    BINARY-LONG.
*>  ---- run control ----
    05 CL-QUIT               PIC 9.          *> 1 = the run ends (quit control or close request)
    05 CL-NOW-MS             BINARY-DOUBLE.  *> the frame's clock (CL-STEP argument)
    05 CL-NEXT-TICK          BINARY-DOUBLE.  *> clock of the next client tick (Client Tick End)
    05 CL-FRAMES             BINARY-DOUBLE.
*>  ---- input state (shim-abi §8 events) ----
    05 IN-STATE.
       10 IN-KEY-DOWN        PIC 9 OCCURS 400 TIMES.   *> GLFW key code + 1
       10 IN-KEY-PRESSED-AREA.
          15 IN-KEY-PRESSED  PIC 9 OCCURS 400 TIMES.   *> went down during this frame
       10 IN-MODS            BINARY-LONG.
       10 IN-TEXT-COUNT      BINARY-LONG.
       10 IN-TEXT            BINARY-LONG OCCURS 32 TIMES.   *> code points typed this frame
       10 IN-BUTTON-DOWN     PIC 9 OCCURS 3 TIMES.     *> button + 1
       10 IN-BUTTON-PRESSED-AREA.
          15 IN-BUTTON-PRESSED PIC 9 OCCURS 3 TIMES.
       10 IN-BUTTON-RELEASED-AREA.
          15 IN-BUTTON-RELEASED PIC 9 OCCURS 3 TIMES. *> went up during this frame
       10 IN-CLICK-X         FLOAT-SHORT.              *> window position of the last button down
       10 IN-CLICK-Y         FLOAT-SHORT.
       10 IN-CURSOR-X        FLOAT-SHORT.
       10 IN-CURSOR-Y        FLOAT-SHORT.
       10 IN-DELTA-X         FLOAT-SHORT.              *> accumulated look delta (captured cursor)
       10 IN-DELTA-Y         FLOAT-SHORT.
       10 IN-SCROLL-X        FLOAT-SHORT.
       10 IN-SCROLL-Y        FLOAT-SHORT.
       10 IN-CAPTURED        PIC 9.                    *> 1 while the cursor is captured
       10 IN-WIN-W           BINARY-LONG.
       10 IN-WIN-H           BINARY-LONG.
       10 IN-RESIZED         PIC 9.
       10 IN-CLOSE           PIC 9.
*>  ---- screen model (data-model §13): the UI layer writes it each frame ----
    05 SM-STATE.
       10 SM-SCREEN          BINARY-LONG.
       10 SM-WIDGET-COUNT    BINARY-LONG.
       10 SM-WIDGET OCCURS 48 TIMES.
          15 SM-W-KIND       BINARY-LONG.
          15 SM-W-ACTION     BINARY-LONG.
          15 SM-W-ARG        BINARY-LONG.
          15 SM-W-X          BINARY-LONG.    *> GUI pixels (window / CL-GUI-SCALE), top-left
          15 SM-W-Y          BINARY-LONG.
          15 SM-W-W          BINARY-LONG.
          15 SM-W-H          BINARY-LONG.
          15 SM-W-STATE      BINARY-LONG.    *> 0 normal, 1 selected or focused, 2 disabled
          15 SM-W-LENGTH     BINARY-LONG.
          15 SM-W-TEXT       PIC X(256).
       10 SM-SELECTED        BINARY-LONG.    *> server list: selected entry, 0 none
       10 SM-FOCUS           BINARY-LONG.    *> edit server: 1 name field, 2 address field
       10 SM-EDIT-INDEX      BINARY-LONG.    *> edit server: entry edited, 0 = a new entry
       10 SM-EDIT-NAME       PIC X(64).
       10 SM-EDIT-NAME-LENGTH BINARY-LONG.
       10 SM-EDIT-ADDR       PIC X(256).
       10 SM-EDIT-ADDR-LENGTH BINARY-LONG.
       10 SM-CONNECT-ADDR    PIC X(256).     *> connecting screen: the address joined
       10 SM-CONNECT-ADDR-LENGTH BINARY-LONG.
       10 SM-MESSAGE         PIC X(512).     *> the last disconnect message, rendered
       10 SM-MESSAGE-LENGTH  BINARY-LONG.
       10 SM-DEATH-CAUSE     PIC X(512).     *> death screen: the Player Combat Kill message, rendered
       10 SM-DEATH-CAUSE-LENGTH BINARY-LONG.
*>  ---- server list (client-surface §2 servers.dat; US2-1, US2-2) ----
    05 SL-STATE.
       10 SL-COUNT           BINARY-LONG.
       10 SL-ENTRY OCCURS 32 TIMES.
          15 SL-NAME         PIC X(64).
          15 SL-NAME-LENGTH  BINARY-LONG.
          15 SL-ADDR         PIC X(256).
          15 SL-ADDR-LENGTH  BINARY-LONG.
          15 SL-POLICY       BINARY-LONG.    *> PackPolicy 0 prompt, 1 enabled, 2 disabled
          15 SL-STATUS       BINARY-LONG.    *> SLS-*
          15 SL-INCOMPATIBLE PIC 9.
          15 SL-ONLINE       BINARY-LONG.
          15 SL-MAX          BINARY-LONG.
          15 SL-DESC         PIC X(256).
          15 SL-DESC-LENGTH  BINARY-LONG.
          15 SL-VERSION      PIC X(64).
          15 SL-VERSION-LENGTH BINARY-LONG.
*>  ---- connections (CONN-GAME, CONN-PING); buffers are PB-BUFFERs kept as their raw 21 bytes ----
    05 CN-CONN OCCURS 2 TIMES.
       10 CN-HANDLE          BINARY-LONG.    *> cc_net handle, 0 = none
       10 CN-PHASE           BINARY-LONG.    *> PH-*
       10 CN-NEXT            BINARY-LONG.    *> phase after connecting: PH-STATUS or PH-LOGIN
       10 CN-ENTRY           BINARY-LONG.    *> ping: the server-list entry
       10 CN-THRESHOLD       BINARY-LONG.    *> compression threshold, -1 = off
       10 CN-HOST            PIC X(256).
       10 CN-HOST-LENGTH     BINARY-LONG.
       10 CN-PORT            BINARY-LONG.
       10 CN-READY           PIC 9.          *> 1 once the buffers are initialised
       10 CN-IN              PIC X(21).      *> received stream
       10 CN-OUT             PIC X(21).      *> bytes not yet sent
       10 CN-MEMORY          PIC 9.          *> 1 = a memory connection of the in-process core (US16)
       10 CN-CORE-ID         BINARY-LONG.    *> memory: the core's connection id, 0 once handed back
*>  ---- single-player (US16; sp-host.cob, game-dir.cob, the world list screens) ----
    05 SP-STATE.
       10 SP-ACTIVE          PIC 9.          *> 1 while this client hosts a world (in-process core)
       10 SP-SETTINGS        PIC X(1707).    *> the hosted world's CORE-SETTINGS (core-host-api §1)
       10 SP-NEXT-TICK       BINARY-DOUBLE.  *> clock of the next core tick
       10 SP-TICKS           BINARY-DOUBLE.  *> core ticks run since the world was opened
       10 SP-PAUSED          PIC 9.          *> 1 while the single-player pause is in effect (US16-4)
       10 SP-FOLDER          PIC X(80).      *> the hosted world's folder under saves/
       10 SP-FOLDER-LENGTH   BINARY-LONG.
       10 SP-CREATE-MODE     BINARY-LONG.    *> create-world screen: 0 survival, 1 creative
*>     Opening to others (US17; sp-host.cob, screens/open-to-others.cob): the screen's choices
*>     (guest mode 0 survival or 1 creative; 1 = guests may use operator commands), the listener
*>     (0 = not opened) and its port, the local addresses shown, and the guest connections: the
*>     cc_net handle (0 = free slot), the core's network connection id, the close flag handed back,
*>     and the bytes taken from CORE-CONN-OUTPUT not yet sent (GH-OUT-PENDING bytes from offset
*>     GH-OUT-START, 1-based, of the CL-GUEST-OUT bytes at GH-OUT-ADDR, allocated on first use).
       10 SP-GUEST-MODE      BINARY-LONG.
       10 SP-GUEST-OPERATOR  BINARY-LONG.
       10 SP-LISTENER        BINARY-LONG.
       10 SP-PORT            BINARY-LONG.
       10 SP-ADDR-COUNT      BINARY-LONG.
       10 SP-ADDR OCCURS 8 TIMES.
          15 SP-ADDR-TEXT    PIC X(16).      *> dotted IPv4 address
          15 SP-ADDR-LENGTH  BINARY-LONG.
       10 GH-GUEST OCCURS 8 TIMES.
          15 GH-HANDLE       BINARY-LONG.
          15 GH-CORE-ID      BINARY-LONG.
          15 GH-CLOSING      PIC 9.
          15 GH-OUT-ADDR     USAGE POINTER.
          15 GH-OUT-START    BINARY-LONG.
          15 GH-OUT-PENDING  BINARY-LONG.
       10 WL-COUNT           BINARY-LONG.    *> the world list (saves/, client-surface §2)
       10 WL-ENTRY OCCURS 32 TIMES.
          15 WL-FOLDER       PIC X(80).
          15 WL-FOLDER-LENGTH BINARY-LONG.
          15 WL-NAME         PIC X(64).      *> level.dat LevelName (the folder name without one)
          15 WL-NAME-LENGTH  BINARY-LONG.
          15 WL-MODE         BINARY-LONG.    *> level.dat GameMode
*>  ---- local player and the joined world (05a Login, 03 registries) ----
    05 PL-STATE.
       10 PL-ENTITY-ID       BINARY-LONG.
       10 PL-X               FLOAT-LONG.
       10 PL-Y               FLOAT-LONG.
       10 PL-Z               FLOAT-LONG.
       10 PL-YAW             FLOAT-SHORT.
       10 PL-PITCH           FLOAT-SHORT.
       10 PL-MODE            BINARY-LONG.
       10 PL-HELD            BINARY-LONG.
       10 PL-SLOT OCCURS 36 TIMES.
          15 PL-SLOT-COUNT   BINARY-LONG.
          15 PL-SLOT-ITEM    BINARY-LONG.
       10 PL-CARRIED-COUNT   BINARY-LONG.    *> the stack on the inventory screen's cursor
       10 PL-CARRIED-ITEM    BINARY-LONG.
       10 PL-INV-STATE-ID    BINARY-LONG.    *> container 0's state id (Container Set Content/Slot)
       10 PL-ABILITIES       BINARY-LONG.
       10 PL-FLY-SPEED       FLOAT-SHORT.
       10 PL-WALK-SPEED      FLOAT-SHORT.
       10 PL-SPAWN-X         BINARY-LONG.
       10 PL-SPAWN-Y         BINARY-LONG.
       10 PL-SPAWN-Z         BINARY-LONG.
       10 PL-VIEW-DISTANCE   BINARY-LONG.
       10 PL-LEVEL-COUNT     BINARY-LONG.    *> Login's dimension names: every dimension the server has
       10 PL-LEVEL           PIC X(64) OCCURS 8 TIMES.
       10 PL-DIM-NAME        PIC X(64).
       10 PL-DIM-TYPE        BINARY-LONG.
       10 PL-MIN-Y           BINARY-LONG.
       10 PL-HEIGHT          BINARY-LONG.
       10 PL-HAS-SKY         PIC 9.
       10 PL-TIME            BINARY-DOUBLE.  *> time of day 0 to 29999 (standin-content §4.8)
       10 PL-LOADED          PIC 9.          *> 1 after Player Loaded was sent
       10 PL-POSITIONED      PIC 9.          *> 1 after the first Player Position
       10 PL-BATCHES         BINARY-LONG.    *> chunk batches finished
       10 PL-CENTER-CX       BINARY-LONG.    *> Set Chunk Cache Center
       10 PL-CENTER-CZ       BINARY-LONG.
*>     Health (US7; standin-content §10): the last Set Health (health, food) and the clock until
*>     which the hurt indication shows (Damage Event or Hurt Animation for the local player).
       10 PL-HEALTH          FLOAT-SHORT.
       10 PL-FOOD            BINARY-LONG.
       10 PL-HURT-UNTIL      BINARY-DOUBLE.
*>     Hunger (US8; standin-content §11; controls.cob): sprinting as last told to the server
*>     (Player Command), and eating: 1 from the Use Item of a food item until the button is
*>     released or Entity Event 9 (eating finished) for the local player; the clock of that Use Item.
       10 PL-SPRINTING       PIC 9.
       10 PL-EATING          PIC 9.
       10 PL-EAT-START       BINARY-DOUBLE.
*>     Weather (US11; standin-content §14): the rain and thunder levels of the last Game Events 7
*>     and 8 (2 sets both to 0), and the kind they map to (WX-*).
       10 PL-RAIN            FLOAT-SHORT.
       10 PL-THUNDER         FLOAT-SHORT.
       10 PL-WEATHER         BINARY-LONG.
*>     Movement (client-surface §3; client/src/physics.cob): vertical speed in blocks per tick,
*>     ground and horizontal-collision flags of the last tick, flying, a Space press not yet
*>     used by a tick, the clock of the last Space press (fly toggle; 0 none), and what the
*>     server last got (Move Player or the accepted Player Position).
       10 PL-VY              FLOAT-LONG.
       10 PL-ON-GROUND       PIC 9.
       10 PL-COLLIDED        PIC 9.
       10 PL-FLYING          PIC 9.
       10 PL-JUMP            PIC 9.
       10 PL-SPACE-MS        BINARY-DOUBLE.
       10 PL-SENT-X          FLOAT-LONG.
       10 PL-SENT-Y          FLOAT-LONG.
       10 PL-SENT-Z          FLOAT-LONG.
       10 PL-SENT-YAW        FLOAT-SHORT.
       10 PL-SENT-PITCH      FLOAT-SHORT.
       10 PL-SENT-FLAGS      BINARY-LONG.
       10 RG-DIM-COUNT       BINARY-LONG.    *> dimension_type registry entries received
       10 RG-DIM OCCURS 8 TIMES.
          15 RG-DIM-NAME     PIC X(64).
          15 RG-DIM-MIN-Y    BINARY-LONG.
          15 RG-DIM-HEIGHT   BINARY-LONG.
          15 RG-DIM-HAS-SKY  PIC 9.
       10 RG-REGISTRIES      BINARY-LONG.    *> Registry Data packets received
       10 RG-BIOMES          BINARY-LONG.    *> worldgen/biome registry entries
       10 RG-BIOME-PRECIP    PIC 9 OCCURS 8 TIMES.   *> biome id + 1: has_precipitation
*>  ---- the target and the break, place and use controls (US4; raycast.cob, controls.cob) ----
    05 CT-STATE.
       10 TG-HIT             PIC 9.          *> 1 = a block within reach is aimed at
       10 TG-X               BINARY-LONG.
       10 TG-Y               BINARY-LONG.
       10 TG-Z               BINARY-LONG.
       10 TG-FACE            BINARY-LONG.    *> 05c Direction: 0 down 1 up 2 north 3 south 4 west 5 east
       10 TG-CX              FLOAT-SHORT.    *> the hit point within the block (0 to 1 each)
       10 TG-CY              FLOAT-SHORT.
       10 TG-CZ              FLOAT-SHORT.
       10 TG-ENTITY-HIT      PIC 9.          *> 1 = a player or mob within attack reach is aimed at
       10 TG-ENTITY          BINARY-LONG.    *> (nearer than the block target, which is then none)
       10 CT-SEQUENCE        BINARY-LONG.    *> the last block-change sequence number sent
       10 CT-ACK             BINARY-LONG.    *> the last Block Changed Ack sequence received
       10 CT-BREAKING        PIC 9.          *> 1 = a survival break is in progress
       10 CT-BREAK-X         BINARY-LONG.
       10 CT-BREAK-Y         BINARY-LONG.
       10 CT-BREAK-Z         BINARY-LONG.
       10 CT-BREAK-FACE      BINARY-LONG.
       10 CT-BREAK-START     BINARY-DOUBLE.  *> clock of the start destroy
       10 CT-BREAK-MS        BINARY-LONG.    *> break time, -1 = never (unbreakable)
       10 CT-DONE            PIC 9.          *> 1 = the block below was finished while held
       10 CT-DONE-X          BINARY-LONG.
       10 CT-DONE-Y          BINARY-LONG.
       10 CT-DONE-Z          BINARY-LONG.
       10 BD-ENTITY          BINARY-LONG.    *> the last Block Destruction (another player's break)
       10 BD-X               BINARY-LONG.
       10 BD-Y               BINARY-LONG.
       10 BD-Z               BINARY-LONG.
       10 BD-PROGRESS        BINARY-LONG.
*>  ---- world replica (data-model §3 replica): one row per chunk ----
    05 WR-STATE.
       10 WR-COUNT           BINARY-LONG.    *> rows in use
       10 WR-CHUNK OCCURS 1089 TIMES.
          15 WR-USED         PIC 9.
          15 WR-CX           BINARY-LONG.
          15 WR-CZ           BINARY-LONG.
          15 WR-ADDR         USAGE POINTER.  *> 3 x 65536 cells: states, sky light, block light
          15 WR-RELEASE      PIC 9.          *> 1 = forgotten: its mesh slots are to be freed
          15 WR-SECTION OCCURS 16 TIMES.
             20 WR-DIRTY     PIC 9.          *> 1 = to be meshed
             20 WR-OP-ADDR   USAGE POINTER.  *> opaque mesh vertices (28 bytes each)
             20 WR-OP-COUNT  BINARY-LONG.
             20 WR-TR-ADDR   USAGE POINTER.  *> translucent mesh vertices
             20 WR-TR-COUNT  BINARY-LONG.
             20 WR-UPLOAD    PIC 9.          *> 1 = meshes changed since the last frame
*>  ---- entity replica (data-model §3 replica; 05a Add Entity, Move Entity, Remove Entities) and
*>       the player list (Player Info Update / Remove) ----
    05 EN-STATE.
       10 EN-COUNT           BINARY-LONG.    *> rows ever used
       10 EN-ENTITY OCCURS 256 TIMES.
          15 EN-USED         PIC 9.
          15 EN-ID           BINARY-LONG.
          15 EN-TYPE         BINARY-LONG.    *> standin-content §3 entity type id
          15 EN-UUID         PIC X(16).
          15 EN-X            FLOAT-LONG.
          15 EN-Y            FLOAT-LONG.
          15 EN-Z            FLOAT-LONG.
          15 EN-YAW          FLOAT-SHORT.
          15 EN-PITCH        FLOAT-SHORT.
          15 EN-HEAD-YAW     FLOAT-SHORT.
          15 EN-ON-GROUND    PIC 9.
*>        A loose_item (US5): its motion (Add Entity, Set Entity Motion; blocks per tick) and the
*>        stack of its Set Entity Data (count 0 until then).
          15 EN-VX           FLOAT-LONG.
          15 EN-VY           FLOAT-LONG.
          15 EN-VZ           FLOAT-LONG.
          15 EN-STACK-COUNT  BINARY-LONG.
          15 EN-STACK-ITEM   BINARY-LONG.
       10 PI-COUNT           BINARY-LONG.    *> rows ever used
       10 PI-ENTRY OCCURS 64 TIMES.
          15 PI-USED         PIC 9.
          15 PI-UUID         PIC X(16).
          15 PI-NAME         PIC X(16).
          15 PI-NAME-LENGTH  BINARY-LONG.
*>  ---- chat (US6; client-surface §4; screens/chat.cob, screens/hud.cob): the line being typed
*>       (UTF-8), the messages scrolled back while chat is open, and the messages received this
*>       session, oldest first (the clock when each arrived, its rendered text) ----
    05 CH-STATE.
       10 CH-LINE            PIC X(1024).
       10 CH-LINE-LENGTH     BINARY-LONG.
       10 CH-SCROLL          BINARY-LONG.
       10 CH-COUNT           BINARY-LONG.
       10 CH-MESSAGE OCCURS 100 TIMES.
          15 CH-TIME         BINARY-DOUBLE.
          15 CH-LENGTH       BINARY-LONG.
          15 CH-TEXT         PIC X(256).
*>  ---- command tree (US14; 05a 0x10 Commands; 09 §3.3 command tree; screens/chat.cob): the nodes
*>       of the last Commands packet (node index i is row i + 1, the first CL-MAX-NODES kept):
*>       flags, name, greedy (a brigadier:string greedy phrase argument: it takes the rest of the
*>       line), and its children as a run of CM-LINK rows (node indices); the root's index ----
    05 CM-STATE.
       10 CM-COUNT           BINARY-LONG.
       10 CM-ROOT            BINARY-LONG.
       10 CM-NODE OCCURS 160 TIMES.
          15 CM-FLAGS        BINARY-LONG.
          15 CM-GREEDY       PIC 9.
          15 CM-NAME         PIC X(32).
          15 CM-NAME-LENGTH  BINARY-LONG.
          15 CM-FIRST        BINARY-LONG.    *> the first child's CM-LINK row
          15 CM-CHILDREN     BINARY-LONG.
       10 CM-LINK-COUNT      BINARY-LONG.
       10 CM-LINK            BINARY-LONG OCCURS 160 TIMES.
*>     Suggestions shown under the chat line (CHAT-SUGGEST): the command names that complete the
*>     word being typed; the last Command Suggestion sent (transaction id, the line it asked about,
*>     0 length = none outstanding) and the texts of its answer; the rows shown in the last frame.
       10 CS-COUNT           BINARY-LONG.
       10 CS-ENTRY OCCURS 10 TIMES.
          15 CS-TEXT         PIC X(32).
          15 CS-LENGTH       BINARY-LONG.
       10 CS-TRANSACTION     BINARY-LONG.
       10 CS-ASKED           PIC X(1024).
       10 CS-ASKED-LENGTH    BINARY-LONG.
       10 CS-ANSWERS         BINARY-LONG.
       10 CS-ANSWER OCCURS 10 TIMES.
          15 CS-A-TEXT       PIC X(64).
          15 CS-A-LENGTH     BINARY-LONG.
       10 CS-SHOWN           BINARY-LONG.
*>  ---- recipe book (US10; standin-content §13; 09 §3.3 Recipe Book Add; screens/crafting.cob):
*>       the recipes of the Recipe Book Adds received, in the order first received: display id,
*>       craftable (crafting requirements present), ingredients (item, count) and result ----
    05 RB-STATE.
       10 RB-COUNT           BINARY-LONG.
       10 RB-RECIPE OCCURS 16 TIMES.
          15 RB-ID           BINARY-LONG.
          15 RB-CRAFTABLE    PIC 9.
          15 RB-IN-COUNT     BINARY-LONG.
          15 RB-IN OCCURS 9 TIMES.
             20 RB-IN-ITEM   BINARY-LONG.
             20 RB-IN-AMOUNT BINARY-LONG.
          15 RB-RES-ITEM     BINARY-LONG.
          15 RB-RES-AMOUNT   BINARY-LONG.
*>  ---- packs (08 §3, §10): stack, language, font ----
*>  The stack (08 §3.1; stack.cob, source.cob): bottom first, the built-in pack at the bottom, then
*>  the enabled local packs (user order), then the server packs (newest on top). A local or server
*>  pack is a folder (kind 1) or a zip (kind 2: PK-ZIP, zip.cob) at PK-ROOT; PK-META holds its
*>  PACK-META (CLMCMETA.cpy: overlays, filter) and PK-FILES its file table (source.cob: the paths it
*>  serves after overlays, without those the filters of the packs above hide), all allocated.
    05 PK-STATE.
       10 PK-COUNT           BINARY-LONG.    *> packs in the stack, bottom first
       10 PK-PACK OCCURS 16 TIMES.
          15 PK-KIND         BINARY-LONG.    *> 0 built-in, 1 folder, 2 zip
          15 PK-SERVER       BINARY-LONG.    *> server pack: its RP-PACK row, else 0
          15 PK-ID           PIC X(80).      *> file/<name>, server/<8 hex>/<uuid>
          15 PK-ID-LENGTH    BINARY-LONG.
          15 PK-ROOT         PIC X(1024).    *> the folder or the zip file
          15 PK-ROOT-LENGTH  BINARY-LONG.
          15 PK-ZIP          USAGE POINTER.
          15 PK-META         USAGE POINTER.
          15 PK-FILES        USAGE POINTER.
          15 PK-FILE-COUNT   BINARY-LONG.
*>     Pack errors of the last stack build (US18-5): rendered "%s cannot be used: %s" texts.
       10 PK-ERROR-COUNT     BINARY-LONG.
       10 PK-ERROR OCCURS 8 TIMES.
          15 PK-ERROR-TEXT   PIC X(256).
          15 PK-ERROR-LENGTH BINARY-LONG.
       10 LG-COUNT           BINARY-LONG.
       10 LG-ENTRY OCCURS 640 TIMES.
          15 LG-KEY          PIC X(80).
          15 LG-KEY-LENGTH   BINARY-LONG.
          15 LG-TEXT         PIC X(200).
          15 LG-TEXT-LENGTH  BINARY-LONG.
       10 FN-CELL-W          BINARY-LONG.    *> glyph cell of the font image
       10 FN-CELL-H          BINARY-LONG.
       10 FN-HEIGHT          BINARY-LONG.    *> provider height (drawn glyph height)
       10 FN-GLYPH-AREA.
        12 FN-GLYPH OCCURS 96 TIMES.         *> code point 32 + index - 1 (32 to 127)
          15 FN-PRESENT      PIC 9.
          15 FN-X            BINARY-LONG.    *> cell top-left in the UI atlas
          15 FN-Y            BINARY-LONG.
          15 FN-ADVANCE      BINARY-LONG.    *> in drawn pixels (height FN-HEIGHT)
*>  ---- local packs (US18-1, US18-2; local.cob, screens/pack-select.cob): the packs of
*>       resourcepacks/ (byte order), their metadata and icon cell; the enabled pack ids of
*>       options.dat, top first; the pack awaiting confirmation (US18-4); the pack screen's
*>       selected entry is SM-SELECTED ----
    05 LP-STATE.
       10 LP-COUNT           BINARY-LONG.
       10 LP-ENTRY OCCURS 32 TIMES.
          15 LP-NAME         PIC X(64).      *> file or folder name
          15 LP-NAME-LENGTH  BINARY-LONG.
          15 LP-ID           PIC X(80).      *> file/<name>
          15 LP-ID-LENGTH    BINARY-LONG.
          15 LP-KIND         BINARY-LONG.    *> 1 folder, 2 zip
          15 LP-VALID        PIC 9.          *> 0 = cannot be used (LP-PROBLEM)
          15 LP-PROBLEM      PIC X(256).     *> rendered problem text
          15 LP-PROBLEM-LENGTH BINARY-LONG.
          15 LP-DESC         PIC X(256).     *> rendered description
          15 LP-DESC-LENGTH  BINARY-LONG.
          15 LP-COMPAT       BINARY-LONG.    *> PM-COMPAT: 0 compatible, 1 too old, 2 too new, 3 unknown
          15 LP-ICON         BINARY-LONG.    *> icon cell of the UI atlas, 0 = none
       10 OP-COUNT           BINARY-LONG.
       10 OP-ENABLED OCCURS 32 TIMES.
          15 OP-ID           PIC X(80).
          15 OP-ID-LENGTH    BINARY-LONG.
       10 LP-CONFIRM         BINARY-LONG.    *> pack confirmation: the LP-ENTRY to enable
       10 LP-ICON-COUNT      BINARY-LONG.    *> icon cells in use
*>  ---- server packs (US18-6 to US18-8; 08 §9; packs/download.cob, packs/cache.cob,
*>       screens/pack-prompt.cob): the packs pushed on the game connection in push order; the
*>       server-list entry joined (its PackPolicy) and this connection's answer ----
    05 RP-STATE.
       10 RP-ENTRY-JOINED    BINARY-LONG.    *> SL-ENTRY of the game connection, 0 = none
       10 RP-DECISION        BINARY-LONG.    *> 0 not asked, 1 allowed, 2 declined
       10 RP-RETURN-SCREEN   BINARY-LONG.    *> screen shown again after the prompt
       10 RP-PUSHES          BINARY-LONG.    *> pushes numbered so far (server/<8 hex> ids)
       10 RP-COUNT           BINARY-LONG.
       10 RP-PACK OCCURS 8 TIMES.
          15 RP-UUID         PIC X(16).
          15 RP-URL          PIC X(1024).
          15 RP-URL-LENGTH   BINARY-LONG.
          15 RP-HASH         PIC X(40).      *> lowercase expected SHA-1, spaces = none
          15 RP-REQUIRED     PIC 9.
          15 RP-PROMPT       PIC X(256).     *> rendered prompt text
          15 RP-PROMPT-LENGTH BINARY-LONG.
          15 RP-STEP         BINARY-LONG.    *> RPS-* (CLCONST.cpy)
          15 RP-NUMBER       BINARY-LONG.    *> push number
          15 RP-HTTP         USAGE POINTER.  *> allocated HTTP-REQUEST while downloading
          15 RP-FILE         PIC X(1100).    *> the cached zip
          15 RP-FILE-LENGTH  BINARY-LONG.
*>  ---- atlases: block atlas (texture 0), UI atlas (texture 2), entity and environment atlases ----
    05 AT-STATE.
       10 AT-W               BINARY-LONG.
       10 AT-H               BINARY-LONG.
       10 AT-ADDR            USAGE POINTER.  *> RGBA pixels, rows top to bottom
       10 AT-SPRITE-COUNT    BINARY-LONG.    *> sprite 1 is the missing texture
       10 AT-SPRITE OCCURS 128 TIMES.
          15 AT-NAME         PIC X(80).      *> sprite id, e.g. cobolcraft:block/greystone
          15 AT-NAME-LENGTH  BINARY-LONG.
          15 AT-X            BINARY-LONG.
          15 AT-Y            BINARY-LONG.
          15 AT-SW           BINARY-LONG.
          15 AT-SH           BINARY-LONG.
          15 AT-TRANSLUCENT  PIC 9.          *> 1 = some pixel has alpha below 255 (08 §5.3)
       10 UA-W               BINARY-LONG.
       10 UA-H               BINARY-LONG.
       10 UA-ADDR            USAGE POINTER.
       10 UA-ICON-Y          BINARY-LONG.    *> first row of the pack icon cells (16 x 16 each)
       10 AT-UPLOAD          PIC 9 OCCURS 4 TIMES.   *> texture id + 1 to be uploaded
*>     Entity atlas (texture 1; 08 §10.11): the entity images stacked from the top, left-aligned;
*>     for entity type t row t + 1 its image's rectangle (loose_item, row 2, has none).
       10 EA-W               BINARY-LONG.
       10 EA-H               BINARY-LONG.
       10 EA-ADDR            USAGE POINTER.
       10 EA-IMAGE OCCURS 4 TIMES.
          15 EA-IM-X         BINARY-LONG.
          15 EA-IM-Y         BINARY-LONG.
          15 EA-IM-W         BINARY-LONG.
          15 EA-IM-H         BINARY-LONG.
*>     Environment atlas (texture 3, repeat wrapping; 08 §10.11; weather-render.cob): row k
*>     (1 drizzle, 2 hailstorm) is its image's columns (left column, size); the image is repeated
*>     down its columns over the whole atlas height.
       10 XA-W               BINARY-LONG.
       10 XA-H               BINARY-LONG.
       10 XA-ADDR            USAGE POINTER.
       10 XA-IMAGE OCCURS 2 TIMES.
          15 XA-IM-X         BINARY-LONG.
          15 XA-IM-W         BINARY-LONG.
          15 XA-IM-H         BINARY-LONG.
*>     Item icons (08 §10.7, itemdefs.cob): for item id i, IT-SPRITE(i + 1) is the block-and-item
*>     atlas sprite of its icon (1 = the missing texture).
       10 IT-SPRITE          BINARY-LONG OCCURS 18 TIMES.
*>  ---- baked block models (08 §4, §5): quads per block state ----
    05 BM-STATE OCCURS 18 TIMES.
       10 BM-QUAD-COUNT      BINARY-LONG.
       10 BM-QUAD OCCURS 24 TIMES.
          15 BM-CULL         BINARY-LONG.    *> DIR-* after the Variant rotation, DIR-NONE
          15 BM-SHADE        BINARY-LONG.    *> DIR-* the face is shaded and lit as
          15 BM-SPRITE       BINARY-LONG.
          15 BM-CORNER OCCURS 4 TIMES.       *> top-left, top-right, bottom-right, bottom-left
             20 BM-X         FLOAT-SHORT.    *> block units 0 to 1
             20 BM-Y         FLOAT-SHORT.
             20 BM-Z         FLOAT-SHORT.
             20 BM-U         FLOAT-SHORT.    *> sprite units 0 to 16
             20 BM-V         FLOAT-SHORT.
*>  ---- sky (standin-content §4.8) ----
    05 SK-STATE.
       10 SK-U               BINARY-LONG.    *> daylight in thousandths
       10 SK-MESHED-U        BINARY-LONG.    *> daylight the meshes were built with
       10 SK-R               FLOAT-SHORT.    *> clear colour
       10 SK-G               FLOAT-SHORT.
       10 SK-B               FLOAT-SHORT.
*>  ---- render list (data-model §13): built each frame, submitted through cc_vk_* ----
    05 RL-STATE.
       10 RL-CLEAR OCCURS 4 TIMES FLOAT-SHORT.
       10 RL-PROJ OCCURS 16 TIMES FLOAT-SHORT.    *> column-major
       10 RL-VIEW OCCURS 16 TIMES FLOAT-SHORT.    *> rotation only (camera at the origin)
       10 RL-DRAW-COUNT      BINARY-LONG.
       10 RL-DRAW OCCURS 8192 TIMES.
          15 RL-D-SLOT       BINARY-LONG.
          15 RL-D-PIPELINE   BINARY-LONG.
          15 RL-D-TEX        BINARY-LONG.
          15 RL-D-MATRIX OCCURS 16 TIMES FLOAT-SHORT.
       10 RL-UPLOAD-COUNT    BINARY-LONG.
       10 RL-UPLOAD OCCURS 4096 TIMES.
          15 RL-U-SLOT       BINARY-LONG.
          15 RL-U-ADDR       USAGE POINTER.
          15 RL-U-COUNT      BINARY-LONG.
       10 RL-EN-COUNT        BINARY-LONG.    *> entity vertices this frame (eye-relative)
       10 RL-EN-UPLOADED     BINARY-LONG.    *> entity vertices last uploaded
       10 RL-EN-VERTEX OCCURS 9216 TIMES.
          15 RL-EN-X         FLOAT-SHORT.
          15 RL-EN-Y         FLOAT-SHORT.
          15 RL-EN-Z         FLOAT-SHORT.
          15 RL-EN-U         FLOAT-SHORT.
          15 RL-EN-V         FLOAT-SHORT.
          15 RL-EN-B         FLOAT-SHORT.
          15 RL-EN-A         FLOAT-SHORT.
*>     Item icons of the slot widgets (texture 0), the UI drawn over them (the slot counts,
*>     texture 2; UI-QUAD writes there while RL-UI-LAYER is 1) and the target highlight
*>     (eye-relative, texture 2); each with the vertex count last uploaded.
       10 RL-IC-COUNT        BINARY-LONG.
       10 RL-IC-UPLOADED     BINARY-LONG.
       10 RL-IC-VERTEX OCCURS 1536 TIMES.
          15 RL-IC-X         FLOAT-SHORT.
          15 RL-IC-Y         FLOAT-SHORT.
          15 RL-IC-Z         FLOAT-SHORT.
          15 RL-IC-U         FLOAT-SHORT.
          15 RL-IC-V         FLOAT-SHORT.
          15 RL-IC-B         FLOAT-SHORT.
          15 RL-IC-A         FLOAT-SHORT.
       10 RL-UI-LAYER        PIC 9.
       10 RL-UT-COUNT        BINARY-LONG.
       10 RL-UT-UPLOADED     BINARY-LONG.
       10 RL-UT-VERTEX OCCURS 1536 TIMES.
          15 RL-UT-X         FLOAT-SHORT.
          15 RL-UT-Y         FLOAT-SHORT.
          15 RL-UT-Z         FLOAT-SHORT.
          15 RL-UT-U         FLOAT-SHORT.
          15 RL-UT-V         FLOAT-SHORT.
          15 RL-UT-B         FLOAT-SHORT.
          15 RL-UT-A         FLOAT-SHORT.
       10 RL-HL-COUNT        BINARY-LONG.
       10 RL-HL-UPLOADED     BINARY-LONG.
       10 RL-HL-VERTEX OCCURS 144 TIMES.
          15 RL-HL-X         FLOAT-SHORT.
          15 RL-HL-Y         FLOAT-SHORT.
          15 RL-HL-Z         FLOAT-SHORT.
          15 RL-HL-U         FLOAT-SHORT.
          15 RL-HL-V         FLOAT-SHORT.
          15 RL-HL-B         FLOAT-SHORT.
          15 RL-HL-A         FLOAT-SHORT.
*>     The ground items (eye-relative billboards, texture 0; entities-render.cob).
       10 RL-GI-COUNT        BINARY-LONG.
       10 RL-GI-UPLOADED     BINARY-LONG.
       10 RL-GI-VERTEX OCCURS 1536 TIMES.
          15 RL-GI-X         FLOAT-SHORT.
          15 RL-GI-Y         FLOAT-SHORT.
          15 RL-GI-Z         FLOAT-SHORT.
          15 RL-GI-U         FLOAT-SHORT.
          15 RL-GI-V         FLOAT-SHORT.
          15 RL-GI-B         FLOAT-SHORT.
          15 RL-GI-A         FLOAT-SHORT.
*>     The weather quads (eye-relative, texture 3; weather-render.cob).
       10 RL-WX-COUNT        BINARY-LONG.
       10 RL-WX-UPLOADED     BINARY-LONG.
       10 RL-WX-VERTEX OCCURS 3468 TIMES.
          15 RL-WX-X         FLOAT-SHORT.
          15 RL-WX-Y         FLOAT-SHORT.
          15 RL-WX-Z         FLOAT-SHORT.
          15 RL-WX-U         FLOAT-SHORT.
          15 RL-WX-V         FLOAT-SHORT.
          15 RL-WX-B         FLOAT-SHORT.
          15 RL-WX-A         FLOAT-SHORT.
       10 RL-UI-COUNT        BINARY-LONG.    *> UI vertices this frame
       10 RL-UI-VERTEX OCCURS 24576 TIMES.
          15 RL-UI-X         FLOAT-SHORT.
          15 RL-UI-Y         FLOAT-SHORT.
          15 RL-UI-Z         FLOAT-SHORT.
          15 RL-UI-U         FLOAT-SHORT.
          15 RL-UI-V         FLOAT-SHORT.
          15 RL-UI-B         FLOAT-SHORT.
          15 RL-UI-A         FLOAT-SHORT.


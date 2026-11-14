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
    05 CL-GUI-SCALE          BINARY-LONG.     *> window pixels per GUI pixel, 1 to CL-MAX-GUI-SCALE (SCREEN-BUILD)
    05 CL-SWING-AT           BINARY-DOUBLE.   *> the clock when the hand last began to swing (0 = never)
    05 CL-CAMERA             BINARY-LONG.     *> F5 camera: 0 first person, 1 behind, 2 in front (camera.cob)
    05 CL-DEBUG              PIC 9.           *> 1 = the F3 overlay is shown (debug-overlay.cob)
    05 CL-FPS                BINARY-LONG.     *> frames in the last whole second
    05 CL-FPS-AT             BINARY-DOUBLE.   *> the clock when CL-FPS was last measured
    05 CL-FPS-FRAMES         BINARY-DOUBLE.   *> CL-FRAMES then
    05 CL-SPEED              FLOAT-LONG.      *> blocks moved in the last client tick
    05 CL-GUI-OPTION         BINARY-LONG.     *> the guiScale option (0 = automatic), applied by SCREEN-BUILD
    05 CL-FOV-DEG            FLOAT-SHORT.     *> the vertical field of view in degrees (fov option; 70 by default)
    05 CL-TURN               FLOAT-SHORT.     *> degrees of turn per mouse pixel (mouseSensitivity; 0.15 by default)
    05 CL-KEYS.                                *> the GLFW key code of each key binding, KB-* of CLCONST.cpy (OPTIONS-APPLY)
       10 KB-CODE            BINARY-LONG OCCURS 25 TIMES.
    05 CL-GENERATED-DIR      PIC X(1024).     *> generated directory (22 section 5.1): --generated-dir
    05 CL-GENERATED-DIR-LENGTH BINARY-LONG.   *> or <game directory>/generated
    05 CL-SET-OWNED          PIC 9.           *> 1 = the client built the content set of the game connection (WT-16)
    05 CL-WORLD              PIC X(80).       *> --world <save folder> / CC_WORLD: opened right after start-up (WORLD-OPEN-ARG)
    05 CL-WORLD-LENGTH       BINARY-LONG.     *> 0 = none
    05 CL-OPENER             PIC X(256).      *> the program that opens a folder (US4): /usr/bin/open, one argument
    05 CL-OPENER-LENGTH      BINARY-LONG.
    05 CL-OPEN-FAILED        PIC 9.           *> 1 = the last Open Pack Folder could not start the opener
    05 CL-WORLD-TYPE         BINARY-LONG.     *> CT-TYPE-* the game connection's content set was opened as (WT-16)
    05 CL-PACKS-STATUS       BINARY-LONG.     *> CT-PACKS-* of the start-up check (CORE-PACKS-STATUS)
    05 CL-PACKS-REASON       PIC X(128).      *> its reason text (a log line, not shown)
*>  ---- run control ----
    05 CL-QUIT               PIC 9.          *> 1 = the run ends (quit control or close request)
    05 CL-NOW-MS             BINARY-DOUBLE.  *> the frame's clock (CL-STEP argument)
    05 CL-NEXT-TICK          BINARY-DOUBLE.  *> clock of the next client tick (Client Tick End)
    05 CL-FRAMES             BINARY-DOUBLE.
*>  ---- screenshot (screenshot.cob; --screenshot-after-frames N, --screenshot-then-exit, CC_SCREENSHOT_AT_FRAME, CC_SCREENSHOT_THEN_EXIT) ----
    05 CL-CMD-AT             BINARY-DOUBLE.   *> the frame from which CL-CMD-TEXT (console commands separated by ;, CC_COMMANDS) runs once (0 = none)
    05 CL-CMD-TEXT           PIC X(1024).
    05 CL-SHOT-AT            BINARY-DOUBLE.   *> the frame number at which one screenshot is taken by itself (0 = none)
    05 CL-SHOT-EXIT          PIC 9.           *> 1 = the run ends once that screenshot is served
    05 CL-CAM-SET            PIC 9.           *> 1 = --camera / CC_CAMERA fixes the view: eye (CL-CAM-X, -Y, -Z), yaw and pitch in degrees
    05 CL-CAM-X              FLOAT-LONG.
    05 CL-CAM-Y              FLOAT-LONG.
    05 CL-CAM-Z              FLOAT-LONG.
    05 CL-CAM-YAW            FLOAT-LONG.
    05 CL-CAM-PITCH          FLOAT-LONG.
    05 CL-SHOT-AUTO          PIC 9.           *> 1 = the screenshot waiting is the automatic one
    05 CL-SHOT-PENDING       PIC 9.           *> 1 = a screenshot waits for its frame (cc_vk_screenshot)
    05 CL-SHOT-NAME          PIC X(40).       *> its file name (YYYY-MM-DD_HH.MM.SS.png, _1, _2 ... after a clash)
    05 CL-SHOT-NAME-LENGTH   BINARY-LONG.
*>  ---- input state (shim-abi §8 events) ----
    05 IN-STATE.
       10 IN-KEY-DOWN        PIC 9 OCCURS 400 TIMES.   *> GLFW key code + 1
       10 IN-KEY-PRESSED-AREA.
          15 IN-KEY-PRESSED  PIC 9 OCCURS 400 TIMES.   *> went down during this frame
       10 IN-KEY-REPEAT-AREA.
          15 IN-KEY-REPEAT   PIC 9 OCCURS 400 TIMES.   *> the frame's down event was the window system's key repeat
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
       10 SM-WIDGET OCCURS 512 TIMES.
          15 SM-W-KIND       BINARY-LONG.
          15 SM-W-ACTION     BINARY-LONG.
          15 SM-W-ARG        BINARY-LONG.
          15 SM-W-X          BINARY-LONG.    *> GUI pixels (window / CL-GUI-SCALE), top-left
          15 SM-W-Y          BINARY-LONG.
          15 SM-W-W          BINARY-LONG.
          15 SM-W-H          BINARY-LONG.
          15 SM-W-SPRITE     BINARY-LONG.    *> WK-IMAGE: the GSP row drawn
          15 SM-W-STATE      BINARY-LONG.    *> 0 normal, 1 selected or focused, 2 disabled
          15 SM-W-LENGTH     BINARY-LONG.
          15 SM-W-TEXT       PIC X(256).
          15 SM-W-COLOUR     BINARY-LONG.    *> text colour as an RGB integer; 0 = white (black is 1); drawn as its grey luminance (the vertex has one brightness)
*>     The tooltip layer (12 section 5.8): the lines of the tooltip to draw this frame, the mouse in GUI pixels, the item-tooltip title gap.
       10 TT-COUNT           BINARY-LONG.
       10 TT-X               BINARY-LONG.
       10 TT-Y               BINARY-LONG.
       10 TT-TITLE-GAP       BINARY-LONG.
       10 TT-LINE OCCURS 8 TIMES.
          15 TT-L-LEN        BINARY-LONG.
          15 TT-L-RGB        BINARY-LONG.
          15 TT-L-TEXT       PIC X(120).
       10 SM-SELECTED        BINARY-LONG.    *> server list: selected entry, 0 none
       10 SM-FOCUS           BINARY-LONG.    *> edit server: 1 name field, 2 address field
       10 SM-EDIT-INDEX      BINARY-LONG.    *> edit server: entry edited, 0 = a new entry
       10 SM-EDIT-NAME       PIC X(64).
       10 SM-EDIT-NAME-LENGTH BINARY-LONG.
       10 SM-EDIT-ADDR       PIC X(256).
       10 SM-EDIT-ADDR-LENGTH BINARY-LONG.
       10 SM-CONNECT-ADDR    PIC X(256).     *> connecting screen: the address joined
       10 SM-CONNECT-ADDR-LENGTH BINARY-LONG.
       10 SM-LOAD-CELLS      PIC X(1225).    *> the loading screen grid (docs/protocol/50 section 2.5): 35 x 35 cells, row by row, each one byte holding status code + 1 (GEN-LOAD-GRID)
       10 SM-LOAD-SMOOTH     BINARY-LONG.    *> the loading bar's smoothed progress in millionths (0.2 of the gap per 50 ms tick, 50 section 2.2)
       10 SM-LOAD-TICK-MS    BINARY-DOUBLE.  *> CL-NOW-MS of the last smoothing tick, 0 before the first
       10 SM-LOAD-GRID-MS    BINARY-DOUBLE.  *> CL-NOW-MS of the last read of the grid
       10 SM-LOAD-SHOWN      BINARY-LONG.    *> 1 once the loading screen has been shown for the hosted world being opened
       10 SM-MESSAGE         PIC X(512).     *> the last disconnect message, rendered
       10 SM-MESSAGE-LENGTH  BINARY-LONG.
       10 SM-DEATH-CAUSE     PIC X(512).     *> death screen: the Player Combat Kill message, rendered
       10 SM-DEATH-CAUSE-LENGTH BINARY-LONG.
       10 SM-CX-TITLE        PIC X(64).      *> container screen: the Open Screen title, rendered
       10 SM-CX-TITLE-LENGTH BINARY-LONG.
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
       10 SP-SETTINGS        PIC X(3829).    *> the hosted world's CORE-SETTINGS (core-host-api §1)
       10 SP-NEXT-TICK       BINARY-DOUBLE.  *> clock of the next core tick
       10 SP-TICKS           BINARY-DOUBLE.  *> core ticks run since the world was opened
       10 SP-PAUSED          PIC 9.          *> 1 while the single-player pause is in effect (US16-4)
       10 SP-FOLDER          PIC X(80).      *> the hosted world's folder under saves/
       10 SP-FOLDER-LENGTH   BINARY-LONG.
       10 SP-CREATE-MODE     BINARY-LONG.    *> create-world screen: 0 survival, 1 creative
       10 SP-CREATE-TYPE     BINARY-LONG.    *> create-world screen: world type, CT-TYPE-* (0 standard,
                                             *> the default; 1 cobolcraft; 2 the hidden debug type)
       10 SP-CREATE-REFUSED  PIC 9.          *> 1 = Create (or Play) was refused: the packs are not ok
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
          15 WL-TYPE         PIC X(16).      *> level.dat WorldType (cobolcraft when absent)
*>  ---- local player and the joined world (05a Login, 03 registries) ----
    05 PL-STATE.
       10 PL-ENTITY-ID       BINARY-LONG.
       10 PL-X               FLOAT-LONG.
       10 PL-Y               FLOAT-LONG.
       10 PL-Z               FLOAT-LONG.
       10 PL-YAW             FLOAT-SHORT.
       10 PL-PITCH           FLOAT-SHORT.
       10 PL-MODE            BINARY-LONG.
       10 PL-PERM            BINARY-LONG.    *> the permission level 0 to 4 (Entity Event 24 + level for the local player; 40-9 section 2.2)
       10 PL-HELD            BINARY-LONG.
       10 PL-SLOT OCCURS 36 TIMES.
          15 PL-SLOT-COUNT   BINARY-LONG.
          15 PL-SLOT-ITEM    BINARY-LONG.
       10 PL-OFFHAND-COUNT   BINARY-LONG.    *> the off-hand stack (menu slot 45, player inventory index 40)
       10 PL-OFFHAND-ITEM    BINARY-LONG.
       10 PL-SLOT-DAMAGE     BINARY-LONG OCCURS 36 TIMES.  *> damage component (3) of each slot's stack, 0 = none
       10 PL-OFFHAND-DAMAGE  BINARY-LONG.
*>     Menu slots outside the player's 36 (12 section 5.6a, b; 13 section 3.5): the inventory menu's armour (IX 1 to 4: head,
*>     chest, legs, feet), crafting result (IX 5) and 2 x 2 grid (IX 6 to 9), and the open bench menu's result (BX 5) and 3 x 3 grid
*>     (BX 6 to 14); BM-ID is the bench's container id (0 = none open), BM-STATE-ID its state id.
       10 IX-STACK OCCURS 16 TIMES.
          15 IX-COUNT        BINARY-LONG.
          15 IX-ITEM         BINARY-LONG.
          15 IX-DAMAGE       BINARY-LONG.
       10 BX-STACK OCCURS 64 TIMES.
          15 BX-COUNT        BINARY-LONG.
          15 BX-ITEM         BINARY-LONG.
          15 BX-DAMAGE       BINARY-LONG.
       10 MX-COUNT           BINARY-LONG.    *> max_damage components (2) the server's stacks carried: item and maximum, newest last
       10 MX-ENTRY OCCURS 16 TIMES.
          15 MX-ITEM         BINARY-LONG.
          15 MX-MAX          BINARY-LONG.
       10 BM-ID              BINARY-LONG.
       10 BM-STATE-ID        BINARY-LONG.
       10 BM-TYPE            BINARY-LONG.    *> menu type of the open bench (12) or container screen (args 401 to 464 are its own slots)
       10 PL-XP-LEVEL        BINARY-LONG.    *> the player's experience level (Set Experience 05b 0x69)
       10 PL-XP-PROGRESS     FLOAT-LONG.     *> its progress 0 to 1 and the total points (002-lane-mobs2)
       10 PL-XP-TOTAL        BINARY-LONG.
       10 PL-KB-X            FLOAT-LONG.     *> the horizontal push of an Explode packet's knockback, decaying each tick (physics.cob)
       10 PL-KB-Z            FLOAT-LONG.
       10 BM-DATA            BINARY-LONG OCCURS 16 TIMES.  *> the data slots of the open menu (Container Set Data 0x13; 40-1 section 4.3)
*>     The container screen's pointer (screens/pointer.cob; 40-1 section 5.5): the drag in progress (button, type 0 charitable, 1 greedy,
*>     2 clone, the slots it has visited), the release the press already acted on, the last click (slot and time) for the double click.
*>     The beacon screen's chosen powers (effect id + 1, 0 none; 40-5 section 3.7) and the merchant screen (40-5 section 2.10): the offers of Merchant Offers
*>     (up to 32), the villager level and XP, the progress and restock flags, the scroll offset, the selected offer, the scroller drag and the stacks the
*>     rows show this frame (argument 801 + 3 x row + 0 first cost, 1 second cost, 2 result).
       10 BC-PRIMARY         BINARY-LONG.
       10 BC-SECONDARY       BINARY-LONG.
       10 MC-COUNT           BINARY-LONG.
       10 MC-LEVEL           BINARY-LONG.
       10 MC-XP              BINARY-LONG.
       10 MC-PROGRESS        BINARY-LONG.
       10 MC-RESTOCK         BINARY-LONG.
       10 MC-SCROLL          BINARY-LONG.
       10 MC-SELECTED        BINARY-LONG.
       10 MC-DRAGGING        BINARY-LONG.
       10 MC-OFFER OCCURS 32 TIMES.
          15 MO-A-ITEM       BINARY-LONG.
          15 MO-A-COUNT      BINARY-LONG.
          15 MO-B-ITEM       BINARY-LONG.
          15 MO-B-COUNT      BINARY-LONG.
          15 MO-R-ITEM       BINARY-LONG.
          15 MO-R-COUNT      BINARY-LONG.
          15 MO-OUT          BINARY-LONG.
          15 MO-USES         BINARY-LONG.
          15 MO-MAX          BINARY-LONG.
          15 MO-XP           BINARY-LONG.
          15 MO-SPECIAL      BINARY-LONG.
          15 MO-DEMAND       BINARY-LONG.
          15 MO-MULT         FLOAT-SHORT.
       10 MC-DISP OCCURS 21 TIMES.
          15 MC-DISP-ITEM    BINARY-LONG.
          15 MC-DISP-COUNT   BINARY-LONG.
       10 CX-DRAG-ON         BINARY-LONG.
       10 CX-DRAG-BUTTON     BINARY-LONG.
       10 CX-DRAG-N          BINARY-LONG.
       10 CX-DRAG-SLOT       BINARY-LONG OCCURS 64 TIMES.
       10 CX-DRAG-ARG        BINARY-LONG OCCURS 64 TIMES.
       10 CX-SKIP-RELEASE    BINARY-LONG.
       10 CX-PREV-SLOT       BINARY-LONG.
       10 CX-PREV-MS         BINARY-DOUBLE.
       10 CX-DOUBLE          BINARY-LONG.
       10 CX-LAST-X          BINARY-LONG.
       10 CX-LAST-Y          BINARY-LONG.
*>     The anvil name field (40-3 section 3.8): the container id it belongs to, the item of slot 0 last seen (-1 none), the field text (UTF-8) and its byte length, the name
*>     last sent (itemName; AN-SENT-NULL 1 = none yet).
*>     The mount inventory (40-6): the entity id, its kind (1 horse family, 2 nautilus), whether the saddle and body slots are shown and the body icon (1 horse armor, 2 llama, 3 nautilus).
*>     The creative inventory engines (40-7): the selected tab (1 to 14), the scroll (0 to 1), the picker's stacks (item, count, 1 = the locked paper of the hotbar tab), the drop
*>     throttler counter (9.3), the saved hotbars (9 x 9 stacks, 10).
       10 CR-TAB             BINARY-LONG.
       10 CR-SCROLL          FLOAT-SHORT.
       10 CR-COUNT           BINARY-LONG.
       10 CR-STACK OCCURS 2048 TIMES.
          15 CR-STACK-ITEM   BINARY-LONG.
          15 CR-STACK-COUNT  BINARY-LONG.
          15 CR-STACK-LOCK   BINARY-LONG.
       10 CR-THROTTLE        BINARY-LONG.
       10 CR-SCROLLING       BINARY-LONG.
       10 CR-QUERY-LEN       BINARY-LONG.
       10 CR-QUERY           PIC X(64).
       10 CY-LIST            BINARY-LONG OCCURS 3 TIMES.   *> the smithing table's cycling icon helpers (40-3 5.6): list id, tick counter, icon index
       10 CY-TICK            BINARY-LONG OCCURS 3 TIMES.
       10 CY-INDEX           BINARY-LONG OCCURS 3 TIMES.
       10 CR-HB-LOADED      BINARY-LONG.    *> 1 once hotbar.nbt was read (lazily, 40-7 10)
       10 CR-HB OCCURS 81 TIMES.
          15 CR-HB-ITEM      BINARY-LONG.
          15 CR-HB-COUNT     BINARY-LONG.
*>     The text engines of 40-8: the page editor (BK: value, indexes 0 based, selection anchor, wrap width and the limits, a fixed advance for tests (0 = the font), the display
*>     lines, the clipboard), the book (BE: the pages, the shown page, the hand, the sign title) and the sign line editor (SG: four lines, the line being edited, cursor and anchor,
*>     the width limit, the sign position, side and clipboard).
       10 BK-VALUE           PIC X(1100).
       10 BK-LEN             BINARY-LONG.
       10 BK-CURSOR          BINARY-LONG.
       10 BK-ANCHOR          BINARY-LONG.
       10 BK-SELECTING       BINARY-LONG.
       10 BK-WIDTH           BINARY-LONG.
       10 BK-ADVANCE         BINARY-LONG.
       10 BK-CHAR-LIMIT      BINARY-LONG.
       10 BK-LINE-LIMIT      BINARY-LONG.
       10 BK-LINE-COUNT      BINARY-LONG.
       10 BK-OVERFLOW        BINARY-LONG.
       10 BK-LINE OCCURS 64 TIMES.
          15 BK-LB           BINARY-LONG.
          15 BK-LE           BINARY-LONG.
       10 BK-CLIP            PIC X(1100).
       10 BK-CLIP-LEN        BINARY-LONG.
       10 BE-PAGE-COUNT      BINARY-LONG.
       10 BE-CURRENT         BINARY-LONG.
       10 BE-HAND            BINARY-LONG.
       10 BE-ACTIVE          BINARY-LONG.
       10 BE-MODE            BINARY-LONG.
       10 BE-TITLE-LEN       BINARY-LONG.
       10 BE-TITLE           PIC X(32).
       10 BE-PAGE OCCURS 100 TIMES.
          15 BE-PAGE-LEN     BINARY-LONG.
          15 BE-PAGE-TEXT    PIC X(1024).
       10 SG-LINE            BINARY-LONG.
       10 SG-CURSOR          BINARY-LONG.
       10 SG-ANCHOR          BINARY-LONG.
       10 SG-MAXW            BINARY-LONG.
       10 SG-X               BINARY-LONG.
       10 SG-Y               BINARY-LONG.
       10 SG-Z               BINARY-LONG.
       10 SG-SIDE            BINARY-LONG.
       10 SG-CLIP-LEN        BINARY-LONG.
       10 SG-CLIP            PIC X(64).
       10 SG-ROW OCCURS 4 TIMES.
          15 SG-LEN          BINARY-LONG.
          15 SG-LINE-TEXT    PIC X(64).
*>     The block editors (40-9): the command block screen's target, mode (0 sequence, 1 auto, 2 redstone), conditional, automatic and track flags, and the command; the jigsaw and structure packet
*>     sources (the screens for those are not drawn yet).
*>     The form screens (test block and jigsaw editors of 40-9): the form (1 test block, 2 jigsaw), the focused box, the box texts, the test block mode (0 to 3), the jigsaw keep flag,
*>     the levels of the slider and whether the jigsaw's front is vertical (the joint cycle shows).
       10 EF-FOCUS           BINARY-LONG.
       10 EF-TEXT            PIC X(256) OCCURS 12 TIMES.
       10 EF-LEN             BINARY-LONG OCCURS 12 TIMES.
       10 EB-FORM            BINARY-LONG.
       10 EB-MC              BINARY-LONG.    *> 1 when the command screen edits a command block minecart (entity id EB-MC-ENTITY)
       10 EB-MC-ENTITY       BINARY-LONG.
       10 EB-TB-MODE         BINARY-LONG.
       10 EB-JG-KEEP         BINARY-LONG.
       10 EB-LEVELS          BINARY-LONG.
       10 EB-VERTICAL        BINARY-LONG.
       10 EB-X               BINARY-LONG.
       10 EB-Y               BINARY-LONG.
       10 EB-Z               BINARY-LONG.
       10 EB-MODE            BINARY-LONG.
       10 EB-COND            BINARY-LONG.
       10 EB-AUTO            BINARY-LONG.
       10 EB-TRACK           BINARY-LONG.
       10 EB-CMD-LEN         BINARY-LONG.
       10 EB-CMD             PIC X(1024).
       10 EB-JG-TEXT         PIC X(256) OCCURS 4 TIMES.
       10 EB-JG-LEN          BINARY-LONG OCCURS 4 TIMES.
       10 EB-JG-JOINT        BINARY-LONG.
       10 EB-JG-SELECTION    BINARY-LONG.
       10 EB-JG-PLACEMENT    BINARY-LONG.
       10 EB-ST-UPDATE       BINARY-LONG.
       10 EB-ST-MODE         BINARY-LONG.
       10 EB-ST-NAME         PIC X(128).
       10 EB-ST-NAME-LEN     BINARY-LONG.
       10 EB-ST-META         PIC X(128).
       10 EB-ST-META-LEN     BINARY-LONG.
       10 EB-ST-OFFSET       BINARY-LONG OCCURS 3 TIMES.
       10 EB-ST-SIZE         BINARY-LONG OCCURS 3 TIMES.
       10 EB-ST-MIRROR       BINARY-LONG.
       10 EB-ST-ROTATION     BINARY-LONG.
       10 EB-ST-INTEGRITY    FLOAT-SHORT.
       10 EB-ST-SEED         BINARY-DOUBLE.
       10 EB-ST-FLAGS        BINARY-LONG.
       10 EB-TI-ROT          BINARY-LONG.    *> the test instance screen (40-x1 8): rotation id, include entities and the info text
       10 EB-TI-ENT          BINARY-LONG.
       10 EB-TI-INFO         PIC X(256).
       10 EB-TI-INFO-LEN     BINARY-LONG.
       10 EB-ST-INIT-MODE    BINARY-LONG.    *> the values at open that Cancel restores (40-x1 5.7)
       10 EB-ST-INIT-MIRROR  BINARY-LONG.
       10 EB-ST-INIT-ROT     BINARY-LONG.
       10 EB-ST-INIT-FLAGS   BINARY-LONG.
       10 MT-ENTITY          BINARY-LONG.
       10 MT-KIND            BINARY-LONG.
       10 MT-SADDLE          BINARY-LONG.
       10 MT-BODY            BINARY-LONG.
       10 MT-ICON            BINARY-LONG.
       10 AN-ID              BINARY-LONG.
       10 AN-ITEM            BINARY-LONG.
       10 AN-NAME-LENGTH     BINARY-LONG.
       10 AN-NAME            PIC X(256).
       10 AN-SENT-LENGTH     BINARY-LONG.
       10 AN-SENT-NULL       BINARY-LONG.
       10 AN-SENT            PIC X(256).
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
       10 PL-WAIT            PIC 9.          *> the wait for the level after Login or Respawn (docs/protocol/50 section 7): 1 while the camera section is awaited after Game Event 13, 2 once it is ready (Player Loaded follows after PL-CLOSE-DELAY), else 0
       10 PL-WAIT-START      BINARY-DOUBLE.  *> CL-NOW-MS of the Login or Respawn: the 30 s deadline counts from here
       10 PL-READY-AT        BINARY-DOUBLE.  *> CL-NOW-MS at which the wait ended
       10 PL-CLOSE-DELAY     BINARY-LONG.    *> ms between the end of the wait and Player Loaded: 500 for a newly created local world, else 0
       10 PL-POSITIONED      PIC 9.          *> 1 after the first Player Position
       10 PL-BATCHES         BINARY-LONG.    *> chunk batches finished
       10 PL-CENTER-CX       BINARY-LONG.    *> Set Chunk Cache Center
       10 PL-CENTER-CZ       BINARY-LONG.
*>     Health (US7; standin-content §10): the last Set Health (health, food) and the clock until
*>     which the hurt indication shows (Damage Event or Hurt Animation for the local player).
       10 PL-HEALTH          FLOAT-SHORT.
       10 PL-FOOD            BINARY-LONG.
       10 PL-SATURATION      FLOAT-SHORT.
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
*>     Fluids (29a section 8; client/src/physics-fluid.cob): the box touches water or lava, the eye is inside one, the fluid's
*>     height above the feet (0 none), and the horizontal speed in blocks per tick kept while in a fluid.
       10 PL-IN-WATER        PIC 9.
       10 PL-IN-LAVA         PIC 9.
       10 PL-EYE-WATER       PIC 9.
       10 PL-EYE-LAVA        PIC 9.
       10 PL-WATER-H         FLOAT-LONG.
       10 PL-LAVA-H          FLOAT-LONG.
       10 PL-VX              FLOAT-LONG.
       10 PL-VZ              FLOAT-LONG.
       10 PL-PUSH-X          FLOAT-LONG.    *> the current's push of this tick (29a section 8.3)
       10 PL-PUSH-Z          FLOAT-LONG.
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
       10 RG-BIOME-PRECIP    PIC 9 OCCURS 255 TIMES.   *> biome id + 1: has_precipitation
*>  ---- status effects and the heart-row state (client/src/effects.cob, hearts.cob; docs/protocol/49) ----
    05 EF-STATE.
       10 EF-COUNT           BINARY-LONG.    *> active effects of the local player
       10 EF-ENTRY OCCURS 40 TIMES.
          15 EF-ID           BINARY-LONG.    *> the effect's registry id
          15 EF-AMP          BINARY-LONG.
          15 EF-DUR          BINARY-LONG.    *> remaining ticks, -1 infinite
          15 EF-FLAGS        BINARY-LONG.    *> 0x01 ambient, 0x02 visible, 0x04 show icon, 0x08 blend
       10 HB-TICK            BINARY-LONG.    *> the HUD tick count
       10 HB-COOLDOWN        BINARY-LONG.    *> the local player's damage cooldown time
       10 HB-FLASH-ARMED     PIC 9.          *> 1 once a Set Health reached this local player
       10 HB-LAST-HEALTH     BINARY-LONG.
       10 HB-DISPLAY-HEALTH  BINARY-LONG.
       10 HB-BLINK-TIME      BINARY-LONG.
       10 HB-LAST-TIME       BINARY-DOUBLE.
       10 HB-BLINK           PIC 9.
       10 HB-RNG             BINARY-DOUBLE.  *> the random source of the frame (a 48-bit Java LCG state)
       10 PL-MAX-HEALTH      FLOAT-SHORT.    *> max_health attribute value
       10 PL-ARMOR           BINARY-LONG.    *> armor attribute value
       10 PL-ABSORPTION      FLOAT-SHORT.
       10 PL-AIR             BINARY-LONG.
       10 PL-MAX-AIR         BINARY-LONG.
       10 PL-EYES-WATER      PIC 9.
       10 PL-TICKS-FROZEN    BINARY-LONG.
       10 PL-HARDCORE        PIC 9.
       10 PL-VEHICLE         BINARY-LONG.    *> entity id of the vehicle ridden, -1 none
       10 PL-MOUNT-HEARTS    BINARY-LONG.
       10 PL-MOUNT-HEALTH    BINARY-LONG.
       10 LL-REASON          BINARY-LONG.    *> level-loading reason of the last Respawn: 0 none, 1 Nether portal, 2 End portal, 3 other (39 section 8.4)
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
       10 CT-BREAK-HELD      BINARY-LONG.    *> the held slot when the break began (a change aborts it)
       10 CT-BREAK-START     BINARY-DOUBLE.  *> clock of the start destroy
       10 CT-BREAK-MS        BINARY-LONG.    *> break time, -1 = never (unbreakable)
       10 CT-DONE            PIC 9.          *> 1 = the block below was finished while held
       10 CT-DONE-X          BINARY-LONG.
       10 CT-DONE-MS         BINARY-DOUBLE.  *> clock of that stop destroy (the 5-tick cooldown, 13 section 2.2)
       10 CT-DONE-Y          BINARY-LONG.
       10 CT-DONE-Z          BINARY-LONG.
       10 BD-ENTITY          BINARY-LONG.    *> the last Block Destruction (another player's break)
       10 BD-X               BINARY-LONG.
       10 BD-Y               BINARY-LONG.
       10 BD-Z               BINARY-LONG.
       10 BD-PROGRESS        BINARY-LONG.
*>     Block break progress by breaker (12 §4.2; break-overlay.cob): one entry per breaker entity id.
       10 BDS-COUNT          BINARY-LONG.
       10 BDS-ENTRY OCCURS 16 TIMES.
          15 BDS-ENTITY      BINARY-LONG.
          15 BDS-X           BINARY-LONG.
          15 BDS-Y           BINARY-LONG.
          15 BDS-Z           BINARY-LONG.
          15 BDS-STAGE       BINARY-LONG.    *> 0 to 9
          15 BDS-AT-MS       BINARY-DOUBLE.  *> clock of the last update (an entry expires after 20 s)
*>  ---- world replica (data-model §3 replica): one row per chunk ----
    05 WR-STATE.
       10 WR-COUNT           BINARY-LONG.    *> rows in use
       10 WR-BLOCK-BITS      BINARY-LONG.    *> bits of the global block state palette of chunk
                                             *> packets: 0 = derive (content set open: ceillog2 of
                                             *> its state count, else 5, the 001 form)
       10 WR-CHUNK OCCURS 1089 TIMES.
          15 WR-USED         PIC 9.
          15 WR-CX           BINARY-LONG.
          15 WR-CZ           BINARY-LONG.
          15 WR-ADDR         USAGE POINTER.  *> one CE-CHUNK (contract/copy/CELLS.cpy, CE-CHUNK-BYTES)
          15 WR-RELEASE      PIC 9.          *> 1 = forgotten: its mesh slots are to be freed
          15 WR-SURF-OK      PIC 9.          *> 1 = WR-SURF and WR-WTOP are current (SKY-STOPGAP-SURFACE, CC-0007 stopgap)
          15 WR-SURF         BINARY-SHORT UNSIGNED OCCURS 256 TIMES.   *> first open y (from min_y) of column z * 16 + x + 1
          15 WR-WTOP         BINARY-SHORT UNSIGNED OCCURS 256 TIMES.   *> one above the topmost fluid cell above WR-SURF, 0 = none
          15 WR-SECTION OCCURS 24 TIMES.
             20 WR-DIRTY     PIC 9.          *> 1 = to be meshed
             20 WR-OP-ADDR   USAGE POINTER.  *> opaque mesh vertices (44 bytes each)
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
*>        The registry key of EN-TYPE in a world of the standard set (EN-VANILLA 1; spaces when the id is outside the
*>        registry) and the row of CL-MODELS (CLMODELS.cpy) that draws it (0 = no model). In a cobolcraft world EN-TYPE is the
*>        stand-in type of standin-content §3 and EN-VANILLA is 0.
          15 EN-VANILLA      PIC 9.
          15 EN-KEY          PIC X(24).
          15 EN-MODEL        BINARY-LONG.
*>        Set Entity Data of the models: the value of an experience_orb (entry 8), the swell direction of a creeper (entry 16: -1 idle, 1
*>        fusing), the swell counter at the moment the direction last changed and that moment (CL-NOW-MS); the counter then runs 1 a tick.
          15 EN-VALUE        BINARY-LONG.
          15 EN-SWELL-DIR    BINARY-LONG.
          15 EN-SWELL-BASE   BINARY-LONG.
          15 EN-SWELL-MS     BINARY-DOUBLE.
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
       10 CS-ENTRY OCCURS 64 TIMES.
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
       10 CS-FROZEN          PIC 9.            *> 1 while Tab cycles: the list is kept as it was
       10 CS-SELECTED        BINARY-LONG.      *> the suggestion Tab last took (1 to CS-COUNT + CS-ANSWERS), 0 none
       10 CS-WORD-START      BINARY-LONG.      *> where the word being typed starts on the line (1-based)
*>  ---- the recipe book (13 section 3.9): the entries of Recipe Book Add, the settings, the panel's state ----
    05 RK-STATE.
       10 RK-COUNT           BINARY-LONG.
       10 RK-ENTRY OCCURS 2048 TIMES.
          15 RK-ID           BINARY-LONG.
          15 RK-TYPE         BINARY-LONG.    *> 0 shapeless, 1 shaped, 2 to 4 other books (kept, not listed)
          15 RK-CATEGORY     BINARY-LONG.    *> 46 section 9.3: 0 building, 1 redstone, 2 equipment, 3 misc for crafting
          15 RK-GROUP        BINARY-LONG.    *> 0 none, else group index + 1
          15 RK-WIDTH        BINARY-LONG.
          15 RK-HEIGHT       BINARY-LONG.
          15 RK-HIGHLIGHT    PIC 9.
          15 RK-REQ-COUNT    BINARY-LONG.    *> crafting requirements (one item each); 0 and RK-REQ-PRESENT 0 = never craftable
          15 RK-REQ-PRESENT  PIC 9.
          15 RK-REQ-ITEM     BINARY-LONG OCCURS 9 TIMES.
          15 RK-SLOTS        BINARY-LONG.    *> ingredient slots
          15 RK-SLOT-ITEM    BINARY-LONG OCCURS 9 TIMES. *> the item each slot shows, -1 none
          15 RK-RES-ITEM     BINARY-LONG.
          15 RK-RES-COUNT    BINARY-LONG.
          15 RK-CAN          PIC 9.          *> craftable now (RK-REFRESH)
          15 RK-HEAD         BINARY-LONG.    *> the first entry of its collection (same category and group)
          15 RK-MATCH        PIC 9.          *> 1 = the search text matches the result's name
          15 RK-NDISP        BINARY-LONG.    *> head only: members that fit the grid
          15 RK-NCAN         BINARY-LONG.    *> head only: members craftable now
          15 RK-NMATCH       BINARY-LONG.    *> head only: members matching the search
       10 RK-OPEN            PIC 9 OCCURS 4 TIMES.
       10 RK-FILTERING       PIC 9 OCCURS 4 TIMES.
       10 RK-TAB             BINARY-LONG.    *> 1 search, 2 equipment, 3 building, 4 misc, 5 redstone
       10 RK-PAGE            BINARY-LONG.
       10 RK-PAGES           BINARY-LONG.
       10 RK-SEARCH          PIC X(50).
       10 RK-SEARCH-LENGTH   BINARY-LONG.
       10 RK-SEARCH-FOCUS    PIC 9.
       10 RK-LAST-PLACED     BINARY-LONG.    *> display id of the last placed recipe, -1 none
       10 RK-DIRTY           PIC 9.          *> 1 = craftability to be recomputed
       10 RK-SDIRTY          PIC 9.          *> 1 = search matches to be recomputed
       10 RK-TABHAS          PIC 9 OCCURS 5 TIMES.
       10 RK-SIG             BINARY-LONG.    *> inventory signature of the last refresh
       10 RK-GRID            BINARY-LONG.    *> grid size of the last refresh (2 or 3)
       10 RK-CELL-COUNT      BINARY-LONG.
       10 RK-CELL OCCURS 20 TIMES.
          15 RK-CELL-ROW     BINARY-LONG.    *> the entry shown
          15 RK-CELL-MANY    BINARY-LONG.    *> displayable recipes in the collection
       10 RK-GHOST-CONTAINER BINARY-LONG.   *> -1 none
       10 RK-GHOST-W         BINARY-LONG.
       10 RK-GHOST-H         BINARY-LONG.
       10 RK-GHOST-TYPE      BINARY-LONG.
       10 RK-GHOST-SLOTS     BINARY-LONG.
       10 RK-GHOST-ITEM      BINARY-LONG OCCURS 9 TIMES.
       10 RK-TOAST-UNTIL     BINARY-DOUBLE.  *> CL-NOW-MS until which the toast shows, 0 none
       10 RK-GHEAD           BINARY-LONG OCCURS 4096 TIMES.
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
          15 PK-LEVEL        BINARY-LONG.    *> level of the stack: 1 built-in, 2 skin, 3 generated vanilla,
                                             *> 4 user packs, 5 server packs (faithful-pack-mapping 9.1)
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
*>     options.txt (options.cob; 13 §7): the options of the table CLOPTS.cpy by row, each in its stored form (OP-OPT-LEN 0 = the
*>     empty string); the confirmed incompatible pack ids as the file's JSON list text; the optional fullscreen video mode line.
       10 OP-OPT OCCURS 160 TIMES.
          15 OP-OPT-VALUE    PIC X(64).
          15 OP-OPT-LEN      BINARY-LONG.
       10 OP-PAGE            BINARY-LONG.     *> the options screen: the page shown, from 0
       10 OP-RETURN          BINARY-LONG.     *> the screen the options screen returns to
       10 OP-REBIND          BINARY-LONG.     *> the key option row waiting for a key (0 = none)
       10 OP-INCOMPAT        PIC X(512).
       10 OP-INCOMPAT-LEN    BINARY-LONG.
       10 OP-FULLSCREEN      PIC X(64).
       10 OP-FULLSCREEN-LEN  BINARY-LONG.
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
       10 AT-PAD             BINARY-LONG.    *> padding around each sprite's slot, pixels (12 section 2.2)
       10 AT-MIPS            BINARY-LONG.    *> mip levels of the atlas texture (levels below the first + 1)
       10 AT-SPRITE OCCURS 4096 TIMES.
          15 AT-NAME         PIC X(80).      *> sprite id, e.g. cobolcraft:block/greystone
          15 AT-NAME-LENGTH  BINARY-LONG.
          15 AT-X            BINARY-LONG.
          15 AT-Y            BINARY-LONG.
          15 AT-SW           BINARY-LONG.
          15 AT-SH           BINARY-LONG.
          15 AT-TRANSLUCENT  PIC 9.          *> 1 = some pixel has alpha below 255 (08 §5.3)
          15 AT-PACK         BINARY-LONG.    *> the pack that gave the image (0 = the missing texture)
          15 AT-ANIM         BINARY-LONG.    *> its row of AN-ANIM, 0 = not animated
*>     Animated sprites of the block atlas (packs/mcmeta.cob ANIM-PARSE, atlas.cob ANIM-TICK): the
*>     frames of each (a vertical strip kept whole), the sequence, the frame shown (AN-CUR: its picture
*>     and blend), and AN-OUT, the pixels last written into the atlas cell (AN-DIRTY 1 until submitted
*>     with cc_vk_texture_update).
       10 AN-COUNT            BINARY-LONG.
       10 AN-START-MS         BINARY-DOUBLE.  *> clock of the first ANIM-TICK (0 = none yet)
       10 AN-ANIM OCCURS 256 TIMES.
          15 AN-SPRITE       BINARY-LONG.
          15 AN-FRAME-W      BINARY-LONG.
          15 AN-FRAME-H      BINARY-LONG.
          15 AN-INTERPOLATE  PIC 9.
          15 AN-ENTRIES      BINARY-LONG.
          15 AN-TOTAL        BINARY-LONG.
          15 AN-CUR          BINARY-LONG.
          15 AN-DIRTY        PIC 9.
          15 AN-PIXELS       USAGE POINTER.
          15 AN-OUT          USAGE POINTER.
          15 AN-SEQ OCCURS 32 TIMES.
             20 AN-SEQ-INDEX BINARY-LONG.
             20 AN-SEQ-TIME  BINARY-LONG.
       10 UA-W               BINARY-LONG.
       10 UA-H               BINARY-LONG.
       10 UA-ADDR            USAGE POINTER.
       10 UA-ICON-Y          BINARY-LONG.    *> first row of the pack icon cells (16 x 16 each)
       10 UA-SPRITE-Y        BINARY-LONG.    *> first row of the GUI sprites (below the icon cells)
*>     GUI sprites of the UI atlas (gui-sprites.cob; 12 §5.9): GSP-* rows. GS-W 0 = the pack gives none
*>     (the swatch draws instead). GS-NINE 1 = a nine_slice .mcmeta: source size GS-LW x GS-LH, borders
*>     left, top, right, bottom.
       10 GS-TOTAL-H         BINARY-LONG.
       10 GS-MAX-W           BINARY-LONG.
       10 GS-ROW OCCURS 153 TIMES.
          15 GS-X            BINARY-LONG.
          15 GS-Y            BINARY-LONG.
          15 GS-W            BINARY-LONG.
          15 GS-H            BINARY-LONG.
          15 GS-NINE         PIC 9.
          15 GS-LW           BINARY-LONG.
          15 GS-LH           BINARY-LONG.
          15 GS-BL           BINARY-LONG.
          15 GS-BT           BINARY-LONG.
          15 GS-BR           BINARY-LONG.
          15 GS-BB           BINARY-LONG.
       10 AT-UPLOAD          PIC 9 OCCURS 5 TIMES.   *> texture id + 1 to be uploaded
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
*>     The images of the entity models (entities-models.cob), stacked below the stand-ins in the order the replica first
*>     showed them: slot k holds the CL-MODELS row EA-MT-MODEL and its image's rectangle.
       10 EA-MT-COUNT        BINARY-LONG.
       10 EA-MT OCCURS 16 TIMES.
          15 EA-MT-MODEL     BINARY-LONG.
          15 EA-MT-X         BINARY-LONG.
          15 EA-MT-Y         BINARY-LONG.
          15 EA-MT-W         BINARY-LONG.
          15 EA-MT-H         BINARY-LONG.
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
*>     Particle atlas (texture 4; particles-live.cob PARTICLE-ATLAS-BUILD): the sprites of the wired particle
*>     types stacked from the top, left-aligned. PRA-FIRST(t + 1) and PRA-COUNT(t + 1) are the first sprite and the
*>     number of sprites of particle type t (registry id, 42-1 section 2); PRA-S-Y, PRA-S-W and PRA-S-H the
*>     rectangle of a sprite (left 0).
       10 PRA-W              BINARY-LONG.
       10 PRA-H              BINARY-LONG.
       10 PRA-ADDR           USAGE POINTER.
       10 PRA-SPRITES        BINARY-LONG.
       10 PRA-TYPE OCCURS 128 TIMES.
          15 PRA-FIRST       BINARY-LONG.
          15 PRA-COUNT       BINARY-LONG.
       10 PRA-SPRITE OCCURS 256 TIMES.
          15 PRA-S-Y         BINARY-LONG.
          15 PRA-S-W         BINARY-LONG.
          15 PRA-S-H         BINARY-LONG.
*>     Item icons (08 §10.7, itemdefs.cob): for item id i, IT-SPRITE(i + 1) is the block-and-item
*>     atlas sprite of its icon (1 = the missing texture).
       10 IT-SPRITE          BINARY-LONG OCCURS 18 TIMES.
*>     The same for the items of a standard set, found on first use (ITEM-SPRITE-OF, models-lazy.cob): 0 = not looked up yet.
       10 IS-SPRITE          BINARY-LONG OCCURS 2048 TIMES.
*>     The faces of a block item's model (ITEM-FACE-SPRITE): IS-FACE-DONE(i + 1) = 1 when the item is a block model, and IS-FACE-SPRITE(i * 6 + d) is
*>     the sprite of face d (DIR-DOWN to DIR-EAST) of its first element, the up sprite where the model has no such face.
       10 IS-FACE-DONE       PIC 9 OCCURS 2048 TIMES.
       10 IS-FACE-SPRITE     BINARY-LONG OCCURS 12288 TIMES.
*>  ---- per-state tables (client/src/state-tables.cob): built once at load from the content set ----
    05 ST-STATE.
       10 ST-READY           PIC 9.          *> 1 = built (0 after CL-INIT; the mesher builds on demand)
       10 ST-COUNT           BINARY-LONG.    *> states known: the set's, else the stand-in table's
       10 ST-OPAQUE          PIC 9 OCCURS 65536 TIMES.        *> state id + 1: occludes faces, blocks light
       10 ST-BLOCK           BINARY-LONG OCCURS 65536 TIMES.  *> state id + 1: its block id
       10 ST-BLOCK-NAME      PIC X(32) OCCURS 2048 TIMES.     *> block id + 1: its name without namespace (the tint sources of 43 section 2.1 key on it); spaces when unknown
       10 ST-FLUID           PIC 9 OCCURS 65536 TIMES.        *> state id + 1: the fluid the cell holds (29a section 1.2): 0 none, 1 water, 2 lava (liquid blocks; always-wet blocks hold water)
       10 ST-LEVEL           PIC 99 OCCURS 65536 TIMES.       *> state id + 1: the liquid block's level 0 to 15 (0 source; 1 to 7 amount 8 - level; 8 and over falling)
       10 ST-OVERLAY         PIC 9 OCCURS 65536 TIMES.        *> state id + 1: 1 = beside water the side faces take the overlay sprite (29a 10.3: HalfTransparentBlock and leaves)
*>  ---- baked block models (08 §4, §5): quads per block state ----
    05 BM-STATE OCCURS 2048 TIMES.   *> rows 1 to 320: the stand-in states (row = state + 1); in a standard world every row is a state baked on first use (MODEL-SLOT-OF)
       10 BM-QUAD-COUNT      BINARY-LONG.
       10 BM-QUAD OCCURS 24 TIMES.
          15 BM-CULL         BINARY-LONG.    *> DIR-* after the Variant rotation, DIR-NONE
          15 BM-SHADE        BINARY-LONG.    *> DIR-* the face is shaded and lit as
          15 BM-SPRITE       BINARY-LONG.
          15 BM-TINT         BINARY-LONG.    *> tintindex of the face (08 5.5), -1 none
          15 BM-CORNER OCCURS 4 TIMES.       *> top-left, top-right, bottom-right, bottom-left
             20 BM-X         FLOAT-SHORT.    *> block units 0 to 1
             20 BM-Y         FLOAT-SHORT.
             20 BM-Z         FLOAT-SHORT.
             20 BM-U         FLOAT-SHORT.    *> sprite units 0 to 16
             20 BM-V         FLOAT-SHORT.
*>       What the mesher needs per quad without arithmetic on floats (computed by STATE-BAKE from the corners above
*>       and the atlas): per corner the position in sixteenths of a block (-1 when it is not a whole number of them,
*>       or outside 0 to 16) and the atlas texture coordinates.
       10 BM-FAST OCCURS 24 TIMES.
          15 BM-FCORNER OCCURS 4 TIMES.
             20 BM-IX       BINARY-LONG.
             20 BM-IY       BINARY-LONG.
             20 BM-IZ       BINARY-LONG.
             20 BM-AU       FLOAT-SHORT.
             20 BM-AV       FLOAT-SHORT.
*>  ---- lazily baked states of a standard world (client/src/models-lazy.cob) ----
    05 BM-LAZY.
       10 BM-MODE            PIC 9.          *> 0 = nothing baked, 1 = the stand-in table, 2 = the standard set (rows taken on demand)
       10 BM-NEXT            BINARY-LONG.    *> the next free row in mode 2
       10 BM-SLOT            BINARY-LONG OCCURS 65536 TIMES.   *> state id + 1: its row (0 = not baked yet)
*>  ---- sky (standin-content §4.8) ----
    05 SK-STATE.
       10 SK-U               BINARY-LONG.    *> daylight in thousandths
       10 SK-R               FLOAT-SHORT.    *> clear colour
       10 SK-G               FLOAT-SHORT.
       10 SK-B               FLOAT-SHORT.
*>  ---- mesh frame budget (client/src/mesher.cob MESH-DIRTY) ----
    05 MB-STATE.
       10 MB-BUDGET-US       BINARY-LONG.    *> microseconds of meshing per frame (CL-INIT: CL-MESH-BUDGET-US)
       10 MB-FAKE            BINARY-LONG.    *> 1 = the injected clock MB-FAKE-NOW (tests), 0 = the process clock
       10 MB-FAKE-NOW        BINARY-DOUBLE.  *> the injected clock, microseconds
       10 MB-FAKE-STEP       BINARY-LONG.    *> microseconds the injected clock advances per section meshed
       10 MB-MESHED          BINARY-LONG.    *> sections meshed by the last MESH-DIRTY
       10 MB-EMPTY           BINARY-LONG.    *> sections found all air (meshed at once, no vertices) since CL-INIT
       10 MB-LIGHT-OFF       PIC 9.          *> 1 = MF-AT reads states only (MESH-FLUID's first look at a cell: most draw nothing)
       10 MB-LAST-US         BINARY-DOUBLE.  *> microseconds the last MESH-DIRTY took
       10 MB-CREDIT-ON       PIC 9.          *> 1 = meshing is paid for from a credit that each frame refills (CL-RUN sets it; 0 in tests)
       10 MB-CREDIT          BINARY-DOUBLE.  *> microseconds of meshing the next frames may spend; below 0 the frame meshes nothing
*>  ---- render list (data-model §13): built each frame, submitted through cc_vk_* ----
    05 RL-STATE.
       10 RL-CLEAR OCCURS 4 TIMES FLOAT-SHORT.
       10 RL-FOG OCCURS 13 TIMES FLOAT-SHORT.    *> the fog of the frame (cc_vk_fog): r g b strength start end p00 p11 up-x up-y up-z render-distance-start end
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
       10 RL-EN-VERTEX OCCURS 49152 TIMES.
          15 RL-EN-X         FLOAT-SHORT.
          15 RL-EN-Y         FLOAT-SHORT.
          15 RL-EN-Z         FLOAT-SHORT.
          15 RL-EN-U         FLOAT-SHORT.
          15 RL-EN-V         FLOAT-SHORT.
          15 RL-EN-B         FLOAT-SHORT.
          15 RL-EN-A         FLOAT-SHORT.
          15 RL-EN-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-EN-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-EN-G         FLOAT-SHORT.
          15 RL-EN-BLUE      FLOAT-SHORT.
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
          15 RL-IC-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-IC-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-IC-G         FLOAT-SHORT.
          15 RL-IC-BLUE      FLOAT-SHORT.
       10 RL-UI-LAYER        PIC 9.
       10 RL-UT-COUNT        BINARY-LONG.
       10 RL-UT-UPLOADED     BINARY-LONG.
       10 RL-UT-VERTEX OCCURS 6144 TIMES.
          15 RL-UT-X         FLOAT-SHORT.
          15 RL-UT-Y         FLOAT-SHORT.
          15 RL-UT-Z         FLOAT-SHORT.
          15 RL-UT-U         FLOAT-SHORT.
          15 RL-UT-V         FLOAT-SHORT.
          15 RL-UT-B         FLOAT-SHORT.
          15 RL-UT-A         FLOAT-SHORT.
          15 RL-UT-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-UT-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-UT-G         FLOAT-SHORT.
          15 RL-UT-BLUE      FLOAT-SHORT.
       10 RL-HL-COUNT        BINARY-LONG.
       10 RL-HL-UPLOADED     BINARY-LONG.
       10 RL-HL-VERTEX OCCURS 1728 TIMES.
          15 RL-HL-X         FLOAT-SHORT.
          15 RL-HL-Y         FLOAT-SHORT.
          15 RL-HL-Z         FLOAT-SHORT.
          15 RL-HL-U         FLOAT-SHORT.
          15 RL-HL-V         FLOAT-SHORT.
          15 RL-HL-B         FLOAT-SHORT.
          15 RL-HL-A         FLOAT-SHORT.
          15 RL-HL-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-HL-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-HL-G         FLOAT-SHORT.
          15 RL-HL-BLUE      FLOAT-SHORT.
*>     The crack overlay of the frame (eye-relative, texture 0, alpha-blended; break-overlay.cob).
       10 RL-BO-COUNT        BINARY-LONG.
       10 RL-BO-UPLOADED     BINARY-LONG.
       10 RL-BO-VERTEX OCCURS 576 TIMES.
          15 RL-BO-X         FLOAT-SHORT.
          15 RL-BO-Y         FLOAT-SHORT.
          15 RL-BO-Z         FLOAT-SHORT.
          15 RL-BO-U         FLOAT-SHORT.
          15 RL-BO-V         FLOAT-SHORT.
          15 RL-BO-B         FLOAT-SHORT.
          15 RL-BO-A         FLOAT-SHORT.
          15 RL-BO-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-BO-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-BO-G         FLOAT-SHORT.
          15 RL-BO-BLUE      FLOAT-SHORT.
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
          15 RL-GI-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-GI-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-GI-G         FLOAT-SHORT.
          15 RL-GI-BLUE      FLOAT-SHORT.
*>     The hand (view space, texture 0; hand.cob).
       10 RL-HAND-COUNT      BINARY-LONG.
       10 RL-HAND-UPLOADED   BINARY-LONG.
       10 RL-HAND-VERTEX OCCURS 36 TIMES.
          15 RL-HAND-X       FLOAT-SHORT.
          15 RL-HAND-Y       FLOAT-SHORT.
          15 RL-HAND-Z       FLOAT-SHORT.
          15 RL-HAND-U       FLOAT-SHORT.
          15 RL-HAND-V       FLOAT-SHORT.
          15 RL-HAND-B       FLOAT-SHORT.
          15 RL-HAND-A         FLOAT-SHORT.
          15 RL-HAND-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-HAND-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-HAND-G         FLOAT-SHORT.
          15 RL-HAND-BLUE      FLOAT-SHORT.
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
          15 RL-WX-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-WX-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-WX-G         FLOAT-SHORT.
          15 RL-WX-BLUE      FLOAT-SHORT.
*>     The particle quads of the frame (eye-relative, texture 4, particles-live.cob PARTICLES-MESH): six vertices
*>     per particle, 2048 particles (PQ-MAX of CLPSTORE.cpy).
       10 RL-PT-COUNT        BINARY-LONG.
       10 RL-PT-UPLOADED     BINARY-LONG.
       10 RL-PT-VERTEX OCCURS 12288 TIMES.
          15 RL-PT-X         FLOAT-SHORT.
          15 RL-PT-Y         FLOAT-SHORT.
          15 RL-PT-Z         FLOAT-SHORT.
          15 RL-PT-U         FLOAT-SHORT.
          15 RL-PT-V         FLOAT-SHORT.
          15 RL-PT-B         FLOAT-SHORT.
          15 RL-PT-A         FLOAT-SHORT.
          15 RL-PT-SKY       FLOAT-SHORT.
          15 RL-PT-R         FLOAT-SHORT.
          15 RL-PT-G         FLOAT-SHORT.
          15 RL-PT-BLUE      FLOAT-SHORT.
       10 RL-UI-COUNT        BINARY-LONG.    *> UI vertices this frame
       10 RL-UI-DARK         FLOAT-SHORT.    *> brightness taken off the next UI quads (0 white; a coloured text's grey)
       10 RL-UI-TINT         BINARY-LONG.    *> RGB integer multiplied into the next UI quads (0 none): the loading screen's status colours and bar
       10 RL-UI-FADE         FLOAT-SHORT.    *> alpha taken off the next UI quads (0 opaque; a sprite widget's state)
       10 RL-UI-VERTEX OCCURS 24576 TIMES.
          15 RL-UI-X         FLOAT-SHORT.
          15 RL-UI-Y         FLOAT-SHORT.
          15 RL-UI-Z         FLOAT-SHORT.
          15 RL-UI-U         FLOAT-SHORT.
          15 RL-UI-V         FLOAT-SHORT.
          15 RL-UI-B         FLOAT-SHORT.
          15 RL-UI-A         FLOAT-SHORT.
          15 RL-UI-SKY       FLOAT-SHORT.   *> brightness term scaled by the daylight at draw time (0 = none)
          15 RL-UI-R         FLOAT-SHORT.   *> tint multiplier (1 = untinted)
          15 RL-UI-G         FLOAT-SHORT.
          15 RL-UI-BLUE      FLOAT-SHORT.


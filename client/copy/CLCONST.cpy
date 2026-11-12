*> Constants of the client program (data-model §13; contracts/shim-abi.md §9; client-surface.md).
*> Package-private: screen ids, widget kinds and actions of the screen model, the mesh slots, pipeline
*> and texture ids the client uses, face directions, and the block state table the renderer needs
*> (standin-content §1.1, §1.2: block key, properties of each state, opaque flag), transcribed.

*> Screens of the screen model (data-model §13).
 78 SCR-TITLE               VALUE 1.
 78 SCR-SERVER-LIST         VALUE 2.
 78 SCR-EDIT-SERVER         VALUE 3.
 78 SCR-CONNECTING          VALUE 4.
 78 SCR-WORLD               VALUE 5.
 78 SCR-INVENTORY           VALUE 6.
 78 SCR-BENCH               VALUE 19.  *> the crafting-bench menu (Open Screen menu type 12; screens/bench.cob)
 78 SCR-CHAT                VALUE 8.
 78 SCR-PAUSE               VALUE 9.
 78 SCR-DEATH               VALUE 10.
 78 SCR-PACKS               VALUE 11.
 78 SCR-PACK-CONFIRM        VALUE 12.
 78 SCR-WORLD-LIST          VALUE 13.
 78 SCR-CREATE-WORLD        VALUE 14.
 78 SCR-CONFIRM-DELETE      VALUE 15.
 78 SCR-OPEN-TO-OTHERS      VALUE 16.
 78 SCR-CONTAINER           VALUE 20.  *> a generic container menu (chests, hopper, dispenser, shulker box; screens/container.cob)
 78 SCR-OPTIONS             VALUE 18.  *> the options pages (US16; screens/options.cob)
 78 SCR-SIGN                VALUE 21.  *> the sign editor (Open Sign Editor 05a 0x3D; screens/signscreen.cob)
 78 SCR-BOOK                VALUE 22.  *> the writable book editor (screens/bookscreen.cob)
 78 SCR-CREATIVE            VALUE 23.
 78 SCR-CMDBLOCK            VALUE 24.
 78 SCR-FORM                VALUE 25.  *> the test block and jigsaw editors (screens/forms.cob)  *> the command block editor (screens/editblocks.cob)  *> the creative inventory (screens/creativescreen.cob)
 78 SCR-PACK-PROMPT         VALUE 17.  *> a server's pack offer (US18-6; screens/pack-prompt.cob)

*> Widget kinds.
 78 WK-LABEL                VALUE 1.
 78 WK-BUTTON               VALUE 2.
 78 WK-FIELD                VALUE 3.   *> text field
 78 WK-ENTRY                VALUE 4.   *> list entry (selectable)
 78 WK-SLOT                 VALUE 5.   *> item slot: argument the slot 0 to 35 (36 = the stack on
                                       *> the cursor), state 1 = the held hotbar slot, text the count
 78 WK-OVERLAY              VALUE 6.   *> a tint over its rectangle on the swatch its argument
                                       *> names (the hurt indication); never clicked
 78 WK-ICON                 VALUE 7.   *> a pack icon: argument the icon cell (1 to CL-MAX-ICONS)
                                       *> of the UI atlas (pack-select.cob); never clicked
 78 WK-SPRITE               VALUE 8.   *> a GUI sprite (GSP-* row in the argument) drawn 1:1 at x, y; never clicked
 78 WK-IMAGE                VALUE 11.  *> a clickable GUI sprite: the sprite row in SM-W-SPRITE, the action's argument in the argument
 78 WK-SHEET                VALUE 10.  *> a region of a 256 x 256 sheet (GSP-SHEET-* row in the argument), x, y on the
                                       *> screen, w x h the region size from the sheet's origin (state 1: origin (1, 1))
 78 WK-METER                VALUE 9.   *> hearts (argument 1) or food (argument 2): state the value in half icons,
                                       *> action the maximum in half icons; hearts grow right from x, y (the bottom
                                       *> row), food grows left (x the first icon), rows of 10 going up 10 pixels

*> Widget actions (what a click on the widget does).
 78 ACT-NONE                VALUE 0.
 78 ACT-MULTIPLAYER         VALUE 1.
 78 ACT-QUIT                VALUE 2.
 78 ACT-JOIN                VALUE 3.
 78 ACT-ADD                 VALUE 4.
 78 ACT-EDIT                VALUE 5.
 78 ACT-REMOVE              VALUE 6.
 78 ACT-BACK                VALUE 7.
 78 ACT-SELECT              VALUE 8.   *> list entry; the widget's argument is the entry index
 78 ACT-DONE                VALUE 9.
 78 ACT-CANCEL              VALUE 10.
 78 ACT-FIELD-NAME          VALUE 11.  *> focus the name field
 78 ACT-FIELD-ADDRESS       VALUE 12.  *> focus the address field
 78 ACT-RESUME              VALUE 13.
 78 ACT-DISCONNECT          VALUE 14.
 78 ACT-SLOT                VALUE 15.  *> inventory slot click; the widget's argument is the slot
 78 ACT-RESPAWN             VALUE 16.  *> death screen: Client Command PERFORM_RESPAWN
 78 ACT-SINGLE-PLAYER       VALUE 18.  *> the world list (title Single-player; Cancel of the
                                       *> create-world and confirm-delete screens)
 78 ACT-PLAY-WORLD          VALUE 19.  *> world list: open the selected world
 78 ACT-NEW-WORLD           VALUE 20.  *> world list: the create-world screen
 78 ACT-DELETE-WORLD        VALUE 21.  *> world list: the confirm-delete screen of the selected world
 78 ACT-CREATE-WORLD        VALUE 22.  *> create-world: create and open the world
 78 ACT-WORLD-MODE          VALUE 23.  *> create-world: switch survival / creative
 78 ACT-CONFIRM-DELETE      VALUE 24.  *> confirm-delete: delete the world for good
 78 ACT-QUIT-WORLD          VALUE 25.  *> pause menu: save and leave the hosted world
 78 ACT-OPEN-TO-OTHERS      VALUE 26.  *> pause menu: the open-to-others screen (US17)
 78 ACT-GUEST-MODE          VALUE 27.  *> open-to-others: switch the guest mode survival / creative
 78 ACT-GUEST-OPERATOR      VALUE 28.  *> open-to-others: switch whether guests may use operator
                                       *> commands
 78 ACT-OPEN-WORLD          VALUE 29.  *> open-to-others: open the world to others
 78 ACT-PAUSE               VALUE 30.  *> open-to-others Cancel: back to the pause menu
 78 ACT-PACKS               VALUE 31.  *> title: the pack selection screen (US18)
 78 ACT-PACK-ENABLE         VALUE 32.  *> pack screen: enable the selected pack (on top)
 78 ACT-PACK-DISABLE        VALUE 33.  *> pack screen: disable the selected pack
 78 ACT-PACK-UP             VALUE 34.  *> pack screen: move the selected pack one up
 78 ACT-PACK-DOWN           VALUE 35.  *> pack screen: move the selected pack one down
 78 ACT-PACK-CONFIRM        VALUE 36.  *> pack confirmation: enable the incompatible pack anyway
 78 ACT-PACK-ACCEPT         VALUE 37.  *> pack prompt: accept the server's packs
 78 ACT-PACK-DECLINE        VALUE 38.  *> pack prompt: decline the server's packs
 78 ACT-PACKS-DONE          VALUE 39.  *> pack screen: save the choice, reload, the title screen
 78 ACT-WORLD-TYPE          VALUE 40.   *> create-world: cycle standard / cobolcraft (Ctrl: debug)
 78 ACT-OPEN-PACK-FOLDER    VALUE 41.   *> pack screen: open resourcepacks/ with the opener (US4)
 78 ACT-OPTIONS             VALUE 42.   *> title, pause menu: the options screen
 78 ACT-OPTION              VALUE 43.   *> options: change the option of row (the argument)
 78 ACT-OPTIONS-PREV        VALUE 44.   *> options: the previous page
 78 ACT-OPTIONS-NEXT        VALUE 45.   *> options: the next page
 78 ACT-OPTIONS-DONE        VALUE 46.   *> options: back to the screen it was opened from
 78 ACT-RB-BOOK             VALUE 47.   *> the recipe book button: open or close the panel
 78 ACT-RB-TAB              VALUE 48.   *> recipe book tab; the argument is the tab 1 to 5
 78 ACT-RB-FILTER           VALUE 49.   *> recipe book: toggle showing craftable only
 78 ACT-RB-PAGE             VALUE 50.   *> recipe book: the argument 1 previous page, 2 next page
 78 ACT-RB-CELL             VALUE 51.   *> recipe book: place the recipe of the cell (argument 200 + cell 1 to 20)
 78 ACT-RB-SEARCH           VALUE 52.   *> recipe book: focus the search box
 78 ACT-BEACON-PRIMARY       VALUE 54.   *> beacon: the argument is the effect id + 1 (40-5 section 3.7)
 78 ACT-BEACON-SECONDARY     VALUE 55.   *> beacon: the argument is the effect id + 1 (0: the upgrade button, the current primary)
 78 ACT-BEACON-CONFIRM       VALUE 56.
 78 ACT-CLOSE-MENU           VALUE 57.   *> beacon cancel, lectern done: close the container
 78 ACT-TRADE-SELECT         VALUE 58.   *> merchant: the argument is the row 0 to 6
 78 ACT-SIGN-DONE            VALUE 59.   *> the sign editor's Done: close and send the lines
 78 ACT-BOOK-DONE            VALUE 60.   *> the book editor's Done
 78 ACT-BOOK-SIGN            VALUE 61.   *> the book editor's Sign button
 78 ACT-BOOK-PAGE            VALUE 62.   *> the book editor's page buttons: the argument 1 back, 2 forward
 78 ACT-BOOK-FINALIZE        VALUE 63.   *> Sign and Close
 78 ACT-BOOK-CANCEL          VALUE 64.   *> Cancel of the book signing
 78 ACT-CREATIVE-TAB         VALUE 65.   *> the creative screen: select the tab of the argument
 78 ACT-CREATIVE-GRID        VALUE 66.   *> a grid slot (argument 901 to 945)
 78 ACT-CREATIVE-HOTBAR      VALUE 67.   *> a hotbar slot (argument 0 to 8)
 78 ACT-CMD-MODE             VALUE 68.
 78 ACT-CMD-TYPE             VALUE 69.
 78 ACT-CMD-TRIGGER          VALUE 70.
 78 ACT-CMD-TRACK            VALUE 71.
 78 ACT-CMD-DONE             VALUE 72.
 78 ACT-EF-FOCUS             VALUE 73.   *> focus the box of the argument
 78 ACT-EF-MODE              VALUE 74.   *> the test block mode cycle, the jigsaw joint cycle
 78 ACT-EF-KEEP              VALUE 75.
 78 ACT-EF-LEVELS            VALUE 76.
 78 ACT-EF-DONE              VALUE 77.
 78 ACT-EF-GENERATE          VALUE 78.
 78 ACT-ST-MODE              VALUE 79.
 78 ACT-ST-INCLUDE           VALUE 80.
 78 ACT-ST-STRICT            VALUE 81.
 78 ACT-ST-SHOWAIR           VALUE 82.
 78 ACT-ST-SHOWBB            VALUE 83.
 78 ACT-ST-MIRROR            VALUE 84.
 78 ACT-ST-ROT               VALUE 85.
 78 ACT-ST-SAVE              VALUE 86.
 78 ACT-ST-LOAD              VALUE 87.
 78 ACT-ST-DETECT            VALUE 88.
 78 ACT-ST-CANCEL            VALUE 89.
 78 ACT-TI-ROT               VALUE 90.
 78 ACT-TI-ENT               VALUE 91.
 78 ACT-TI-RESET             VALUE 92.
 78 ACT-TI-SAVE              VALUE 93.
 78 ACT-TI-RUN               VALUE 94.
 78 ACT-TI-DONE              VALUE 95.
 78 ACT-MENU-BUTTON          VALUE 53.   *> a menu's button: Container Button Click of the argument (enchanting rows)

*> Server pack steps (RP-STEP; packs/download.cob, 08 §9.1).
 78 RPS-PROMPT              VALUE 1.   *> waiting for the prompt's answer
 78 RPS-DOWNLOAD            VALUE 2.   *> accepted: to be fetched (RP-HTTP while fetching)
 78 RPS-READY               VALUE 3.   *> downloaded: applied once no pack is fetched any more
 78 RPS-ACTIVE              VALUE 4.   *> on the stack

*> Connections: the game connection and the server-list status ping.
 78 CONN-GAME               VALUE 1.
 78 CONN-PING               VALUE 2.
*> Connection phases.
 78 PH-NONE                 VALUE 0.
 78 PH-CONNECTING           VALUE 1.
 78 PH-STATUS               VALUE 2.
 78 PH-LOGIN                VALUE 3.
 78 PH-CONFIG               VALUE 4.
 78 PH-PLAY                 VALUE 5.

*> Server-list entry status.
 78 SLS-NONE                VALUE 0.   *> not asked yet
 78 SLS-PINGING             VALUE 1.
 78 SLS-ANSWERED            VALUE 2.
 78 SLS-UNREACHABLE         VALUE 3.

*> Mesh slots (cc_vk_mesh 1 to 65535): slot 1 is the user interface; each section of each replica
*> chunk row has an opaque and a translucent slot (MESH-SLOT-BASE + ((row - 1) * 24 + section) * 2,
*> + 1 for the translucent one; 24 = CL-MAX-SECTIONS, 1089 rows end below MESH-SLOT-ENTITIES).
 78 MESH-SLOT-UI            VALUE 1.
 78 MESH-SLOT-BASE          VALUE 2.
*> The entity figures of the frame (one mesh, eye-relative): above every section slot.
 78 MESH-SLOT-ENTITIES      VALUE 65000.
*> The item icons of the frame's slot widgets (texture 0), the slot counts drawn over them (texture 2)
*> and the target highlight outline (eye-relative, texture 2).
 78 MESH-SLOT-ICONS         VALUE 65001.
 78 MESH-SLOT-UI-TOP        VALUE 65002.
 78 MESH-SLOT-HIGHLIGHT     VALUE 65003.
*> The ground items of the frame (one mesh of item-icon billboards, eye-relative, texture 0).
 78 MESH-SLOT-GROUND-ITEMS  VALUE 65004.
*> The weather quads of the frame (one mesh, eye-relative, texture 3).
 78 MESH-SLOT-WEATHER       VALUE 65005.
*> The crack overlay of the frame (one mesh, eye-relative, texture 0).
 78 MESH-SLOT-BREAK         VALUE 65006.
*> The hand in first person (one mesh, view space, texture 0; hand.cob), drawn after a depth clear.
 78 MESH-SLOT-HAND          VALUE 65007.
*> The particle quads of the frame (one mesh, eye-relative, texture 4).
 78 MESH-SLOT-PARTICLES     VALUE 65008.
 78 CL-SWING-MS             VALUE 300.  *> the hand's swing, milliseconds

*> Weather kinds (standin-content §14.1), from the Game Event pair (rain level, thunder level).
 78 WX-CLEAR                VALUE 0.
 78 WX-DRIZZLE              VALUE 1.
 78 WX-HAILSTORM            VALUE 2.

*> Face directions (08 §5.4 names, block model axes of 08 §5.4.1: +x east, +y up, +z south).
 78 DIR-NONE                VALUE 0.
 78 DIR-DOWN                VALUE 1.
 78 DIR-UP                  VALUE 2.
 78 DIR-NORTH               VALUE 3.
 78 DIR-SOUTH               VALUE 4.
 78 DIR-WEST                VALUE 5.
 78 DIR-EAST                VALUE 6.

*> Limits of the client state (CLSTATE.cpy).
*> The lectern's page keys (GLFW codes; 40-5 section 4.7 leaves the key-code space open, Open question 6).
 78 CL-KEY-PAGE-UP         VALUE 266.
 78 CL-KEY-PAGE-DOWN       VALUE 267.
 78 CL-MAX-SERVERS          VALUE 32.
 78 CL-MAX-WORLDS           VALUE 32.
 78 CL-MAX-GUESTS           VALUE 8.   *> guest connections of a world opened to others (US17)
 78 CL-MAX-ADDRESSES        VALUE 8.   *> local addresses shown on the open-to-others screen
 78 CL-GUEST-OUT            VALUE 65536.   *> each guest's outbound buffer, bytes
 78 CL-MAX-WIDGETS          VALUE 512.
 78 CL-MAX-CHUNKS           VALUE 1089.
 78 CL-MAX-SECTIONS         VALUE 24.   *> CE-MAX-SECTIONS: the tallest dimension (384 / 16)
 78 CL-MAX-LANG             VALUE 640.
 78 CL-MAX-SPRITES          VALUE 4096. *> block and item atlas sprites (Faithful alone has 1,297 block sprites)
 78 CL-MAX-STATES           VALUE 65536. *> state ids are 16 bits (CE-STATE, contract/copy/CELLS.cpy)
 78 CL-STAND-STATES         VALUE 18.   *> states of the stand-in table below
 78 CL-MAX-BAKED            VALUE 320.  *> states with baked models (BM-STATE)
 78 CL-MAX-ROWS             VALUE 2048. *> rows of BM-STATE
 78 CL-MAX-QUADS            VALUE 24.
 78 CL-MAX-DRAWS            VALUE 8192.
 78 CL-MAX-UPLOADS          VALUE 4096.
*> Uploads and draws every frame may list after the section meshes: entities, ground items, weather,
*> highlight, UI, icons and UI text (RENDER-LIST-BUILD keeps this many entries of each list free).
 78 CL-UPLOAD-RESERVE       VALUE 7.
 78 CL-DRAW-RESERVE         VALUE 7.
 78 CL-MAX-DIM-TYPES        VALUE 8.
 78 CL-MAX-LEVELS           VALUE 8.
 78 CL-MAX-NODES            VALUE 160.
 78 CL-MAX-LINKS            VALUE 160.
 78 CL-MAX-SUGGEST          VALUE 10.   *> suggestion lines shown
 78 CL-MAX-COMMANDS         VALUE 64.   *> command suggestions kept (sorted, then the first CL-MAX-SUGGEST shown)
 78 CL-MAX-PACKS            VALUE 16.
 78 CL-MAX-LOCAL-PACKS      VALUE 32.  *> packs listed from resourcepacks/ (US18-1)
 78 CL-MAX-SERVER-PACKS     VALUE 8.   *> server-pushed packs of one connection (08 §9)
 78 CL-MAX-ICONS            VALUE 16.  *> pack icon cells of the UI atlas (16 x 16 each)
 78 CL-MAX-PACK-ERRORS      VALUE 8.   *> pack errors kept from the last reload (US18-5)
 78 CL-MAX-PACK-FILES       VALUE 16384. *> files of one local, generated or server pack (vanilla has 11,605)
 78 CL-PACK-SIZE-LIMIT      VALUE 262144000.  *> server pack download limit (08 §9.3)
 78 CL-MAX-UI-VERTICES      VALUE 24576.
 78 CL-MAX-ENTITIES         VALUE 256.
 78 CL-MAX-PLAYER-INFO      VALUE 64.
 78 CL-MAX-ENTITY-VERTICES  VALUE 9216.
 78 CL-MAX-GI-VERTICES      VALUE 1536.
 78 CL-MAX-BIOMES           VALUE 255.  *> biome ids are one byte; 255 is none known
*> Weather quads (standin-content §14.5): 17 x 17 columns of two quads.
 78 CL-MAX-WX-VERTICES      VALUE 3468.
 78 CL-PROTOCOL             VALUE 777.
 78 CL-DEFAULT-PORT         VALUE 25565.
 78 CL-MAX-GUI-SCALE        VALUE 8.    *> the GUI scale is 1 to this (CL-GUI-SCALE of CLSTATE.cpy)
 78 CL-MIN-GUI-W            VALUE 320.  *> the smallest GUI, GUI pixels: the minimum window at scale 1
 78 CL-MIN-GUI-H            VALUE 240.
 78 CL-TICK-MS              VALUE 50.
 78 CL-MAX-PUMP-TICKS       VALUE 3.    *> core ticks SP-PUMP runs in one frame
 78 CL-PUMP-DEBT-MS         VALUE 250.  *> owed time SP-PUMP keeps after those ticks; more is dropped
 78 CL-MESH-BUDGET-US       VALUE 8000. *> microseconds of meshing per frame (MESH-DIRTY)
 78 CL-TINT-RADIUS          VALUE 2.    *> biome blend radius (43 section 4: the biomeBlendRadius default)
 78 CL-MAX-ICON-VERTICES    VALUE 1536.
 78 CL-MAX-TOP-VERTICES     VALUE 6144.
 78 CL-MAX-HL-VERTICES      VALUE 144.
 78 CL-ITEM-COUNT           VALUE 18.  *> item ids 0 to 17 (standin-content §2)
 78 CL-SLOT-SIZE            VALUE 20.  *> slot widget, GUI pixels (16-pixel icon, 2-pixel inset)
*> Chat (client-surface §4; 05c Chat Message String(max 256)): messages kept, messages shown, how
*> long a message shows while chat is closed, the longest line in UTF-16 code units.
 78 CL-MAX-CHAT             VALUE 100.
 78 CL-CHAT-SHOWN           VALUE 10.
 78 CL-CHAT-MS              VALUE 10000.
 78 CL-CHAT-UNITS           VALUE 256.
*> Block reach of the target ray, in blocks from the eye (standin-content §11.4).
 78 CL-REACH                VALUE 5.
*> Health (standin-content §10.1 maximum health; §10.4 attack reach in blocks from the eye) and how
*> long the hurt indication shows, in milliseconds (a client choice).
 78 CL-MAX-HEALTH           VALUE 20.
 78 CL-ATTACK-REACH         VALUE 4.
 78 CL-HURT-MS              VALUE 500.
*> Hunger (standin-content §11.1 maximum food; §11.6 eating time, 30 ticks, in milliseconds).
 78 CL-MAX-FOOD             VALUE 20.
*> A survival Player sprints only with food above 6 (17 section 4.9).
 78 CL-SPRINT-FOOD          VALUE 6.
 78 CL-EAT-MS               VALUE 1500.

*> Entity types (standin-content §3).
 78 ET-OPERATOR             VALUE 0.
 78 ET-LOOSE-ITEM           VALUE 1.
 78 ET-SODGRAZER            VALUE 2.
 78 ET-ABEND                VALUE 3.

*> Entity types (standin-content §3), for type t row t + 1: 1 = a player or mob (attacked by the
*> left button, §10.4), the collision box's half width and its height in blocks.
 01 CL-ENTITY-DATA.
    05 FILLER PIC X(8) VALUE "10350175".
    05 FILLER PIC X(8) VALUE "00150030".
    05 FILLER PIC X(8) VALUE "10450090".
    05 FILLER PIC X(8) VALUE "10375075".
*>   Types 4 to 28 (the registry ids of the standard set, 21 section 2) have no box here; type 29, the command block minecart (0.98 x 0.7), can be aimed at and used (40-9 2.1).
    05 FILLER PIC X(200) VALUE ALL "0".
    05 FILLER PIC X(8) VALUE "10490070".
 01 CL-ENTITIES REDEFINES CL-ENTITY-DATA.
    05 CL-ET OCCURS 30 TIMES.
       10 CL-ET-ATTACK      PIC 9.
       10 CL-ET-HALF        PIC 9V999.
       10 CL-ET-HEIGHT      PIC 9V99.

*> Key bindings (13 §7.3): the index of a mapping in KB-CODE; KB-NAMES (OPTIONS-APPLY) names them in this order.
 78 KB-FORWARD              VALUE 1.
 78 KB-LEFT                 VALUE 2.
 78 KB-BACK                 VALUE 3.
 78 KB-RIGHT                VALUE 4.
 78 KB-JUMP                 VALUE 5.
 78 KB-SNEAK                VALUE 6.
 78 KB-SPRINT               VALUE 7.
 78 KB-INVENTORY            VALUE 8.
 78 KB-SWAP-OFFHAND         VALUE 9.
 78 KB-DROP                 VALUE 10.
 78 KB-HOTBAR-1             VALUE 11.   *> to KB-HOTBAR-1 + 8
 78 KB-CHAT                 VALUE 20.
 78 KB-COMMAND              VALUE 21.
 78 KB-PERSPECTIVE          VALUE 22.
 78 KB-SAVE-TOOLBAR         VALUE 23.
 78 KB-LOAD-TOOLBAR         VALUE 24.
 78 KB-COUNT                VALUE 24.

*> GUI sprites of the UI atlas (GS-ROW rows).
 78 GSP-BUTTON              VALUE 1.
 78 GSP-SLOT                VALUE 2.
 78 GSP-HOTBAR              VALUE 3.
 78 GSP-HOTBAR-SELECTION    VALUE 4.
 78 GSP-OFFHAND-LEFT        VALUE 5.
 78 GSP-CROSSHAIR           VALUE 6.
 78 GSP-HEART-CONTAINER     VALUE 7.
 78 GSP-HEART-FULL          VALUE 8.
 78 GSP-HEART-HALF          VALUE 9.
 78 GSP-FOOD-EMPTY          VALUE 10.
 78 GSP-FOOD-FULL           VALUE 11.
 78 GSP-FOOD-HALF           VALUE 12.
 78 GSP-SHEET-INVENTORY     VALUE 13.   *> textures/gui/container/inventory.png (256 x 256 sheet, 4.11)
 78 GSP-SHEET-BENCH         VALUE 14.   *> textures/gui/container/crafting_table.png
 78 GSP-SHEET-BOOK          VALUE 15.   *> textures/gui/recipe_book.png
 78 GSP-RB-BUTTON           VALUE 16.   *> recipe_book/button
 78 GSP-RB-TAB              VALUE 17.
 78 GSP-RB-TAB-SEL          VALUE 18.
 78 GSP-RB-FILTER-ON        VALUE 19.
 78 GSP-RB-FILTER-OFF       VALUE 20.
 78 GSP-RB-FORWARD          VALUE 21.
 78 GSP-RB-BACKWARD         VALUE 22.
 78 GSP-RB-SLOT             VALUE 23.   *> slot_craftable
 78 GSP-RB-SLOT-NO          VALUE 24.   *> slot_uncraftable
 78 GSP-TOAST               VALUE 25.   *> toast/recipe
 78 EF-TABLE-COUNT         VALUE 40.   *> status effects (CLEFFECT.cpy)
 78 GSP-MOB-EFFECT-0        VALUE 26.   *> mob_effect/<key> of effect id n at GSP-MOB-EFFECT-0 + n (EF-TABLE-COUNT rows, 49 section 1)
 78 GSP-EFFECT-BG            VALUE 66.   *> hud/effect_background and the ambient one (49 section 2.5)
 78 GSP-EFFECT-BG-AMBIENT    VALUE 67.
 78 GSP-INV-EFFECT-BG        VALUE 68.   *> container/inventory/effect_background and the ambient one (49 section 3.2)
 78 GSP-INV-EFFECT-BG-AMBIENT VALUE 69.
 78 GSP-ARMOR-EMPTY          VALUE 70.   *> hud/armor_empty, armor_half, armor_full (49 section 5.3)
 78 GSP-ARMOR-HALF           VALUE 71.
 78 GSP-ARMOR-FULL           VALUE 72.
 78 GSP-AIR                  VALUE 73.   *> hud/air, air_empty, air_bursting (49 section 5.5)
 78 GSP-AIR-EMPTY            VALUE 74.
 78 GSP-AIR-BURSTING         VALUE 75.
 78 GSP-VEHICLE-CONTAINER    VALUE 76.   *> hud/heart/vehicle_container, vehicle_full, vehicle_half (49 section 5.6)
 78 GSP-VEHICLE-FULL         VALUE 77.
 78 GSP-VEHICLE-HALF         VALUE 78.
 78 GSP-HEART-CONTAINER-BLINK VALUE 79.  *> hud/heart/container_blinking, container_hardcore, container_hardcore_blinking
 78 GSP-HEART-CONTAINER-HARDCORE VALUE 80.
 78 GSP-HEART-CONTAINER-HARDCORE-BLINK VALUE 81.
 78 GSP-HEART-VARIANT-0      VALUE 82.   *> the 40 heart sprites: row + ((type x 2 + hardcore) x 2 + half) x 2 + blinking, type 0 normal,
                                        *> 1 poisoned, 2 withered, 3 frozen, 4 absorbing (49 section 5.2)
 78 GSP-FOOD-EMPTY-HUNGER    VALUE 122.  *> hud/food_empty_hunger, food_half_hunger, food_full_hunger (49 section 5.4)
 78 GSP-FOOD-HALF-HUNGER     VALUE 123.
 78 GSP-FOOD-FULL-HUNGER     VALUE 124.
 78 GSP-HIGHLIGHT-BACK      VALUE 125.  *> container/slot_highlight_back and _front, 24 x 24 (40-1 section 5.4)
 78 GSP-HIGHLIGHT-FRONT     VALUE 126.
 78 GSP-TOOLTIP-BACK        VALUE 127.  *> tooltip/background and tooltip/frame, nine-slice (12 section 5.8)
 78 GSP-TOOLTIP-FRAME       VALUE 128.
 78 GSP-CSLOT-0             VALUE 129.  *> container/slot/<name> of the 20 hint icons of the smithing table (40-3 5.6): armor_trim, netherite_upgrade templates, helmet, chestplate, leggings, boots, ingot, redstone_dust, lapis_lazuli, quartz, diamond, emerald, amethyst_shard, sword, pickaxe, axe, hoe, shovel, nautilus_armor, spear
 78 GSP-CSLOT-SHIELD        VALUE 149.  *> container/slot/shield (the empty off-hand slot)
 78 GSP-FURNACE-LIT          VALUE 150.  *> container/furnace/lit_progress and burn_progress
 78 GSP-FURNACE-BURN         VALUE 151.
 78 GSP-COUNT               VALUE 151.
 78 CL-FREEZE-TICKS         VALUE 140.  *> ticks frozen of a fully frozen player (49 open question 7: the threshold was not read; 140 assumed)
 78 CL-RK-MAX               VALUE 2048. *> recipes the book keeps (the rest are dropped)


*> UI atlas (texture 2) swatches: 8 x 8 cells below the font image, by index from 0 (x = index * 8).
 78 SW-WHITE                VALUE 0.
 78 SW-MISSING-GLYPH        VALUE 1.
 78 SW-PANEL                VALUE 2.
 78 SW-BUTTON               VALUE 3.
 78 SW-SELECTED             VALUE 4.
 78 SW-FIELD                VALUE 5.
 78 SW-HURT                 VALUE 6.
 78 SW-BLACK                VALUE 7.
 78 SW-BAR-0                VALUE 8.   *> 24 swatches SW-BAR-0 to SW-BAR-0 + 23: the durability bar colours, red to green
 78 SW-COUNT                VALUE 32.

*> Items (standin-content §2): for item id i, row i + 1: key path (the item definition file name,
*> 08 §10.7), maximum stack size, the block state its item places (0 = places no block; cardstack
*> places its default state's block with the axis of the clicked face, §1.3), and the tool class
*> it speeds up ("H" hard, "S" soft, §2 pry_bar and trowel), and its food value (§11.5; 0 = not
*> food).
 01 CL-ITEM-DATA.
    05 FILLER PIC X(22) VALUE "nothing         0000 0".
    05 FILLER PIC X(22) VALUE "baseplate       6401 0".
    05 FILLER PIC X(22) VALUE "greystone       6402 0".
    05 FILLER PIC X(22) VALUE "loam            6403 0".
    05 FILLER PIC X(22) VALUE "turf            6404 0".
    05 FILLER PIC X(22) VALUE "grit            6405 0".
    05 FILLER PIC X(22) VALUE "cardstack       6409 0".
    05 FILLER PIC X(22) VALUE "lucite          6412 0".
    05 FILLER PIC X(22) VALUE "glowtube        6413 0".
    05 FILLER PIC X(22) VALUE "ledger_tile     6415 0".
    05 FILLER PIC X(22) VALUE "pry_bar         0100H0".
    05 FILLER PIC X(22) VALUE "trowel          0100S0".
    05 FILLER PIC X(22) VALUE "grazer_flank    3200 3".
    05 FILLER PIC X(22) VALUE "seared_flank    3200 8".
    05 FILLER PIC X(22) VALUE "sod_cake        1600 2".
    05 FILLER PIC X(22) VALUE "dump_shard      6400 0".
    05 FILLER PIC X(22) VALUE "goto_pad        1616 0".
    05 FILLER PIC X(22) VALUE "slag            6417 0".
 01 CL-ITEMS REDEFINES CL-ITEM-DATA.
    05 CL-IT OCCURS 18 TIMES.
       10 CL-IT-KEY         PIC X(16).
       10 CL-IT-MAX         PIC 99.
       10 CL-IT-STATE       PIC 99.
       10 CL-IT-TOOL        PIC X.
       10 CL-IT-FOOD        PIC 9.

*> Blocks (standin-content §1.1, §2): for block id b, row b + 1: hand break time in milliseconds
*> (99999 = unbreakable, baseplate) and its class ("H" hard, "S" soft, space none).
 01 CL-BLOCK-DATA.
    05 FILLER PIC X(6) VALUE "00000 ".
    05 FILLER PIC X(6) VALUE "99999 ".
    05 FILLER PIC X(6) VALUE "01500H".
    05 FILLER PIC X(6) VALUE "00600S".
    05 FILLER PIC X(6) VALUE "00700S".
    05 FILLER PIC X(6) VALUE "00500S".
    05 FILLER PIC X(6) VALUE "01000H".
    05 FILLER PIC X(6) VALUE "00400 ".
    05 FILLER PIC X(6) VALUE "00300 ".
    05 FILLER PIC X(6) VALUE "01200H".
    05 FILLER PIC X(6) VALUE "02000 ".
    05 FILLER PIC X(6) VALUE "01200H".
 01 CL-BLOCKS REDEFINES CL-BLOCK-DATA.
    05 CL-BK OCCURS 12 TIMES.
       10 CL-BK-BREAK-MS    PIC 9(5).
       10 CL-BK-CLASS       PIC X.

*> Block states (standin-content §1.2): for state id s, row s + 1: block key path (the block state
*> file name, 08 §10.6), the state's properties as a variant key (sorted by name, 08 §4.2), and
*> whether the block is opaque (§1.1: occludes faces, blocks light). Block id: §1.1.
 01 CL-BLOCK-STATE-DATA.
    05 FILLER PIC X(64) VALUE "00void".
    05 FILLER PIC X(64) VALUE "11baseplate".
    05 FILLER PIC X(64) VALUE "21greystone".
    05 FILLER PIC X(64) VALUE "31loam".
    05 FILLER PIC X(64) VALUE "41turf".
    05 FILLER PIC X(64) VALUE "51grit".
    05 FILLER PIC X(64) VALUE "61cardstack axis=x,punched=true".
    05 FILLER PIC X(64) VALUE "61cardstack axis=x,punched=false".
    05 FILLER PIC X(64) VALUE "61cardstack axis=y,punched=true".
    05 FILLER PIC X(64) VALUE "61cardstack axis=y,punched=false".
    05 FILLER PIC X(64) VALUE "61cardstack axis=z,punched=true".
    05 FILLER PIC X(64) VALUE "61cardstack axis=z,punched=false".
    05 FILLER PIC X(64) VALUE "70lucite".
    05 FILLER PIC X(64) VALUE "81glowtube lit=true".
    05 FILLER PIC X(64) VALUE "81glowtube lit=false".
    05 FILLER PIC X(64) VALUE "91ledger_tile".
    05 FILLER PIC X(64) VALUE "A1goto_pad".
    05 FILLER PIC X(64) VALUE "B1slag".
 01 CL-BLOCK-STATES REDEFINES CL-BLOCK-STATE-DATA.
    05 CL-BS OCCURS 18 TIMES.
       10 CL-BS-BLOCK       PIC X.       *> block id in hex (0 to B)
       10 CL-BS-OPAQUE      PIC 9.
       10 CL-BS-TEXT        PIC X(62).   *> "<block path>[ <variant key>]"

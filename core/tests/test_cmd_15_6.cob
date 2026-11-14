*> Acceptance test of docs/protocol/15-commands-framework.md §6 Argument types: the parse of the enumerations (§6.2), uuid (§6.3),
*> the scoreboard types (§6.4), item slots (§6.6), resource locations and registry types (§6.7), function (§6.8), ranges (§6.9)
*> and time (§6.10), and the value each leaves in the trail. Generated from a case table: the tree has one literal per type
*> (a type then its argument v); the result reads "ok v[start,end]" and the value ("i=" the integer value, "slot=" and "n=" for
*> slots, "min=" and "max=" for ranges, "-" an absent bound) or "err <key>|<args>@<cursor>".
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 01 WS-TYPES.
    05 FILLER PIC X(8) VALUE "gm".
    05 FILLER PIC S9(9) BINARY VALUE 42.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "an".
    05 FILLER PIC S9(9) BINARY VALUE 38.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "mi".
    05 FILLER PIC S9(9) BINARY VALUE 49.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "tr".
    05 FILLER PIC S9(9) BINARY VALUE 50.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "hm".
    05 FILLER PIC S9(9) BINARY VALUE 51.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "sw".
    05 FILLER PIC S9(9) BINARY VALUE 60.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "tc".
    05 FILLER PIC S9(9) BINARY VALUE 16.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "hx".
    05 FILLER PIC S9(9) BINARY VALUE 17.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "tm".
    05 FILLER PIC S9(9) BINARY VALUE 43.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "tn".
    05 FILLER PIC S9(9) BINARY VALUE 43.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 5.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "ir".
    05 FILLER PIC S9(9) BINARY VALUE 39.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "fr".
    05 FILLER PIC S9(9) BINARY VALUE 40.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "ob".
    05 FILLER PIC S9(9) BINARY VALUE 24.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "cr".
    05 FILLER PIC S9(9) BINARY VALUE 25.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "op".
    05 FILLER PIC S9(9) BINARY VALUE 26.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "sl".
    05 FILLER PIC S9(9) BINARY VALUE 30.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "te".
    05 FILLER PIC S9(9) BINARY VALUE 33.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "is".
    05 FILLER PIC S9(9) BINARY VALUE 34.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "iss".
    05 FILLER PIC S9(9) BINARY VALUE 35.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "rl".
    05 FILLER PIC S9(9) BINARY VALUE 36.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "fn".
    05 FILLER PIC S9(9) BINARY VALUE 37.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "di".
    05 FILLER PIC S9(9) BINARY VALUE 41.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "rs".
    05 FILLER PIC S9(9) BINARY VALUE 46.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:mob_effect".
    05 FILLER PIC X(8) VALUE "ro".
    05 FILLER PIC S9(9) BINARY VALUE 44.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:block".
    05 FILLER PIC X(8) VALUE "rk".
    05 FILLER PIC S9(9) BINARY VALUE 45.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:block".
    05 FILLER PIC X(8) VALUE "rg".
    05 FILLER PIC S9(9) BINARY VALUE 47.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:advancement".
    05 FILLER PIC X(8) VALUE "rp".
    05 FILLER PIC S9(9) BINARY VALUE 48.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:block".
    05 FILLER PIC X(8) VALUE "lt".
    05 FILLER PIC S9(9) BINARY VALUE 52.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "id".
    05 FILLER PIC S9(9) BINARY VALUE 61.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "ci".
    05 FILLER PIC S9(9) BINARY VALUE 56.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "cf".
    05 FILLER PIC S9(9) BINARY VALUE 55.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "fe".
    05 FILLER PIC S9(9) BINARY VALUE 59.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE OCCURS 32 TIMES.
       10 WS-T-LIT PIC X(8).
       10 WS-T-ID PIC S9(9) BINARY.
       10 WS-T-FLAGS PIC S9(9) BINARY.
       10 WS-T-HASMIN PIC S9(9) BINARY.
       10 WS-T-IMIN PIC S9(9) BINARY.
       10 WS-T-SK PIC S9(9) BINARY.
       10 WS-T-REG PIC X(40).
 01 WS-CASES.
    05 FILLER PIC X(300) VALUE "gm survival$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] i=0".
    05 FILLER PIC X(300) VALUE "gm creative$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] i=1".
    05 FILLER PIC X(300) VALUE "gm adventure$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] i=2".
    05 FILLER PIC X(300) VALUE "gm spectator$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] i=3".
    05 FILLER PIC X(300) VALUE "gm Survival$".
    05 FILLER PIC X(200) VALUE "err argument.gamemode.invalid|Survival@1" &
         "1".
    05 FILLER PIC X(300) VALUE "gm x$".
    05 FILLER PIC X(200) VALUE "err argument.gamemode.invalid|x@4".
    05 FILLER PIC X(300) VALUE "gm creative1$".
    05 FILLER PIC X(200) VALUE "err argument.gamemode.invalid|creative1@" &
         "12".
    05 FILLER PIC X(300) VALUE "an feet$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "an eyes$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=1".
    05 FILLER PIC X(300) VALUE "an head$".
    05 FILLER PIC X(200) VALUE "err argument.anchor.invalid|head@3".
    05 FILLER PIC X(300) VALUE "mi none$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "mi left_right$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] i=1".
    05 FILLER PIC X(300) VALUE "mi front_back$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] i=2".
    05 FILLER PIC X(300) VALUE "mi up$".
    05 FILLER PIC X(200) VALUE "err argument.enum.invalid|up@5".
    05 FILLER PIC X(300) VALUE "tr none$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "tr clockwise_90$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] i=1".
    05 FILLER PIC X(300) VALUE "tr 180$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=2".
    05 FILLER PIC X(300) VALUE "tr counterclockwise_90$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] i=3".
    05 FILLER PIC X(300) VALUE "tr 90$".
    05 FILLER PIC X(200) VALUE "err argument.enum.invalid|90@5".
    05 FILLER PIC X(300) VALUE "hm world_surface$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] i=0".
    05 FILLER PIC X(300) VALUE "hm ocean_floor$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] i=1".
    05 FILLER PIC X(300) VALUE "hm motion_blocking$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] i=2".
    05 FILLER PIC X(300) VALUE "hm motion_blocking_no_leaves$".
    05 FILLER PIC X(200) VALUE "ok v[3,28] i=3".
    05 FILLER PIC X(300) VALUE "hm world_surface_wg$".
    05 FILLER PIC X(200) VALUE "err argument.enum.invalid|world_surface_" &
         "wg@19".
    05 FILLER PIC X(300) VALUE "hm ocean_floor_wg$".
    05 FILLER PIC X(200) VALUE "err argument.enum.invalid|ocean_floor_wg" &
         "@17".
    05 FILLER PIC X(300) VALUE "sw none$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "sw whack$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] i=1".
    05 FILLER PIC X(300) VALUE "sw stab$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=2".
    05 FILLER PIC X(300) VALUE "sw poke$".
    05 FILLER PIC X(200) VALUE "err argument.swing_animation.invalid|pok" &
         "e@7".
    05 FILLER PIC X(300) VALUE "tc black$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] i=0".
    05 FILLER PIC X(300) VALUE "tc dark_blue$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] i=1".
    05 FILLER PIC X(300) VALUE "tc dark_green$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] i=2".
    05 FILLER PIC X(300) VALUE "tc dark_aqua$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] i=3".
    05 FILLER PIC X(300) VALUE "tc dark_red$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] i=4".
    05 FILLER PIC X(300) VALUE "tc dark_purple$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] i=5".
    05 FILLER PIC X(300) VALUE "tc gold$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=6".
    05 FILLER PIC X(300) VALUE "tc gray$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=7".
    05 FILLER PIC X(300) VALUE "tc dark_gray$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] i=8".
    05 FILLER PIC X(300) VALUE "tc blue$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=9".
    05 FILLER PIC X(300) VALUE "tc green$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] i=10".
    05 FILLER PIC X(300) VALUE "tc aqua$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=11".
    05 FILLER PIC X(300) VALUE "tc red$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=12".
    05 FILLER PIC X(300) VALUE "tc light_purple$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] i=13".
    05 FILLER PIC X(300) VALUE "tc yellow$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] i=14".
    05 FILLER PIC X(300) VALUE "tc white$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] i=15".
    05 FILLER PIC X(300) VALUE "tc reset$".
    05 FILLER PIC X(200) VALUE "err argument.color.invalid|reset@8".
    05 FILLER PIC X(300) VALUE "tc Red$".
    05 FILLER PIC X(200) VALUE "err argument.color.invalid|Red@6".
    05 FILLER PIC X(300) VALUE "hx F00$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=16711680".
    05 FILLER PIC X(300) VALUE "hx ff0000$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] i=16711680".
    05 FILLER PIC X(300) VALUE "hx 00FF7f$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] i=65407".
    05 FILLER PIC X(300) VALUE "hx abc$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=11189196".
    05 FILLER PIC X(300) VALUE "hx 000$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=0".
    05 FILLER PIC X(300) VALUE "hx FFFFFF$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] i=16777215".
    05 FILLER PIC X(300) VALUE "hx 12$".
    05 FILLER PIC X(200) VALUE "err argument.hexcolor.invalid|12@5".
    05 FILLER PIC X(300) VALUE "hx GGG$".
    05 FILLER PIC X(200) VALUE "err argument.hexcolor.invalid|GGG@6".
    05 FILLER PIC X(300) VALUE "hx abcd$".
    05 FILLER PIC X(200) VALUE "err argument.hexcolor.invalid|abcd@7".
    05 FILLER PIC X(300) VALUE "hx 1234567$".
    05 FILLER PIC X(200) VALUE "err argument.hexcolor.invalid|1234567@10".
    05 FILLER PIC X(300) VALUE "hx #fff$".
    05 FILLER PIC X(200) VALUE "err argument.hexcolor.invalid|@3".
    05 FILLER PIC X(300) VALUE "tm 10$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=10".
    05 FILLER PIC X(300) VALUE "tm 10t$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=10".
    05 FILLER PIC X(300) VALUE "tm 1.5s$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=30".
    05 FILLER PIC X(300) VALUE "tm 1d$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=24000".
    05 FILLER PIC X(300) VALUE "tm 0.5d$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=12000".
    05 FILLER PIC X(300) VALUE "tm 2s$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=40".
    05 FILLER PIC X(300) VALUE "tm 0.5$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=1".
    05 FILLER PIC X(300) VALUE "tm 0.4t$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "tm 2.5$".
    05 FILLER PIC X(200) VALUE "ok v[3,6] i=3".
    05 FILLER PIC X(300) VALUE "tm -0.5$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "tm 0$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] i=0".
    05 FILLER PIC X(300) VALUE "tm 100000d$".
    05 FILLER PIC X(200) VALUE "ok v[3,10] i=2147483647".
    05 FILLER PIC X(300) VALUE "tm -1$".
    05 FILLER PIC X(200) VALUE "err argument.time.tick_count_too_low|0|-" &
         "1@5".
    05 FILLER PIC X(300) VALUE "tm -2s$".
    05 FILLER PIC X(200) VALUE "err argument.time.tick_count_too_low|0|-" &
         "40@6".
    05 FILLER PIC X(300) VALUE "tn 4$".
    05 FILLER PIC X(200) VALUE "err argument.time.tick_count_too_low|5|4" &
         "@4".
    05 FILLER PIC X(300) VALUE "tn 5$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] i=5".
    05 FILLER PIC X(300) VALUE "tm 1e3s$".
    05 FILLER PIC X(200) VALUE "err argument.time.invalid_unit@7".
    05 FILLER PIC X(300) VALUE "tm 5x$".
    05 FILLER PIC X(200) VALUE "err argument.time.invalid_unit@5".
    05 FILLER PIC X(300) VALUE "tm 5ss$".
    05 FILLER PIC X(200) VALUE "err argument.time.invalid_unit@6".
    05 FILLER PIC X(300) VALUE "tm abc$".
    05 FILLER PIC X(200) VALUE "err parsing.float.expected@3".
    05 FILLER PIC X(300) VALUE "tm 1.2.3$".
    05 FILLER PIC X(200) VALUE "err parsing.float.invalid|1.2.3@3".
    05 FILLER PIC X(300) VALUE "ir 0..5$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] min=0 max=5".
    05 FILLER PIC X(300) VALUE "ir 5$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] min=5 max=5".
    05 FILLER PIC X(300) VALUE "ir -5$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] min=-5 max=-5".
    05 FILLER PIC X(300) VALUE "ir -100..$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] min=-100 max=-".
    05 FILLER PIC X(300) VALUE "ir ..100$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] min=- max=100".
    05 FILLER PIC X(300) VALUE "ir 0..0$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] min=0 max=0".
    05 FILLER PIC X(300) VALUE "ir -3..-1$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] min=-3 max=-1".
    05 FILLER PIC X(300) VALUE "ir 5..0$".
    05 FILLER PIC X(200) VALUE "err argument.range.swapped@3".
    05 FILLER PIC X(300) VALUE "ir 1.5$".
    05 FILLER PIC X(200) VALUE "err parsing.int.invalid|1.5@3".
    05 FILLER PIC X(300) VALUE "ir ..$".
    05 FILLER PIC X(200) VALUE "err argument.range.empty@5".
    05 FILLER PIC X(300) VALUE "ir x$".
    05 FILLER PIC X(200) VALUE "err argument.range.empty@3".
    05 FILLER PIC X(300) VALUE "ir 0..5..7$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@7".
    05 FILLER PIC X(300) VALUE "ir 99999999999$".
    05 FILLER PIC X(200) VALUE "err parsing.int.invalid|99999999999@3".
    05 FILLER PIC X(300) VALUE "ir -$".
    05 FILLER PIC X(200) VALUE "err parsing.int.invalid|-@3".
    05 FILLER PIC X(300) VALUE "ir 0..x$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@6".
    05 FILLER PIC X(300) VALUE "fr 0..5.2$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] min=0.0 max=5.2".
    05 FILLER PIC X(300) VALUE "fr -5.4$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] min=-5.4 max=-5.4".
    05 FILLER PIC X(300) VALUE "fr -100.76..$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] min=-100.76 max=-".
    05 FILLER PIC X(300) VALUE "fr ..100$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] min=- max=100.0".
    05 FILLER PIC X(300) VALUE "fr .5..1$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] min=0.5 max=1.0".
    05 FILLER PIC X(300) VALUE "fr 1.5..0.5$".
    05 FILLER PIC X(200) VALUE "err argument.range.swapped@3".
    05 FILLER PIC X(300) VALUE "fr 1.2.3$".
    05 FILLER PIC X(200) VALUE "err parsing.double.invalid|1.2.3@3".
    05 FILLER PIC X(300) VALUE "ob kills$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "ob a.b_c$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "cr dummy$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "cr trigger$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "cr deathCount$".
    05 FILLER PIC X(200) VALUE "ok v[3,13]".
    05 FILLER PIC X(300) VALUE "cr playerKillCount$".
    05 FILLER PIC X(200) VALUE "ok v[3,18]".
    05 FILLER PIC X(300) VALUE "cr totalKillCount$".
    05 FILLER PIC X(200) VALUE "ok v[3,17]".
    05 FILLER PIC X(300) VALUE "cr health$".
    05 FILLER PIC X(200) VALUE "ok v[3,9]".
    05 FILLER PIC X(300) VALUE "cr food$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "cr air$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "cr armor$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "cr xp$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "cr level$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "cr teamkill.red$".
    05 FILLER PIC X(200) VALUE "ok v[3,15]".
    05 FILLER PIC X(300) VALUE "cr killedByTeam.aqua$".
    05 FILLER PIC X(200) VALUE "ok v[3,20]".
    05 FILLER PIC X(300) VALUE "cr minecraft.mined:minecraft.stone$".
    05 FILLER PIC X(200) VALUE "ok v[3,34]".
    05 FILLER PIC X(300) VALUE "cr minecraft.custom:minecraft.jump$".
    05 FILLER PIC X(200) VALUE "ok v[3,34]".
    05 FILLER PIC X(300) VALUE "cr foo$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|foo@3".
    05 FILLER PIC X(300) VALUE "cr teamkill.pink$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|teamkill.p" &
         "ink@3".
    05 FILLER PIC X(300) VALUE "cr xyz:abc$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|xyz:abc@3".
    05 FILLER PIC X(300) VALUE "cr Dummy$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|Dummy@3".
    05 FILLER PIC X(300) VALUE "cr minecraft.mined:$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|minecraft." &
         "mined:@3".
    05 FILLER PIC X(300) VALUE "cr teamkill.$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|teamkill.@" &
         "3".
    05 FILLER PIC X(300) VALUE "cr minecraft.mined:minecraft.stone:x$".
    05 FILLER PIC X(200) VALUE "err argument.criteria.invalid|minecraft." &
         "mined:minecraft.stone:x@3".
    05 FILLER PIC X(300) VALUE "op =$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] i=0".
    05 FILLER PIC X(300) VALUE "op +=$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=1".
    05 FILLER PIC X(300) VALUE "op -=$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=2".
    05 FILLER PIC X(300) VALUE "op *=$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=3".
    05 FILLER PIC X(300) VALUE "op /=$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=4".
    05 FILLER PIC X(300) VALUE "op %=$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=5".
    05 FILLER PIC X(300) VALUE "op <$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] i=6".
    05 FILLER PIC X(300) VALUE "op >$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] i=7".
    05 FILLER PIC X(300) VALUE "op ><$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] i=8".
    05 FILLER PIC X(300) VALUE "op ==$".
    05 FILLER PIC X(200) VALUE "err arguments.operation.invalid@5".
    05 FILLER PIC X(300) VALUE "op <>$".
    05 FILLER PIC X(200) VALUE "err arguments.operation.invalid@5".
    05 FILLER PIC X(300) VALUE "sl list$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] i=0".
    05 FILLER PIC X(300) VALUE "sl sidebar$".
    05 FILLER PIC X(200) VALUE "ok v[3,10] i=1".
    05 FILLER PIC X(300) VALUE "sl below_name$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] i=2".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.black$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] i=3".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.dark_blue$".
    05 FILLER PIC X(200) VALUE "ok v[3,25] i=4".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.dark_green$".
    05 FILLER PIC X(200) VALUE "ok v[3,26] i=5".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.dark_aqua$".
    05 FILLER PIC X(200) VALUE "ok v[3,25] i=6".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.dark_red$".
    05 FILLER PIC X(200) VALUE "ok v[3,24] i=7".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.dark_purple$".
    05 FILLER PIC X(200) VALUE "ok v[3,27] i=8".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.gold$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] i=9".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.gray$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] i=10".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.dark_gray$".
    05 FILLER PIC X(200) VALUE "ok v[3,25] i=11".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.blue$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] i=12".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.green$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] i=13".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.aqua$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] i=14".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.red$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] i=15".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.light_purple$".
    05 FILLER PIC X(200) VALUE "ok v[3,28] i=16".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.yellow$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] i=17".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.white$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] i=18".
    05 FILLER PIC X(300) VALUE "sl footer$".
    05 FILLER PIC X(200) VALUE "err argument.scoreboardDisplaySlot.inval" &
         "id|footer@9".
    05 FILLER PIC X(300) VALUE "sl sidebar.team.pink$".
    05 FILLER PIC X(200) VALUE "err argument.scoreboardDisplaySlot.inval" &
         "id|sidebar.team.pink@20".
    05 FILLER PIC X(300) VALUE "te red$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "is weapon.mainhand$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] slot=98 n=1".
    05 FILLER PIC X(300) VALUE "is weapon$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] slot=98 n=1".
    05 FILLER PIC X(300) VALUE "is weapon.offhand$".
    05 FILLER PIC X(200) VALUE "ok v[3,17] slot=99 n=1".
    05 FILLER PIC X(300) VALUE "is hotbar.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] slot=0 n=1".
    05 FILLER PIC X(300) VALUE "is hotbar.8$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] slot=8 n=1".
    05 FILLER PIC X(300) VALUE "is inventory.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] slot=9 n=1".
    05 FILLER PIC X(300) VALUE "is inventory.26$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] slot=35 n=1".
    05 FILLER PIC X(300) VALUE "is container.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] slot=0 n=1".
    05 FILLER PIC X(300) VALUE "is container.53$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] slot=53 n=1".
    05 FILLER PIC X(300) VALUE "is enderchest.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] slot=200 n=1".
    05 FILLER PIC X(300) VALUE "is enderchest.26$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] slot=226 n=1".
    05 FILLER PIC X(300) VALUE "is armor.feet$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] slot=100 n=1".
    05 FILLER PIC X(300) VALUE "is armor.legs$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] slot=101 n=1".
    05 FILLER PIC X(300) VALUE "is armor.chest$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] slot=102 n=1".
    05 FILLER PIC X(300) VALUE "is armor.head$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] slot=103 n=1".
    05 FILLER PIC X(300) VALUE "is armor.body$".
    05 FILLER PIC X(200) VALUE "ok v[3,13] slot=105 n=1".
    05 FILLER PIC X(300) VALUE "is horse.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,10] slot=500 n=1".
    05 FILLER PIC X(300) VALUE "is horse.14$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] slot=514 n=1".
    05 FILLER PIC X(300) VALUE "is horse.chest$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] slot=499 n=1".
    05 FILLER PIC X(300) VALUE "is player.cursor$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] slot=499 n=1".
    05 FILLER PIC X(300) VALUE "is player.crafting.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] slot=500 n=1".
    05 FILLER PIC X(300) VALUE "is player.crafting.3$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] slot=503 n=1".
    05 FILLER PIC X(300) VALUE "is saddle$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] slot=106 n=1".
    05 FILLER PIC X(300) VALUE "is contents$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] slot=0 n=1".
    05 FILLER PIC X(300) VALUE "is mob.inventory.0$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] slot=300 n=1".
    05 FILLER PIC X(300) VALUE "is mob.inventory.7$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] slot=307 n=1".
    05 FILLER PIC X(300) VALUE "is hotbar.9$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|hotbar.9@11".
    05 FILLER PIC X(300) VALUE "is villager.0$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|villager.0@13".
    05 FILLER PIC X(300) VALUE "is horse.15$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|horse.15@11".
    05 FILLER PIC X(300) VALUE "is inventory.27$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|inventory.27@15".
    05 FILLER PIC X(300) VALUE "is armor.hat$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|armor.hat@12".
    05 FILLER PIC X(300) VALUE "is container.54$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|container.54@15".
    05 FILLER PIC X(300) VALUE "is hotbar.00$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|hotbar.00@12".
    05 FILLER PIC X(300) VALUE "is hotbar.$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|hotbar.@10".
    05 FILLER PIC X(300) VALUE "is player.crafting.4$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|player.crafting.4@20".
    05 FILLER PIC X(300) VALUE "is horse.saddle$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|horse.saddle@15".
    05 FILLER PIC X(300) VALUE "is mob.inventory.8$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|mob.inventory.8@18".
    05 FILLER PIC X(300) VALUE "is hotbar.*$".
    05 FILLER PIC X(200) VALUE "err slot.only_single_allowed|hotbar.*@11".
    05 FILLER PIC X(300) VALUE "is armor.*$".
    05 FILLER PIC X(200) VALUE "err slot.only_single_allowed|armor.*@10".
    05 FILLER PIC X(300) VALUE "is weapon.*$".
    05 FILLER PIC X(200) VALUE "err slot.only_single_allowed|weapon.*@11".
    05 FILLER PIC X(300) VALUE "iss hotbar.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,12] slot=0 n=9".
    05 FILLER PIC X(300) VALUE "iss armor.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,11] slot=103 n=5".
    05 FILLER PIC X(300) VALUE "iss weapon.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,12] slot=98 n=2".
    05 FILLER PIC X(300) VALUE "iss inventory.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,15] slot=9 n=27".
    05 FILLER PIC X(300) VALUE "iss container.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,15] slot=0 n=54".
    05 FILLER PIC X(300) VALUE "iss enderchest.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,16] slot=200 n=27".
    05 FILLER PIC X(300) VALUE "iss horse.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,11] slot=500 n=15".
    05 FILLER PIC X(300) VALUE "iss mob.inventory.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,19] slot=300 n=8".
    05 FILLER PIC X(300) VALUE "iss player.crafting.*$".
    05 FILLER PIC X(200) VALUE "ok v[4,21] slot=500 n=4".
    05 FILLER PIC X(300) VALUE "iss hotbar.3$".
    05 FILLER PIC X(200) VALUE "ok v[4,12] slot=3 n=1".
    05 FILLER PIC X(300) VALUE "iss weapon$".
    05 FILLER PIC X(200) VALUE "ok v[4,10] slot=98 n=1".
    05 FILLER PIC X(300) VALUE "iss nothing.*$".
    05 FILLER PIC X(200) VALUE "err slot.unknown|nothing.*@13".
    05 FILLER PIC X(300) VALUE "rl minecraft:stone$".
    05 FILLER PIC X(200) VALUE "ok v[3,18]".
    05 FILLER PIC X(300) VALUE "rl stone$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "rl foo/bar_baz.x-y$".
    05 FILLER PIC X(200) VALUE "ok v[3,18]".
    05 FILLER PIC X(300) VALUE "rl a:b$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "rl a-b.c_d:e/f$".
    05 FILLER PIC X(200) VALUE "ok v[3,14]".
    05 FILLER PIC X(300) VALUE "rl 012$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "rl Stone$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@3".
    05 FILLER PIC X(300) VALUE "rl a#b$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@4".
    05 FILLER PIC X(300) VALUE "rl a:b:c$".
    05 FILLER PIC X(200) VALUE "err argument.id.invalid@3".
    05 FILLER PIC X(300) VALUE "rl a:B$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@5".
    05 FILLER PIC X(300) VALUE "rl a:b/c:d$".
    05 FILLER PIC X(200) VALUE "err argument.id.invalid@3".
    05 FILLER PIC X(300) VALUE "rl a:b c$".
    05 FILLER PIC X(200) VALUE "err command.unknown.argument@7".
    05 FILLER PIC X(300) VALUE "fn #foo$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "fn foo:bar$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "di minecraft:overworld$".
    05 FILLER PIC X(200) VALUE "ok v[3,22]".
    05 FILLER PIC X(300) VALUE "di x:y$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "rs speed$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "rs minecraft:speed$".
    05 FILLER PIC X(200) VALUE "ok v[3,18]".
    05 FILLER PIC X(300) VALUE "ro #minecraft:foo$".
    05 FILLER PIC X(200) VALUE "ok v[3,17]".
    05 FILLER PIC X(300) VALUE "ro stone$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "ro #$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "rk #a:b$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "rk a$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "rg x$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "rp minecraft:*$".
    05 FILLER PIC X(200) VALUE "ok v[3,14]".
    05 FILLER PIC X(300) VALUE "rp *$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "rp *:asset$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "rp *:*$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "rp a*:b*c$".
    05 FILLER PIC X(200) VALUE "ok v[3,9]".
    05 FILLER PIC X(300) VALUE "rp minecraft:stone$".
    05 FILLER PIC X(200) VALUE "ok v[3,18]".
    05 FILLER PIC X(300) VALUE "rp A*$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@3".
    05 FILLER PIC X(300) VALUE "lt minecraft:chests/x$".
    05 FILLER PIC X(200) VALUE "ok v[3,21]".
    05 FILLER PIC X(300) VALUE "lt {a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "lt {a:{b:[1,2]},c:'x y'}$".
    05 FILLER PIC X(200) VALUE "ok v[3,24]".
    05 FILLER PIC X(300) VALUE "ci 5$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "ci -1.5$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "ci a:b$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "ci {type:x}$".
    05 FILLER PIC X(200) VALUE "ok v[3,11]".
    05 FILLER PIC X(300) VALUE "cf 0.5$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "cf x:y$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "cf {a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "fe a:b$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "fe {a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "id 12345678-1234-1234-1234-123456789abc$".
    05 FILLER PIC X(200) VALUE "ok v[3,39]".
    05 FILLER PIC X(300) VALUE "id 1-2-3-4-5$".
    05 FILLER PIC X(200) VALUE "ok v[3,12]".
    05 FILLER PIC X(300) VALUE "id AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE$".
    05 FILLER PIC X(200) VALUE "ok v[3,39]".
    05 FILLER PIC X(300) VALUE "id 123456789-1-1-1-1$".
    05 FILLER PIC X(200) VALUE "ok v[3,20]".
    05 FILLER PIC X(300) VALUE "id xyz$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
    05 FILLER PIC X(300) VALUE "id 123$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
    05 FILLER PIC X(300) VALUE "id 1-2-3-4$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
    05 FILLER PIC X(300) VALUE "id 1-2-3-4-5-6$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
    05 FILLER PIC X(300) VALUE "id --$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
    05 FILLER PIC X(300) VALUE "id 1--3-4-5$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
    05 FILLER PIC X(300) VALUE "id 12345678901234567-1-1-1-1$".
    05 FILLER PIC X(200) VALUE "err argument.uuid.invalid@3".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 264 TIMES.
       10 WS-CASE-LINE PIC X(300).
       10 WS-CASE-EXPECTED PIC X(200).
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-VERDICT             BINARY-LONG.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-EDIT                PIC -(19)9.
 01 WS-NUMBER              PIC X(32).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-ZERO-INF            BINARY-LONG VALUE 0.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE-ID             BINARY-LONG.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-ARG-TEXT            PIC X(1024).

 PROCEDURE DIVISION.
     PERFORM SETUP
     CALL "BR-TREE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         PERFORM ADD-TYPE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 264
         MOVE WS-CASE-LINE(WS-I) TO WS-LINE
         MOVE WS-CASE-EXPECTED(WS-I) TO WS-EXPECTED
         PERFORM CHECK
     END-PERFORM
     GOBACK.

*> A literal under the root named WS-T-LIT(WS-I) with the argument "v" of its type (command WS-I).
 ADD-TYPE.
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE-ID
     MOVE WS-T-LIT(WS-I) TO WS-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-CHILD WS-CREATED
     MOVE WS-CHILD TO WS-NODE
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE "v" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     MOVE WS-T-ID(WS-I) TO WS-TYPE-ID
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-CHILD WS-CREATED
     MOVE WS-I TO BR-N-COMMAND(WS-CHILD)
     MOVE WS-T-FLAGS(WS-I) TO BR-N-FLAGS(WS-CHILD)
     MOVE WS-T-HASMIN(WS-I) TO BR-N-HAS-MIN(WS-CHILD)
     MOVE WS-T-IMIN(WS-I) TO BR-N-IMIN(WS-CHILD)
     MOVE WS-T-SK(WS-I) TO BR-N-STRING-KIND(WS-CHILD)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-T-REG(WS-I))) TO BR-N-REG-LENGTH(WS-CHILD)
     MOVE WS-T-REG(WS-I) TO BR-N-REG(WS-CHILD).

 CHECK.
     MOVE 4 TO WS-LEVEL
     IF WS-LINE(1:2) = "0>"
         MOVE 0 TO WS-LEVEL
         MOVE WS-LINE(3:) TO WS-ARG-TEXT
         MOVE WS-ARG-TEXT TO WS-LINE
     END-IF
     MOVE 0 TO WS-LENGTH
     INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
     CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH RS-TRAIL
     CALL "BR-VERDICT" USING RS-TRAIL WS-VERDICT WS-COMMAND
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     IF WS-VERDICT = 0
         PERFORM DESCRIBE-OK
     ELSE
         PERFORM DESCRIBE-ERROR
     END-IF
     MOVE SPACES TO TL-CASE
     MOVE WS-LEVEL TO WS-EDIT
     STRING "acceptance US13 15§6 Argument types [" WS-LINE(1:WS-LENGTH) "] level " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 DESCRIBE-ERROR.
     STRING "err " FUNCTION TRIM(BR-E-KEY) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > BR-E-ARG-COUNT
         STRING "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         IF BR-E-ARG-LENGTH(WS-E) > 0
             STRING BR-E-ARG(WS-E)(1:BR-E-ARG-LENGTH(WS-E)) DELIMITED BY SIZE
                 INTO WS-TEXT WITH POINTER WS-POS
         END-IF
     END-PERFORM
     MOVE BR-E-CURSOR TO WS-EDIT
     STRING "@" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

*> "ok" and the argument range, then the value text of the type.
 DESCRIBE-OK.
     MOVE "ok" TO WS-TEXT(1:2)
     MOVE 3 TO WS-POS
     MOVE RS-COUNT TO WS-E
     MOVE RS-START(WS-E) TO WS-EDIT
     STRING " v[" FUNCTION TRIM(WS-EDIT) "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE RS-END(WS-E) TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) "]" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE BR-N-TYPE(RS-NODE(WS-E)) TO WS-TYPE-ID
     PERFORM DESCRIBE-VALUE.

*> " i=<n>" for an integer value
 PUT-INT.
     MOVE RS-IVAL(WS-E) TO WS-EDIT
     STRING " i=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

*> a double as Java prints it
 PUT-DOUBLE-1.
     CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE RS-IVAL(WS-E) RS-DVAL(WS-E) WS-ZERO-INF
         WS-NUMBER WS-NUMBER-LENGTH
     STRING WS-NUMBER(1:WS-NUMBER-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

 PUT-DOUBLE-2.
     CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE RS-IVAL2(WS-E) RS-DVAL2(WS-E) WS-ZERO-INF
         WS-NUMBER WS-NUMBER-LENGTH
     STRING WS-NUMBER(1:WS-NUMBER-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.


 DESCRIBE-VALUE.
     EVALUATE WS-TYPE-ID
         WHEN BR-P-GAMEMODE
         WHEN BR-P-ANCHOR
         WHEN BR-P-MIRROR
         WHEN BR-P-TEMPLATE-ROT
         WHEN BR-P-HEIGHTMAP
         WHEN BR-P-SWING
         WHEN BR-P-TEAM-COLOR
         WHEN BR-P-HEX-COLOR
         WHEN BR-P-TIME
         WHEN BR-P-OPERATION
         WHEN BR-P-SLOT-DISPLAY
             PERFORM PUT-INT
         WHEN BR-P-ITEM-SLOT
         WHEN BR-P-ITEM-SLOTS
             MOVE RS-IVAL(WS-E) TO WS-EDIT
             STRING " slot=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             MOVE RS-IVAL2(WS-E) TO WS-EDIT
             STRING " n=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         WHEN BR-P-INT-RANGE
             STRING " min=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             IF RS-AUX(WS-E) = 1 OR RS-AUX(WS-E) = 3
                 MOVE RS-IVAL(WS-E) TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             ELSE
                 STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             END-IF
             STRING " max=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             IF RS-AUX(WS-E) >= 2
                 MOVE RS-IVAL2(WS-E) TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             ELSE
                 STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             END-IF
         WHEN BR-P-FLOAT-RANGE
             STRING " min=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             IF RS-AUX(WS-E) = 1 OR RS-AUX(WS-E) = 3
                 PERFORM PUT-DOUBLE-1
             ELSE
                 STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             END-IF
             STRING " max=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             IF RS-AUX(WS-E) >= 2
                 PERFORM PUT-DOUBLE-2
             ELSE
                 STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE.

 SETUP.
     CONTINUE.

 END PROGRAM TEST-CMD-15-6.

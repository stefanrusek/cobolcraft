*> Acceptance test of docs/protocol/15-commands-framework.md §7 Entity selectors: the argument flags (§7.1), the top-level grammar
*> and selector types (§7.2, §7.3), the option list grammar (§7.4), every option with its value reader and applicability rule
*> (§7.5, §7.7), game_profile (§7.8), score_holder (§7.9) and the message type that embeds selectors (§6.3). A line starting
*> with "0>" is parsed by a source of permission level 0 (the rest is the line). One literal per argument type: en entity,
*> es single entity, ep players, eps single player, gp game_profile, sh score_holder, sm score_holder (multiple), ms message.
*> The result reads "ok v[start,end]" then t= (selector type 1 p, 2 a, 3 r, 4 s, 5 e, 6 n, 7 name, 8 UUID), lim= (* none),
*> sort=, ent= and the options set (x y z dx dy dz dist lvl xrot yrot gm= allowed/denied masks, name team type tag nbt scores
*> adv pred), or "err <key>|<args>@<cursor>". The entity type table of the test holds minecraft:zombie and minecraft:pig;
*> text options of a name selector print as typed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 01 WS-TYPES.
    05 FILLER PIC X(8) VALUE "en".
    05 FILLER PIC S9(9) BINARY VALUE 6.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "es".
    05 FILLER PIC S9(9) BINARY VALUE 6.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "ep".
    05 FILLER PIC S9(9) BINARY VALUE 6.
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "eps".
    05 FILLER PIC S9(9) BINARY VALUE 6.
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "gp".
    05 FILLER PIC S9(9) BINARY VALUE 7.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "sh".
    05 FILLER PIC S9(9) BINARY VALUE 31.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "sm".
    05 FILLER PIC S9(9) BINARY VALUE 31.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "ms".
    05 FILLER PIC S9(9) BINARY VALUE 20.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE OCCURS 8 TIMES.
       10 WS-T-LIT PIC X(8).
       10 WS-T-ID PIC S9(9) BINARY.
       10 WS-T-FLAGS PIC S9(9) BINARY.
       10 WS-T-HASMIN PIC S9(9) BINARY.
       10 WS-T-IMIN PIC S9(9) BINARY.
       10 WS-T-SK PIC S9(9) BINARY.
       10 WS-T-REG PIC X(40).
 01 WS-CASES.
    05 FILLER PIC X(300) VALUE "en @p$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=1 lim=1 sort=1 ent=0".
    05 FILLER PIC X(300) VALUE "en @a$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=2 lim=* sort=0 ent=0".
    05 FILLER PIC X(300) VALUE "en @r$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=3 lim=1 sort=3 ent=0".
    05 FILLER PIC X(300) VALUE "en @s$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=4 lim=1 sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "en @e$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=5 lim=* sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "en @n$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=6 lim=1 sort=1 ent=1".
    05 FILLER PIC X(300) VALUE "en Steve$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=St" &
         "eve".
    05 FILLER PIC X(300) VALUE "en 12345678-1234-1234-1234-123456789abc$".
    05 FILLER PIC X(200) VALUE "ok v[3,39] t=8 lim=1 sort=0 ent=1 text=1" &
         "2345678-1234-1234-1234-123456789abc".
    05 FILLER PIC X(300) VALUE "en ""a b""$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=a " &
         "b".
    05 FILLER PIC X(300) VALUE "en @x$".
    05 FILLER PIC X(200) VALUE "err argument.entity.selector.unknown|@x@" &
         "4".
    05 FILLER PIC X(300) VALUE "en @$".
    05 FILLER PIC X(200) VALUE "err argument.entity.selector.missing@4".
    05 FILLER PIC X(300) VALUE "en Steve1234567890123$".
    05 FILLER PIC X(200) VALUE "err argument.entity.invalid@3".
    05 FILLER PIC X(300) VALUE "0>en @a$".
    05 FILLER PIC X(200) VALUE "err argument.entity.selector.not_allowed" &
         "@3".
    05 FILLER PIC X(300) VALUE "0>en Steve$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=St" &
         "eve".
    05 FILLER PIC X(300) VALUE "en ""abc$".
    05 FILLER PIC X(200) VALUE "err parsing.quote.expected.end@7".
    05 FILLER PIC X(300) VALUE "en @e[type=zombie]$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] t=5 lim=* sort=0 ent=1 type=m" &
         "inecraft:zombie".
    05 FILLER PIC X(300) VALUE "en @e[type=minecraft:pig]$".
    05 FILLER PIC X(200) VALUE "ok v[3,25] t=5 lim=* sort=0 ent=1 type=m" &
         "inecraft:pig".
    05 FILLER PIC X(300) VALUE "en @e[type=!zombie,type=!pig]$".
    05 FILLER PIC X(200) VALUE "ok v[3,29] t=5 lim=* sort=0 ent=1 type=!" &
         "minecraft:zombie,!minecraft:pig".
    05 FILLER PIC X(300) VALUE "en @e[type=#minecraft:skeletons]$".
    05 FILLER PIC X(200) VALUE "ok v[3,32] t=5 lim=* sort=0 ent=1 type=#" &
         "minecraft:skeletons".
    05 FILLER PIC X(300) VALUE "en @a[type=zombie]$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] t=2 lim=* sort=0 ent=0 type=m" &
         "inecraft:zombie".
    05 FILLER PIC X(300) VALUE "en @e[type=player]$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] t=5 lim=* sort=0 ent=0 type=m" &
         "inecraft:player".
    05 FILLER PIC X(300) VALUE "en @e[type=!player]$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] t=5 lim=* sort=0 ent=1 type=!" &
         "minecraft:player".
    05 FILLER PIC X(300) VALUE "en @e[type=zombie,type=pig]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|type@18".
    05 FILLER PIC X(300) VALUE "en @e[type=!zombie,type=pig]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|type@24".
    05 FILLER PIC X(300) VALUE "en @e[type=zombie,type=!pig]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|type@18".
    05 FILLER PIC X(300) VALUE "en @e[type=banana]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.type.invalid" &
         "|minecraft:banana@11".
    05 FILLER PIC X(300) VALUE "en @e[type=#a:b,type=#a:b]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|type@21".
    05 FILLER PIC X(300) VALUE "en @e[type=#a:b,type=#a:c]$".
    05 FILLER PIC X(200) VALUE "ok v[3,26] t=5 lim=* sort=0 ent=1 type=#" &
         "a:b,#a:c".
    05 FILLER PIC X(300) VALUE "en @e[x=1.5,y=64,z=-2]$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] t=5 lim=* sort=0 ent=1 x=1.5 " &
         "y=64.0 z=-2.0".
    05 FILLER PIC X(300) VALUE "en @e[dx=3,dy=-1,dz=2]$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] t=5 lim=* sort=0 ent=1 dx=3.0" &
         " dy=-1.0 dz=2.0".
    05 FILLER PIC X(300) VALUE "en @e[x=1,x=2]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|x@10".
    05 FILLER PIC X(300) VALUE "en @e[x=a]$".
    05 FILLER PIC X(200) VALUE "err parsing.double.expected@8".
    05 FILLER PIC X(300) VALUE "en @e[y=]$".
    05 FILLER PIC X(200) VALUE "err parsing.double.expected@8".
    05 FILLER PIC X(300) VALUE "en @e[distance=..5]$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] t=5 lim=* sort=0 ent=1 dist=-" &
         "..5.0".
    05 FILLER PIC X(300) VALUE "en @e[distance=2..5]$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] t=5 lim=* sort=0 ent=1 dist=2" &
         ".0..5.0".
    05 FILLER PIC X(300) VALUE "en @e[distance=3]$".
    05 FILLER PIC X(200) VALUE "ok v[3,17] t=5 lim=* sort=0 ent=1 dist=3" &
         ".0..3.0".
    05 FILLER PIC X(300) VALUE "en @e[distance=-1]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.distance.neg" &
         "ative@15".
    05 FILLER PIC X(300) VALUE "en @e[distance=..-1]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.distance.neg" &
         "ative@15".
    05 FILLER PIC X(300) VALUE "en @e[distance=1,distance=2]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|distance@17".
    05 FILLER PIC X(300) VALUE "en @a[level=5..]$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] t=2 lim=* sort=0 ent=0 lvl=5." &
         ".-".
    05 FILLER PIC X(300) VALUE "en @e[level=..3]$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] t=5 lim=* sort=0 ent=0 lvl=-." &
         ".3".
    05 FILLER PIC X(300) VALUE "en @a[level=-1]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.level.negati" &
         "ve@12".
    05 FILLER PIC X(300) VALUE "en @e[level=1.5]$".
    05 FILLER PIC X(200) VALUE "err parsing.int.invalid|1.5@12".
    05 FILLER PIC X(300) VALUE "en @e[x_rotation=-45..45]$".
    05 FILLER PIC X(200) VALUE "ok v[3,25] t=5 lim=* sort=0 ent=1 xrot=-" &
         "45.0..45.0".
    05 FILLER PIC X(300) VALUE "en @e[y_rotation=90]$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] t=5 lim=* sort=0 ent=1 yrot=9" &
         "0.0..90.0".
    05 FILLER PIC X(300) VALUE "en @e[x_rotation=5..1]$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] t=5 lim=* sort=0 ent=1 xrot=5" &
         ".0..1.0".
    05 FILLER PIC X(300) VALUE "en @e[x_rotation=a]$".
    05 FILLER PIC X(200) VALUE "err argument.range.empty@17".
    05 FILLER PIC X(300) VALUE "en @e[limit=3]$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] t=5 lim=3 sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "en @a[limit=1]$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] t=2 lim=1 sort=0 ent=0".
    05 FILLER PIC X(300) VALUE "en @e[limit=0]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.limit.toosma" &
         "ll@12".
    05 FILLER PIC X(300) VALUE "en @e[limit=1,limit=2]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|limit@14".
    05 FILLER PIC X(300) VALUE "en @s[limit=1]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|limit@6".
    05 FILLER PIC X(300) VALUE "en @s[sort=random]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|sort@6".
    05 FILLER PIC X(300) VALUE "en @e[sort=arbitrary]$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] t=5 lim=* sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "en @e[sort=nearest]$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] t=5 lim=* sort=1 ent=1".
    05 FILLER PIC X(300) VALUE "en @e[sort=furthest]$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] t=5 lim=* sort=2 ent=1".
    05 FILLER PIC X(300) VALUE "en @e[sort=random]$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] t=5 lim=* sort=3 ent=1".
    05 FILLER PIC X(300) VALUE "en @e[sort=sideways]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.sort.irrever" &
         "sible|sideways@11".
    05 FILLER PIC X(300) VALUE "en @e[sort=random,sort=random]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|sort@18".
    05 FILLER PIC X(300) VALUE "en @a[gamemode=creative]$".
    05 FILLER PIC X(200) VALUE "ok v[3,24] t=2 lim=* sort=0 ent=0 gm=2/0".
    05 FILLER PIC X(300) VALUE "en @e[gamemode=!survival]$".
    05 FILLER PIC X(200) VALUE "ok v[3,25] t=5 lim=* sort=0 ent=0 gm=0/1".
    05 FILLER PIC X(300) VALUE "en @a[gamemode=!creative,gamemode=!survi" &
         "val]$".
    05 FILLER PIC X(200) VALUE "ok v[3,44] t=2 lim=* sort=0 ent=0 gm=0/3".
    05 FILLER PIC X(300) VALUE "en @a[gamemode=creative,gamemode=surviva" &
         "l]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|gamemode@24".
    05 FILLER PIC X(300) VALUE "en @a[gamemode=!creative,gamemode=surviv" &
         "al]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|gamemode@34".
    05 FILLER PIC X(300) VALUE "en @a[gamemode=foo]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.mode.invalid" &
         "|foo@15".
    05 FILLER PIC X(300) VALUE "en @e[team=red]$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] t=5 lim=* sort=0 ent=1 team=r" &
         "ed".
    05 FILLER PIC X(300) VALUE "en @e[team=!red,team=!blue]$".
    05 FILLER PIC X(200) VALUE "ok v[3,27] t=5 lim=* sort=0 ent=1 team=!" &
         "red,!blue".
    05 FILLER PIC X(300) VALUE "en @e[team=]$".
    05 FILLER PIC X(200) VALUE "ok v[3,12] t=5 lim=* sort=0 ent=1 team=".
    05 FILLER PIC X(300) VALUE "en @e[team=red,team=blue]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|team@15".
    05 FILLER PIC X(300) VALUE "en @e[tag=a,tag=!b,tag=]$".
    05 FILLER PIC X(200) VALUE "ok v[3,24] t=5 lim=* sort=0 ent=1 tag=a," &
         "!b,".
    05 FILLER PIC X(300) VALUE "en @e[name=Steve]$".
    05 FILLER PIC X(200) VALUE "ok v[3,17] t=5 lim=* sort=0 ent=1 name=S" &
         "teve".
    05 FILLER PIC X(300) VALUE "en @e[name=!Steve]$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] t=5 lim=* sort=0 ent=1 name=!" &
         "Steve".
    05 FILLER PIC X(300) VALUE "en @e[name=""A B""]$".
    05 FILLER PIC X(200) VALUE "ok v[3,17] t=5 lim=* sort=0 ent=1 name=A" &
         " B".
    05 FILLER PIC X(300) VALUE "en @e[name=a,name=b]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|name@13".
    05 FILLER PIC X(300) VALUE "en @e[nbt={a:1}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] t=5 lim=* sort=0 ent=1 nbt=1".
    05 FILLER PIC X(300) VALUE "en @e[nbt=!{a:1},nbt={b:[1,2]}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,31] t=5 lim=* sort=0 ent=1 nbt=2".
    05 FILLER PIC X(300) VALUE "en @e[nbt=5]$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.compound@10".
    05 FILLER PIC X(300) VALUE "en @e[scores={kills=1..,deaths=..3}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,36] t=5 lim=* sort=0 ent=1 scores" &
         "=kills:1..-,deaths:-..3".
    05 FILLER PIC X(300) VALUE "en @e[scores={a=5}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] t=5 lim=* sort=0 ent=1 scores" &
         "=a:5..5".
    05 FILLER PIC X(300) VALUE "en @e[scores={ a = 5 , b = 1..2 }]$".
    05 FILLER PIC X(200) VALUE "ok v[3,34] t=5 lim=* sort=0 ent=1 scores" &
         "=a:5..5,b:1..2".
    05 FILLER PIC X(300) VALUE "en @e[scores=5]$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|{@13".
    05 FILLER PIC X(300) VALUE "en @e[scores={a=1},scores={a=2}]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|scores@19".
    05 FILLER PIC X(300) VALUE "en @e[advancements={story/mine_stone=tru" &
         "e}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,43] t=5 lim=* sort=0 ent=0 adv=".
    05 FILLER PIC X(300) VALUE "en @e[advancements={a:b={c=true,d=false}" &
         ",e=false}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,50] t=5 lim=* sort=0 ent=0 adv=".
    05 FILLER PIC X(300) VALUE "en @e[advancements={a=maybe}]$".
    05 FILLER PIC X(200) VALUE "err parsing.bool.invalid|maybe@22".
    05 FILLER PIC X(300) VALUE "en @e[advancements={a=true},advancements" &
         "={b=true}]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.inapplicable" &
         "|advancements@28".
    05 FILLER PIC X(300) VALUE "en @e[predicate=foo]$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] t=5 lim=* sort=0 ent=1 pred=m" &
         "inecraft:foo".
    05 FILLER PIC X(300) VALUE "en @e[predicate=!x:y]$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] t=5 lim=* sort=0 ent=1 pred=!" &
         "x:y".
    05 FILLER PIC X(300) VALUE "en @e[$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.unterminated" &
         "@6".
    05 FILLER PIC X(300) VALUE "en @e[x=1$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.unterminated" &
         "@9".
    05 FILLER PIC X(300) VALUE "en @e[x=1 y=2]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.unterminated" &
         "@10".
    05 FILLER PIC X(300) VALUE "en @e[bad=1]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.unknown|bad@" &
         "6".
    05 FILLER PIC X(300) VALUE "en @e[x]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.valueless|x@" &
         "6".
    05 FILLER PIC X(300) VALUE "en @e[x=1,]$".
    05 FILLER PIC X(200) VALUE "ok v[3,11] t=5 lim=* sort=0 ent=1 x=1.0".
    05 FILLER PIC X(300) VALUE "en @e[]$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] t=5 lim=* sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "en @e[ x = 1 ]$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] t=5 lim=* sort=0 ent=1 x=1.0".
    05 FILLER PIC X(300) VALUE "en @p[distance=..5]$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] t=1 lim=1 sort=1 ent=0 dist=-" &
         "..5.0".
    05 FILLER PIC X(300) VALUE "es @a$".
    05 FILLER PIC X(200) VALUE "err argument.entity.toomany@0".
    05 FILLER PIC X(300) VALUE "es @e[limit=2]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.toomany@0".
    05 FILLER PIC X(300) VALUE "es @p$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=1 lim=1 sort=1 ent=0".
    05 FILLER PIC X(300) VALUE "es Steve$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=St" &
         "eve".
    05 FILLER PIC X(300) VALUE "es @e[limit=1]$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] t=5 lim=1 sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "ep @e$".
    05 FILLER PIC X(200) VALUE "err argument.player.entities@0".
    05 FILLER PIC X(300) VALUE "ep @s$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=4 lim=1 sort=0 ent=1".
    05 FILLER PIC X(300) VALUE "ep @a$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=2 lim=* sort=0 ent=0".
    05 FILLER PIC X(300) VALUE "ep @e[type=player]$".
    05 FILLER PIC X(200) VALUE "ok v[3,18] t=5 lim=* sort=0 ent=0 type=m" &
         "inecraft:player".
    05 FILLER PIC X(300) VALUE "eps @a$".
    05 FILLER PIC X(200) VALUE "err argument.player.toomany@0".
    05 FILLER PIC X(300) VALUE "eps @e$".
    05 FILLER PIC X(200) VALUE "err argument.player.toomany@0".
    05 FILLER PIC X(300) VALUE "eps @p$".
    05 FILLER PIC X(200) VALUE "ok v[4,6] t=1 lim=1 sort=1 ent=0".
    05 FILLER PIC X(300) VALUE "gp Steve$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=St" &
         "eve".
    05 FILLER PIC X(300) VALUE "gp @a$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=2 lim=* sort=0 ent=0".
    05 FILLER PIC X(300) VALUE "gp @e$".
    05 FILLER PIC X(200) VALUE "err argument.player.entities@5".
    05 FILLER PIC X(300) VALUE "gp @s$".
    05 FILLER PIC X(200) VALUE "err argument.player.entities@5".
    05 FILLER PIC X(300) VALUE "0>gp @a$".
    05 FILLER PIC X(200) VALUE "err argument.entity.selector.not_allowed" &
         "@3".
    05 FILLER PIC X(300) VALUE "gp Steve_Long_Name_x$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] t=7 lim=1 sort=0 ent=0 text=S" &
         "teve_Long_Name_x".
    05 FILLER PIC X(300) VALUE "sh Steve$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=St" &
         "eve".
    05 FILLER PIC X(300) VALUE "sh *$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] t=7 lim=1 sort=0 ent=0 text=*".
    05 FILLER PIC X(300) VALUE "sh #obj$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] t=7 lim=1 sort=0 ent=0 text=#o" &
         "bj".
    05 FILLER PIC X(300) VALUE "sh @p$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=1 lim=1 sort=1 ent=0".
    05 FILLER PIC X(300) VALUE "sh @a$".
    05 FILLER PIC X(200) VALUE "err argument.entity.toomany@5".
    05 FILLER PIC X(300) VALUE "sm @a$".
    05 FILLER PIC X(200) VALUE "ok v[3,5] t=2 lim=* sort=0 ent=0".
    05 FILLER PIC X(300) VALUE "sh 12345678-1234-1234-1234-123456789abc$".
    05 FILLER PIC X(200) VALUE "ok v[3,39] t=8 lim=1 sort=0 ent=1 text=1" &
         "2345678-1234-1234-1234-123456789abc".
    05 FILLER PIC X(300) VALUE "0>sh @p$".
    05 FILLER PIC X(200) VALUE "err argument.entity.selector.not_allowed" &
         "@3".
    05 FILLER PIC X(300) VALUE "0>sh Steve$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] t=7 lim=1 sort=0 ent=0 text=St" &
         "eve".
    05 FILLER PIC X(300) VALUE "ms hello world$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] n=0".
    05 FILLER PIC X(300) VALUE "ms @a hi$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] n=1".
    05 FILLER PIC X(300) VALUE "ms @e[type=zombie] x @p$".
    05 FILLER PIC X(200) VALUE "ok v[3,23] n=2".
    05 FILLER PIC X(300) VALUE "ms @x hi$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] n=0".
    05 FILLER PIC X(300) VALUE "ms @$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] n=0".
    05 FILLER PIC X(300) VALUE "ms email@a.com$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] n=1".
    05 FILLER PIC X(300) VALUE "ms say @s and @$".
    05 FILLER PIC X(200) VALUE "ok v[3,15] n=1".
    05 FILLER PIC X(300) VALUE "ms @e[bad=1]$".
    05 FILLER PIC X(200) VALUE "err argument.entity.options.unknown|bad@" &
         "6".
    05 FILLER PIC X(300) VALUE "ms aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaa$".
    05 FILLER PIC X(200) VALUE "ok v[3,259] n=0".
    05 FILLER PIC X(300) VALUE "ms aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" &
         "aaaaaaaaaaaaaaaaaaaa$".
    05 FILLER PIC X(200) VALUE "err argument.message.too_long|257|256@-1".
    05 FILLER PIC X(300) VALUE "0>ms @a hi$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] n=1".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 135 TIMES.
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
 COPY BRSEL.
 COPY CITEMS.
 01 WS-N                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-AUX                 BINARY-LONG.
 01 WS-ZERO-I              BINARY-DOUBLE VALUE 0.
 01 WS-DOUBLE-V            FLOAT-LONG.
 01 WS-DOUBLE-A            FLOAT-LONG.
 01 WS-DOUBLE-B            FLOAT-LONG.
 PROCEDURE DIVISION.
     PERFORM SETUP
     CALL "BR-TREE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         PERFORM ADD-TYPE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135
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
     STRING "acceptance US13 15§7 Entity selectors [" WS-LINE(1:WS-LENGTH) "] level " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
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
         WHEN BR-P-MESSAGE
             MOVE RS-IVAL(WS-E) TO WS-EDIT
             STRING " n=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         WHEN OTHER
             PERFORM DESCRIBE-SELECTOR
     END-EVALUATE.

 DESCRIBE-SELECTOR.
     MOVE SL-TYPE TO WS-EDIT
     STRING " t=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF SL-LIMIT = 2147483647
         STRING " lim=*" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     ELSE
         MOVE SL-LIMIT TO WS-EDIT
         STRING " lim=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SL-SORT TO WS-EDIT
     STRING " sort=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE SL-INCLUDES-ENTITIES TO WS-EDIT
     STRING " ent=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF SL-TEXT-LENGTH > 0
         STRING " text=" SL-TEXT(1:SL-TEXT-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 6
         IF SL-HAS-POS(WS-N) = 1
             EVALUATE WS-N
                 WHEN 1
                     STRING " x=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
                 WHEN 2
                     STRING " y=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
                 WHEN 3
                     STRING " z=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
                 WHEN 4
                     STRING " dx=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
                 WHEN 5
                     STRING " dy=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
                 WHEN OTHER
                     STRING " dz=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             END-EVALUATE
             MOVE SL-POS(WS-N) TO WS-DOUBLE-V
             PERFORM PUT-DOUBLE-V
         END-IF
     END-PERFORM
     IF SL-DIST-AUX > 0
         STRING " dist=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         MOVE SL-DIST-AUX TO WS-AUX
         MOVE SL-DIST-MIN TO WS-DOUBLE-A
         MOVE SL-DIST-MAX TO WS-DOUBLE-B
         PERFORM PUT-DOUBLE-RANGE
     END-IF
     IF SL-LEVEL-AUX > 0
         STRING " lvl=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         IF SL-LEVEL-AUX = 1 OR SL-LEVEL-AUX = 3
             MOVE SL-LEVEL-MIN TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         ELSE
             STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         STRING ".." DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         IF SL-LEVEL-AUX >= 2
             MOVE SL-LEVEL-MAX TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         ELSE
             STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
     END-IF
     IF SL-XROT-AUX > 0
         STRING " xrot=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         MOVE SL-XROT-AUX TO WS-AUX
         MOVE SL-XROT-MIN TO WS-DOUBLE-A
         MOVE SL-XROT-MAX TO WS-DOUBLE-B
         PERFORM PUT-DOUBLE-RANGE
     END-IF
     IF SL-YROT-AUX > 0
         STRING " yrot=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         MOVE SL-YROT-AUX TO WS-AUX
         MOVE SL-YROT-MIN TO WS-DOUBLE-A
         MOVE SL-YROT-MAX TO WS-DOUBLE-B
         PERFORM PUT-DOUBLE-RANGE
     END-IF
     IF SL-GM-ALLOW > 0 OR SL-GM-DENY > 0
         MOVE SL-GM-ALLOW TO WS-EDIT
         STRING " gm=" FUNCTION TRIM(WS-EDIT) "/" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         MOVE SL-GM-DENY TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     IF SL-NAME-COUNT > 0
         STRING " name=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SL-NAME-COUNT
             PERFORM PUT-NAME
         END-PERFORM
     END-IF
     IF SL-TEAM-COUNT > 0
         STRING " team=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SL-TEAM-COUNT
             PERFORM PUT-TEAM
         END-PERFORM
     END-IF
     IF SL-TYPE-COUNT > 0
         STRING " type=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SL-TYPE-COUNT
             PERFORM PUT-TYPE
         END-PERFORM
     END-IF
     IF SL-TAG-COUNT > 0
         STRING " tag=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SL-TAG-COUNT
             PERFORM PUT-TAG
         END-PERFORM
     END-IF
     IF SL-NBT-COUNT > 0
         MOVE SL-NBT-COUNT TO WS-EDIT
         STRING " nbt=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     IF SL-SCORE-COUNT > 0
         STRING " scores=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SL-SCORE-COUNT
             PERFORM PUT-SCORE
         END-PERFORM
     END-IF
     IF SL-ADV-SET = 1
         STRING " adv=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     IF SL-PRED-COUNT > 0
         STRING " pred=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SL-PRED-COUNT
             PERFORM PUT-PRED
         END-PERFORM
     END-IF.

 PUT-DOUBLE-V.
     CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE WS-ZERO-I WS-DOUBLE-V WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
     STRING WS-NUMBER(1:WS-NUMBER-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

*> a range of doubles with "-" for an absent bound
 PUT-DOUBLE-RANGE.
     IF WS-AUX = 1 OR WS-AUX = 3
         MOVE WS-DOUBLE-A TO WS-DOUBLE-V
         PERFORM PUT-DOUBLE-V
     ELSE
         STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     STRING ".." DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF WS-AUX >= 2
         MOVE WS-DOUBLE-B TO WS-DOUBLE-V
         PERFORM PUT-DOUBLE-V
     ELSE
         STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF.

 PUT-COMMA.
     IF WS-N > 1
         STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF.

 PUT-NAME.
     PERFORM PUT-COMMA
     IF SL-NAME-NEG(WS-N) = 1
         STRING "!" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SL-NAME-LENGTH(WS-N) TO WS-LEN
     IF WS-LEN > 0
         STRING SL-NAME-TEXT(WS-N)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF.

 PUT-TEAM.
     PERFORM PUT-COMMA
     IF SL-TEAM-NEG(WS-N) = 1
         STRING "!" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SL-TEAM-LENGTH(WS-N) TO WS-LEN
     IF WS-LEN > 0
         STRING SL-TEAM-TEXT(WS-N)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF.

 PUT-TYPE.
     PERFORM PUT-COMMA
     IF SL-TYPE-NEG(WS-N) = 1
         STRING "!" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     IF SL-TYPE-TAG(WS-N) = 1
         STRING "#" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SL-TYPE-LENGTH(WS-N) TO WS-LEN
     STRING SL-TYPE-TEXT(WS-N)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

 PUT-TAG.
     PERFORM PUT-COMMA
     IF SL-TAG-NEG(WS-N) = 1
         STRING "!" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SL-TAG-LENGTH(WS-N) TO WS-LEN
     IF WS-LEN > 0
         STRING SL-TAG-TEXT(WS-N)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF.

 PUT-PRED.
     PERFORM PUT-COMMA
     IF SL-PRED-NEG(WS-N) = 1
         STRING "!" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SL-PRED-LENGTH(WS-N) TO WS-LEN
     STRING SL-PRED-TEXT(WS-N)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

 PUT-SCORE.
     PERFORM PUT-COMMA
     MOVE SL-SCORE-LENGTH(WS-N) TO WS-LEN
     STRING SL-SCORE-OBJECTIVE(WS-N)(1:WS-LEN) ":" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF SL-SCORE-AUX(WS-N) = 1 OR SL-SCORE-AUX(WS-N) = 3
         MOVE SL-SCORE-MIN(WS-N) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     ELSE
         STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     STRING ".." DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF SL-SCORE-AUX(WS-N) >= 2
         MOVE SL-SCORE-MAX(WS-N) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     ELSE
         STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF.


*> The entity types the selector option type= knows.
 SETUP.
     MOVE 2 TO ET-COUNT
     MOVE "minecraft:zombie" TO ET-KEY(1)
     MOVE 16 TO ET-KEY-LENGTH(1)
     MOVE "minecraft:pig" TO ET-KEY(2)
     MOVE 13 TO ET-KEY-LENGTH(2).

 END PROGRAM TEST-CMD-15-7.

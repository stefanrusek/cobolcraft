*> The custom suggestion providers of the command nodes (docs/protocol/57-client-closures-4 sections 2.3 and 7: the nodes marked sug=): one row per node,
*> kind (1 minecraft:ask_server, 2 minecraft:available_sounds, 3 minecraft:summonable_entities, 4 minecraft:post_effects), strict (1 when the command's tree
*> equals the document's tree, so the path must exist), then the names of the nodes from the root literal down, separated by spaces. Applied by BR-SUGGEST-APPLY
*> (core/src/cmd-tree-std.cob) after the standard tree is built. Generated from the listings of section 7 (the {=Tn} reuse markers expanded): 131 rows.
 78 BRSUG-ROWS             VALUE 131.
 01 BRSUG-DATA.
    05 FILLER              PIC X(80) VALUE "11advancement grant targets only advancement criterion".
    05 FILLER              PIC X(80) VALUE "11advancement revoke targets only advancement criterion".
    05 FILLER              PIC X(80) VALUE "11attribute target attribute modifier remove id".
    05 FILLER              PIC X(80) VALUE "11attribute target attribute modifier value get id".
    05 FILLER              PIC X(80) VALUE "10execute if score target".
    05 FILLER              PIC X(80) VALUE "10execute if score target targetObjective = source".
    05 FILLER              PIC X(80) VALUE "10execute if score target targetObjective < source".
    05 FILLER              PIC X(80) VALUE "10execute if score target targetObjective <= source".
    05 FILLER              PIC X(80) VALUE "10execute if score target targetObjective > source".
    05 FILLER              PIC X(80) VALUE "10execute if score target targetObjective >= source".
    05 FILLER              PIC X(80) VALUE "10execute if function name".
    05 FILLER              PIC X(80) VALUE "10execute if stopwatch id".
    05 FILLER              PIC X(80) VALUE "10execute if data storage source".
    05 FILLER              PIC X(80) VALUE "10execute unless score target".
    05 FILLER              PIC X(80) VALUE "10execute unless score target targetObjective = source".
    05 FILLER              PIC X(80) VALUE "10execute unless score target targetObjective < source".
    05 FILLER              PIC X(80) VALUE "10execute unless score target targetObjective <= source".
    05 FILLER              PIC X(80) VALUE "10execute unless score target targetObjective > source".
    05 FILLER              PIC X(80) VALUE "10execute unless score target targetObjective >= source".
    05 FILLER              PIC X(80) VALUE "10execute unless function name".
    05 FILLER              PIC X(80) VALUE "10execute unless stopwatch id".
    05 FILLER              PIC X(80) VALUE "10execute unless data storage source".
    05 FILLER              PIC X(80) VALUE "10execute store result score targets".
    05 FILLER              PIC X(80) VALUE "10execute store result bossbar id".
    05 FILLER              PIC X(80) VALUE "10execute store result storage target".
    05 FILLER              PIC X(80) VALUE "10execute store success score targets".
    05 FILLER              PIC X(80) VALUE "10execute store success bossbar id".
    05 FILLER              PIC X(80) VALUE "10execute store success storage target".
    05 FILLER              PIC X(80) VALUE "30execute summon entity".
    05 FILLER              PIC X(80) VALUE "11bossbar remove id".
    05 FILLER              PIC X(80) VALUE "11bossbar set id".
    05 FILLER              PIC X(80) VALUE "11bossbar get id".
    05 FILLER              PIC X(80) VALUE "10data merge storage target".
    05 FILLER              PIC X(80) VALUE "10data get storage target".
    05 FILLER              PIC X(80) VALUE "10data remove storage target".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath insert index from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath insert index string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath prepend from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath prepend string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath append from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath append string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath set from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath set string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath merge from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify entity target targetPath merge string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath insert index from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath insert index string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath prepend from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath prepend string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath append from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath append string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath set from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath set string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath merge from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify block target targetPath merge string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath insert index from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath insert index string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath prepend from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath prepend string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath append from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath append string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath set from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath set string storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath merge from storage source".
    05 FILLER              PIC X(80) VALUE "10data modify storage target targetPath merge string storage source".
    05 FILLER              PIC X(80) VALUE "11datapack enable name".
    05 FILLER              PIC X(80) VALUE "11datapack enable name after existing".
    05 FILLER              PIC X(80) VALUE "11datapack enable name before existing".
    05 FILLER              PIC X(80) VALUE "11datapack disable name".
    05 FILLER              PIC X(80) VALUE "10debug function name".
    05 FILLER              PIC X(80) VALUE "11function name".
    05 FILLER              PIC X(80) VALUE "11function name with storage source".
    05 FILLER              PIC X(80) VALUE "11place template template".
    05 FILLER              PIC X(80) VALUE "21playsound sound".
    05 FILLER              PIC X(80) VALUE "41posteffect add targets posteffect".
    05 FILLER              PIC X(80) VALUE "41posteffect remove targets posteffect".
    05 FILLER              PIC X(80) VALUE "10random value range sequence".
    05 FILLER              PIC X(80) VALUE "10random roll range sequence".
    05 FILLER              PIC X(80) VALUE "10random reset sequence".
    05 FILLER              PIC X(80) VALUE "11schedule function function".
    05 FILLER              PIC X(80) VALUE "11schedule clear function".
    05 FILLER              PIC X(80) VALUE "11scoreboard players list target".
    05 FILLER              PIC X(80) VALUE "11scoreboard players set targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players get target".
    05 FILLER              PIC X(80) VALUE "11scoreboard players add targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players remove targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players reset targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players enable targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players enable targets objective".
    05 FILLER              PIC X(80) VALUE "11scoreboard players display name targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players display numberformat targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players operation targets".
    05 FILLER              PIC X(80) VALUE "11scoreboard players operation targets targetObjective operation source".
    05 FILLER              PIC X(80) VALUE "21stopsound targets * sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets master sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets music sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets record sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets weather sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets block sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets hostile sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets neutral sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets player sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets ambient sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets voice sound".
    05 FILLER              PIC X(80) VALUE "21stopsound targets ui sound".
    05 FILLER              PIC X(80) VALUE "11stopwatch query id".
    05 FILLER              PIC X(80) VALUE "11stopwatch restart id".
    05 FILLER              PIC X(80) VALUE "11stopwatch remove id".
    05 FILLER              PIC X(80) VALUE "31summon entity".
    05 FILLER              PIC X(80) VALUE "11tag targets remove name".
    05 FILLER              PIC X(80) VALUE "11team join team members".
    05 FILLER              PIC X(80) VALUE "11team leave members".
    05 FILLER              PIC X(80) VALUE "10test run tests".
    05 FILLER              PIC X(80) VALUE "10test runmultiple tests".
    05 FILLER              PIC X(80) VALUE "10test verify tests".
    05 FILLER              PIC X(80) VALUE "10test locate tests".
    05 FILLER              PIC X(80) VALUE "11tick rate rate".
    05 FILLER              PIC X(80) VALUE "11tick step time".
    05 FILLER              PIC X(80) VALUE "11tick sprint time".
    05 FILLER              PIC X(80) VALUE "10time set timemarker".
    05 FILLER              PIC X(80) VALUE "10time query timeline".
    05 FILLER              PIC X(80) VALUE "10time of clock set timemarker".
    05 FILLER              PIC X(80) VALUE "10time of clock query timeline".
    05 FILLER              PIC X(80) VALUE "11trigger objective".
    05 FILLER              PIC X(80) VALUE "11deop targets".
    05 FILLER              PIC X(80) VALUE "11op targets".
    05 FILLER              PIC X(80) VALUE "11pardon targets".
    05 FILLER              PIC X(80) VALUE "11pardon-ip target".
    05 FILLER              PIC X(80) VALUE "11whitelist add targets".
    05 FILLER              PIC X(80) VALUE "11whitelist remove targets".
 01 BRSUG-TABLE REDEFINES BRSUG-DATA.
    05 BRSUG-ROW           PIC X(80) OCCURS 131 TIMES.

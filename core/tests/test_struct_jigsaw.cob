*> Acceptance test of the jigsaw assembly (docs/protocol/36-structures-3 sections 3 to 13 and 17, 36-structures-9 sections 5 and 6) over the generated vanilla-data (CC_GENERATED_DIR, read only;
*> skipped as a pass without it): the jigsaw fields of the structure data, the template pools and their elements, and the pieces and junctions that STRUCT-FIND-POINT builds for the pillager
*> outpost and the villages, against core/tests/fixtures/gen_jigsaw.py (an independent model of the assembler over the same JSON and NBT: world seed 12345, the synthetic surface of
*> JIG-TEST-SURFACE), the remembered starts, and the emptying of the tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-JIGSAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-OUTPOST             BINARY-LONG.
 01 WS-IGLOO               BINARY-LONG.
 01 WS-TRIAL               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-NJ                  BINARY-LONG.
 01 WS-ED1                 PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-DESC                PIC X(64).
 01 WS-EL                  BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-POOL                BINARY-LONG.
 01 WS-LABEL               PIC X(100).
 01 WS-SAVE-X              BINARY-LONG.
 01 WS-SAVE-Y              BINARY-LONG.
 01 WS-SAVE-Z              BINARY-LONG.
 01 WS-SAVE-N              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
*> the model's cases: H (structure, chunk, piece and junction counts), P (element, position, rotation, box, ground delta, projection), J (owner, source, delta, projection)
 01 WS-ROWS-DATA.
    05 FILLER PIC X(140) VALUE "Hpillager_outpost        +000003-000002+000012+000022                                                                                       ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/base_plate                                     +000048+000069-0000320+000048+000069-000032+000063+000098-000017+0010      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_plate                                  +000079+000072-0000172+000064+000072-000048+000079+000077-000017+0011      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_plate                                  +000048+000071-0000013+000048+000071-000016+000079+000076-000001+0011      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_plate                                  +000032+000068-0000320+000032+000068-000032+000047+000073-000001+0011      ".
    05 FILLER PIC X(140) VALUE "Plist:pillager_outpost/watchtower                                +000048+000069-0000320+000048+000069-000032+000062+000091-000018+0010      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage_with_allays                       +000071+000072-0000410+000071+000072-000041+000077+000075-000035+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage2                                  +000070+000072-0000042+000064+000072-000010+000070+000075-000004+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_logs                                   +000073+000071-0000080+000073+000071-000008+000078+000073-000002+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_logs                                   +000040+000070-0000042+000035+000070-000010+000040+000072-000004+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_tent2                                  +000041+000070-0000160+000041+000070-000016+000046+000073-000010+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_tent2                                  +000038+000069-0000161+000032+000069-000016+000038+000072-000011+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_logs                                   +000041+000071-0000023+000041+000071-000007+000047+000073-000002+0000      ".
    05 FILLER PIC X(140) VALUE "J+000001+000064+000070-000024+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000063+000070-000024+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000055+000070-000016+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000055+000070-000017+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000047+000070-000025+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000048+000070-000025+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000055+000070-000019+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005+000055+000070-000018+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000077+000073-000040+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006+000077+000072-000040-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000069+000073-000010+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000007+000069+000072-000010-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000078+000072-000002+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008+000078+000071-000002-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000035+000071-000004+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009+000035+000070-000004-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000041+000071-000011+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000010+000041+000070-000011-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000037+000070-000011+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011+000037+000069-000011-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000041+000072-000007+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012+000041+000071-000007-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "Hpillager_outpost        -000007+000005+000016+000030                                                                                       ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/base_plate                                     -000112+000067+0000800-000112+000067+000080-000097+000096+000095+0010      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_plate                                  -000112+000069+0001113-000112+000069+000096-000081+000074+000111+0011      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_plate                                  -000128+000071+0000800-000128+000071+000080-000113+000076+000111+0011      ".
    05 FILLER PIC X(140) VALUE "Plist:pillager_outpost/watchtower                                -000112+000067+0000800-000112+000067+000080-000098+000089+000094+0010      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_plate                                  -000081+000070+0000952-000096+000070+000064-000081+000075+000095+0011      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_tent2                                  -000096+000071+0001103-000096+000071+000105-000090+000074+000110+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_targets                                -000085+000070+0001021-000091+000070+000102-000085+000072+000104+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage1                                  -000081+000069+0001112-000087+000069+000105-000081+000072+000111+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_targets                                -000093+000069+0001001-000099+000069+000100-000093+000071+000102+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_targets                                -000089+000071+0001003-000089+000071+000098-000083+000073+000100+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage2                                  -000116+000072+0000931-000122+000072+000093-000116+000075+000099+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_tent1                                  -000123+000072+0001022-000128+000072+000096-000123+000075+000102+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage1                                  -000127+000071+0001093-000127+000071+000103-000121+000074+000109+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage1                                  -000114+000071+0001031-000120+000071+000103-000114+000074+000109+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_cage_with_allays                       -000089+000072+0000691-000095+000072+000069-000089+000075+000075+0000      ".
    05 FILLER PIC X(140) VALUE "Ppillager_outpost/feature_tent1                                  -000081+000071+0000731-000087+000071+000073-000081+000074+000078+0000      ".
    05 FILLER PIC X(140) VALUE "J+000001-000105+000068+000096+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000105+000068+000095+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000113+000068+000087+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003-000112+000068+000087+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000105+000068+000093+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004-000105+000068+000094+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000096+000068+000088+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005-000097+000068+000088+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000095+000072+000110+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000095+000071+000110-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000091+000071+000102+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000007-000091+000070+000102-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000082+000070+000110+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008-000082+000069+000110-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000093+000070+000100+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009-000093+000069+000100-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000083+000072+000098+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000010-000083+000071+000098-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003-000117+000073+000099+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011-000117+000072+000099-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003-000123+000073+000101+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000123+000072+000101-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003-000126+000072+000103+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000013-000126+000071+000103-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003-000115+000072+000109+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000014-000115+000071+000109-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005-000090+000073+000070+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015-000090+000072+000070-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005-000082+000072+000078+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000016-000082+000071+000078-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "Hvillage_plains          +000005+000007+000115+000228                                                                                       ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/town_centers/plains_meeting_point_2              +000080+000068+0001121+000066+000068+000112+000080+000072+000119+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_06                              +000081+000068+0001112+000061+000068+000094+000081+000081+000111+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/iron_golem                                       +000076+000069+0001132+000076+000069+000113+000076+000071+000113+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_05                              +000065+000067+0001161+000049+000067+000116+000065+000080+000135+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/cat_black                                +000069+000069+0001160+000069+000069+000116+000069+000071+000116+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000074+000069+0001131+000074+000069+000113+000074+000071+000113+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000091+000071+0001161+000081+000071+000116+000091+000084+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000078+000070+0001282+000068+000070+000120+000078+000083+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/cat_calico                               +000069+000069+0001131+000069+000069+000113+000069+000071+000113+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000070+000069+0001141+000070+000069+000114+000070+000071+000114+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000072+000069+0001141+000072+000069+000114+000072+000071+000114+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_masons_house_1                     +000070+000070+0001042+000063+000070+000096+000070+000076+000104+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_1                      +000075+000068+0001050+000075+000068+000105+000081+000074+000111+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_temple_4                           +000071+000068+0001112+000062+000068+000105+000071+000079+000111+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/turn_01                                  +000077+000068+0000932+000060+000068+000086+000077+000081+000093+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_farm_1                       +000060+000071+0001191+000052+000071+000119+000060+000076+000125+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000048+000068+0001161+000038+000068+000116+000048+000081+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000102+000068+0001161+000092+000068+000116+000102+000081+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000076+000068+0001290+000076+000068+000129+000086+000081+000137+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000078+000069+0001082+000078+000069+000108+000078+000071+000108-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_06                              +000077+000070+0000852+000057+000070+000068+000077+000083+000085+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_5                      +000047+000071+0001191+000039+000071+000119+000047+000081+000127+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000037+000070+0001161+000029+000070+000116+000037+000083+000126+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000087+000069+0001150+000087+000069+000115+000091+000070+000119+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_1                      +000099+000071+0001191+000093+000071+000119+000099+000077+000125+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_05                              +000103+000071+0001183+000103+000071+000099+000119+000084+000118+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_04                             +000075+000068+0001240+000075+000068+000124+000078+000069+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_farm_1                       +000079+000070+0001290+000079+000070+000129+000085+000075+000137+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000078+000070+0001462+000068+000070+000138+000078+000083+000146+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:flower_plain                                            +000068+000072+0000701+000068+000072+000070+000068+000072+000070+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_tannery_1                          +000066+000072+0000822+000059+000072+000073+000066+000078+000082+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_animal_pen_1                       +000070+000071+0000690+000070+000071+000069+000074+000078+000074+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_4                      +000071+000070+0000790+000071+000070+000079+000077+000076+000085+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000067+000071+0000590+000067+000071+000059+000077+000084+000067+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:oak                                                     +000044+000072+0001272+000044+000072+000127+000044+000072+000127+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000042+000073+0001223+000042+000073+000122+000042+000075+000122-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/nitwit                                 +000045+000073+0001222+000045+000073+000122+000045+000075+000122-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_farm_1                       +000037+000070+0001191+000029+000070+000119+000037+000075+000125+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000024+000068+0001150+000024+000068+000115+000028+000069+000119+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000088+000067+0001040+000088+000067+000104+000100+000080+000114+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000082+000067+0001193+000082+000067+000115+000086+000068+000119+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000088+000068+0001233+000088+000068+000120+000091+000069+000123+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000096+000072+0001222+000096+000072+000122+000096+000074+000122-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_01                              +000135+000070+0001101+000120+000070+000110+000135+000075+000125+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000076+000067+0001200+000076+000067+000120+000079+000068+000123+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_01                                +000070+000067+0001470+000070+000067+000147+000085+000080+000162+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_2                      +000075+000072+0001452+000069+000072+000139+000075+000078+000145+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/pigs_1                                   +000072+000072+0000703+000072+000072+000070+000072+000074+000070+0000      ".
    05 FILLER PIC X(140) VALUE "Pfeature:oak                                                     +000073+000072+0000733+000073+000072+000073+000073+000072+000073+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000074+000071+0000823+000074+000071+000082+000074+000073+000082-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000069+000068+0000582+000057+000068+000048+000069+000081+000058+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_05                              +000027+000071+0001142+000008+000071+000098+000027+000084+000114+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000027+000067+0001302+000015+000067+000120+000027+000080+000130+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000032+000068+0001182+000029+000068+000115+000032+000069+000118+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000020+000067+0001183+000020+000067+000115+000023+000068+000118+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_3                      +000091+000072+0001060+000091+000072+000106+000097+000078+000112+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000088+000070+0000950+000088+000070+000095+000098+000083+000103+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_04                             +000091+000067+0001192+000088+000067+000115+000091+000068+000119+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000086+000071+0001142+000082+000071+000110+000086+000072+000114+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000086+000067+0001242+000082+000067+000120+000086+000068+000124+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000087+000067+0001172+000087+000067+000117+000087+000068+000117+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:flower_plain                                            +000129+000070+0001213+000129+000070+000121+000129+000070+000121+0000      ".
    05 FILLER PIC X(140) VALUE "Pfeature:pile_hay                                                +000122+000071+0001121+000122+000071+000112+000122+000071+000112+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_06                             +000140+000069+0001151+000136+000069+000115+000140+000074+000119+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000080+000071+0001212+000080+000071+000121+000080+000072+000121+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_04                             +000079+000067+0001462+000076+000067+000142+000079+000068+000146+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/plains_lamp_1                                    +000072+000068+0001523+000072+000068+000150+000074+000071+000152+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/plains_lamp_1                                    +000072+000071+0001590+000072+000071+000159+000074+000074+000161+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/plains_lamp_1                                    +000081+000070+0001491+000079+000070+000149+000081+000073+000151+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_02                                +000069+000067+0001541+000054+000067+000154+000069+000080+000169+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:oak                                                     +000078+000071+0001590+000078+000071+000159+000078+000071+000159+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000072+000073+0001423+000072+000073+000142+000072+000075+000142-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_masons_house_1                     +000066+000072+0000572+000059+000072+000049+000066+000078+000057+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_04                             +000066+000071+0000430+000066+000071+000043+000069+000072+000047+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000066+000068+0000590+000066+000068+000059+000070+000069+000063+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000025+000067+0000940+000025+000067+000094+000028+000068+000097+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000027+000071+0001182+000024+000071+000115+000027+000072+000118+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_animal_pen_1                       +000024+000069+0001272+000020+000069+000122+000024+000076+000127+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000027+000070+0001392+000017+000070+000131+000027+000083+000139+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_03                              +000030+000067+0001040+000030+000067+000104+000042+000080+000114+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/villagers/unemployed                             +000094+000073+0001090+000094+000073+000109+000094+000075+000109-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000088+000067+0000860+000088+000067+000086+000098+000080+000094+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000087+000071+0001122+000087+000071+000112+000087+000072+000112+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000084+000071+0001153+000084+000071+000115+000084+000072+000115+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_04                             +000082+000070+0001050+000082+000070+000105+000085+000071+000109+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000081+000070+0001120+000081+000070+000112+000081+000071+000112+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/corner_03                                +000085+000069+0001282+000082+000069+000125+000085+000070+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000080+000067+0001210+000080+000067+000121+000081+000068+000123+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000087+000068+0001222+000087+000068+000122+000087+000069+000122+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_02                              +000137+000070+0001200+000137+000070+000120+000152+000083+000135+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_04                              +000141+000071+0001183+000141+000071+000108+000149+000084+000118+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_05                             +000140+000069+0001142+000136+000069+000110+000140+000070+000114+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:flower_plain                                            +000138+000071+0001172+000138+000071+000117+000138+000071+000117+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/crossroad_04                             +000080+000067+0001420+000080+000067+000142+000083+000068+000146+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/streets/straight_05                              +000054+000067+0001700+000054+000067+000170+000073+000080+000186+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_house_2                      +000058+000072+0001600+000058+000072+000160+000064+000078+000166+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000063+000069+0000440+000063+000069+000044+000065+000070+000046+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000069+000069+0000391+000066+000069+000039+000069+000070+000042+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000063+000068+0000600+000063+000068+000060+000065+000069+000062+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000067+000069+0000663+000067+000069+000064+000069+000070+000066+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000071+000069+0000612+000071+000069+000061+000071+000070+000061+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000029+000067+0000952+000029+000067+000095+000029+000068+000095+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000025+000067+0000993+000025+000067+000098+000027+000068+000099+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000025+000067+0001433+000025+000067+000140+000028+000068+000143+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000031+000070+0001031+000031+000070+000103+000031+000071+000103+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000090+000070+0000821+000087+000070+000082+000090+000071+000085+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000089+000067+0000953+000089+000067+000095+000089+000068+000095+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000084+000069+0001041+000084+000069+000104+000084+000070+000104+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000079+000068+0001260+000079+000068+000126+000081+000069+000128+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000085+000069+0001231+000083+000069+000123+000085+000070+000124+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000137+000069+0001383+000137+000069+000136+000139+000070+000138+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000153+000068+0001182+000150+000068+000115+000153+000069+000118+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000139+000068+0001081+000137+000068+000108+000139+000069+000109+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000083+000067+0001381+000080+000067+000138+000083+000068+000141+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000054+000071+0001883+000054+000071+000187+000056+000072+000188+0011      ".
    05 FILLER PIC X(140) VALUE "J+000001+000073+000069+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000073+000069+000112+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000076+000069+000113+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000076+000068+000113-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000065+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000066+000069+000117+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000069+000069+000116+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005+000069+000068+000116-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000074+000069+000113+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006+000074+000068+000113-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000081+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000007+000080+000069+000117+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000077+000069+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008+000077+000069+000119+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000069+000069+000113+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009+000069+000068+000113-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000070+000069+000114+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000010+000070+000068+000114-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000072+000069+000114+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011+000072+000068+000114-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000070+000070+000101+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012+000071+000070+000101-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000075+000068+000108+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000013+000074+000068+000108-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000071+000068+000108+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000014+000072+000068+000108-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000072+000069+000093+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015+000072+000069+000094+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000056+000071+000119+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000016+000056+000071+000118-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000048+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017+000049+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000007+000092+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000091+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008+000077+000069+000129+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000019+000077+000069+000128+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000013+000078+000068+000108+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000020+000078+000067+000108-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015+000069+000071+000085+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000069+000071+000086+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017+000043+000072+000119+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000043+000072+000118+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017+000037+000071+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023+000038+000071+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000091+000070+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000024+000092+000070+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000096+000071+000119+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000096+000071+000118-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000103+000072+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000026+000102+000072+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000019+000077+000069+000128+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027+000077+000069+000129+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000019+000079+000070+000133+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000028+000078+000070+000133-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000019+000077+000071+000138+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000029+000077+000071+000137+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000068+000073+000070+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000030+000068+000072+000070-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000066+000072+000075+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000031+000067+000072+000075-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000070+000072+000071+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032+000069+000072+000071+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000071+000070+000082+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000033+000070+000070+000082-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000068+000072+000067+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034+000068+000072+000068+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000044+000072+000127+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000035+000044+000071+000127-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000042+000072+000122+0000020                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000036+000042+000071+000122-0000020                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000045+000072+000122+0000020                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037+000045+000071+000122-0000020                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023+000033+000070+000119+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000038+000033+000070+000118-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023+000028+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000029+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000024+000089+000068+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000040+000089+000068+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000024+000086+000068+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000041+000087+000068+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000024+000089+000069+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000042+000089+000069+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000096+000071+000122+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043+000096+000070+000122-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000026+000120+000071+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000044+000119+000071+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027+000077+000068+000123+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000045+000077+000068+000124+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000029+000077+000068+000147+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000077+000068+000146+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000029+000075+000072+000142+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000047+000076+000072+000142-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032+000072+000072+000070+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000048+000072+000071+000070-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032+000073+000072+000073+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049+000073+000071+000073-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000033+000074+000070+000082+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000050+000074+000069+000082-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034+000068+000069+000058+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051+000068+000069+000059+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000026+000072+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000052+000026+000072+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000026+000068+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053+000026+000068+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000029+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000054+000028+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000023+000068+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000055+000024+000068+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000040+000091+000072+000109+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056+000090+000072+000109-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000040+000089+000071+000103+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000057+000089+000071+000104+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000040+000089+000068+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000058+000089+000068+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000041+000084+000072+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059+000084+000072+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000041+000084+000068+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060+000084+000068+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000041+000087+000068+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000061+000086+000068+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000044+000129+000071+000121+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000062+000129+000070+000121-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000044+000122+000072+000112+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000063+000122+000071+000112-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000044+000136+000070+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064+000135+000070+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000045+000080+000072+000121+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000065+000079+000072+000121+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000077+000068+000146+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000066+000077+000068+000147+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000073+000069+000151+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000067+000073+000068+000151-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000073+000072+000160+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000068+000073+000071+000160-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000080+000071+000150+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000069+000080+000070+000150-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000069+000068+000155+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000070+000070+000068+000155+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000078+000072+000159+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000071+000078+000071+000159-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000047+000072+000072+000142+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000072+000072+000071+000142-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051+000066+000072+000054+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000073+000067+000072+000054-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051+000068+000072+000047+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000074+000068+000072+000048+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051+000068+000069+000059+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000075+000068+000069+000058+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000052+000026+000068+000097+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000076+000026+000068+000098+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000052+000026+000072+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000077+000026+000072+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053+000024+000070+000125+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000078+000025+000070+000125+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053+000026+000071+000131+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000079+000026+000071+000130+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000054+000031+000068+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000080+000031+000068+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056+000094+000072+000109+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000081+000094+000071+000109-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000057+000089+000068+000094+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000082+000089+000068+000095+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059+000087+000072+000112+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000083+000086+000072+000112+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059+000084+000072+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000084+000084+000072+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059+000084+000071+000109+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000085+000084+000071+000110+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059+000081+000071+000112+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000086+000082+000071+000112+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060+000084+000070+000125+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000087+000084+000070+000124+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060+000081+000068+000122+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000088+000082+000068+000122+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060+000087+000069+000122+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000089+000086+000069+000122+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064+000138+000071+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000090+000138+000071+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064+000141+000072+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000091+000140+000072+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064+000138+000070+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000092+000138+000070+000115+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064+000138+000072+000117+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000093+000138+000071+000117-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000066+000080+000068+000144+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000094+000079+000068+000144+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000070+000055+000068+000170+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000095+000055+000068+000169+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000070+000058+000072+000163+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000096+000057+000072+000163-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000074+000065+000070+000045+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000097+000066+000070+000045+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000074+000068+000070+000042+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000098+000068+000070+000043+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000075+000065+000069+000061+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000099+000066+000069+000061+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000075+000068+000070+000064+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000100+000068+000070+000063+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000075+000071+000070+000061+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000101+000070+000070+000061+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000076+000029+000068+000095+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000102+000028+000068+000095+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000076+000026+000068+000098+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000103+000026+000068+000097+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000079+000026+000068+000140+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000104+000026+000068+000139+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000080+000031+000071+000103+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000105+000031+000071+000104+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000082+000089+000071+000085+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000106+000089+000071+000086+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000082+000089+000068+000095+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000107+000089+000068+000094+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000085+000084+000070+000104+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000108+000084+000070+000105+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000087+000081+000069+000127+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000109+000082+000069+000127+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000087+000084+000070+000124+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000110+000084+000070+000125+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000090+000138+000070+000136+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000111+000138+000070+000135+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000091+000150+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000112+000149+000069+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000092+000138+000069+000109+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000113+000138+000069+000110+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000094+000082+000068+000141+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000114+000082+000068+000142+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000095+000055+000072+000187+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000115+000055+000072+000186+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "Hvillage_desert          -000004+000009+000089+000176                                                                                       ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/town_centers/desert_meeting_point_1              -000064+000070+0001440-000064+000070+000144-000048+000075+000152+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/cat_red                                  -000055+000072+0001501-000055+000072+000150-000055+000074+000150-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/iron_golem                                       -000055+000071+0001453-000055+000071+000145-000055+000073+000145+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_03                             -000050+000070+0001432-000054+000070+000139-000050+000071+000143+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_5                      -000058+000070+0001471-000063+000070+000147-000058+000075+000151+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_01                              -000054+000067+0001673-000054+000067+000153-000043+000086+000167+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000053+000071+0001442-000053+000071+000144-000053+000073+000144+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/baby                                   -000049+000071+0001450-000049+000071+000145-000049+000072+000145+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_02                              -000047+000067+0001340-000047+000067+000134-000033+000086+000151+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/camel_spawn                                      -000056+000071+0001482-000056+000071+000147-000056+000074+000148+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000049+000071+0001513-000049+000071+000151-000049+000073+000151+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_01                              -000050+000068+0001241-000061+000068+000124-000050+000087+000138+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/turn_01                                  -000055+000068+0001391-000058+000068+000139-000055+000073+000142+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000061+000071+0001500-000061+000071+000150-000061+000073+000150+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_shepherd_house_1                   -000046+000069+0001551-000050+000069+000155-000046+000074+000165+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000054+000070+0001662-000054+000070+000166-000054+000073+000166+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/square_02                                -000044+000070+0001681-000062+000070+000168-000044+000089+000183+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_03                              -000053+000067+0001523-000053+000067+000149-000051+000068+000152+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000054+000072+0001540-000054+000072+000154-000054+000075+000154+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000048+000067+0001492-000050+000067+000147-000048+000068+000149+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000035+000071+0001513-000035+000071+000151-000035+000074+000151+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_02                             -000032+000070+0001430-000032+000070+000143-000022+000075+000153+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_5                      -000038+000068+0001462-000042+000068+000141-000038+000073+000146+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_03                             -000050+000068+0001432-000054+000068+000139-000050+000069+000143+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_03                              -000053+000070+0001233-000053+000070+000120-000051+000071+000123+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_2                      -000054+000069+0001282-000060+000069+000124-000054+000074+000128+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_5                      -000054+000070+0001291-000059+000070+000129-000054+000075+000133+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000050+000069+0001372-000050+000069+000137-000050+000072+000137+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000058+000068+0001423-000058+000068+000142-000058+000071+000142+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/sheep_2                                  -000048+000070+0001582-000048+000070+000158-000048+000072+000158+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_medium_house_1                     -000056+000071+0001762-000061+000071+000170-000056+000076+000176+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_02                             -000022+000070+0001321-000032+000070+000132-000022+000075+000142+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:patch_cactus                                            -000031+000072+0001513-000031+000072+000151-000031+000072+000151+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/square_01                                -000039+000068+0001663-000039+000068+000154-000012+000087+000166+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/corner_02                                -000021+000068+0001470-000021+000068+000147-000016+000073+000152+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000041+000069+0001431-000041+000069+000143-000041+000071+000143+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/corner_01                                -000056+000069+0001193-000056+000069+000113-000042+000088+000119+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000055+000070+0001270-000055+000070+000127-000055+000072+000127+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000057+000071+0001323-000057+000071+000132-000057+000073+000132+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000059+000072+0001723-000059+000072+000172-000059+000074+000172+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000059+000072+0001742-000059+000072+000174-000059+000074+000174+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000027+000070+0001370-000027+000070+000137-000027+000073+000137+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_01                              -000029+000068+0001313-000029+000068+000117-000018+000087+000131+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:pile_hay                                                -000023+000072+0001410-000023+000072+000141-000023+000072+000141+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/corner_02                                -000021+000070+0001360-000021+000070+000136-000016+000075+000141+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_7                      -000023+000070+0001550-000023+000070+000155-000016+000074+000161+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_tannery_1                          -000030+000068+0001601-000035+000068+000160-000030+000077+000166+0020      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_5                      -000031+000068+0001551-000036+000068+000155-000031+000073+000159+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/square_01                                -000039+000071+0001793-000039+000071+000167-000012+000090+000179+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:patch_cactus                                            -000029+000069+0001561-000029+000069+000156-000029+000069+000156+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_03                             -000025+000068+0001532-000029+000068+000149-000025+000069+000153+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000020+000070+0001510-000020+000070+000151-000020+000073+000151+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000022+000068+0001492-000024+000068+000147-000022+000069+000149+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_farm_1                             -000050+000069+0001130-000050+000069+000113-000046+000074+000119+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_03                              -000053+000068+0001233-000053+000068+000120-000051+000069+000123+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/square_02                                -000057+000071+0001222-000072+000071+000104-000057+000090+000122+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:patch_cactus                                            -000029+000069+0001183-000029+000069+000118-000029+000069+000118+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_03                             -000025+000067+0001321-000029+000067+000132-000025+000068+000136+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_7                      -000025+000069+0001180-000025+000069+000118-000018+000073+000124+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_02                             -000032+000069+0001060-000032+000069+000106-000022+000074+000116+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:pile_hay                                                -000029+000072+0001302-000029+000072+000130-000029+000072+000130+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/turn_01                                  -000015+000067+0001421-000018+000067+000142-000015+000072+000145+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/nitwit                                 -000018+000071+0001582-000018+000071+000158-000018+000073+000158+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000034+000069+0001582-000034+000069+000158-000034+000071+000158+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/houses/desert_small_house_2                      -000031+000071+0001712-000037+000071+000167-000031+000076+000171+0010      ".
    05 FILLER PIC X(140) VALUE "Pfeature:patch_cactus                                            -000029+000072+0001691-000029+000072+000169-000029+000072+000169+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/turn_01                                  -000029+000069+0001800-000029+000069+000180-000026+000074+000183+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_03                              -000026+000067+0001451-000028+000067+000145-000026+000068+000148+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000024+000067+0001500-000024+000067+000150-000022+000068+000152+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000057+000071+0001123-000057+000071+000112-000057+000074+000112+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000030+000067+0001352-000032+000067+000133-000030+000068+000135+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_03                              -000021+000068+0001352-000024+000068+000133-000021+000069+000135+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000020+000070+0001211-000020+000070+000121-000020+000072+000121+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_01                              -000007+000068+0001132-000021+000068+000102-000007+000087+000113+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_02                              -000041+000071+0001053-000041+000071+000091-000024+000090+000105+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_03                              -000033+000071+0001122-000036+000071+000110-000033+000072+000112+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/crossroad_03                             -000019+000067+0001370-000019+000067+000137-000015+000068+000141+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/straight_01                              -000014+000069+0001420-000014+000069+000142+000000+000088+000153+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/cat_red                                  -000031+000072+0001682-000031+000072+000168-000031+000074+000168+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/villagers/unemployed                             -000032+000072+0001701-000032+000072+000170-000032+000074+000170+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/streets/turn_01                                  -000030+000069+0001801-000033+000069+000180-000030+000074+000183+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/desert_lamp_1                                    -000026+000071+0001833-000026+000071+000183-000026+000074+000183+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000020+000069+0001330-000020+000069+000133-000018+000070+000135+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000006+000067+0001100-000006+000067+000110-000004+000068+000112+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_02                        -000028+000067+0000903-000028+000067+000088-000026+000072+000090+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000037+000070+0001122-000039+000070+000110-000037+000071+000112+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_02                        -000014+000067+0001380-000014+000067+000138-000012+000072+000140+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        +000001+000068+0001430+000001+000068+000143+000003+000069+000145+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/desert/terminators/terminator_01                        -000033+000069+0001793-000033+000069+000177-000031+000070+000179+0011      ".
    05 FILLER PIC X(140) VALUE "J+000001-000055+000071+000150+0000020                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002-000055+000070+000150-0000020                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000055+000071+000145+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003-000055+000070+000145-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000052+000071+000143+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004-000052+000071+000144+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000058+000071+000149+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005-000057+000071+000149+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000052+000071+000153+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000052+000071+000152+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000053+000071+000144+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000007-000053+000070+000144-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000049+000071+000145+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008-000049+000070+000145-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000047+000071+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009-000048+000071+000148+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000056+000071+000148+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000010-000056+000070+000148-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001-000049+000071+000151+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011-000049+000070+000151-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004-000052+000069+000138+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000052+000069+000139+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004-000055+000069+000141+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000013-000054+000069+000141+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005-000061+000071+000150+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000014-000061+000070+000150-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000050+000070+000160+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015-000051+000070+000160+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000054+000071+000166+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000016-000054+000070+000166-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000052+000071+000168+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017-000052+000071+000167+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000052+000068+000152+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018-000052+000068+000153+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006-000054+000073+000154+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000019-000054+000072+000154-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009-000048+000068+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000020-000047+000068+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009-000035+000072+000151+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021-000035+000071+000151-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009-000032+000071+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022-000033+000071+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009-000040+000069+000146+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023-000040+000069+000147+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000052+000069+000139+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000024-000052+000069+000138+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000052+000071+000123+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025-000052+000071+000124+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000054+000070+000126+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000026-000053+000070+000126+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000054+000071+000131+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027-000053+000071+000131+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012-000050+000070+000137+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000028-000050+000069+000137-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000013-000058+000069+000142+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000029-000058+000068+000142-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015-000048+000070+000158+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000030-000048+000069+000158-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017-000056+000072+000173+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000031-000055+000072+000173+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022-000027+000071+000142+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032-000027+000071+000143+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022-000031+000073+000151+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000033-000031+000072+000151-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022-000027+000069+000154+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000027+000069+000153+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022-000021+000069+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000035-000022+000069+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023-000041+000069+000143+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000036-000041+000068+000143-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025-000052+000070+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037-000052+000070+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000026-000055+000070+000127+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000038-000055+000069+000127-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027-000057+000071+000132+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039-000057+000070+000132-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000031-000059+000072+000172+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000040-000059+000071+000172-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000031-000059+000072+000174+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000041-000059+000071+000174-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032-000027+000071+000137+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000042-000027+000070+000137-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032-000027+000069+000131+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043-000027+000069+000132+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032-000023+000073+000141+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000044-000023+000072+000141-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032-000021+000071+000137+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000045-000022+000071+000137+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000023+000071+000156+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046-000024+000071+000156+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000030+000070+000163-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000047-000029+000070+000163+0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000031+000069+000157+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000048-000030+000069+000157+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000027+000072+000167+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049-000027+000072+000166+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000029+000070+000156+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000050-000029+000069+000156-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034-000027+000069+000153+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051-000027+000069+000154+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000035-000020+000071+000151+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000052-000020+000070+000151-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000035-000022+000069+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053-000021+000069+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037-000050+000069+000116+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000054-000051+000069+000116-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037-000052+000069+000120+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000055-000052+000069+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037-000057+000072+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056-000056+000072+000114+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043-000029+000070+000118+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000057-000029+000069+000118-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043-000027+000068+000132+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000058-000027+000068+000131+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043-000025+000070+000119+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059-000026+000070+000119+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043-000027+000070+000116+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060-000027+000070+000117+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043-000029+000073+000130+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000061-000029+000072+000130-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000045-000017+000068+000142+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000062-000017+000068+000141+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046-000018+000071+000158+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000063-000018+000070+000158-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000048-000034+000069+000158+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064-000034+000068+000158-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049-000031+000072+000169+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000065-000030+000072+000169+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049-000029+000073+000169+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000066-000029+000072+000169-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049-000027+000070+000180+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000067-000027+000070+000179+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051-000027+000068+000148+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000068-000027+000068+000149+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051-000024+000068+000151+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000069-000025+000068+000151+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056-000057+000072+000112+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000070-000057+000071+000112-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000058-000030+000068+000134+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000071-000029+000068+000134+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000058-000024+000069+000134+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000072-000025+000069+000134+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059-000020+000070+000121+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000073-000020+000069+000121-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060-000021+000069+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000074-000022+000069+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060-000027+000072+000105+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000075-000027+000072+000106+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060-000033+000072+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000076-000032+000072+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000062-000017+000068+000141+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000077-000017+000068+000142+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000062-000014+000070+000144+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000078-000015+000070+000144+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000065-000031+000072+000168+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000079-000031+000071+000168-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000065-000032+000072+000170+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000080-000032+000071+000170-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000067-000030+000070+000182+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000081-000029+000070+000182+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000067-000026+000072+000183+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000082-000026+000071+000183-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000072-000020+000070+000134+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000083-000021+000070+000134+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000074-000006+000068+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000084-000007+000068+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000075-000027+000068+000090+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000085-000027+000068+000091+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000076-000037+000071+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000086-000036+000071+000111+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000077-000014+000068+000139+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000087-000015+000068+000139+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000078+000001+000069+000144+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000088+000000+000069+000144+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000081-000032+000070+000179+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000089-000032+000070+000180+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "Hvillage_plains          +000005+000000+000067+000132                                                                                       ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/town_centers/plains_meeting_point_3       +000080+000071+0000003+000080+000071-000010+000090+000079+000000+0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000087+000068+0000011+000083+000068+000001+000087+000069+000004+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_06                      +000083+000070-0000150+000083+000070-000015+000087+000075-000011+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_05                       +000107+000067-0000061+000091+000067-000006+000107+000080+000013+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/common/animals/cat_calico                               +000083+000072-0000032+000083+000072-000003+000083+000074-000003+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000086+000068-0000031+000083+000068-000003+000086+000069+000000+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000088+000068+0000032+000088+000068+000003+000088+000069+000003+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_03                       +000082+000067+0000021+000072+000067+000002+000082+000080+000014+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:flower_plain                                            +000085+000070-0000130+000085+000070-000013+000085+000070-000013+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000087+000069-0000162+000084+000069-000020+000087+000070-000016+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_02                       +000067+000068-0000123+000067+000068-000027+000082+000081-000012+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_03                       +000088+000069-0000123+000088+000069-000024+000098+000082-000012+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_small_farm_1                       +000102+000071-0000031+000094+000071-000003+000102+000076+000003+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000090+000067-0000032+000087+000067-000007+000090+000068-000003+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/turn_01                           +000108+000071+0000003+000108+000071-000017+000115+000084+000000+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_1               +000082+000068+0000051+000076+000068+000005+000082+000074+000011+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_02                       +000056+000070+0000043+000056+000070-000011+000071+000083+000004+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000084+000068-0000240+000084+000068-000024+000087+000069-000021+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000086+000068-0000122+000083+000068-000015+000086+000069-000012+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_02                       +000051+000069-0000123+000051+000069-000027+000066+000082-000012+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_2               +000088+000071-0000153+000088+000071-000021+000094+000077-000015+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/turn_01                           +000099+000067-0000083+000099+000067-000025+000106+000080-000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000086+000067-0000083+000086+000067-000011+000090+000068-000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000088+000068-0000023+000088+000068-000002+000088+000069-000002+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_06                       +000133+000068-0000171+000116+000068-000017+000133+000081+000003+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/villagers/unemployed                      +000079+000069+0000081+000079+000069+000008+000079+000071+000008-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_03                       +000055+000071+0000021+000045+000071+000002+000055+000084+000014+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000091+000067-0000241+000088+000067-000024+000091+000068-000021+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000087+000067-0000162+000084+000067-000020+000087+000068-000016+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000047+000070-0000123+000047+000070-000015+000050+000071-000012+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/villagers/unemployed                      +000091+000072-0000182+000091+000072-000018+000091+000074-000018-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000107+000069-0000143+000107+000069-000017+000111+000070-000014+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000098+000067-0000151+000094+000067-000015+000098+000068-000012+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000094+000071-0000111+000091+000071-000011+000094+000072-000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:pile_hay                                                +000118+000070-0000083+000118+000070-000008+000118+000070-000008+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_2               +000133+000068-0000071+000127+000068-000007+000133+000074-000001+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_7               +000121+000071-0000103+000121+000071-000016+000128+000077-000010+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000112+000069-0000073+000112+000069-000010+000115+000070-000007+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_04                       +000134+000067-0000083+000134+000067-000018+000142+000080-000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pfeature:oak                                                     +000124+000072-0000082+000124+000072-000008+000124+000072-000008+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/houses/plains_armorer_house_1                    +000053+000071+0000051+000046+000071+000005+000053+000078+000013+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_04                       +000036+000068+0000043+000036+000068-000006+000044+000081+000004+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000050+000070-0000162+000047+000070-000020+000050+000071-000016+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000097+000067-0000191+000094+000067-000019+000097+000068-000016+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000093+000068-0000073+000093+000068-000007+000093+000069-000007+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/villagers/unemployed                      +000130+000069-0000040+000130+000069-000004+000130+000071-000004-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/villagers/nitwit                          +000125+000072-0000132+000125+000072-000013+000125+000074-000013-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_05                      +000115+000067-0000151+000111+000067-000015+000115+000068-000011+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_03                       +000143+000069-0000083+000143+000069-000020+000153+000082-000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_3               +000135+000069-0000113+000135+000069-000017+000141+000075-000011+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_1               +000037+000068+0000013+000037+000068-000005+000043+000074+000001+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_03                       +000035+000071+0000021+000025+000071+000002+000035+000084+000014+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_04                      +000045+000068+0000053+000045+000068+000002+000049+000069+000005+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/straight_03                       +000049+000069-0000212+000037+000069-000031+000049+000082-000021+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/crossroad_05                      +000111+000067-0000100+000111+000067-000010+000115+000068-000006+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/streets/corner_03                         +000157+000067-0000101+000154+000067-000010+000157+000068-000007+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/houses/plains_small_house_2               +000144+000071-0000113+000144+000071-000017+000150+000077-000011+0000      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/zombie/villagers/unemployed                      +000138+000070-0000142+000138+000070-000014+000138+000072-000014-0010      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_02                        +000024+000068+0000030+000024+000068+000003+000024+000069+000003+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000052+000069+0000042+000050+000069+000002+000052+000070+000004+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000046+000069+0000083+000046+000069+000006+000048+000070+000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_03                        +000049+000071-0000341+000047+000071-000034+000049+000072-000032+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000047+000068-0000173+000047+000068-000020+000050+000069-000017+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_04                        +000112+000068-0000023+000112+000068-000005+000115+000069-000002+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000109+000067-0000090+000109+000067-000009+000110+000068-000007+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000152+000067-0000100+000152+000067-000010+000153+000068-000008+0011      ".
    05 FILLER PIC X(140) VALUE "Pvillage/plains/terminators/terminator_01                        +000155+000069-0000053+000155+000069-000006+000157+000070-000005+0011      ".
    05 FILLER PIC X(140) VALUE "J+000001+000085+000072+000001+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000085+000072+000000+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000085+000072-000011+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000085+000072-000010+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000091+000072-000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000090+000072-000005+0000000                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000001+000083+000072-000003+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000005+000083+000071-000003-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000085+000069+000000+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000006+000085+000069+000001+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000088+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000007+000087+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000002+000082+000068+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008+000083+000068+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000085+000071-000013+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000009+000085+000070-000013-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000085+000070-000016+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000010+000085+000070-000015+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000082+000069-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011+000083+000069-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000003+000088+000070-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012+000087+000070-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000098+000071-000003+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000013+000098+000071-000004-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000090+000068-000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000014+000091+000068-000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000004+000108+000072-000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015+000107+000072-000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008+000079+000068+000005+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000016+000079+000068+000004-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000008+000071+000071+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017+000072+000071+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000010+000085+000069-000021+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000085+000069-000020+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011+000083+000069-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000019+000082+000069-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000011+000066+000070-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000020+000067+000070-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012+000091+000071-000015+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000091+000071-000014-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000012+000099+000068-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000098+000068-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000014+000088+000068-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023+000088+000068-000007+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000014+000088+000069-000002+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000024+000088+000069-000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000015+000116+000069-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000115+000069-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000016+000079+000068+000008+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000026+000079+000067+000008-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000017+000055+000072+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027+000056+000072+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000088+000068-000023+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000028+000087+000068-000023+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000018+000085+000068-000020+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000029+000085+000068-000021+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000020+000050+000071-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000030+000051+000071-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000021+000091+000071-000018+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000031+000091+000070-000018-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000107+000070-000016+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000032+000106+000070-000016+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000022+000098+000068-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000033+000099+000068-000013+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000023+000091+000072-000010+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034+000090+000072-000010+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000118+000071-000008+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000035+000118+000070-000008-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000130+000068-000007+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000036+000130+000068-000008-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000125+000071-000010+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037+000125+000071-000009-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000115+000070-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000038+000116+000070-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000134+000068-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000133+000068-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000025+000124+000073-000008+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000040+000124+000072-000008-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027+000049+000071+000005+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000041+000049+000071+000004-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000027+000044+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000042+000045+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000030+000048+000071-000016+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043+000048+000071-000015+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000033+000096+000068-000016+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000044+000096+000068-000015+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000034+000093+000069-000007+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000045+000093+000069-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000036+000130+000068-000004+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000046+000130+000067-000004-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000037+000125+000071-000013+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000047+000125+000070-000013-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000038+000113+000068-000011+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000048+000113+000068-000010+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000143+000070-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049+000142+000070-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000039+000138+000069-000011+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000050+000138+000069-000010-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000042+000040+000068+000001+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000051+000040+000068+000002-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000042+000035+000072+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000052+000036+000072+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000042+000045+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053+000044+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000043+000048+000070-000021+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000054+000048+000070-000020+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000048+000113+000068-000010+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000055+000113+000068-000011+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049+000154+000068-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056+000153+000068-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000049+000147+000071-000011+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000057+000147+000071-000010-0000011                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000050+000138+000069-000014+0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000058+000138+000068-000014-0000010                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000052+000024+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000059+000025+000069+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053+000050+000070+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000060+000049+000070+000003+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000053+000047+000070+000006+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000061+000047+000070+000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000054+000048+000072-000032+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000062+000048+000072-000031+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000054+000048+000069-000020+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000063+000048+000069-000021+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000055+000113+000069-000005+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000064+000113+000069-000006+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000055+000110+000068-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000065+000111+000068-000008+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056+000153+000068-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000066+000154+000068-000009+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000056+000156+000070-000006+0000001                                                                                                       ".
    05 FILLER PIC X(140) VALUE "J+000067+000156+000070-000007+0000001                                                                                                       ".
 01 WS-ROWS-T REDEFINES WS-ROWS-DATA.
    05 WS-RW OCCURS 892 TIMES.
       10 RW-TAG           PIC X.
       10 RW-BODY          PIC X(139).
       10 RW-H REDEFINES RW-BODY.
          15 RH-NAME       PIC X(24).
          15 RH-CX         PIC S9(6) SIGN LEADING SEPARATE.
          15 RH-CZ         PIC S9(6) SIGN LEADING SEPARATE.
          15 RH-NP         PIC S9(6) SIGN LEADING SEPARATE.
          15 RH-NJ         PIC S9(6) SIGN LEADING SEPARATE.
          15 FILLER        PIC X(86).
       10 RW-P REDEFINES RW-BODY.
          15 RP-DESC       PIC X(64).
          15 RP-X          PIC S9(6) SIGN LEADING SEPARATE.
          15 RP-Y          PIC S9(6) SIGN LEADING SEPARATE.
          15 RP-Z          PIC S9(6) SIGN LEADING SEPARATE.
          15 RP-ROT        PIC 9.
          15 RP-B          PIC S9(6) SIGN LEADING SEPARATE OCCURS 6 TIMES.
          15 RP-GROUND     PIC S999 SIGN LEADING SEPARATE.
          15 RP-PROJ       PIC 9.
          15 FILLER        PIC X(6).
       10 RW-J REDEFINES RW-BODY.
          15 RJ-OWNER      PIC S9(6) SIGN LEADING SEPARATE.
          15 RJ-X          PIC S9(6) SIGN LEADING SEPARATE.
          15 RJ-Y          PIC S9(6) SIGN LEADING SEPARATE.
          15 RJ-Z          PIC S9(6) SIGN LEADING SEPARATE.
          15 RJ-DELTA      PIC S9(6) SIGN LEADING SEPARATE.
          15 RJ-PROJ       PIC 9.
          15 FILLER        PIC X(102).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct jigsaw no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:village_plains"
                 MOVE WS-I TO WS-PLAINS
             WHEN "minecraft:pillager_outpost"
                 MOVE WS-I TO WS-OUTPOST
             WHEN "minecraft:igloo"
                 MOVE WS-I TO WS-IGLOO
             WHEN "minecraft:trial_chambers"
                 MOVE WS-I TO WS-TRIAL
         END-EVALUATE
     END-PERFORM
     CALL "JIG-RESET"
     PERFORM DATA-CASES
     PERFORM POOL-CASES
     PERFORM ASSEMBLY-CASES
     PERFORM MEMO-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 3.1: the jigsaw fields of a structure file
 DATA-CASES.
     MOVE "test struct jigsaw given the village_plains data when it is read then the pool, size, start height, heightmap, hack, distance, padding, liquid settings and ok are the file's" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-POOL(WS-PLAINS) = "minecraft:village/plains/town_centers" AND SDT-JIG-SIZE(WS-PLAINS) = 6 AND SDT-JIG-Y(WS-PLAINS) = 0
        AND SDT-JIG-PROJ(WS-PLAINS) = 0 AND SDT-JIG-HACK(WS-PLAINS) = 1 AND SDT-JIG-HOR(WS-PLAINS) = 80 AND SDT-JIG-VER(WS-PLAINS) = 80
        AND SDT-JIG-PADB(WS-PLAINS) = 0 AND SDT-JIG-PADT(WS-PLAINS) = 0 AND SDT-JIG-LIQ(WS-PLAINS) = 0 AND SDT-JIG-OK(WS-PLAINS) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct jigsaw given the pillager_outpost data when it is read then the pool, size 7 and ok are the file's" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-POOL(WS-OUTPOST) = "minecraft:pillager_outpost/base_plates" AND SDT-JIG-SIZE(WS-OUTPOST) = 7 AND SDT-JIG-OK(WS-OUTPOST) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct jigsaw given a structure that is not a jigsaw when it is read then it is not ok" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(WS-IGLOO) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct jigsaw given the trial_chambers data (pool aliases, a start height that is not absolute) when it is read then it is not ok" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(WS-TRIAL) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 6: pools and elements
 POOL-CASES.
     MOVE "minecraft:village/plains/houses" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE "test struct jigsaw given the plains houses pool when it is read then its weights sum to 87 and its fallback is the terminators pool" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-POOL > 1 AND JP-TOTAL(WS-POOL) = 87 AND JP-STATUS(WS-POOL) = 1
         MOVE "minecraft:village/plains/terminators" TO WS-KEY
         CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
         IF WS-ROW = JP-FALLBACK(WS-POOL)
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE "test struct jigsaw given the pool minecraft:empty when it is asked then it is row 1 with no entry and itself as fallback" TO TL-CASE
     MOVE "minecraft:empty" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE 0 TO WS-FLAG
     IF WS-ROW = 1 AND JP-TOTAL(1) = 0 AND JP-FALLBACK(1) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct jigsaw given a pool that does not exist when it is asked then there is none, and the answer is remembered" TO TL-CASE
     MOVE "minecraft:village/no_such_pool" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-K
     MOVE JP-COUNT TO WS-SAVE-N
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE 0 TO WS-FLAG
     IF WS-K = 0 AND WS-ROW = 0 AND JP-COUNT = WS-SAVE-N
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:pillager_outpost/towers" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE JN-ELEM(JP-FIRST(WS-POOL)) TO WS-EL
     MOVE "test struct jigsaw given the outpost towers pool when it is read then its element is a list of two rigid templates" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JE-KIND(WS-EL) = 3 AND JE-SUB-N(WS-EL) = 2 AND JE-PROJ(WS-EL) = 0
         MOVE JS-ELEM(JE-SUB-FIRST(WS-EL)) TO WS-SUB
         IF JE-LOC(WS-SUB) = "minecraft:pillager_outpost/watchtower" AND JE-PROJ(WS-SUB) = 0
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE "minecraft:pillager_outpost/feature_plates" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE JN-ELEM(JP-FIRST(WS-POOL)) TO WS-EL
     MOVE "test struct jigsaw given the outpost feature plates pool when it is read then its element is a terrain matching legacy template with the outpost rot list" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JE-KIND(WS-EL) = 2 AND JE-PROJ(WS-EL) = 1 AND JE-LOC(WS-EL) = "minecraft:pillager_outpost/feature_plate"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:village/plains/trees" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE 0 TO WS-FLAG
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-POOL)
         MOVE JN-ELEM(JP-FIRST(WS-POOL) + WS-I) TO WS-EL
         IF JE-KIND(WS-EL) = 4 AND JE-FEATURE(WS-EL)(1:10) = "minecraft:"
             MOVE 1 TO WS-FLAG
         END-IF
     END-PERFORM
     MOVE "test struct jigsaw given the plains trees pool when it is read then it holds feature elements" TO TL-CASE
     PERFORM CHECK.

*> 9 to 12: the model's pieces and junctions
 ASSEMBLY-CASES.
     MOVE 1 TO JIG-TEST-SURFACE
     MOVE 1 TO WS-R
     PERFORM UNTIL WS-R > 892
         PERFORM ONE-CASE
     END-PERFORM
     MOVE 0 TO JIG-TEST-SURFACE.

*> WS-R the H row of a case: it is built and compared, and WS-R is left after the case's rows
 ONE-CASE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(RH-NAME(WS-R)) DELIMITED BY SIZE INTO WS-KEY
     MOVE 0 TO WS-STRUCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-STRUCT
         END-IF
     END-PERFORM
     MOVE RH-CX(WS-R) TO WS-CX
     MOVE RH-CZ(WS-R) TO WS-CZ
     MOVE RH-NP(WS-R) TO WS-NP
     MOVE RH-NJ(WS-R) TO WS-NJ
     MOVE WS-CX TO WS-ED1
     MOVE WS-CZ TO WS-ED2
     MOVE SPACES TO WS-LABEL
     STRING FUNCTION TRIM(RH-NAME(WS-R)) " chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO WS-LABEL
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE SPACES TO TL-CASE
     STRING "test struct jigsaw given " FUNCTION TRIM(WS-LABEL) " when it is built then it is valid with the model's piece and junction counts" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND SP-COUNT = WS-NP AND JJ-COUNT = WS-NJ
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NP
         ADD 1 TO WS-R
         MOVE WS-J TO WS-ED1
         MOVE SPACES TO TL-CASE
         STRING "test struct jigsaw given " FUNCTION TRIM(WS-LABEL) " when it is built then piece " FUNCTION TRIM(WS-ED1) " is the model's (element, origin, rotation, box, ground level delta, projection)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-J <= SP-COUNT
             PERFORM DESCRIBE-PIECE
             IF WS-DESC = RP-DESC(WS-R) AND SP-T-X(WS-J) = RP-X(WS-R) AND SP-T-Y(WS-J) = RP-Y(WS-R) AND SP-T-Z(WS-J) = RP-Z(WS-R)
                AND SP-T-ROT(WS-J) = RP-ROT(WS-R) AND SP-X0(WS-J) = RP-B(WS-R, 1) AND SP-Y0(WS-J) = RP-B(WS-R, 2) AND SP-Z0(WS-J) = RP-B(WS-R, 3)
                AND SP-X1(WS-J) = RP-B(WS-R, 4) AND SP-Y1(WS-J) = RP-B(WS-R, 5) AND SP-Z1(WS-J) = RP-B(WS-R, 6)
                AND SP-F2(WS-J) = RP-GROUND(WS-R) AND SP-T-AUX(WS-J) = RP-PROJ(WS-R) AND SP-TYPE(WS-J) = 60
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NJ
         ADD 1 TO WS-R
         MOVE WS-J TO WS-ED1
         MOVE SPACES TO TL-CASE
         STRING "test struct jigsaw given " FUNCTION TRIM(WS-LABEL) " when it is built then junction " FUNCTION TRIM(WS-ED1) " is the model's (owner, source position, delta, projection)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-J <= JJ-COUNT
             IF JJ-OWNER(WS-J) = RJ-OWNER(WS-R) AND JJ-X(WS-J) = RJ-X(WS-R) AND JJ-Y(WS-J) = RJ-Y(WS-R) AND JJ-Z(WS-J) = RJ-Z(WS-R)
                AND JJ-DELTA(WS-J) = RJ-DELTA(WS-R) AND JJ-PROJ(WS-J) = RJ-PROJ(WS-R)
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
     END-PERFORM
     ADD 1 TO WS-R.

*> WS-DESC the description of the element of piece WS-J as the model prints it: the template without minecraft:, list: and the first sub-element, or feature: and the feature
 DESCRIBE-PIECE.
     MOVE SP-F1(WS-J) TO WS-EL
     MOVE SPACES TO WS-DESC
     EVALUATE JE-KIND(WS-EL)
         WHEN 1
             MOVE JE-LOC(WS-EL)(11:86) TO WS-DESC
         WHEN 2
             MOVE JE-LOC(WS-EL)(11:86) TO WS-DESC
         WHEN 3
             MOVE JS-ELEM(JE-SUB-FIRST(WS-EL)) TO WS-SUB
             STRING "list:" FUNCTION TRIM(JE-LOC(WS-SUB)(11:86)) DELIMITED BY SIZE INTO WS-DESC
         WHEN 4
             STRING "feature:" FUNCTION TRIM(JE-FEATURE(WS-EL)(11:70)) DELIMITED BY SIZE INTO WS-DESC
         WHEN OTHER
             MOVE "empty" TO WS-DESC
     END-EVALUATE.

*> a start that was built is remembered: asked again with the real terrain (which would give other heights) it is the same; and the tables are emptied when they are getting full
 MEMO-CASES.
     MOVE 1 TO JIG-TEST-SURFACE
     MOVE 5 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-PLAINS CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE WS-Y TO WS-SAVE-Y
     MOVE SP-COUNT TO WS-SAVE-N
     MOVE SP-T-Y(WS-SAVE-N) TO WS-SAVE-X
     MOVE 0 TO JIG-TEST-SURFACE
     MOVE 99999 TO SP-T-X(1)
     CALL "STRUCT-FIND-POINT" USING WS-PLAINS CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "test struct jigsaw given a start built before when it is asked again then the same pieces and stub come back from the memory" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND WS-Y = WS-SAVE-Y AND SP-COUNT = WS-SAVE-N AND SP-T-Y(WS-SAVE-N) = WS-SAVE-X AND SP-T-X(1) = 80 AND JJ-COUNT > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the cache is full: a start of another chunk empties the tables first and still gives its pieces
     MOVE 1 TO JIG-TEST-SURFACE
     MOVE 101 TO TP-COUNT
     MOVE -4 TO WS-CX
     MOVE 9 TO WS-CZ
     MOVE JIG-GEN TO WS-SAVE-N
     CALL "STRUCT-FIND-POINT" USING WS-PLAINS CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE 0 TO JIG-TEST-SURFACE
     MOVE "test struct jigsaw given a full template cache when a new start is built then the tables are emptied and the start is built" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JIG-GEN > WS-SAVE-N AND TP-COUNT < 100 AND SP-COUNT > 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the biome of the stub (5.3): with the noise terrain a start is made exactly when the stub is in a biome of the structure; the stub is returned either way
     MOVE 0 TO WS-K
     MOVE 0 TO WS-J
     PERFORM VARYING WS-CX FROM 20 BY 1 UNTIL WS-CX > 29
         MOVE 30 TO WS-CZ
         CALL "STRUCT-FIND-POINT" USING WS-PLAINS CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         CALL "STRUCT-VALID-AT" USING WS-PLAINS WS-X WS-Y WS-Z WS-FLAG
         IF WS-VALID = WS-FLAG
             ADD 1 TO WS-K
         END-IF
         IF WS-VALID = 0
             ADD 1 TO WS-J
         END-IF
     END-PERFORM
     MOVE "test struct jigsaw given ten chunks when their starts are built on the noise terrain then each is made exactly when the stub's biome is the structure's" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct jigsaw given ten chunks when their starts are built on the noise terrain then some have a biome that is not the structure's" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-J > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-JIGSAW.

 COPY CORETEST.

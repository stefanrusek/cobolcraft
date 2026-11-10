*> The loot engine's state (core/src/loot*.cob; docs/protocol/26-loot-and-predicates.md): EXTERNAL.
*> LOOT-WORK: the working copy of the caller's context (LW-C-*, the fields of LOOTCTXF.cpy), the random source of the roll
*> (LW-KIND 1 Xoroshiro128++ with the 128-bit state LW-LO/LW-HI, 2 the Java LCG with its 48-bit state in LW-LO; LW-SEQ the
*> row of LOOT-SEQUENCES it continues, 0 for an explicit seed), the tables being rolled (LW-VIS: the loop guard of 5.1 step 2),
*> the function chain (LW-CHAIN: the entry, pool and table modifiers wrapped around the stack consumer, outermost first, 5.1
*> step 3 and 5.3 step 5), the stacks produced so far (LW-OUT) and the error flag of the number providers (LW-ERR: 9.1, an
*> arithmetic error makes getInt 0).
*> LOOT-SEQUENCES: the named random sequences (section 4 step 5): the three seeding parameters (LQ-SALT, LQ-NO-WORLD-SEED and
*> LQ-NO-SEQUENCE-ID are 1 for include_world_seed / include_sequence_id false; a fresh state includes both) and one generator
*> state per id.
*> LOOT-DOCS: the parsed JSON of the tables, predicates and providers a roll reads (a cache of LD-SLOTS documents over the
*> element store of content/copy/CTSHAPE.cpy; LDS-ADDR is the text address the document was parsed from, so a reloaded
*> element is parsed again; LDS-STAMP is the roll serial (LDS-SERIAL) that last used the slot: a slot used by the current roll is not
*> replaced while another is free). The node layout equals JSONDOC.cpy.
 78 LD-SLOTS             VALUE 24.
 78 LW-MAX-OUT           VALUE 256.
 78 LQ-MAX               VALUE 64.
 01 LOOT-WORK EXTERNAL.
    05 LW-CTX.
       COPY LOOTCTXF REPLACING LEADING ==LC-== BY ==LW-C-==.
    05 LW-KIND              BINARY-LONG.
    05 LW-LO                BINARY-DOUBLE UNSIGNED.
    05 LW-HI                BINARY-DOUBLE UNSIGNED.
    05 LW-SEQ               BINARY-LONG.
    05 LW-ERR               BINARY-LONG.
    05 LW-VIS-COUNT         BINARY-LONG.
    05 LW-VIS               PIC X(112) OCCURS 16 TIMES.
    05 LW-CHAIN-COUNT       BINARY-LONG.
    05 LW-CHAIN             OCCURS 48 TIMES.
       10 LW-CH-SLOT        BINARY-LONG.
       10 LW-CH-NODE        BINARY-LONG.
    05 LW-OUT-COUNT         BINARY-LONG.
    05 LW-OUT               OCCURS 256 TIMES.
       10 LW-OUT-ITEM       BINARY-LONG.
       10 LW-OUT-AMOUNT     BINARY-LONG.
       10 LW-OUT-HANDLE     BINARY-LONG.
 01 LOOT-SEQUENCES EXTERNAL.
    05 LQ-SALT              BINARY-LONG.
    05 LQ-NO-WORLD-SEED     BINARY-LONG.
    05 LQ-NO-SEQUENCE-ID    BINARY-LONG.
    05 LQ-COUNT             BINARY-LONG.
    05 LQ-ENTRY             OCCURS 64 TIMES.
       10 LQ-KEY            PIC X(112).
       10 LQ-LO             BINARY-DOUBLE UNSIGNED.
       10 LQ-HI             BINARY-DOUBLE UNSIGNED.
 01 LOOT-DOCS EXTERNAL.
    05 LDS-NEXT             BINARY-LONG.
    05 LDS-SERIAL           BINARY-LONG.
    05 LDS-ENTRY            OCCURS 24 TIMES.
       10 LDS-REGISTRY      PIC X(48).
       10 LDS-KEY           PIC X(112).
       10 LDS-ADDR          USAGE POINTER.
       10 LDS-STAMP         BINARY-LONG.
       10 LDS-DOC.
          15 LDS-JD-ADDR    USAGE POINTER.
          15 LDS-JD-LENGTH  BINARY-LONG.
          15 LDS-JD-ERROR   PIC 9.
          15 LDS-JD-COUNT   BINARY-LONG.
          15 LDS-NODE       OCCURS 4096 TIMES.
             20 LDS-JN-TYPE       BINARY-LONG.
             20 LDS-JN-PARENT     BINARY-LONG.
             20 LDS-JN-FIRST      BINARY-LONG.
             20 LDS-JN-LAST       BINARY-LONG.
             20 LDS-JN-NEXT       BINARY-LONG.
             20 LDS-JN-COUNT      BINARY-LONG.
             20 LDS-JN-KEY-POS    BINARY-LONG.
             20 LDS-JN-KEY-LENGTH BINARY-LONG.
             20 LDS-JN-POS        BINARY-LONG.
             20 LDS-JN-LENGTH     BINARY-LONG.
             20 LDS-JN-NUM        FLOAT-LONG.

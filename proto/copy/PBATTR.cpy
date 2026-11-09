*> Record of the Update Attributes packet of proto/src/attributes.cob (05b 0x86; the Update Mob
*> Effect packet 0x87 takes plain fields). The wire allows 128 attribute snapshots and no limit on
*> the modifiers of one; this record holds 8 modifiers per snapshot, so a reader meeting more fails.
*> Identifier texts keep an explicit byte length next to a 64-byte area.

 78 PB-AT-MAX-ATTRIBUTES    VALUE 128.    *> snapshots in one packet (wire maximum)
 78 PB-AT-MAX-MODIFIERS     VALUE 8.      *> modifiers in one snapshot (record capacity)
 78 PB-AT-ID-MAX            VALUE 64.     *> bytes of a modifier identifier text

 01 PB-ATTRIBUTES.
    05 PB-AT-ENTITY          BINARY-LONG.   *> entity id VarInt, not negative
    05 PB-AT-COUNT           BINARY-LONG.   *> 0 to PB-AT-MAX-ATTRIBUTES
    05 PB-AT-ENTRY           OCCURS 128 TIMES.
       10 PB-AT-ATTRIBUTE      BINARY-LONG.   *> RegistryId<attribute>, not negative
       10 PB-AT-BASE           FLOAT-LONG.    *> base value
       10 PB-AT-MOD-COUNT      BINARY-LONG.   *> 0 to PB-AT-MAX-MODIFIERS
       10 PB-AT-MODIFIER       OCCURS 8 TIMES.
          15 PB-AT-MOD-ID-LENGTH  BINARY-LONG.
          15 PB-AT-MOD-ID         PIC X(64).
          15 PB-AT-MOD-AMOUNT     FLOAT-LONG.
          15 PB-AT-MOD-OPERATION  BINARY-LONG. *> 0 add, 1 add multiplied base, 2 add multiplied total

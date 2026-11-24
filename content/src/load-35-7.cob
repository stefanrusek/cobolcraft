*> Loader of the data pack file shapes of docs/protocol/35-worldgen-features-7-nether-end-misc.md (features: Nether, End and miscellaneous).
*> LOAD-35-7 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). The files come through the
*> registry loader and JSON-STRICT (23 section 3.2); each is checked against the shape of its type (shapes.cob, CTSHAPE.cpy).
*> Registry worldgen/feature (23 section 2.1): the feature types 35-7 owns: delta_feature (3), stepped_column_cluster (4), end_spike (8.1),
*> chorus_plant (9, no members), end_island (10.1), end_platform (10.2), end_podium (10.3), end_gateway (10.4), void_start_platform (10.5), and the
*> ones section 6.2 and 11 restate: replace_single_block (6.2), bonus_chest (11.1, no members) and template (11.3). Not strict: the other feature
*> types belong to the sibling parts. Groups shared with sibling parts (identical rows everywhere): block_state (D id;o properties), template_entry,
*> template_weighted. The block member of stepped_column_cluster is a state provider value, a registry reference or a bare state (35-2 section 4), so it
*> is checked as any value. The RuleTest of replace_single_block is not read by the document (Open question 2): its target is checked as an object.
*> 48 2.8 (feature / targets): an entry has the members state (a block state: a block id or {id, properties?}, form Q) and target (a rule test object), both required.
*> 48 3.1: end_gateway.exit is an array of integers (optional, 1 of 2) and exact is required; end_spike.spikes is an array (empty in the data), crystal_beam_target an array (the three-element length and integer entries are not checked).
*> 48 3.1: delta_feature size and rim_size are provider objects, contents and rim block ids; stepped_column_cluster has block (a state), integers cluster_reach and column_count, column_reach an integer or a provider; their documented ranges (0..16, 1..150 ...) are limits of the provider value and are not checked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "template_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;a rotations".
    05 FILLER PIC X(24) VALUE "template_weighted".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T data=template_entry;I weight=0..".
    05 FILLER PIC X(24) VALUE "end_spike_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "i centerX;i centerZ;i radius;i height;b guarded".
    05 FILLER PIC X(24) VALUE "block_replacement".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "O target;Q state".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "delta_feature".
    05 FILLER PIC X(600) VALUE "D contents;D rim;V size=int_provider;V rim_size=int_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "stepped_column_cluster".
    05 FILLER PIC X(600) VALUE "Q block;T continue_through=block_predicate;T can_replace=block_predicate;H can" &
        "not_place_on=block;I cluster_reach;I column_count;V column_reach=int_provider;" &
        "V height=int_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_spike".
    05 FILLER PIC X(600) VALUE "L spikes=end_spike_entry;b crystal_invulnerable;a crystal_beam_target".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "chorus_plant".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_island".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_platform".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_podium".
    05 FILLER PIC X(600) VALUE "b active".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_gateway".
    05 FILLER PIC X(600) VALUE "a exit;B exact".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "void_start_platform".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC X(600) VALUE "L targets=block_replacement".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "bonus_chest".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(600) VALUE "L templates=template_weighted;o processors".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 16.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/feature".
 01 WS-GROUP-1            PIC X(24) VALUE "feature".
 01 WS-STRICT-1           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-STRICT-1
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-35-7.

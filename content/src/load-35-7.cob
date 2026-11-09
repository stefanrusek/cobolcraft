*> Loader of the data pack file shapes of docs/protocol/35-worldgen-features-7-nether-end-misc.md (features: Nether, End and miscellaneous).
*> LOAD-35-7 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). The files come through the
*> registry loader and JSON-STRICT (23 section 3.2); each is checked against the shape of its type (shapes.cob, CTSHAPE.cpy).
*> Registry worldgen/feature (23 section 2.1): the feature types 35-7 owns: delta_feature (3), stepped_column_cluster (4), end_spike (8.1),
*> chorus_plant (9, no members), end_island (10.1), end_platform (10.2), end_podium (10.3), end_gateway (10.4), void_start_platform (10.5), and the
*> ones section 6.2 and 11 restate: replace_single_block (6.2), bonus_chest (11.1, no members) and template (11.3). Not strict: the other feature
*> types belong to the sibling parts. Groups shared with sibling parts (identical rows everywhere): block_state (S Name;o Properties), template_entry,
*> template_weighted. The block member of stepped_column_cluster is a state provider value, a registry reference or a bare state (35-2 section 4), so it
*> is checked as any value. The RuleTest of replace_single_block is not read by the document (Open question 2): its target is checked as an object.
*> ASSUMPTION: replace_single_block.targets entries are objects with members target (an object) and state (a block state), both required (35-7 section 6.2 names them: {target: RuleTest, state}).
*> ASSUMPTION: end_gateway.exit and end_spike.crystal_beam_target are arrays (35-7 states a block position [x, y, z]; the three-element length and integer entries are not checked).
*> ASSUMPTION: delta_feature.size/rim_size and stepped_column_cluster provider members accept a number or an object of the provider group; their documented ranges (0..16, 1..150 ...) are limits of the provider value and are not checked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "S Name;o Properties".
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
    05 FILLER PIC X(600) VALUE "O target;T state=block_state".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "delta_feature".
    05 FILLER PIC X(600) VALUE "T contents=block_state;T rim=block_state;V size=int_provider;V rim_size=int_prov" &
        "ider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "stepped_column_cluster".
    05 FILLER PIC X(600) VALUE "X block;T continue_through=block_predicate;T can_replace=block_predicate;H canno" &
        "t_place_on=block;V cluster_reach=int_provider;V column_count=int_provider;V colu" &
        "mn_reach=int_provider;V height=int_provider".
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
    05 FILLER PIC X(600) VALUE "L templates=template_weighted;x processors".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 17.
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

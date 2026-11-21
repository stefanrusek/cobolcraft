*> The paragraphs of the template census (see VILCENSW.cpy): VC-COLLECT fills VC-TPL (names of files with extension VC-EXT below the folder VC-BASE: "structure" and ".nbt" by default, "worldgen/template_pool" and ".json" for the pools) (template ids "village/plains/houses/plains_small_house_1", without namespace and extension) from
*> <VC-ROOT>/data/minecraft/structure/village and /pillager_outpost, VC-TPL-N of them.
 VC-COLLECT.
     MOVE 0 TO VC-TPL-N
     MOVE 2 TO VC-DIR-N
     MOVE "village" TO VC-DIR(1)
     MOVE "pillager_outpost" TO VC-DIR(2)
     MOVE 1 TO VC-DIR-I
     PERFORM UNTIL VC-DIR-I > VC-DIR-N
         MOVE SPACES TO VC-PATH
         STRING FUNCTION TRIM(VC-ROOT) "/data/minecraft/" FUNCTION TRIM(VC-BASE) "/" FUNCTION TRIM(VC-DIR(VC-DIR-I)) DELIMITED BY SIZE INTO VC-PATH
         MOVE LOW-VALUES TO VC-PATHZ
         COMPUTE VC-NAME-LEN = FUNCTION LENGTH(FUNCTION TRIM(VC-PATH))
         MOVE VC-PATH(1:VC-NAME-LEN) TO VC-PATHZ(1:VC-NAME-LEN)
         MOVE 0 TO VC-LIST-COUNT
         CALL STATIC "cc_fs_list" USING BY REFERENCE VC-PATHZ BY REFERENCE VC-LIST
             BY VALUE VC-CAPACITY BY REFERENCE VC-LIST-COUNT RETURNING VC-RC
         IF VC-RC = 0
             MOVE 1 TO VC-PTR
             PERFORM VC-LIST-COUNT TIMES
                 MOVE SPACES TO VC-ENTRY
                 MOVE 0 TO VC-ENTRY-LEN
                 UNSTRING VC-LIST DELIMITED BY X"0A" INTO VC-ENTRY COUNT IN VC-ENTRY-LEN WITH POINTER VC-PTR
                 MOVE SPACES TO VC-NAME
                 IF VC-ENTRY(1:1) = "D" AND VC-DIR-N < 128
                     ADD 1 TO VC-DIR-N
                     STRING FUNCTION TRIM(VC-DIR(VC-DIR-I)) "/" VC-ENTRY(2:VC-ENTRY-LEN - 1) DELIMITED BY SIZE INTO VC-DIR(VC-DIR-N)
                 END-IF
                 IF VC-ENTRY(1:1) = "F" AND VC-ENTRY-LEN > 6 AND VC-TPL-N < 600
                     COMPUTE VC-K = VC-ENTRY-LEN - VC-EXT-LEN + 1
                     IF VC-ENTRY(VC-K:VC-EXT-LEN) = VC-EXT(1:VC-EXT-LEN)
                         ADD 1 TO VC-TPL-N
                         COMPUTE VC-K = VC-ENTRY-LEN - VC-EXT-LEN - 1
                         STRING FUNCTION TRIM(VC-DIR(VC-DIR-I)) "/" VC-ENTRY(2:VC-K) DELIMITED BY SIZE INTO VC-TPL(VC-TPL-N)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
         ADD 1 TO VC-DIR-I
     END-PERFORM.

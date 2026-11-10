*> Render-list submission (research R4; shim-abi.md §9): SUBMIT-FRAME uploads the atlases marked
*> for upload (texture 0 the block atlas, texture 1 the entity atlas, texture 2 the UI atlas,
*> texture 3 the environment atlas, with repeat wrapping) with cc_vk_texture and the render list's
*> meshes with cc_vk_mesh, then records the draws in render-list order between cc_vk_frame_begin
*> (the clear colour) and cc_vk_frame_end. A minimised window skips the frame.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUBMIT-FRAME.
*> USING CLIENT-STATE, presented out (1 = the frame was drawn and presented).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-TEX                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-WRAP                BINARY-LONG.
 01 WS-CLEAR               FLOAT-SHORT OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PRESENTED            BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PRESENTED.
     MOVE CC-TEX-BLOCKS TO WS-TEX
     IF AT-UPLOAD(1) = 1
         CALL STATIC "cc_vk_texture_ex" USING BY VALUE WS-TEX BY VALUE AT-W BY VALUE AT-H
             BY VALUE AT-ADDR BY VALUE AT-MIPS RETURNING WS-RC
         MOVE 0 TO AT-UPLOAD(1)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AN-COUNT
             MOVE 0 TO AN-DIRTY(WS-I)
         END-PERFORM
     END-IF
*>   An animated sprite whose frame changed: just its cell (the whole atlas upload above has it already).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AN-COUNT
         IF AN-DIRTY(WS-I) = 1
             MOVE AN-SPRITE(WS-I) TO WS-S
             CALL STATIC "cc_vk_texture_update" USING BY VALUE WS-TEX BY VALUE AT-X(WS-S)
                 BY VALUE AT-Y(WS-S) BY VALUE AN-FRAME-W(WS-I) BY VALUE AN-FRAME-H(WS-I)
                 BY VALUE AN-OUT(WS-I) RETURNING WS-RC
             MOVE 0 TO AN-DIRTY(WS-I)
         END-IF
     END-PERFORM
     IF AT-UPLOAD(2) = 1
         MOVE CC-TEX-ENTITIES TO WS-TEX
         CALL STATIC "cc_vk_texture" USING BY VALUE WS-TEX BY VALUE EA-W BY VALUE EA-H
             BY VALUE EA-ADDR RETURNING WS-RC
         MOVE 0 TO AT-UPLOAD(2)
     END-IF
     IF AT-UPLOAD(3) = 1
         MOVE CC-TEX-UI TO WS-TEX
         CALL STATIC "cc_vk_texture" USING BY VALUE WS-TEX BY VALUE UA-W BY VALUE UA-H
             BY VALUE UA-ADDR RETURNING WS-RC
         MOVE 0 TO AT-UPLOAD(3)
     END-IF
     IF AT-UPLOAD(4) = 1
         MOVE CC-TEX-ENVIRONMENT TO WS-TEX
         MOVE CC-WRAP-REPEAT TO WS-WRAP
         CALL STATIC "cc_vk_texture_wrap" USING BY VALUE WS-TEX BY VALUE WS-WRAP RETURNING WS-RC
         CALL STATIC "cc_vk_texture" USING BY VALUE WS-TEX BY VALUE XA-W BY VALUE XA-H
             BY VALUE XA-ADDR RETURNING WS-RC
         MOVE 0 TO AT-UPLOAD(4)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         CALL STATIC "cc_vk_mesh" USING BY VALUE RL-U-SLOT(WS-I) BY VALUE RL-U-ADDR(WS-I)
             BY VALUE RL-U-COUNT(WS-I) RETURNING WS-RC
     END-PERFORM
     MOVE 0 TO RL-UPLOAD-COUNT L-PRESENTED
     CALL STATIC "cc_vk_frame_begin" USING BY REFERENCE RL-CLEAR(1) RETURNING WS-RC
     IF WS-RC = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
             CALL STATIC "cc_vk_draw" USING BY VALUE RL-D-SLOT(WS-I) BY VALUE RL-D-PIPELINE(WS-I)
                 BY VALUE RL-D-TEX(WS-I) BY REFERENCE RL-D-MATRIX(WS-I, 1)
         END-PERFORM
         CALL STATIC "cc_vk_frame_end"
         MOVE 1 TO L-PRESENTED
     END-IF
     GOBACK.
 END PROGRAM SUBMIT-FRAME.

*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 10: game events and vibrations. Conventions of particles-42-7.cob.
*> Entry points for the integrator (inputs):
*>   P7-VIBRATION site(X(24)) IN(16 floats) P6-EMITS: vibration_start IN(origin x y z, travel time in ticks): the packet at scheduling (EM-STATE is the travel time); vibration_reload
*>     IN(reload flag, origin x y z, destination x y z, remaining ticks, total ticks, received by a player): nothing unless the flag is set, else the particle at origin + (destination - origin)
*>     (1 - remaining / total) with the remaining ticks, and the sound row reload_cleared when a player received it (the flag is then cleared); elder_guardian IN(x y z of the local player).
*>   P7-ELDER IN(parameter) OUT(1 when the parameter rounds to 1: the curse sound plays).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-VIBRATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS.
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     EVALUATE L-SITE
         WHEN "vibration_start"
             MOVE "vibration" TO WS-N
             MOVE L-I(1) TO WS-V(1)
             MOVE L-I(2) TO WS-V(2)
             MOVE L-I(3) TO WS-V(3)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             COMPUTE EM-STATE(EM-COUNT) = L-I(4)
         WHEN "vibration_reload"
             IF L-I(1) NOT = 0
                 MOVE "vibration" TO WS-N
                 COMPUTE WS-F = 1 - L-I(8) / L-I(9)
                 COMPUTE WS-V(1) = L-I(2) + (L-I(5) - L-I(2)) * WS-F
                 COMPUTE WS-V(2) = L-I(3) + (L-I(6) - L-I(3)) * WS-F
                 COMPUTE WS-V(3) = L-I(4) + (L-I(7) - L-I(4)) * WS-F
                 CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
                 COMPUTE EM-STATE(EM-COUNT) = L-I(8)
                 IF L-I(10) NOT = 0
                     ADD 1 TO EM-SOUND-COUNT
                     MOVE "reload_cleared" TO EM-SOUND(EM-SOUND-COUNT)
                 END-IF
             END-IF
         WHEN "elder_guardian"
             MOVE "elder_guardian" TO WS-N
             MOVE L-I(1) TO WS-V(1)
             MOVE L-I(2) TO WS-V(2)
             MOVE L-I(3) TO WS-V(3)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-EVALUATE
     GOBACK.
 END PROGRAM P7-VIBRATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-ELDER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) >= 0.5 AND L-I(1) < 1.5
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM P7-ELDER.

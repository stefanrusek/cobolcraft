*> Game core host API records and constants (specs/001-cobolcraft-complete/contracts/core-host-api.md §1).
*> Contract artifact (constitution 3.3): produced from the contract document, never edited by lanes.
*> Hosts (server program, client single-player host) drive the core only through the entry points of
*> core-host-api.md §2 with these records.

*> Connection kinds (CORE-CONN-OPEN).
 78 CORE-CONN-NETWORK          VALUE 0.   *> compression per 01 §3 and wire-profile.md §2
 78 CORE-CONN-MEMORY           VALUE 1.   *> no compression, no encryption (02 Offline mode)

*> Settings: FR-009 plus the single-player/open-to-others extras (FR-007, FR-016, FR-017)
 01 CORE-SETTINGS.
    05 CS-DEFAULT-MODE        PIC 9.            *> 0 survival, 1 creative
    05 CS-DESCRIPTION         PIC X(256).       *> server-list description (US2-2)
    05 CS-VIEW-DISTANCE       BINARY-LONG.      *> 2..32
    05 CS-PLAYER-COMBAT       PIC 9.            *> 1 enabled
    05 CS-HOSTILE-MOBS        PIC 9.
    05 CS-WEATHER-CHANGES     PIC 9.
    05 CS-EXTRA-DIMENSIONS    PIC 9.
    05 CS-ALLOW-LIST-ENFORCED PIC 9.
    05 CS-PACK-OFFERED        PIC 9.
    05 CS-PACK-URL            PIC X(1024).
    05 CS-PACK-SHA1           PIC X(40).
    05 CS-PACK-ID             PIC X(36).        *> UUID text
    05 CS-PACK-REQUIRED       PIC 9.
    05 CS-PACK-PROMPT         PIC X(256).       *> empty = none
    05 CS-HOST-KIND           PIC 9.            *> 0 dedicated server, 1 single-player, 2 opened to others
    05 CS-HOST-NAME           PIC X(16).        *> kinds 1-2: the host player's offline name (holds operator status)
    05 CS-GUEST-MODE          PIC 9.            *> kind 2: game mode for joining players
    05 CS-GUEST-OPERATOR      PIC 9.            *> kind 2: 1 = guests may use operator commands
    05 CS-NEW-WORLD-NAME      PIC X(64).        *> name stored in level.dat when a world is created

 01 CORE-BUFFER.                                *> a caller-owned byte buffer
    05 CB-ADDR                USAGE POINTER.
    05 CB-CAPACITY            BINARY-LONG.
    05 CB-LENGTH              BINARY-LONG.

 01 CORE-STATUS.
    05 CST-RUN-STATE          PIC 9.            *> 0 running, 1 stop requested (stop command), 2 stopped
    05 CST-PLAYERS-ONLINE     BINARY-LONG.

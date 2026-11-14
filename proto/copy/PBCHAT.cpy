*> Records of the chat and command packets of proto/src/chat-commands.cob (package-private; the
*> argument lists of the simple packets are plain fields). Documents: 05a 0x0F Command Suggestions,
*> 0x21 Disguised Chat, 0x42 Player Chat and the composites ChatTypeBound, SignedMessageBodyPacked,
*> FilterMask; 05c 0x07 Chat Command and 0x0F Command Suggestion.
*> A text component here is a kind (PB-TEXT-PLAIN, -LITERAL or -TRANSLATE of PROTO.cpy), a byte
*> length and the text or translation key; a component with translation arguments is not
*> representable (a reader sets PB-ERROR on one). A kind of -1 means "absent" where a component is
*> optional.

 78 PB-SG-MAX               VALUE 128.    *> suggestion entries of one response
 78 PB-SG-TEXT-MAX          VALUE 128.    *> bytes of a suggestion text or tooltip
 78 PB-PCH-SEEN-MAX          VALUE 20.     *> last-seen entries of a message body
 78 PB-PCH-CONTENT-MAX       VALUE 768.    *> bytes of a message (256 UTF-16 code units)
 78 PB-CT-TEXT-MAX          VALUE 256.    *> bytes of a sender or target name, message or content
 78 PB-PCH-FILTER-MAX        VALUE 32.     *> bytes of a partial filter mask

*> Command Suggestions (05a 0x0F): transaction id, replaced range, entries with optional tooltip.
 01 PB-SUGGESTIONS.
    05 PB-SG-TRANSACTION     BINARY-LONG.
    05 PB-SG-START           BINARY-LONG.
    05 PB-SG-LENGTH          BINARY-LONG.
    05 PB-SG-COUNT           BINARY-LONG.   *> 0 to PB-SG-MAX
    05 PB-SG-ENTRY           OCCURS 128 TIMES.
       10 PB-SG-TEXT-LENGTH    BINARY-LONG.
       10 PB-SG-TEXT           PIC X(128).
       10 PB-SG-TOOLTIP-KIND   BINARY-LONG.   *> -1 none, else a PB-TEXT kind
       10 PB-SG-TOOLTIP-LENGTH BINARY-LONG.
       10 PB-SG-TOOLTIP        PIC X(128).

*> ChatTypeBound: the chat type as a Holder reference (registry id; wire id + 1), the sender name and
*> an optional target name.
 01 PB-CHAT-BOUND.
    05 PB-CB-TYPE            BINARY-LONG.
    05 PB-CB-SENDER-KIND     BINARY-LONG.
    05 PB-CB-SENDER-LENGTH   BINARY-LONG.
    05 PB-CB-SENDER          PIC X(256).
    05 PB-CB-TARGET-KIND     BINARY-LONG.   *> -1 none
    05 PB-CB-TARGET-LENGTH   BINARY-LONG.
    05 PB-CB-TARGET          PIC X(256).

*> Player Chat (05a 0x42) apart from its ChatTypeBound (the second argument of PB-PUT-PLAYER-CHAT).
*> A last-seen entry is a PackedMessageSignature: PB-PCH-SEEN-REF 0 = the full signature follows in
*> PB-PCH-SEEN-SIGNATURE, n > 0 = a reference to cache index n - 1.
 01 PB-PLAYER-CHAT.
    05 PB-PCH-GLOBAL-INDEX    BINARY-LONG.
    05 PB-PCH-SENDER          PIC X(16).
    05 PB-PCH-INDEX           BINARY-LONG.
    05 PB-PCH-SIGNATURE-PRESENT BINARY-LONG.   *> 0 or 1
    05 PB-PCH-SIGNATURE       PIC X(256).
    05 PB-PCH-CONTENT-LENGTH  BINARY-LONG.
    05 PB-PCH-CONTENT         PIC X(768).
    05 PB-PCH-TIMESTAMP       BINARY-DOUBLE.
    05 PB-PCH-SALT            BINARY-DOUBLE.
    05 PB-PCH-SEEN-COUNT      BINARY-LONG.   *> 0 to PB-PCH-SEEN-MAX
    05 PB-PCH-SEEN            OCCURS 20 TIMES.
       10 PB-PCH-SEEN-REF       BINARY-LONG.
       10 PB-PCH-SEEN-SIGNATURE PIC X(256).
    05 PB-PCH-UNSIGNED-KIND   BINARY-LONG.   *> -1 absent
    05 PB-PCH-UNSIGNED-LENGTH BINARY-LONG.
    05 PB-PCH-UNSIGNED        PIC X(256).
    05 PB-PCH-FILTER-KIND     BINARY-LONG.   *> 0 pass through, 1 fully filtered, 2 partially
    05 PB-PCH-FILTER-LENGTH   BINARY-LONG.   *> partial: bytes of the mask, 0 to PB-PCH-FILTER-MAX
    05 PB-PCH-FILTER-MASK     PIC X(32).

*> Disguised Chat (05a 0x21) apart from its ChatTypeBound (the second argument of PB-PUT-DISGUISED-CHAT).
 01 PB-DISGUISED-CHAT.
    05 PB-DC-KIND            BINARY-LONG.
    05 PB-DC-LENGTH          BINARY-LONG.
    05 PB-DC-MESSAGE         PIC X(256).

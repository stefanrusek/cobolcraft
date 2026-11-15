*> A rectangle of portal blocks (docs/protocol/39-portals.md section 4.3): its minimum corner (the lowest x, y, z cell) and its sizes along
*> the portal's axis (PR-W) and along Y (PR-H); PR-AXIS 0 for X, 1 for Z.
 01 PORTAL-RECT.
    05 PR-X                   BINARY-LONG.
    05 PR-Y                   BINARY-LONG.
    05 PR-Z                   BINARY-LONG.
    05 PR-W                   BINARY-LONG.
    05 PR-H                   BINARY-LONG.
    05 PR-AXIS                BINARY-LONG.

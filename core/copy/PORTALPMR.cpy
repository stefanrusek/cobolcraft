*> A position, move and rotation (docs/protocol/39-portals.md section 6.3, PositionMoveRotation): position, yaw and pitch in degrees, velocity.
*> COPY it with REPLACING for each instance, e.g. COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==L-BASE== LEADING ==PMR-== BY ==B-==.
 01 PORTAL-PMR.
    05 PMR-X                  FLOAT-LONG.
    05 PMR-Y                  FLOAT-LONG.
    05 PMR-Z                  FLOAT-LONG.
    05 PMR-YAW                FLOAT-LONG.
    05 PMR-PITCH              FLOAT-LONG.
    05 PMR-DX                 FLOAT-LONG.
    05 PMR-DY                 FLOAT-LONG.
    05 PMR-DZ                 FLOAT-LONG.

#!/usr/bin/env python3
"""Independent expected values of client/tests/test_ground_item_faces.cob (T32300): which faces of a dropped block item face the camera.

A dropped block item is a cube of side 0.25 (12 section 8.2, block/block ground display: scale 0.25) centred 0.2875 above the entity's feet
at age 0 (34-9 section 9.2: bob 0.1 + base 0.1875, phase 0 for entity id 64). For an eye at E the face with outward normal n faces the camera
exactly when n . (E - centre) > 0.125 (the eye is on the outer side of the face plane). The vertex order of a face is clockwise seen from
outside (the terrain's winding, CC-PIPE-TRANSLUCENT-CULL front face clockwise), so for a triangle v1 v2 v3 of a visible face
cross(v2 - v1, v3 - v2) . (v1 - eye) > 0. Prints one line per case: name, the sorted face letters (S N E W U D)."""
FACES = {"S": (0, 0, 1), "N": (0, 0, -1), "E": (1, 0, 0), "W": (-1, 0, 0), "U": (0, 1, 0), "D": (0, -1, 0)}
ENTITY = (10.5, 64.0, 10.5)
CENTRE = (ENTITY[0], ENTITY[1] + 0.2875, ENTITY[2])
CASES = {
    "A eye (10.5, 66, 8.5)": (10.5, 66.0, 8.5),
    "B eye (12, 65, 12)": (12.0, 65.0, 12.0),
    "C eye (9, 63, 9)": (9.0, 63.0, 9.0),
    "D eye (10, 64, 10)": (10.0, 64.0, 10.0),
}
for name, eye in CASES.items():
    seen = []
    for letter, n in FACES.items():
        if sum(n[i] * (eye[i] - CENTRE[i]) for i in range(3)) > 0.125:
            seen.append(letter)
    print(name, "".join(sorted(seen)))

#!/bin/sh
# Regenerate the 34-4 and 34-5 entity model sources and tests from docs/protocol/34-*.
# Usage: client/tests/gen/regen.sh   (then: git diff --stat client/ must be empty)
set -e
cd "$(dirname "$0")"
# the layer lists are rebuilt from scratch, in section order
echo '[]' > state/layers_done.json; echo '[]' > state/layers5_done.json; echo '{}' > state/defined.json
for n in 2 3 4 5 6 7 8 9 10 11 12; do python3 s$n.py; done
for n in $(ls s5_*.py | sed 's/s5_//; s/.py//' | sort -n); do python3 s5_$n.py; done
for n in 0 1 2 3 4 5 6 7 8 9 10 11 12; do python3 t$n.py; done
for n in $(ls t5_*.py | sed 's/t5_//; s/.py//' | sort -n); do python3 t5_$n.py; done

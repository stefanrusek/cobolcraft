#!/bin/sh
# Regenerate the 34-4 to 34-7 entity model sources and tests from docs/protocol/34-*.
# Usage: client/tests/gen/regen.sh   (then: git diff --stat client/ must be empty)
set -e
cd "$(dirname "$0")"
# the layer lists are rebuilt from scratch, in section order
echo '[]' > state/layers_done.json; echo '[]' > state/layers5_done.json; echo '{}' > state/defined.json; echo '{}' > state/layers6_done.json; echo '{}' > state/layers7_done.json
for n in 2 3 4 5 6 7 8 9 10 11 12; do python3 s$n.py; done
for n in $(ls s5_*.py | sed 's/s5_//; s/.py//' | sort -n); do python3 s5_$n.py; done
for n in 0 1 2 3 4 5 6 7 8 9 10 11 12; do python3 t$n.py; done
for n in $(ls t5_*.py | sed 's/t5_//; s/.py//' | sort -n); do python3 t5_$n.py; done
for n in $(ls s6_[0-9]*.py | sed 's/s6_//; s/.py//' | sort -n); do python3 s6_$n.py; done
for n in $(ls t6_[0-9]*.py | sed 's/t6_//; s/.py//' | sort -n); do python3 t6_$n.py; done
for n in $(ls s7_[0-9]*.py | sed 's/s7_//; s/.py//' | sort -n); do python3 s7_$n.py; done
for n in $(ls t7_[0-9]*.py | sed 's/t7_//; s/.py//' | sort -n); do python3 t7_$n.py; done

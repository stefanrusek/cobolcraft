#!/bin/sh
# usage: mut.sh testname file(relative to repo) perl-substitution [tag]
R=/Users/stefanrusek/Code/cobolcraft-lane-client
cd $R
BAK=$R/scratchpad/ui2/.bak-$(basename "$2")
cp "$2" "$BAK"
perl -0pi -e "$3" "$2"
if cmp -s "$2" "$BAK"; then echo "MUTATION DID NOT APPLY"; exit 3; fi
sleep 1; touch "$2"
OUTF=$R/scratchpad/ui2/mut-$1${4:+-$4}.txt
$R/scratchpad/ui2/rt.sh "$1" 200 > $OUTF 2>&1
cp "$BAK" "$2"; sleep 1; touch "$2"
echo "fails: $(grep -c FAIL $OUTF)"
grep FAIL $OUTF | head -3

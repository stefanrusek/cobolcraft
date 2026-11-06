#!/bin/sh
# Prints the identity of a clean-room source artifact: its file name, size, SHA-256, and for a jar its version.json
# name and protocol (when present), and whether it matches the artifact recorded in docs/protocol/README.md.
# Usage: artifact-id.sh <path>
set -eu
if [ $# -ne 1 ] || [ ! -f "$1" ]; then
    echo "usage: $0 <artifact path>" >&2
    exit 2
fi
path=$1
sha=$(shasum -a 256 "$path" | cut -d' ' -f1)
echo "file:    $(basename "$path")"
echo "size:    $(wc -c < "$path" | tr -d ' ') bytes"
echo "sha256:  $sha"
case "$path" in
    *.jar|*.zip)
        if unzip -l "$path" version.json >/dev/null 2>&1; then
            unzip -p "$path" version.json | python3 -c 'import json,sys; v=json.load(sys.stdin); print("version: %s (protocol %s, world %s)" % (v.get("name"), v.get("protocol_version"), v.get("world_version")))'
        fi
        ;;
esac
root=$(cd "$(dirname "$0")/../../../.." && pwd)
if grep -q "$sha" "$root/docs/protocol/README.md" 2>/dev/null; then
    echo "matches: the artifact recorded in docs/protocol/README.md"
else
    echo "matches: none (a new artifact: record it in the new document's header and the README)"
fi

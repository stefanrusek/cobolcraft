#!/bin/sh
# Throwaway test CA and server certificate for tools/testsrv/testsrv.py (research R9, R10; T195).
# Test infrastructure: never shipped, never trusted outside a test process.
#
# usage: make-ca.sh [OUTDIR]        (default: <repo>/build/testsrv)
#
# Writes into OUTDIR:
#   ca.pem       test CA certificate: point SSL_CERT_FILE at it in the test process
#   ca.key       test CA private key
#   server.pem   server certificate for DNS:localhost and IP:127.0.0.1, signed by the test CA
#   server.key   server private key
# Existing files are replaced. Uses the openssl CLI (Homebrew openssl@3 when present, research R1).
set -eu
REPO=$(cd "$(dirname "$0")/../.." && pwd)
OUT=${1:-$REPO/build/testsrv}

OPENSSL=openssl
if command -v brew >/dev/null 2>&1; then
    candidate="$(brew --prefix)/opt/openssl@3/bin/openssl"
    if [ -x "$candidate" ]; then
        OPENSSL=$candidate
    fi
fi

mkdir -p "$OUT"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

cat > "$WORK/ca.ext" <<'EOF'
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF

cat > "$WORK/server.ext" <<'EOF'
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:localhost, IP:127.0.0.1
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid
EOF

# Test CA (self-signed).
"$OPENSSL" req -new -newkey rsa:2048 -nodes -keyout "$WORK/ca.key" -subj "/CN=CobolCraft Test CA" \
    -out "$WORK/ca.csr" 2>/dev/null
"$OPENSSL" x509 -req -in "$WORK/ca.csr" -signkey "$WORK/ca.key" -days 3650 -sha256 \
    -extfile "$WORK/ca.ext" -out "$WORK/ca.pem" 2>/dev/null

# Server certificate for localhost / 127.0.0.1, signed by the test CA.
"$OPENSSL" req -new -newkey rsa:2048 -nodes -keyout "$WORK/server.key" -subj "/CN=localhost" \
    -out "$WORK/server.csr" 2>/dev/null
"$OPENSSL" x509 -req -in "$WORK/server.csr" -CA "$WORK/ca.pem" -CAkey "$WORK/ca.key" \
    -set_serial "0x$("$OPENSSL" rand -hex 8)" -days 3650 -sha256 -extfile "$WORK/server.ext" \
    -out "$WORK/server.pem" 2>/dev/null

"$OPENSSL" verify -CAfile "$WORK/ca.pem" "$WORK/server.pem" >/dev/null

for file in ca.pem ca.key server.pem server.key; do
    cp "$WORK/$file" "$OUT/$file"
done
chmod 600 "$OUT/ca.key" "$OUT/server.key"
echo "make-ca: wrote ca.pem ca.key server.pem server.key to $OUT"

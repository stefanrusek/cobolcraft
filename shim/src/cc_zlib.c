/* cc_zlib: one-shot compression (contracts/shim-abi.md §5). Glue only: zlib's z_stream layout and the
 * deflateInit2/inflateInit2 macros over versioned functions cannot be used cleanly from COBOL.
 *
 * Mode CC_ZLIB = zlib wrapper, CC_GZIP = gzip wrapper, CC_RAW = raw deflate (window bits 15, 31, -15).
 * Deflate uses level 6. A too small output buffer is CC_SMALL (the caller enlarges and retries);
 * corrupt or truncated inflate input is CC_BADDATA. Anything else goes through cc_fatal. */
#include <string.h>
#include <zlib.h>

#include "ccshim.h"

static int window_bits(int32_t mode) {
    if (mode < CC_ZLIB || mode > CC_RAW) cc_fatal("cc_zlib: invalid mode");
    static const int bits[] = {15, 15 + 16, -15};
    return bits[mode];
}

static void attach(z_stream *s, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap) {
    memset(s, 0, sizeof *s);
    s->next_in = (Bytef *)in;
    s->avail_in = (uInt)inlen;
    s->next_out = out;
    s->avail_out = (uInt)cap;
}

int32_t cc_deflate(int32_t mode, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap,
                   int32_t *outlen) {
    z_stream s;
    attach(&s, in, inlen, out, cap);
    int bits = window_bits(mode);
    if (deflateInit2(&s, 6, Z_DEFLATED, bits, 8, Z_DEFAULT_STRATEGY) != Z_OK) cc_fatal("cc_deflate: deflateInit2 failed");
    int result = deflate(&s, Z_FINISH);
    *outlen = (int32_t)s.total_out;
    deflateEnd(&s);
    if (result != Z_STREAM_END && result != Z_OK && result != Z_BUF_ERROR) cc_fatal("cc_deflate: deflate failed");
    return result == Z_STREAM_END ? 0 : CC_SMALL;
}

int32_t cc_inflate(int32_t mode, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap,
                   int32_t *outlen) {
    z_stream s;
    attach(&s, in, inlen, out, cap);
    int bits = window_bits(mode);
    if (inflateInit2(&s, bits) != Z_OK) cc_fatal("cc_inflate: inflateInit2 failed");
    int result = inflate(&s, Z_FINISH);
    *outlen = (int32_t)s.total_out;
    int output_full = s.avail_out == 0;
    inflateEnd(&s);
    if (result == Z_STREAM_END) return 0;
    if (result == Z_MEM_ERROR || result == Z_STREAM_ERROR) cc_fatal("cc_inflate: inflate failed");
    /* Z_BUF_ERROR or Z_OK with the output full: more output space is needed; anything else
     * (Z_DATA_ERROR, Z_NEED_DICT, input ending before the stream end) is corrupt input. */
    return (result == Z_BUF_ERROR || result == Z_OK) && output_full ? CC_SMALL : CC_BADDATA;
}

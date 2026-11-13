/* cc_png: PNG file writer (contracts/shim-delta.md, cc_png_write). Glue only: the checksums and the
 * deflate stream come from zlib, COBOL has neither. Writes an 8-bit RGBA image, filter 0 on every row,
 * one IDAT chunk, no ancillary chunks. Returns 0, or CC_FAILED when the file cannot be written. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#include "ccshim.h"

static void put32(uint8_t *p, uint32_t v) {
    p[0] = (uint8_t)(v >> 24);
    p[1] = (uint8_t)(v >> 16);
    p[2] = (uint8_t)(v >> 8);
    p[3] = (uint8_t)v;
}

/* One chunk: length, type, data, CRC32 over type and data. */
static int chunk(FILE *f, const char *type, const uint8_t *data, uint32_t length) {
    uint8_t head[8], tail[4];
    put32(head, length);
    memcpy(head + 4, type, 4);
    uLong crc = crc32(crc32(0L, Z_NULL, 0), (const Bytef *)type, 4);
    if (length > 0) crc = crc32(crc, data, length);
    put32(tail, (uint32_t)crc);
    return fwrite(head, 1, 8, f) == 8 && (length == 0 || fwrite(data, 1, length, f) == length) && fwrite(tail, 1, 4, f) == 4;
}

int32_t cc_png_write(const char *path, int32_t w, int32_t h, const uint8_t *rgba) {
    if (w < 1 || h < 1) cc_fatal("cc_png_write: invalid size");
    size_t row = (size_t)w * 4, raw_size = (row + 1) * (size_t)h;
    uint8_t *raw = malloc(raw_size);
    uLongf packed_size = compressBound((uLong)raw_size);
    uint8_t *packed = malloc(packed_size);
    if (raw == NULL || packed == NULL) cc_fatal("cc_png_write: out of memory");
    for (int32_t y = 0; y < h; y++) {
        raw[(size_t)y * (row + 1)] = 0;
        memcpy(raw + (size_t)y * (row + 1) + 1, rgba + (size_t)y * row, row);
    }
    if (compress2(packed, &packed_size, raw, (uLong)raw_size, 6) != Z_OK) cc_fatal("cc_png_write: deflate failed");
    free(raw);
    int32_t rc = CC_FAILED;
    FILE *f = fopen(path, "wb");
    if (f != NULL) {
        static const uint8_t signature[8] = {0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A};
        uint8_t header[13];
        put32(header, (uint32_t)w);
        put32(header + 4, (uint32_t)h);
        header[8] = 8;  /* bit depth */
        header[9] = 6;  /* colour type: RGBA */
        header[10] = header[11] = header[12] = 0;
        int ok = fwrite(signature, 1, 8, f) == 8 && chunk(f, "IHDR", header, 13) && chunk(f, "IDAT", packed, (uint32_t)packed_size) &&
                 chunk(f, "IEND", NULL, 0);
        ok = (fclose(f) == 0) && ok;
        if (ok) rc = 0;
    }
    free(packed);
    return rc;
}

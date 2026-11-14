/* Implementation test of cc_png_write (contracts/shim-delta.md §14): the file of a 2 x 2 image has the PNG signature, an IHDR
 * chunk with the CRC32 computed independently (Python zlib.crc32 of "IHDR" + 2,2,8,6,0,0,0 is 72B60D24), an IDAT chunk whose
 * inflated bytes are the rows with filter byte 0, and the 12-byte IEND chunk (CRC AE426082); an unwritable path is CC_FAILED. */
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "ccshim.h"
#include "testlib.h"

int main(void) {
    static const uint8_t rgba[16] = {1, 2, 3, 255, 4, 5, 6, 255, 7, 8, 9, 128, 10, 11, 12, 0};
    char path[] = "/tmp/test_cc_png_XXXXXX";
    int fd = mkstemp(path);
    close(fd);
    tl_int("test cc_png_write returns 0", 0, cc_png_write(path, 2, 2, rgba));
    uint8_t file[512];
    FILE *f = fopen(path, "rb");
    size_t n = f ? fread(file, 1, sizeof file, f) : 0;
    if (f) fclose(f);
    unlink(path);
    static const uint8_t head[8 + 8 + 13 + 4] = {0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 13, 'I', 'H', 'D', 'R', 0, 0, 0, 2,
                                                  0, 0, 0, 2, 8, 6, 0, 0, 0, 0x72, 0xB6, 0x0D, 0x24};
    tl_bytes("test cc_png_write signature and IHDR chunk with its CRC32", head, sizeof head, file, sizeof head);
    static const uint8_t iend[12] = {0, 0, 0, 0, 'I', 'E', 'N', 'D', 0xAE, 0x42, 0x60, 0x82};
    tl_bytes("test cc_png_write ends with the IEND chunk", iend, sizeof iend, file + n - 12, 12);
    uint32_t idat_len = (uint32_t)file[33] << 24 | (uint32_t)file[34] << 16 | (uint32_t)file[35] << 8 | file[36];
    tl_str("test cc_png_write second chunk is IDAT", "IDAT", (char[]){(char)file[37], (char)file[38], (char)file[39], (char)file[40], 0});
    tl_int("test cc_png_write file length is the three chunks", 33 + 12 + (long long)idat_len + 12, (long long)n);
    uint8_t raw[64];
    int32_t raw_len = 0;
    tl_int("test cc_png_write IDAT inflates", 0, cc_inflate(CC_ZLIB, file + 41, (int32_t)idat_len, raw, sizeof raw, &raw_len));
    static const uint8_t expected[18] = {0, 1, 2, 3, 255, 4, 5, 6, 255, 0, 7, 8, 9, 128, 10, 11, 12, 0};
    tl_bytes("test cc_png_write rows are filter byte 0 and the RGBA bytes", expected, sizeof expected, raw, (size_t)raw_len);
    tl_int("test cc_png_write to an unwritable path is CC_FAILED", CC_FAILED, cc_png_write("/nonexistent-dir/x.png", 2, 2, rgba));
    return 0;
}

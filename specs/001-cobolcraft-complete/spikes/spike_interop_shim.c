/* spike: C side of COBOL<->C interop probe (throwaway) */
#include <stdint.h>
#include <string.h>
#include <stdio.h>
int spk_add(int a, int b) { return a + b; }
int spk_fill(unsigned char *buf, int len) { for (int i = 0; i < len; i++) buf[i] = (unsigned char)(i + 1); return len; }
int spk_read_double(const double *d, char *out, int outlen) { return snprintf(out, outlen, "%.6f", *d); }

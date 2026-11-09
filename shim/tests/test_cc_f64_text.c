/* Implementation test of cc_f64_from_text: the nearest double of a decimal text (strtod), over the
 * vectors of f64_vectors.txt, where Python's float() is the independent reference; and 0.1 + 0.2 through
 * the text path (a decimal literal loaded by COBOL is not always the nearest double, research R5). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "f64_vectors.h"

int main(void) {
    FILE *in = fopen(F64_VECTOR_FILE, "r");
    char line[512];
    int count = 0;
    char first[256] = "";
    if (in == NULL) {
        tl_str("test cc_f64_from_text vector file opens", "ok", "missing " F64_VECTOR_FILE);
        return 0;
    }
    while (fgets(line, sizeof line, in) != NULL) {
        char *t[4];
        int nt = 0;
        for (char *p = strtok(line, " \n"); p != NULL && nt < 4; p = strtok(NULL, " \n")) t[nt++] = p;
        if (nt != 3 || strcmp(t[0], "from_text") != 0) continue;
        double r = 0;
        cc_f64_from_text(t[1], &r);
        count++;
        if (!f64_same(r, t[2]) && first[0] == '\0') snprintf(first, sizeof first, "from_text %s expected %s", t[1], t[2]);
    }
    fclose(in);
    char want[64];
    snprintf(want, sizeof want, "all %d vectors match", count);
    tl_str("test cc_f64_from_text over its vectors", count > 0 ? want : "at least one vector", first[0] != '\0' ? first : want);

    double a = 0, b = 0, r = 0;
    cc_f64_from_text("0.1", &a);
    cc_f64_from_text("0.2", &b);
    cc_f64_add(&a, &b, &r);
    tl_int("test cc_f64_from_text then add: 0.1 + 0.2 bits", 0x3FD3333333333334LL, (long long)f64_bits_of(r));
    return 0;
}

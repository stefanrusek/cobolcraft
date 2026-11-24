/* Test infrastructure (excluded from coverage): reads shim/tests/f64_vectors.txt, written by
 * gen_f64_vectors.py from independent computations, and runs the vectors of one group of cc_f64_*
 * functions. One test line per function: "all <n> vectors match", or the first mismatch. Tests run from
 * the repository root. */
#ifndef F64_VECTORS_H
#define F64_VECTORS_H

#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ccshim.h"
#include "testlib.h"

#define F64_VECTOR_FILE "shim/tests/f64_vectors.txt"

enum f64_kind { K_D1, K_D2, K_D3, K_D_I32, K_D_I64, K_I32_D, K_I64_D };
enum f64_group { G_ARITH, G_LIBM };

struct f64_fn {
    const char *name;
    enum f64_group group;
    enum f64_kind kind;
    void *fn;
};

#define FN(n, g, k) {#n, g, k, (void *)cc_f64_##n}
static const struct f64_fn f64_fns[] = {
    FN(add, G_ARITH, K_D2), FN(sub, G_ARITH, K_D2), FN(mul, G_ARITH, K_D2), FN(div, G_ARITH, K_D2),
    FN(floor, G_ARITH, K_D1), FN(sqrt, G_ARITH, K_D1),
    FN(ceil, G_LIBM, K_D1), FN(f32_round, G_LIBM, K_D1), FN(to_i32, G_LIBM, K_D_I32),
    FN(to_i64, G_LIBM, K_D_I64), FN(i32_to_f32, G_LIBM, K_I32_D), FN(round_f32, G_LIBM, K_D_I32),
    FN(round_f64, G_LIBM, K_D_I64), FN(fmod, G_LIBM, K_D2), FN(min_j, G_LIBM, K_D2), FN(max_j, G_LIBM, K_D2),
    FN(clamp_f32, G_LIBM, K_D3), FN(clamp_f64, G_LIBM, K_D3), FN(signum, G_LIBM, K_D1),
    FN(nextdown, G_LIBM, K_D1), FN(next_up, G_LIBM, K_D1), FN(abs_f32, G_LIBM, K_D1),
    FN(abs_f64, G_LIBM, K_D1), FN(log1p, G_LIBM, K_D1), FN(to_radians, G_LIBM, K_D1),
    FN(copysign, G_LIBM, K_D2), FN(pow, G_LIBM, K_D2), FN(log, G_LIBM, K_D1), FN(sin, G_LIBM, K_D1),
    FN(cos, G_LIBM, K_D1), FN(asin, G_LIBM, K_D1), FN(acos, G_LIBM, K_D1), FN(atan2_lib, G_LIBM, K_D2),
    FN(atan2_mth, G_LIBM, K_D2), FN(sin_tab, G_LIBM, K_D1), FN(cos_tab, G_LIBM, K_D1),
    FN(f64_bits, G_LIBM, K_D_I64), FN(f64_from_bits, G_LIBM, K_I64_D), FN(fast_inv_sqrt, G_LIBM, K_D1),
    FN(inv_sqrt, G_LIBM, K_D1), FN(lerp_f32, G_LIBM, K_D3), FN(lerp_f64, G_LIBM, K_D3),
};
#undef FN

static inline double f64_parse(const char *tok) {
    uint64_t b = strcmp(tok, "nan") == 0 ? 0x7FF8000000000000ULL : strtoull(tok, NULL, 16);
    double x;
    memcpy(&x, &b, sizeof x);
    return x;
}

static inline uint64_t f64_bits_of(double x) {
    uint64_t b;
    memcpy(&b, &x, sizeof b);
    return b;
}

/* 1 when `got` is the expected double (any NaN matches the token nan). */
static inline int f64_same(double got, const char *tok) {
    if (strcmp(tok, "nan") == 0) return got != got;
    return f64_bits_of(got) == f64_bits_of(f64_parse(tok));
}

/* Runs one vector (operand and result tokens); returns 1 on a match, else describes the miss. */
static inline int f64_run(const struct f64_fn *f, char **t, char *why, size_t why_size) {
    double a = 0, b = 0, c = 0, r = 0;
    int32_t i32 = 0;
    int64_t i64 = 0;
    int ok = 0;
    switch (f->kind) {
    case K_D1:
        a = f64_parse(t[0]);
        ((void (*)(const double *, double *))f->fn)(&a, &r);
        ok = f64_same(r, t[1]);
        break;
    case K_D2:
        a = f64_parse(t[0]);
        b = f64_parse(t[1]);
        ((void (*)(const double *, const double *, double *))f->fn)(&a, &b, &r);
        ok = f64_same(r, t[2]);
        break;
    case K_D3:
        a = f64_parse(t[0]);
        b = f64_parse(t[1]);
        c = f64_parse(t[2]);
        ((void (*)(const double *, const double *, const double *, double *))f->fn)(&a, &b, &c, &r);
        ok = f64_same(r, t[3]);
        break;
    case K_D_I32:
        a = f64_parse(t[0]);
        ((void (*)(const double *, int32_t *))f->fn)(&a, &i32);
        ok = i32 == (int32_t)strtol(t[1], NULL, 10);
        break;
    case K_D_I64:
        a = f64_parse(t[0]);
        ((void (*)(const double *, int64_t *))f->fn)(&a, &i64);
        ok = i64 == (int64_t)strtoll(t[1], NULL, 10);
        break;
    case K_I32_D:
        i32 = (int32_t)strtol(t[0], NULL, 10);
        ((void (*)(const int32_t *, double *))f->fn)(&i32, &r);
        ok = f64_same(r, t[1]);
        break;
    case K_I64_D:
        i64 = (int64_t)strtoll(t[0], NULL, 10);
        ((void (*)(const int64_t *, double *))f->fn)(&i64, &r);
        ok = f64_same(r, t[1]);
        break;
    }
    if (!ok) snprintf(why, why_size, "%s on %s: expected %s", f->name, t[0], t[f->kind == K_D2 ? 2 : f->kind == K_D3 ? 3 : 1]);
    return ok;
}

/* Runs every vector of the functions of `group`; one test line each (a function without a vector fails). */
static inline void f64_run_group(enum f64_group group) {
    size_t n = sizeof f64_fns / sizeof f64_fns[0];
    int *count = calloc(n, sizeof *count);
    char **first = calloc(n, sizeof *first);
    FILE *in = fopen(F64_VECTOR_FILE, "r");
    char line[512];
    if (in == NULL) {
        tl_str("test cc_f64 vector file opens", "ok", "missing " F64_VECTOR_FILE);
        free(count);
        free(first);
        return;
    }
    while (fgets(line, sizeof line, in) != NULL) {
        char *t[8];
        int nt = 0;
        for (char *p = strtok(line, " \n"); p != NULL && nt < 8; p = strtok(NULL, " \n")) t[nt++] = p;
        if (nt < 3) continue;
        for (size_t i = 0; i < n; i++) {
            if (f64_fns[i].group != group || strcmp(f64_fns[i].name, t[0]) != 0) continue;
            char why[256];
            count[i]++;
            if (!f64_run(&f64_fns[i], t + 1, why, sizeof why) && first[i] == NULL) first[i] = strdup(why);
        }
    }
    fclose(in);
    for (size_t i = 0; i < n; i++) {
        if (f64_fns[i].group != group) continue;
        char name[96], want[64];
        snprintf(name, sizeof name, "test cc_f64_%s over its vectors", f64_fns[i].name);
        snprintf(want, sizeof want, "all %d vectors match", count[i]);
        tl_str(name, count[i] > 0 ? want : "at least one vector", first[i] != NULL ? first[i] : want);
        free(first[i]);
    }
    free(count);
    free(first);
}

#endif

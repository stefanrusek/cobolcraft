/* C glue ABI of the shim package (specs/001-cobolcraft-complete/contracts/shim-abi.md §1 to §9).
 * Contract artifact (constitution 3.3): produced from the contract document, never edited by lanes.
 * COBOL mirror: contract/copy/CCSHIM.cpy.
 *
 * Conventions (§1): every function is extern and prefixed cc_; integers are int32_t; buffers are
 * uint8_t * plus an explicit int32_t length or capacity; handles are positive (0 is never a valid
 * handle); 0 is success, positive values are the defined outcomes below, there are no negative return
 * codes; any failure that is not a defined outcome calls cc_fatal. Strings are NUL-terminated UTF-8. */
#ifndef COBOLCRAFT_CCSHIM_H
#define COBOLCRAFT_CCSHIM_H

#include <stdint.h>

/* Defined outcomes (§1, §3 to §7). */
#define CC_AGAIN       1 /* nothing available now / still in progress */
#define CC_ADDR_IN_USE 2 /* cc_net_listen: port taken */
#define CC_UNRESOLVED  3 /* cc_net_connect, cc_tls_connect: host name does not resolve */
#define CC_CLOSED      4 /* refused, reset, closed, failed handshake, end of console input */
#define CC_SMALL       5 /* output capacity too small: caller enlarges and retries */
#define CC_BADDATA     6 /* cc_inflate: corrupt input */
#define CC_NOTFOUND    7 /* cc_fs_list: directory absent */
#define CC_FAILED      8 /* cc_png_write, cc_vk_screenshot_result: the file could not be written */

/* Compression modes (§5). */
#define CC_ZLIB 0 /* zlib wrapper (01 §3, 07 §5.2) */
#define CC_GZIP 1 /* gzip (07 §5.1) */
#define CC_RAW  2 /* raw deflate, zip entries (08 §1.1) */

/* Event kinds of the 24-byte event record (§8). */
#define CC_EV_KEY_DOWN      1 /* a = GLFW key code, b = modifiers, c = repeat flag */
#define CC_EV_KEY_UP        2 /* a = GLFW key code, b = modifiers */
#define CC_EV_TEXT          3 /* a = Unicode code point */
#define CC_EV_BUTTON_DOWN   4 /* a = button, b = modifiers, x, y = cursor position */
#define CC_EV_BUTTON_UP     5 /* a = button, b = modifiers, x, y = cursor position */
#define CC_EV_CURSOR        6 /* x, y = position (free cursor) or accumulated delta (captured) */
#define CC_EV_SCROLL        7 /* x, y = scroll offsets */
#define CC_EV_RESIZE        8 /* a = window width, b = window height */
#define CC_EV_CLOSE_REQUEST 9

/* Mouse buttons of event kinds 4 and 5 (§8). */
#define CC_BUTTON_LEFT   0
#define CC_BUTTON_RIGHT  1
#define CC_BUTTON_MIDDLE 2

/* Event record (§8): 24 bytes, little-endian. */
typedef struct cc_event {
    int32_t kind;
    int32_t a;
    int32_t b;
    int32_t c;
    float x;
    float y;
} cc_event;
_Static_assert(sizeof(cc_event) == 24, "cc_event is the 24-byte event record of shim-abi.md §8");

/* Pipelines (§9). */
#define CC_PIPE_OPAQUE      0 /* depth test and write, no blend */
#define CC_PIPE_TRANSLUCENT 1 /* depth test, no write, alpha blend */
#define CC_PIPE_UI          2 /* no depth, alpha blend */
#define CC_PIPE_CRUMBLING   3 /* depth test (less or equal, biased), no write, rgb = 2 x src x dst, alpha = src, texels under alpha 0.1 discarded */

/* Texture ids (§9). RGBA8, sampled NEAREST, clamp-to-edge unless cc_vk_texture_wrap set repeat. */
#define CC_TEX_BLOCKS      0 /* block and item atlas */
#define CC_TEX_ENTITIES    1 /* entity atlas */
#define CC_TEX_UI          2 /* font and UI atlas */
#define CC_TEX_ENVIRONMENT 3 /* environment atlas */
#define CC_TEX_PARTICLES   4 /* particle atlas */

/* Texture wrap modes of cc_vk_texture_wrap (§9). */
#define CC_WRAP_CLAMP  0 /* clamp-to-edge (the default) */
#define CC_WRAP_REPEAT 1 /* repeat */

/* Vertex buffer slots of cc_vk_mesh (§9). */
#define CC_MESH_SLOT_MIN 1
#define CC_MESH_SLOT_MAX 65535

/* Vertex (§9): 11 x float32 = 44 bytes. The colour drawn is texel rgb x (r, g, b) x
 * max(brightness, sky x daylight), the alpha texel alpha x alpha. Untinted vertices carry (1, 1, 1),
 * vertices that do not follow the daylight carry sky 0. */
typedef struct cc_vertex {
    float x;
    float y;
    float z;
    float u;
    float v;
    float brightness;
    float alpha;
    float sky;
    float r;
    float g;
    float b;
} cc_vertex;
_Static_assert(sizeof(cc_vertex) == 44, "cc_vertex is the 44-byte vertex of shim-abi.md §9");

/* §2 cc_fatal: writes "FATAL <what>: <detail>" to standard error and exits with status 1. */
_Noreturn void cc_fatal(const char *what);

/* §3 cc_net: TCP sockets (non-blocking, TCP_NODELAY on every connection). */
int32_t cc_net_listen(int32_t port, int32_t *handle_out, int32_t *port_out);
int32_t cc_net_accept(int32_t listener, int32_t *handle_out);
int32_t cc_net_connect(const char *host, int32_t port, int32_t *handle_out);
int32_t cc_net_status(int32_t h);
int32_t cc_net_send(int32_t h, const uint8_t *buf, int32_t len, int32_t *sent_out);
int32_t cc_net_recv(int32_t h, uint8_t *buf, int32_t cap, int32_t *got_out);
void cc_net_close(int32_t h);
int32_t cc_net_poll(int32_t timeout_ms, const int32_t *handles, int32_t count, int32_t include_console,
                    uint8_t *ready_out);
int32_t cc_net_local_addresses(uint8_t *out, int32_t cap);

/* §4 cc_con: console input. */
int32_t cc_con_readline(uint8_t *buf, int32_t cap, int32_t *len_out);

/* §5 cc_zlib: compression (level 6). */
int32_t cc_deflate(int32_t mode, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap,
                   int32_t *outlen);
int32_t cc_inflate(int32_t mode, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap,
                   int32_t *outlen);

/* §6 cc_tls: TLS 1.2+ client (system trust, honours SSL_CERT_FILE). TLS handles are accepted by
 * cc_net_poll; send, recv and close have the signatures and outcomes of their cc_net counterparts. */
int32_t cc_tls_connect(const char *host, int32_t port, int32_t *handle_out);
int32_t cc_tls_status(int32_t h);
int32_t cc_tls_send(int32_t h, const uint8_t *buf, int32_t len, int32_t *sent_out);
int32_t cc_tls_recv(int32_t h, uint8_t *buf, int32_t cap, int32_t *got_out);
void cc_tls_close(int32_t h);

/* §7 cc_fs: directory enumeration ("<F|D><name>\n" per entry, byte order, no . and ..). */
int32_t cc_fs_list(const char *dir, uint8_t *out, int32_t cap, int32_t *count_out);

/* §8 cc_win: window and input (GLFW). cc_win_poll: cap is the buffer capacity in bytes (§1 buffer
 * convention), count_out the number of 24-byte event records written. */
int32_t cc_win_open(int32_t width, int32_t height, const char *title, int32_t visible);
int32_t cc_win_poll(uint8_t *events, int32_t cap, int32_t *count_out);
void cc_win_size(int32_t *win_w, int32_t *win_h, int32_t *fb_w, int32_t *fb_h);
void cc_win_capture_cursor(int32_t on);
void cc_win_close(void);

/* §9 cc_vk: Vulkan submission. Matrices are column-major. */
int32_t cc_vk_init(void);
int32_t cc_vk_texture(int32_t tex_id, int32_t w, int32_t h, const uint8_t *rgba);
int32_t cc_vk_texture_wrap(int32_t tex_id, int32_t wrap);
int32_t cc_vk_mesh(int32_t slot, const float *verts, int32_t vertex_count);
int32_t cc_vk_frame_begin(const float clear_rgba[4]);
void cc_vk_draw(int32_t slot, int32_t pipeline, int32_t tex_id, const float matrix[16]);
void cc_vk_frame_end(void);
void cc_vk_shutdown(void);

/* §10 cc_f64: IEEE double arithmetic by reference (specs/002-client-polish/contracts/shim-delta.md;
 * function set fixed by 10 §16). COBOL cannot receive a C double return value, so every operand and
 * result is passed by reference and every function returns nothing. Float (binary32) values travel as
 * doubles that are exactly representable in float; the _f32 forms round their result to float.
 * add and mul are fma(a,1,b) and fma(a,b,0) so results are exactly IEEE binary64; the library is built
 * without contraction and without fast-math. int results are int32_t or int64_t by reference. */
void cc_f64_add(const double *a, const double *b, double *r);
void cc_f64_sub(const double *a, const double *b, double *r);
void cc_f64_mul(const double *a, const double *b, double *r);
void cc_f64_div(const double *a, const double *b, double *r);
void cc_f64_floor(const double *a, double *r);
void cc_f64_ceil(const double *a, double *r);
void cc_f64_sqrt(const double *a, double *r);
void cc_f64_from_text(const char *text, double *r);          /* strtod of a decimal text */
void cc_f64_f32_round(const double *a, double *r);           /* nearest binary32, ties to even (10 §16.2) */
void cc_f64_to_i32(const double *a, int32_t *r);             /* d2i: truncate, saturate, NaN gives 0 */
void cc_f64_to_i64(const double *a, int64_t *r);             /* d2l */
void cc_f64_i32_to_f32(const int32_t *a, double *r);         /* i2f */
void cc_f64_round_f32(const double *a, int32_t *r);          /* Math.round(float): exact floor(x + 1/2) */
void cc_f64_round_f64(const double *a, int64_t *r);          /* Math.round(double) */
void cc_f64_fmod(const double *a, const double *b, double *r);
void cc_f64_min_j(const double *a, const double *b, double *r);   /* Math.min: NaN propagates, -0.0 < 0.0 */
void cc_f64_max_j(const double *a, const double *b, double *r);
void cc_f64_clamp_f32(const double *v, const double *lo, const double *hi, double *r);
void cc_f64_clamp_f64(const double *v, const double *lo, const double *hi, double *r);
void cc_f64_signum(const double *a, double *r);
void cc_f64_nextdown(const double *a, double *r);
void cc_f64_next_up(const double *a, double *r);
void cc_f64_abs_f32(const double *a, double *r);             /* sign bit cleared */
void cc_f64_abs_f64(const double *a, double *r);
void cc_f64_log1p(const double *a, double *r);
void cc_f64_to_radians(const double *a, double *r);          /* a * 0.017453292519943295 */
void cc_f64_copysign(const double *a, const double *b, double *r);
void cc_f64_pow(const double *a, const double *b, double *r);
void cc_f64_log(const double *a, double *r);
void cc_f64_sin(const double *a, double *r);
void cc_f64_cos(const double *a, double *r);
void cc_f64_asin(const double *a, double *r);
void cc_f64_acos(const double *a, double *r);
void cc_f64_atan2_lib(const double *y, const double *x, double *r);   /* libm atan2 */
void cc_f64_atan2_mth(const double *y, const double *x, double *r);   /* the table routine of 10 §16.4 */
void cc_f64_sin_tab(const double *a, double *r);             /* the 65536-entry table sine of 10 §16.3 */
void cc_f64_cos_tab(const double *a, double *r);
void cc_f64_f64_bits(const double *a, int64_t *r);           /* raw bits */
void cc_f64_f64_from_bits(const int64_t *a, double *r);
void cc_f64_fast_inv_sqrt(const double *a, double *r);       /* 10 §16.4 */
void cc_f64_inv_sqrt(const double *a, double *r);            /* 1/sqrt(a), 10 §16.2 (inferred replacement of org.joml.Math.invsqrt) */
void cc_f64_lerp_f32(const double *t, const double *a, const double *b, double *r);
void cc_f64_lerp_f64(const double *t, const double *a, const double *b, double *r);

/* §11 texture upload with mip levels and sub-rectangle update (US3/US5): cc_vk_texture is
 * cc_vk_texture_ex with mip_levels 1; cc_vk_texture_update replaces one rectangle of the base level and
 * regenerates the mip levels it touches. Both return 0 or call cc_fatal. */
int32_t cc_vk_texture_ex(int32_t tex_id, int32_t w, int32_t h, const uint8_t *rgba, int32_t mip_levels);
int32_t cc_vk_texture_update(int32_t tex_id, int32_t x, int32_t y, int32_t w, int32_t h, const uint8_t *rgba);

/* §9 addition: the daylight factor (0 to 1, default 1) that scales every vertex's sky term in the draws that
 * follow; read through a pointer (a COBOL FLOAT-SHORT is passed BY REFERENCE). */
void cc_vk_daylight(const float *daylight);

/* §9 addition: the fog of the draws that follow (12 section 3.3), read through a pointer to 8 floats: the fog colour r, g, b, its strength a
 * (0 to 1: 0 is no fog, the default and the state after cc_vk_init), the start and end distance in blocks and the two focal terms p00 and p11
 * of the projection (the matrix entries that scale x and y: the shader recovers the camera-relative position from the clip coordinates).
 * A fragment's colour becomes lerp(colour, rgb, value x a) with value 0 up to start, 1 from end and (d - start) / (end - start) between, d the
 * distance from the camera (spherical). Applies to the world and entity pipelines (not the UI). */
void cc_vk_fog(const float *fog);

/* §9 addition: clears the depth attachment between the world pass and the hand pass (US20). */
void cc_vk_clear_depth(void);

/* §12 cc_open_path: starts opener with path as its only argument (posix_spawn) and returns 0 at once, or
 * CC_NOTFOUND when the opener cannot be started. Does not wait (US4). */
int32_t cc_open_path(const char *opener, const char *path);

/* §14 screenshot: cc_png_write writes an 8-bit RGBA image (w * h * 4 bytes, row 0 at the top) as a PNG file (filter 0, one
 * IDAT, zlib level 6) and returns 0 or CC_FAILED. cc_vk_screenshot(path) asks for the frame that the
 * next cc_vk_frame_end presents to be saved as a PNG at path (exactly the pixels presented, in RGBA order whatever the swapchain
 * format) and returns 0, or CC_AGAIN when an earlier request has not been served yet. cc_vk_screenshot_result returns CC_AGAIN
 * while the request waits for its frame, then 0 (file written) or CC_FAILED (not written, or the swapchain image could not be
 * read), and 0 when there never was a request. */
int32_t cc_png_write(const char *path, int32_t w, int32_t h, const uint8_t *rgba);
int32_t cc_vk_screenshot(const char *path);
int32_t cc_vk_screenshot_result(void);

/* §13 cc_u64: unsigned 64-bit wrap-around arithmetic by reference (GnuCOBOL has none; BINARY-DOUBLE UNSIGNED items).
 * r = a + b, a * b modulo 2^64, a << n, a >> n (logical), rotate left by n (n is int32_t, 1 to 63; shl and shr give 0 for
 * 64 or more). The result may alias an operand. */
void cc_u64_add(const uint64_t *a, const uint64_t *b, uint64_t *r);
void cc_u64_mul(const uint64_t *a, const uint64_t *b, uint64_t *r);
void cc_u64_shl(const uint64_t *a, const int32_t *n, uint64_t *r);
void cc_u64_shr(const uint64_t *a, const int32_t *n, uint64_t *r);
void cc_u64_rotl(const uint64_t *a, const int32_t *n, uint64_t *r);

/* §15 cc_wk: worker processes (core generation worker). cc_wk_spawn forks the caller: the parent gets a slot id (1 to 8, or -1
 * when none is free or fork fails), the child gets 0 and talks to the parent only through cc_wk_child_read / cc_wk_child_write
 * and ends with cc_wk_child_exit (_exit). cc_wk_send writes n bytes to the worker (n, or -1); cc_wk_recv reads without blocking
 * (bytes read, 0 when nothing is there yet, -1 at end of file or for an unknown slot); cc_wk_stop frees the slot and reaps the
 * process (force 1 kills it first, 0 waits for it to end after end of input; -1 for an unknown slot). cc_wk_child_read reads
 * exactly n bytes (n, 0 at end of input, -1 on error); cc_wk_child_write writes all n (n, or -1). */
int32_t cc_wk_spawn(void);
int32_t cc_wk_send(int32_t slot, const uint8_t *buf, int32_t n);
int32_t cc_wk_recv(int32_t slot, uint8_t *buf, int32_t n);
int32_t cc_wk_stop(int32_t slot, int32_t force);
int32_t cc_wk_child_read(uint8_t *buf, int32_t n);
int32_t cc_wk_child_write(const uint8_t *buf, int32_t n);
void cc_wk_child_exit(void);
/* cc_wk_cpus: the number of processors online (at least 1), for sizing the worker pool. */
int32_t cc_wk_cpus(void);

#endif

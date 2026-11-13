# Contract: C glue ABI (`shim` ↔ `proto`, `core`, `server`, `client`)

**Status**: frozen at plan time (constitution 3.3). Changing a signature or a semantic below is a plan-level
decision. **Materialized** in the Foundational phase as `contract/include/ccshim.h` (C prototypes and
constants) and `contract/copy/CCSHIM.cpy` (COBOL constants and record layouts). Both are produced from this
document and are the only artifacts lanes compile against.

**Scope** (constitution Principle I, v1.2.0; research R5): COBOL calls C libraries directly wherever the
call can be expressed cleanly. The `shim` package holds only glue for calls that cannot, and contains no game
or protocol logic. Each module and its reason:

| Module | Wraps | Why COBOL cannot call it cleanly |
|---|---|---|
| `cc_fatal` | `fputs`/`exit` from glue code | Glue modules need a fatal path in C; also callable from COBOL so every program has one fatal-exit format. |
| `cc_net` | BSD sockets, `getaddrinfo`, `fcntl`, `poll`, `errno`, `getifaddrs` | `struct sockaddr*`/`addrinfo`/`ifaddrs`/`pollfd` platform layouts, variadic `fcntl`, `errno` is a macro. |
| `cc_con` | `read` on standard input after `poll` | Non-blocking readiness needs `pollfd`; line assembly across partial reads stays byte-level (no logic). |
| `cc_zlib` | `deflateInit2`/`inflateInit2`/`deflate`/`inflate` | `z_stream` struct layout; `*Init2` are macros over versioned functions. |
| `cc_tls` | OpenSSL `SSL_*` | `SSL_set_tlsext_host_name` and friends are macros over `SSL_ctrl`; non-blocking handshake needs `errno`/`SSL_get_error` mapping. |
| `cc_fs` | `opendir`/`readdir`/`closedir` | `struct dirent` platform layout (GnuCOBOL 3.2 has no `C$LIST-DIRECTORY`, `spike_fileio.out.txt`). |
| `cc_win` | GLFW | Keyboard, character (layout-aware Unicode text, so non-US layouts work), mouse button, cursor and scroll input arrive only through C callbacks; `glfwInitVulkanLoader` takes a function pointer. |
| `cc_vk` | Vulkan | Every call takes nested platform structs (`Vk*CreateInfo`); the module only submits COBOL-built geometry. |

Called **directly from COBOL** (no glue): OpenSSL `EVP_sha1`, `EVP_md5`, `EVP_Digest` (one-shot digest:
`CALL STATIC "EVP_Digest" USING BY REFERENCE data BY VALUE length(BINARY-DOUBLE UNSIGNED) BY REFERENCE
digest BY REFERENCE digest-length BY VALUE algorithm-pointer BY VALUE NULL`; proved by
`spikes/spike_direct_openssl.out.txt`), GnuCOBOL `CBL_*` file routines, and `DISPLAY` for console output.
A new direct call needs no contract change; a new glue function does.

## 1. Conventions

- C11, all functions `extern`, prefixed `cc_`. Integer parameters are `int32_t` or `int64_t`; buffers are
  `uint8_t *` plus an explicit `int32_t` length or capacity. No function retains a caller's pointer after it
  returns, except where "retains" is stated.
- COBOL calls them as `CALL STATIC "cc_..." USING BY VALUE <BINARY-LONG|BINARY-DOUBLE|POINTER> ...
  BY REFERENCE <buffer> RETURNING <BINARY-LONG>` (research R2).
- Handles are positive `int32_t`. 0 is never a valid handle.
- Return codes: `0` success; positive values are defined outcomes listed per function (for example
  `CC_AGAIN = 1` "nothing available now"); there are no negative return codes.
- **Fatal errors** (FR-012, research R14): any failure not listed as a defined outcome calls
  `cc_fatal(const char *what)`, which writes `FATAL <what>: <detail>` to standard error and exits with status 1.
  `cc_fatal` is also callable from COBOL (`CALL STATIC "cc_fatal" USING BY REFERENCE <z-string>`), and is the
  single fatal-exit path of every program.
- Strings crossing the boundary are NUL-terminated byte strings (`z-string`), UTF-8.

## 2. `cc_fatal` — fatal exit

| Function | Behaviour |
|---|---|
| `void cc_fatal(const char *what)` | See §1. Does not return. |

Console output (server console lines US13-3, US15; logged failures FR-012) is COBOL `DISPLAY`, not glue.

## 3. `cc_net` — TCP sockets (non-blocking)

| Function | Behaviour |
|---|---|
| `int32_t cc_net_listen(int32_t port, int32_t *handle_out, int32_t *port_out)` | Binds `0.0.0.0:port` (port 0 = system-chosen, used by US17), listens. `port_out` = actual port. Returns 0, or `CC_ADDR_IN_USE = 2`. |
| `int32_t cc_net_accept(int32_t listener, int32_t *handle_out)` | 0 with a new non-blocking connection handle, or `CC_AGAIN = 1`. |
| `int32_t cc_net_connect(const char *host, int32_t port, int32_t *handle_out)` | Resolves `host` (blocking DNS), starts a non-blocking connect. 0 = started; `CC_UNRESOLVED = 3`. Completion is observed through `cc_net_poll` (writable) then `cc_net_status`. |
| `int32_t cc_net_status(int32_t h)` | 0 connected, `CC_AGAIN = 1` still connecting, `CC_CLOSED = 4` refused/reset/closed. |
| `int32_t cc_net_send(int32_t h, const uint8_t *buf, int32_t len, int32_t *sent_out)` | Sends up to `len` bytes; `sent_out` may be less than `len`. 0, or `CC_CLOSED = 4`. |
| `int32_t cc_net_recv(int32_t h, uint8_t *buf, int32_t cap, int32_t *got_out)` | 0 with `got_out > 0`, `CC_AGAIN = 1` (no data), `CC_CLOSED = 4` (peer closed or reset). |
| `void cc_net_close(int32_t h)` | Closes a connection or listener. |
| `int32_t cc_net_poll(int32_t timeout_ms, const int32_t *handles, int32_t count, int32_t include_console, uint8_t *ready_out)` | Waits up to `timeout_ms` for any listed handle (and, if `include_console`, standard input) to become readable or, for connecting handles, writable. `ready_out[i]` = 1 for ready handles; `ready_out[count]` = 1 if the console has input. Returns 0. |
| `int32_t cc_net_local_addresses(uint8_t *out, int32_t cap)` | Writes the non-loopback IPv4 addresses as dotted strings, each ending in `\n` (US17-1). Only whole entries are written; one that does not fit in `cap` is left out. Returns the number of entries written (never `CC_SMALL`). |

TCP_NODELAY is set on every connection.

## 4. `cc_con` — console input

| Function | Behaviour |
|---|---|
| `int32_t cc_con_readline(uint8_t *buf, int32_t cap, int32_t *len_out)` | Non-blocking: 0 with one complete line (without newline), `CC_AGAIN = 1`, or `CC_CLOSED = 4` at end of input. A line longer than `cap` is cut to `cap` bytes and the rest of it is dropped. An unterminated last line is returned at end of input; every later call returns `CC_CLOSED`. |

## 5. `cc_zlib` — compression

`mode`: `CC_ZLIB = 0` (zlib wrapper: 01 §3, 07 §5.2), `CC_GZIP = 1` (07 §5.1), `CC_RAW = 2` (zip entries,
08 §1.1).

| Function | Behaviour |
|---|---|
| `int32_t cc_deflate(int32_t mode, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap, int32_t *outlen)` | Level 6. 0, or `CC_SMALL = 5` if `cap` is too small (caller enlarges and retries). |
| `int32_t cc_inflate(int32_t mode, const uint8_t *in, int32_t inlen, uint8_t *out, int32_t cap, int32_t *outlen)` | 0, `CC_SMALL = 5`, or `CC_BADDATA = 6` (corrupt input: a defined outcome because 01 §3.3, 08 §2.3 and §9 define what the caller does). |

## 6. `cc_tls` — TLS

| Function | Behaviour |
|---|---|
| `int32_t cc_tls_connect(const char *host, int32_t port, int32_t *handle_out)` | Non-blocking TCP connect plus TLS 1.2+ client handshake with system trust and host-name verification (OpenSSL default verify paths; honours the standard `SSL_CERT_FILE`). 0 = started, `CC_UNRESOLVED = 3`. |
| `int32_t cc_tls_status(int32_t h)` | 0 ready, `CC_AGAIN = 1` handshaking, `CC_CLOSED = 4` failed (connect, handshake or verification). |
| `int32_t cc_tls_send(...)`, `cc_tls_recv(...)`, `void cc_tls_close(int32_t h)` | Same signatures and outcomes as `cc_net_send/recv/close`. TLS handles are accepted by `cc_net_poll`. |

## 7. `cc_fs` — directory enumeration

| Function | Behaviour |
|---|---|
| `int32_t cc_fs_list(const char *dir, uint8_t *out, int32_t cap, int32_t *count_out)` | Writes each entry as `<type><name>\n`, type `F` file or `D` directory, excluding `.` and `..`, sorted by byte order. 0, `CC_SMALL = 5`, or `CC_NOTFOUND = 7` (any directory that cannot be opened: absent, not a directory, or unreadable). Types follow symbolic links. On `CC_SMALL` nothing is written and the count is 0; the caller enlarges `out` and calls again. |

Everything else on files (create, read, write, delete, rename, make directory) is COBOL `CBL_*` routines
(research R2).

## 8. `cc_win` — window and input

| Function | Behaviour |
|---|---|
| `int32_t cc_win_open(int32_t width, int32_t height, const char *title, int32_t visible)` | Calls `glfwInitVulkanLoader(vkGetInstanceProcAddr)` then `glfwInit`, creates the window (no client API). `visible` = 0 only in shim tests. 0. |
| `int32_t cc_win_poll(uint8_t *events, int32_t cap, int32_t *count_out)` | Pumps the OS event queue and copies queued events as fixed 24-byte records (layout below). |
| `void cc_win_size(int32_t *win_w, int32_t *win_h, int32_t *fb_w, int32_t *fb_h)` | Window size (input coordinates) and framebuffer size (pixels). They differ on Retina displays (research R3). |
| `void cc_win_capture_cursor(int32_t on)` | Hides and locks the cursor for mouse-look (1) or releases it (0). |
| `void cc_win_close(void)` | Destroys the window and terminates GLFW. |

Event record (24 bytes, little-endian): `int32 kind`, `int32 a`, `int32 b`, `int32 c`, `float32 x`,
`float32 y`.

| kind | Meaning | a | b | c | x, y |
|---|---|---|---|---|---|
| 1 | key down | key code (GLFW key code) | modifiers | repeat flag | — |
| 2 | key up | key code | modifiers | 0 | — |
| 3 | text character | Unicode code point after the OS keyboard layout and input method (any layout) | 0 | 0 | — |
| 4 | mouse button down | button (0 left, 1 right, 2 middle) | modifiers | 0 | cursor position |
| 5 | mouse button up | button | modifiers | 0 | cursor position |
| 6 | cursor moved | 0 | 0 | 0 | position (free cursor) or accumulated delta (captured) |
| 7 | scroll | 0 | 0 | 0 | x offset, y offset |
| 8 | window resized | window w | window h | 0 | — |
| 9 | close requested | 0 | 0 | 0 | — |

Key codes are GLFW's numeric values, re-declared as named constants in `CCSHIM.cpy`; COBOL never includes
GLFW headers.

## 9. `cc_vk` — Vulkan submission

Pipelines: `CC_PIPE_OPAQUE = 0` (depth test+write, no blend), `CC_PIPE_TRANSLUCENT = 1` (depth test, no
write, alpha blend), `CC_PIPE_UI = 2` (no depth, alpha blend), `CC_PIPE_CRUMBLING = 3` (the crack overlay of 12 section 4.3: depth test less-or-equal with a bias toward the camera, no depth write; colour = 2 x source x destination (blend factors DST_COLOR and SRC_COLOR), alpha = source alpha; a fragment whose texel alpha times vertex alpha is under 0.1 is discarded). Vertex: 11 x `float32` = 44 bytes
(x, y, z, u, v, brightness, alpha, sky, r, g, b), field offsets 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40. The drawn colour is
`texel.rgb x (r, g, b) x max(brightness, sky x daylight)` and the drawn alpha `texel.a x alpha` (the UI pipeline ignores brightness,
sky and daylight: colour `texel.rgb x (r, g, b)`). An untinted vertex carries `r = g = b = 1`; a vertex that does not follow the
daylight carries `sky = 0`. A mesh baked once (a terrain section) puts the light the daylight does not scale in `brightness` and the
sky-light term in `sky`, so a change of daylight needs no new mesh (research R4). Textures are RGBA8, sampled NEAREST, clamp-to-edge
unless `cc_vk_texture_wrap` sets repeat for the texture id (`CC_WRAP_CLAMP = 0`, `CC_WRAP_REPEAT = 1`).

| Function | Behaviour |
|---|---|
| `int32_t cc_vk_init(void)` | Instance (portability enumeration), surface on the `cc_win` window, device (swapchain + portability subset), swapchain, depth buffer, pipelines from the build's SPIR-V. 0. |
| `int32_t cc_vk_texture(int32_t tex_id, int32_t w, int32_t h, const uint8_t *rgba)` | Creates or replaces texture `tex_id` (0 = block/item atlas, 1 = entity atlas, 2 = font and UI atlas, 3 = environment atlas, 4 = particle atlas). 0. |
| `int32_t cc_vk_texture_wrap(int32_t tex_id, int32_t wrap)` | Sets the wrap mode (`CC_WRAP_CLAMP` or `CC_WRAP_REPEAT`, both axes) used by the next `cc_vk_texture` of `tex_id`; a texture already uploaded keeps its mode until replaced. Default clamp-to-edge, and `cc_vk_shutdown` resets every id to it. 0; an invalid id or mode is fatal. |
| `int32_t cc_vk_mesh(int32_t slot, const float *verts, int32_t vertex_count)` | Creates, replaces or (with `vertex_count` = 0) frees vertex buffer `slot` (1 to 65535). 0. |
| `int32_t cc_vk_frame_begin(const float clear_rgba[4])` | Acquires the next image (recreating the swapchain after a resize) and begins recording. 0, or `CC_AGAIN = 1` when the window is minimised (frame skipped). |
| `void cc_vk_daylight(const float *daylight)` | Sets the daylight factor (0 to 1; 1 until set, and again after `cc_vk_init`) that the draws recorded afterwards use (push constant, with the matrix, read by the vertex shader). |
| `void cc_vk_draw(int32_t slot, int32_t pipeline, int32_t tex_id, const float matrix[16])` | Records a draw of the slot's triangles with the matrix as push constant (column-major). |
| `void cc_vk_frame_end(void)` | Submits and presents (FIFO). |
| `void cc_vk_shutdown(void)` | Waits idle and destroys everything. |

## 15. `cc_wk` — worker processes (002 generation worker)

Added by the 002 operator decision (docs/design/generation-worker.md): chunk generation runs outside the game loop. A
thread cannot share the COBOL runtime, so the glue forks. `cc_wk_spawn` returns a slot id (1 to 8) in the parent, 0 in the
child, -1 when no slot is free or the fork fails. The parent: `cc_wk_send` (write n bytes: n or -1), `cc_wk_recv` (read
without blocking: bytes, 0 when nothing yet, -1 at end of file or unknown slot), `cc_wk_stop(slot, force)` (reap; force 1
kills first; -1 unknown slot). The child: `cc_wk_child_read` (exactly n bytes; 0 at end of input; -1 error),
`cc_wk_child_write` (all n bytes or -1), `cc_wk_child_exit` (`_exit` after dumping coverage counters when instrumented). A
`cc_wk_cpus` returns the processors online (at least 1). A child closes the pipe ends of every other slot, so end of input reaches it when the parent ends. SIGPIPE is ignored.

## 10. Contract tests

- `shim/tests/contract_shim_provider.c`: every function above, against the real libraries (loopback
  sockets, a hidden window, MoltenVK, a local TLS test server with `SSL_CERT_FILE`), asserting the return
  codes and outputs stated here.
- `core/tests/contract_shim_consumer.cob` and `client/tests/contract_shim_consumer.cob`: every `CCSHIM.cpy`
  constant and record layout used by that package has the size and value stated here (record lengths with
  `FUNCTION LENGTH`, constant values), and each `CALL STATIC` the package makes links and returns a defined
  outcome on a minimal valid call.

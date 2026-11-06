/* cc_win: the game window and its input (contracts/shim-abi.md §8). Glue only: keyboard, character,
 * mouse button, cursor and scroll input arrive only through GLFW C callbacks, and
 * glfwInitVulkanLoader takes a function pointer (shim-abi §1 table; research R3).
 *
 * The callbacks append 24-byte event records to a queue that cc_win_poll copies out. While the cursor
 * is captured, cursor movement is accumulated and cc_win_poll emits one kind-6 record carrying the
 * accumulated delta; while it is free, every movement is a kind-6 record carrying the position. */
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"

GLFWwindow *cc_win_window = NULL;

#define QUEUE_MAX 4096
static cc_event queue[QUEUE_MAX];
static int32_t queued = 0;
static int captured = 0;
static int delta_pending = 0;
static double last_x, last_y, delta_x, delta_y;

static void push(int32_t kind, int32_t a, int32_t b, int32_t c, double x, double y) {
    if (queued == QUEUE_MAX) cc_fatal("cc_win: event queue overflow");
    queue[queued++] = (cc_event){kind, a, b, c, (float)x, (float)y};
}

static void on_key(GLFWwindow *w, int key, int scancode, int action, int mods) {
    (void)w, (void)scancode;
    if (action == GLFW_RELEASE) push(CC_EV_KEY_UP, key, mods, 0, 0, 0);
    else push(CC_EV_KEY_DOWN, key, mods, action == GLFW_REPEAT, 0, 0);
}

static void on_char(GLFWwindow *w, unsigned int codepoint) {
    (void)w;
    push(CC_EV_TEXT, (int32_t)codepoint, 0, 0, 0, 0);
}

static void on_button(GLFWwindow *w, int button, int action, int mods) {
    double x, y;
    glfwGetCursorPos(w, &x, &y);
    push(action == GLFW_PRESS ? CC_EV_BUTTON_DOWN : CC_EV_BUTTON_UP, button, mods, 0, x, y);
}

static void on_cursor(GLFWwindow *w, double x, double y) {
    (void)w;
    if (captured) {
        delta_x += x - last_x;
        delta_y += y - last_y;
        delta_pending = 1;
    } else {
        push(CC_EV_CURSOR, 0, 0, 0, x, y);
    }
    last_x = x;
    last_y = y;
}

static void on_scroll(GLFWwindow *w, double x, double y) {
    (void)w;
    push(CC_EV_SCROLL, 0, 0, 0, x, y);
}

static void on_resize(GLFWwindow *w, int width, int height) {
    (void)w;
    push(CC_EV_RESIZE, width, height, 0, 0, 0);
}

static void on_close(GLFWwindow *w) {
    glfwSetWindowShouldClose(w, GLFW_FALSE);
    push(CC_EV_CLOSE_REQUEST, 0, 0, 0, 0, 0);
}

int32_t cc_win_open(int32_t width, int32_t height, const char *title, int32_t visible) {
    glfwInitVulkanLoader(vkGetInstanceProcAddr);
    if (!glfwInit()) cc_fatal("cc_win_open: glfwInit failed");
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindowHint(GLFW_VISIBLE, visible ? GLFW_TRUE : GLFW_FALSE);
    cc_win_window = glfwCreateWindow(width, height, title, NULL, NULL);
    if (cc_win_window == NULL) cc_fatal("cc_win_open: glfwCreateWindow failed");
    glfwSetKeyCallback(cc_win_window, on_key);
    glfwSetCharCallback(cc_win_window, on_char);
    glfwSetMouseButtonCallback(cc_win_window, on_button);
    glfwSetCursorPosCallback(cc_win_window, on_cursor);
    glfwSetScrollCallback(cc_win_window, on_scroll);
    glfwSetWindowSizeCallback(cc_win_window, on_resize);
    glfwSetWindowCloseCallback(cc_win_window, on_close);
    queued = 0;
    captured = 0;
    delta_pending = 0;
    return 0;
}

int32_t cc_win_poll(uint8_t *events, int32_t cap, int32_t *count_out) {
    glfwPollEvents();
    if (delta_pending) push(CC_EV_CURSOR, 0, 0, 0, delta_x, delta_y);
    delta_pending = 0;
    delta_x = delta_y = 0;
    int32_t room = cap / (int32_t)sizeof(cc_event);
    int32_t n = queued < room ? queued : room;
    memcpy(events, queue, (size_t)n * sizeof(cc_event));
    memmove(queue, queue + n, (size_t)(queued - n) * sizeof(cc_event));
    queued -= n;
    *count_out = n;
    return 0;
}

void cc_win_size(int32_t *win_w, int32_t *win_h, int32_t *fb_w, int32_t *fb_h) {
    int w, h, fw, fh;
    glfwGetWindowSize(cc_win_window, &w, &h);
    glfwGetFramebufferSize(cc_win_window, &fw, &fh);
    *win_w = w;
    *win_h = h;
    *fb_w = fw;
    *fb_h = fh;
}

void cc_win_capture_cursor(int32_t on) {
    captured = on != 0;
    glfwSetInputMode(cc_win_window, GLFW_CURSOR, captured ? GLFW_CURSOR_DISABLED : GLFW_CURSOR_NORMAL);
    if (captured && glfwRawMouseMotionSupported()) glfwSetInputMode(cc_win_window, GLFW_RAW_MOUSE_MOTION, GLFW_TRUE);
    glfwGetCursorPos(cc_win_window, &last_x, &last_y);
}

void cc_win_close(void) {
    glfwDestroyWindow(cc_win_window);
    glfwTerminate();
    cc_win_window = NULL;
    queued = 0;
}

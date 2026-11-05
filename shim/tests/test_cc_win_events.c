/* Implementation test of shim/src/cc_win.c: injects input through the GLFW callbacks cc_win_open
 * registered on the window (obtained back from GLFW) and asserts the 24-byte records of
 * contracts/shim-abi.md §8 that cc_win_poll returns, every kind 1 to 9, including a non-ASCII code
 * point for kind 3 (text typed on a non-US keyboard layout). */
#include <stdio.h>
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

static GLFWkeyfun key;
static GLFWcharfun character;
static GLFWmousebuttonfun button;
static GLFWcursorposfun cursor;
static GLFWscrollfun scroll;
static GLFWwindowsizefun resize;
static GLFWwindowclosefun closing;

/* Reads back each registered callback (glfwSet* returns the previous one) and registers it again. */
static void take_callbacks(GLFWwindow *w) {
    key = glfwSetKeyCallback(w, NULL);
    glfwSetKeyCallback(w, key);
    character = glfwSetCharCallback(w, NULL);
    glfwSetCharCallback(w, character);
    button = glfwSetMouseButtonCallback(w, NULL);
    glfwSetMouseButtonCallback(w, button);
    cursor = glfwSetCursorPosCallback(w, NULL);
    glfwSetCursorPosCallback(w, cursor);
    scroll = glfwSetScrollCallback(w, NULL);
    glfwSetScrollCallback(w, scroll);
    resize = glfwSetWindowSizeCallback(w, NULL);
    glfwSetWindowSizeCallback(w, resize);
    closing = glfwSetWindowCloseCallback(w, NULL);
    glfwSetWindowCloseCallback(w, closing);
}

static cc_event events[256];
static int32_t count;

/* Polls into `events`; the hidden window receives no input of its own, so the records are the
 * injected ones. */
static void poll_events(void) {
    cc_win_poll((uint8_t *)events, sizeof events, &count);
}

static void expect(const char *name, const cc_event *e, int32_t kind, int32_t a, int32_t b, int32_t c, float x, float y) {
    char expected[160], observed[160];
    snprintf(expected, sizeof expected, "%d,%d,%d,%d,%g,%g", kind, a, b, c, x, y);
    snprintf(observed, sizeof observed, "%d,%d,%d,%d,%g,%g", e->kind, e->a, e->b, e->c, e->x, e->y);
    tl_str(name, expected, observed);
}

int main(void) {
    cc_win_open(320, 240, "test_cc_win_events", 0);
    GLFWwindow *w = cc_win_window;
    poll_events();
    take_callbacks(w);
    double px, py;
    glfwGetCursorPos(w, &px, &py);

    key(w, GLFW_KEY_W, 17, GLFW_PRESS, GLFW_MOD_SHIFT);
    key(w, GLFW_KEY_W, 17, GLFW_REPEAT, GLFW_MOD_SHIFT);
    key(w, GLFW_KEY_W, 17, GLFW_RELEASE, 0);
    character(w, 0x00e9); /* é, typed with a French or similar layout */
    button(w, GLFW_MOUSE_BUTTON_RIGHT, GLFW_PRESS, GLFW_MOD_CONTROL);
    button(w, GLFW_MOUSE_BUTTON_RIGHT, GLFW_RELEASE, 0);
    cursor(w, 30.5, 40.25);
    scroll(w, 0.0, -2.0);
    resize(w, 400, 300);
    closing(w);
    poll_events();
    tl_int("test cc_win poll returns every injected event", 10, count);
    expect("test cc_win kind 1 key down: key code, modifiers, repeat 0", &events[0], CC_EV_KEY_DOWN, GLFW_KEY_W, GLFW_MOD_SHIFT, 0, 0, 0);
    expect("test cc_win kind 1 key down with repeat flag 1 for a key repeat", &events[1], CC_EV_KEY_DOWN, GLFW_KEY_W, GLFW_MOD_SHIFT, 1, 0, 0);
    expect("test cc_win kind 2 key up", &events[2], CC_EV_KEY_UP, GLFW_KEY_W, 0, 0, 0, 0);
    expect("test cc_win kind 3 text character carries a non-ASCII code point", &events[3], CC_EV_TEXT, 0xe9, 0, 0, 0, 0);
    expect("test cc_win kind 4 mouse button down with modifiers and cursor position", &events[4], CC_EV_BUTTON_DOWN, CC_BUTTON_RIGHT, GLFW_MOD_CONTROL, 0, (float)px, (float)py);
    expect("test cc_win kind 5 mouse button up", &events[5], CC_EV_BUTTON_UP, CC_BUTTON_RIGHT, 0, 0, (float)px, (float)py);
    expect("test cc_win kind 6 cursor moved carries the position while free", &events[6], CC_EV_CURSOR, 0, 0, 0, 30.5f, 40.25f);
    expect("test cc_win kind 7 scroll offsets", &events[7], CC_EV_SCROLL, 0, 0, 0, 0, -2);
    expect("test cc_win kind 8 window resized", &events[8], CC_EV_RESIZE, 400, 300, 0, 0, 0);
    expect("test cc_win kind 9 close requested", &events[9], CC_EV_CLOSE_REQUEST, 0, 0, 0, 0, 0);
    tl_int("test cc_win close request does not close the window by itself", 0, glfwWindowShouldClose(w));

    /* Captured cursor: movements accumulate into one kind-6 record carrying the delta. */
    cc_win_capture_cursor(1);
    double x0, y0;
    glfwGetCursorPos(w, &x0, &y0);
    poll_events();
    cursor(w, x0 + 3, y0 - 1);
    cursor(w, x0 + 5, y0 + 4);
    poll_events();
    tl_int("test cc_win captured cursor movements produce one record", 1, count);
    expect("test cc_win kind 6 carries the accumulated delta while captured", &events[0], CC_EV_CURSOR, 0, 0, 0, 5, 4);
    poll_events();
    tl_int("test cc_win captured cursor without movement produces no record", 0, count);
    cc_win_capture_cursor(0);

    /* A buffer smaller than the queue: the rest stays queued for the next poll. */
    scroll(w, 1, 0);
    scroll(w, 2, 0);
    scroll(w, 3, 0);
    cc_win_poll((uint8_t *)events, 2 * (int32_t)sizeof(cc_event) + 5, &count);
    tl_int("test cc_win poll copies only as many records as fit", 2, count);
    poll_events();
    tl_int("test cc_win poll keeps the records that did not fit", 1, count);
    expect("test cc_win poll keeps queued records in order", &events[0], CC_EV_SCROLL, 0, 0, 0, 3, 0);

    cc_win_close();
    return 0;
}

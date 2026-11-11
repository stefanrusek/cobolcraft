#version 450
// User-interface vertex shader (shim-abi §9): the same 44-byte vertex layout as the world shader and
// the same push constants; the matrix is the orthographic screen projection built by the client. The
// UI pipeline ignores brightness, sky and daylight; the tint multiplies the texel.
layout(push_constant) uniform Push { mat4 matrix; float daylight; } push;
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_uv;
layout(location = 2) in float in_brightness;
layout(location = 3) in float in_alpha;
layout(location = 4) in float in_sky;
layout(location = 5) in vec3 in_tint;
layout(location = 0) out vec2 out_uv;
layout(location = 1) out float out_alpha;
layout(location = 2) out vec3 out_tint;

void main() {
    gl_Position = push.matrix * vec4(in_position, 1.0);
    out_uv = in_uv;
    out_alpha = in_alpha;
    out_tint = in_tint;
}

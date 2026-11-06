#version 450
// User-interface vertex shader (research R4): the same 28-byte vertex layout as the world shader;
// the push-constant matrix is the orthographic screen projection built by the client.
layout(push_constant) uniform Push { mat4 matrix; } push;
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_uv;
layout(location = 2) in float in_brightness;
layout(location = 3) in float in_alpha;
layout(location = 0) out vec2 out_uv;
layout(location = 1) out float out_alpha;

void main() {
    gl_Position = push.matrix * vec4(in_position, 1.0);
    out_uv = in_uv;
    out_alpha = in_alpha;
}

#version 450
// World vertex shader (research R4): vertex = position xyz, texture coordinate uv, brightness, alpha
// multiplier (28 bytes); the 4 x 4 matrix (column-major) arrives as a push constant.
layout(push_constant) uniform Push { mat4 matrix; } push;
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_uv;
layout(location = 2) in float in_brightness;
layout(location = 3) in float in_alpha;
layout(location = 0) out vec2 out_uv;
layout(location = 1) out float out_brightness;
layout(location = 2) out float out_alpha;

void main() {
    gl_Position = push.matrix * vec4(in_position, 1.0);
    out_uv = in_uv;
    out_brightness = in_brightness;
    out_alpha = in_alpha;
}

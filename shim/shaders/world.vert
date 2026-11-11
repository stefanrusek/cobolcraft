#version 450
// World vertex shader (shim-abi §9): vertex = position xyz, texture coordinate uv, brightness, alpha
// multiplier, sky term, tint rgb (44 bytes); the 4 x 4 matrix (column-major) and the daylight factor
// arrive as push constants. The brightness the fragment shader gets is max(brightness, sky x daylight).
layout(push_constant) uniform Push { mat4 matrix; float daylight; } push;
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_uv;
layout(location = 2) in float in_brightness;
layout(location = 3) in float in_alpha;
layout(location = 4) in float in_sky;
layout(location = 5) in vec3 in_tint;
layout(location = 0) out vec2 out_uv;
layout(location = 1) out float out_brightness;
layout(location = 2) out float out_alpha;
layout(location = 3) out vec3 out_tint;

void main() {
    gl_Position = push.matrix * vec4(in_position, 1.0);
    out_uv = in_uv;
    out_brightness = max(in_brightness, in_sky * push.daylight);
    out_alpha = in_alpha;
    out_tint = in_tint;
}

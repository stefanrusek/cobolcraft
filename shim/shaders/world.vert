#version 450
// World vertex shader (shim-abi §9): vertex = position xyz, texture coordinate uv, brightness, alpha
// multiplier, sky term, tint rgb (44 bytes); the 4 x 4 matrix (column-major) and the daylight factor
// arrive as push constants. The brightness the fragment shader gets is max(brightness, sky x daylight).
// The fog (cc_vk_fog) shares the push constant block with the fragment stage: colour rgb and strength, start, end, and the focal
// terms of the projection, from which the camera-relative distance is recovered out of the clip coordinates.
layout(push_constant) uniform Push { mat4 matrix; float daylight; vec4 fog_colour; vec4 fog_range; } push;
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
layout(location = 4) out vec3 out_view;

void main() {
    gl_Position = push.matrix * vec4(in_position, 1.0);
    // Perspective: clip.x = p00 x view.x, clip.y = p11 x view.y, clip.w = depth: the view position, linear in the vertex, so that its
    // interpolation is exact and the fragment shader takes its length (the distance to the camera).
    float vx = gl_Position.x / push.fog_range.z;
    float vy = gl_Position.y / push.fog_range.w;
    out_view = vec3(vx, vy, gl_Position.w);
    out_uv = in_uv;
    out_brightness = max(in_brightness, in_sky * push.daylight);
    out_alpha = in_alpha;
    out_tint = in_tint;
}

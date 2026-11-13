#version 450
// World fragment shader (shim-abi §9): the atlas sampled NEAREST (sampler state set by the shim);
// colour = texel colour x tint x brightness, alpha = texel alpha x alpha multiplier; then the fog (12 section 3.3 include/fog.glsl):
// value(d, s, e) = 0 up to s, 1 from e, (d - s) / (e - s) between; colour = lerp(colour, fog rgb, value x fog strength).
layout(push_constant) uniform Push { mat4 matrix; float daylight; vec4 fog_colour; vec4 fog_range; } push;
layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(location = 0) in vec2 in_uv;
layout(location = 1) in float in_brightness;
layout(location = 2) in float in_alpha;
layout(location = 3) in vec3 in_tint;
layout(location = 4) in vec3 in_view;
layout(location = 0) out vec4 out_colour;

void main() {
    vec4 texel = texture(atlas, in_uv);
    vec3 colour = texel.rgb * in_tint * in_brightness;
    float d = length(in_view);
    float s = push.fog_range.x;
    float e = push.fog_range.y;
    float value = d <= s ? 0.0 : (d >= e ? 1.0 : (d - s) / (e - s));
    colour = mix(colour, push.fog_colour.rgb, value * push.fog_colour.a);
    out_colour = vec4(colour, texel.a * in_alpha);
}

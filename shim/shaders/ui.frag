#version 450
// User-interface fragment shader (research R4): texel with its alpha x the alpha multiplier; the UI
// pipeline has no depth test.
layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(location = 0) in vec2 in_uv;
layout(location = 1) in float in_alpha;
layout(location = 0) out vec4 out_colour;

void main() {
    vec4 texel = texture(atlas, in_uv);
    out_colour = vec4(texel.rgb, texel.a * in_alpha);
}

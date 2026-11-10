#version 450
// World fragment shader (shim-abi §9): the atlas sampled NEAREST (sampler state set by the shim);
// colour = texel colour x tint x brightness, alpha = texel alpha x alpha multiplier.
layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(location = 0) in vec2 in_uv;
layout(location = 1) in float in_brightness;
layout(location = 2) in float in_alpha;
layout(location = 3) in vec3 in_tint;
layout(location = 0) out vec4 out_colour;

void main() {
    vec4 texel = texture(atlas, in_uv);
    out_colour = vec4(texel.rgb * in_tint * in_brightness, texel.a * in_alpha);
}

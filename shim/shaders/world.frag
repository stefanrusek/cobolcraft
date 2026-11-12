#version 450
// World fragment shader (shim-abi §9): the atlas sampled with the nearest-with-edge-blend of 12 §2.4
// (sampleNearest) through the linear mip sampler: crisp texels when a texel covers several screen pixels,
// the box-filtered mip sample when it is smaller than a pixel.
// colour = texel colour x tint x brightness, alpha = texel alpha x alpha multiplier.
layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(location = 0) in vec2 in_uv;
layout(location = 1) in float in_brightness;
layout(location = 2) in float in_alpha;
layout(location = 3) in vec3 in_tint;
layout(location = 0) out vec4 out_colour;

void main() {
    vec2 pixel_size = 1.0 / vec2(textureSize(atlas, 0));
    vec2 dx = dFdx(in_uv);
    vec2 dy = dFdy(in_uv);
    vec2 texel_screen = max(sqrt(dx * dx + dy * dy), vec2(1e-9));
    vec2 t = in_uv / pixel_size;
    vec2 c = round(t) - 0.5;
    vec2 o = t - c;
    vec2 o2 = clamp((o - 0.5) * pixel_size / texel_screen + 0.5, 0.0, 1.0);
    vec4 texel = textureGrad(atlas, (c + o2) * pixel_size, dx, dy);
    out_colour = vec4(texel.rgb * in_tint * in_brightness, texel.a * in_alpha);
}

#version 450
// World fragment shader (shim-abi §9): the atlas sampled with the nearest-with-edge-blend of 12 §2.4
// (sampleNearest) through the bound sampler: crisp texels when a texel covers several screen pixels,
// the box-filtered mip sample when it is smaller than a pixel;
// colour = texel colour x tint x brightness, alpha = texel alpha x alpha multiplier; then the fog (12 section 3.3 include/fog.glsl):
// value(d, s, e) = 0 up to s, 1 from e, (d - s) / (e - s) between; colour = lerp(colour, fog rgb, value x fog strength).
layout(push_constant) uniform Push { mat4 matrix; float daylight; float fog_r; float fog_g; float fog_b; float fog_a; float fog_start; float fog_end; float p00; float p11; float up_x; float up_y; float up_z; float rd_start; float rd_end; } push;
layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(location = 0) in vec2 in_uv;
layout(location = 1) in float in_brightness;
layout(location = 2) in float in_alpha;
layout(location = 3) in vec3 in_tint;
layout(location = 4) in vec3 in_view;
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
    // Cut-out: a texel with alpha under 0.1 is dropped on every pipeline, as the crumbling shader does (the transparent texels of an
    // entity skin or of its overlay layer, the empty corners of a block sprite).
    if (texel.a * in_alpha < 0.1) discard;
    float d = length(in_view);
    // The environment fog is spherical; the render-distance fog cylindrical: max(horizontal distance, |height|), the height being the
    // component of the view position along the world up direction.
    float h = dot(in_view, vec3(push.up_x, push.up_y, push.up_z));
    float cyl = max(sqrt(max(d * d - h * h, 0.0)), abs(h));
    float s1 = push.fog_start;
    float e1 = push.fog_end;
    float v1 = d <= s1 ? 0.0 : (d >= e1 ? 1.0 : (d - s1) / (e1 - s1));
    float s2 = push.rd_start;
    float e2 = push.rd_end;
    float v2 = cyl <= s2 ? 0.0 : (cyl >= e2 ? 1.0 : (cyl - s2) / (e2 - s2));
    vec3 colour = texel.rgb * in_tint * in_brightness;
    colour = mix(colour, vec3(push.fog_r, push.fog_g, push.fog_b), max(v1, v2) * push.fog_a);
    out_colour = vec4(colour, texel.a * in_alpha);
}

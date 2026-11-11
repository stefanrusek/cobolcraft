#version 450
// Crack-overlay fragment shader (12 section 4.3, CC_PIPE_CRUMBLING): as the world shader, and a fragment whose
// texel alpha times the vertex alpha is under 0.1 is discarded (the blend is fixed-function: 2 x src x dst).
layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(location = 0) in vec2 in_uv;
layout(location = 1) in float in_brightness;
layout(location = 2) in float in_alpha;
layout(location = 3) in vec3 in_tint;
layout(location = 0) out vec4 out_colour;

void main() {
    vec4 texel = texture(atlas, in_uv);
    float alpha = texel.a * in_alpha;
    if (alpha < 0.1) discard;
    out_colour = vec4(texel.rgb * in_tint * in_brightness, alpha);
}

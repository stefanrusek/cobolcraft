#version 450
layout(location = 0) in vec3 inPos;
layout(location = 1) in vec2 inUV;
layout(location = 2) in float inShade;
layout(push_constant) uniform PC { mat4 viewProj; } pc;
layout(location = 0) out vec2 vUV;
layout(location = 1) out float vShade;
void main() { gl_Position = pc.viewProj * vec4(inPos, 1.0); vUV = inUV; vShade = inShade; }

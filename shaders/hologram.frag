#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize.xy;

    // Create holographic grid pattern
    float grid = sin(uv.x * 100.0) * sin(uv.y * 100.0);
    grid = step(0.9, grid);

    // Add diffraction effect
    vec2 center = vec2(0.5);
    float diffract = 0.05 / distance(uv, center);

    // Time-based animation
    float wave = sin(uTime * 2.0 + uv.y * 10.0) * 0.1;

    // Create color with blue-green hue
    vec3 color = vec3(0.0, 0.8, 1.0) * (grid + diffract + wave);

    // Final output with transparency
    fragColor = vec4(color, 0.7);
}
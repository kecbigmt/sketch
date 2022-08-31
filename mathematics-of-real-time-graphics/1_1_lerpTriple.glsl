#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

void main() {
    vec3[3] palette = vec3[](
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 0.0, 1.0),
        vec3(0.0, 1.0, 0.0)
    );

    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos.x *= 2.0;
    int ind = int(pos.x);
    vec3 col = mix(palette[ind], palette[ind + 1], fract(pos.x));
    outColor = vec4(col, 1.0);
}

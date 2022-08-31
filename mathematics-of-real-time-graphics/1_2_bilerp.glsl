#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

void main() {
    vec3[4] palette = vec3[](
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 0.0, 1.0),
        vec3(0.0, 1.0, 0.0),
        vec3(1.0, 1.0, 0.0)
    );

    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = mix(mix(palette[0], palette[1], pos.x), mix(palette[2], palette[3], pos.x), pos.y);
    outColor = vec4(col, 1.0);
}

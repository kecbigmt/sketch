#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

const float PI = 3.1415926;
const vec3 lightColor = vec3(0.95, 0.95, 0.5);  // 背景の後光の色
const vec3 backColor = vec3(0.95, 0.25, 0.25);  // 背景の下地の色

void sunrise(vec2 p, out vec3 i) {
    float rad = atan(p.y, p.x);
    float fs = sin(rad * 10.);
    i = mix(lightColor, backColor, fs);
}

void main() {
    vec2 p = (gl_FragCoord.xy * 2. - u_resolution.xy) / min(u_resolution.x, u_resolution.y);
    vec3 destColor = vec3(1.);

    sunrise(p, destColor);

    outColor = vec4(destColor, 1.);
}
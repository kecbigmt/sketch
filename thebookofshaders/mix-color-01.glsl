#version 300 es
#define PI 3.14159265359

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

vec3 colorA = vec3(.149, .141, .912);
vec3 colorB = vec3(1., .833, .224);
vec3 lineColor = vec3(0., 1., 0.);

float plot(vec2 st, float pct) {
  return smoothstep(pct - .01, pct, st.y)
    - smoothstep(pct, pct + .01, st.y);
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(.0);

  float pct = st.x;

  color = mix(colorA, colorB, pct);
  color = mix(color, lineColor, plot(st, pct));

  outColor = vec4(vec3(color), 1.);
}

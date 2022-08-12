#version 300 es
#define PI 3.14159265359

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

vec3 colorA = vec3(.149, .141, .912);
vec3 colorB = vec3(1., .833, .224);

float exponentialInOut(float t) {
  return t == .0 || t == 1. ? t : t < .5 ? .5 * pow(2.,(20. * t) - 10.) : -.5 * pow(20., 10. - (t * 20.)) + 1.;
}

float plot(vec2 st, float pct) {
  return smoothstep(pct - .01, pct, st.y)
    - smoothstep(pct, pct + .01, st.y);
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(.0);

  vec3 pct = vec3(st.x);

  pct.r = smoothstep(0., 1., st.x);
  pct.g = sin(st.x * PI);
  pct.b = pow(st.x, .5);

  color = mix(colorA, colorB, pct);

  // Plot transition lines for each channel
  color = mix(color, vec3(1., 0., 0.), plot(st, pct.r));
  color = mix(color, vec3(0., 1., 0.), plot(st, pct.g));
  color = mix(color, vec3(0., 0., 1.), plot(st, pct.b));

  outColor = vec4(vec3(color), 1.);
}
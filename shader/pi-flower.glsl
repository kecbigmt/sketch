#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

const float PI = 3.1415926535897932384626433832795;
const float RAD_36_DEG = 36. * PI / 180.;

void main() {
  vec2 p = (gl_FragCoord.xy * 2. - u_resolution.xy) / min(u_resolution.x, u_resolution.y);

  vec3 base_col = vec3(1., 0.3, 0.7);

  float f = 0.;
  for (float i = 0.; i < 10.; i++) {
    float x = cos(u_time + i * RAD_36_DEG) * 0.5;
    float y = sin(u_time + i * RAD_36_DEG) * 0.5;
    vec2 o = vec2(x, y);
    f += 0.0025 / abs(length(p + o) - 0.5);
  }

  outColor = vec4(base_col * f, 1.0);
}
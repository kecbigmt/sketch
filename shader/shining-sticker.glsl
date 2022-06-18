#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

void main() {
  vec2 p = (gl_FragCoord.xy * 2. - u_resolution.xy) / min(u_resolution.x, u_resolution.y);
  vec2 q = mod(p, .2) - .1;

  float s = sin(u_time);
  float c = cos(u_time);
  q *= mat2(c, s, -s, c);

  float v = .1 / abs(q.x) * abs(q.y);
  float r = v * abs(sin(u_time * 6.) + 1.5);
  float g = v * abs(sin(u_time * 4.5) + 1.5);
  float b = v * abs(sin(u_time * 3.) + 1.5);
  
  outColor = vec4(vec3(r, g, b), 1.);
}
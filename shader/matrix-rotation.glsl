#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

void main(){
  // 現在のピクセルの座標をウィンドウ中央を原点とした座標に変換したもの
  vec2 p = (gl_FragCoord.xy * 2. - u_resolution.xy) / min(u_resolution.x, u_resolution.y);

  // 座標を回転
  float s = sin(u_time);
  float c = cos(u_time);
  mat2 m = mat2(c, s, -s, c);
  p *= m;

  vec2 o = vec2(1., 0);
  float l = 0.1 / length(p - o);
  outColor = vec4(vec3(l), 1.);
}
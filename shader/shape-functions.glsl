#version 300 es

precision mediump float;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

#define white vec3(1.0);
const vec3 red = vec3(1., 0.,0.);
const vec3 green = vec3(0., 1., 0.);
const vec3 blue = vec3(0., 0., 1.);

// 正円
void circle(vec2 p, vec2 offset, float size, vec3 color, out vec3 i) {
    float l = length(p - offset);
    if(l < size) {
        i = color;
    }
}

// 正方形
void rect(vec2 p, vec2 offset, float size, vec3 color, out vec3 i) {
    // offset分だけ基準座標をずらしたうえで、sizeが1.0になる座標系に変換
    vec2 q = (p - offset) / size;
    if (abs(q.x) < 1.0 && abs(q.y) < 1.0) {
        i = color;
    }
}

// 楕円
void ellipse(vec2 p, vec2 offset, vec2 prop, float size, vec3 color, out vec3 i) {
    float l = length((p - offset) / prop);
    if (l < size) {
        i = color;
    }
}

void main(void) {
  vec3 destColor = white;
  vec2 p = (gl_FragCoord.xy * 2. - u_resolution.xy) / min(u_resolution.x, u_resolution.y);

  circle(p, vec2(0., .5), .25, red, destColor);

  rect(p, vec2(.5, -.5), .25, green, destColor);

  ellipse(p, vec2(-.5, -.5), vec2(.5, 1.), .25, blue, destColor);

  outColor = vec4(destColor, 1.);
}
#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

const float r = 50.;

void main() {
    // 現在のピクセル位置をウィンドウの中央を原点とする座標に変換(-width/2 ~ width/2, -height/2 ~ height/2)
    vec2 p = gl_FragCoord.xy * 2. - u_resolution.xy;

    // 座標を正規化
    p /= min(u_resolution.x, u_resolution.y);

    // 「ウィンドウ中央から一定距離（ウィンドウ端まで半分の地点）を半径とした円弧」からの距離
    float l = abs(length(p) - .5);

    // 現在のピクセルの色
    vec3 col = vec3(0.01 / l);

    outColor = vec4(col, 1.);
}
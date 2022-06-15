#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

vec3[5] pallete = vec3[](
    vec3(0.05, 0., 0.),
    vec3(0., 0.05, 0.),
    vec3(0., 0., 0.05),
    vec3(0.05, 0.05, 0.),
    vec3(0., 0.05, 0.05)
);

void main() {
    // 現在のピクセル位置をウィンドウの中央を原点とする座標に変換(-width/2 ~ width/2, -height/2 ~ height/2)
    vec2 p = gl_FragCoord.xy * 2. - u_resolution.xy;

    // 座標を正規化
    p /= min(u_resolution.x, u_resolution.y);

    // 現在のピクセルの色
    vec3 col;

    // 5つの球ひとつずつ処理を行って、最終的なピクセルの色を決定する
    for (int i = 0; i < 5; i++) {
        // 画面中央から見た球の角度（全ピクセル共通）
        float ang = u_time * float(i + 1);
        
        // 球の中央の座標（全ピクセル共通）
        vec2 o = vec2(sin(ang), cos(ang));

        // 球の中央からの距離
        float l = length(p - o);
        
        // 球の中央からの距離が近いほど、色が強くなるようにする
        col += pallete[i] / l;
    }

    outColor = vec4(col, 1.0);
}
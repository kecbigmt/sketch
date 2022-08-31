#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

const float PI = 3.1415926;

// 偏角を求める関数atanの拡張版
// atanのままだとx = 0で機能しないところを、機能するようにする
float atan2(float y, float x) { // 値の範囲は[-PI, PI]
    if (x == 0.0) {
        // sign関数は引数が正なら1.0、負なら-0.0、ゼロなら0.0を返す
        // これにより、yが正なら偏角90°、yが負なら-90°、yがゼロ（つまり原点）なら0°になる
        // 本来原点の偏角は定義されないが、ここでは便宜上0°とする
        return sign(y) * PI / 2.0;
    } else {
        return atan(y, x);
    }
}

// 直交座標を極座標に変換する関数
vec2 xy2pol(vec2 xy) {
    return vec2(atan2(xy.y, xy.x), length(xy));
}

// 極座標を直交座標に変換する関数
vec2 pol2xy(vec2 pol) {
    return pol.y * vec2(cos(pol.x), sin(pol.x));
}

// s: 偏角、t: 動径
vec3 tex(vec2 st) {
    float time = 0.2 * u_time;
    vec3 circ = vec3(pol2xy(vec2(time, 0.5)) + 0.5, 1.0); // (0.5, 0.5, 1.0)を中心とした、z = 1 平面上の半径0.5の円上を動くベクトル
    vec3[3] palette = vec3[](circ.rgb, circ.gbr, circ.brg); // スウィズル演算子を使ってcircの成分をずらし、3つのベクトルを作る

    st.s = st.s / PI + 1.0; // 偏角の範囲を[0, 2)区間に変換
    st.x += u_time; // 偏角を時間とともに動かす
    int ind = int(st.s); // 偏角を配列のインデックスに対応させる
    vec3 col = mix(palette[ind % 2], palette[(ind + 1) % 2], fract(st.s)); // 偏角によって赤・青・白を補完
    return mix(palette[2], col, st.t);
}

void main() {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos = 2.0 * pos.xy - vec2(1.0);
    pos = xy2pol(pos); // 極座標に変換
    outColor = vec4(tex(pos), 1.0); // テクスチャマッピング
}

#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

uvec3 k = uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u); // 算術積で使う定数
uvec3 u = uvec3(1, 2, 3); // シフト数
const uint UINT_MAX = 0xffffffffu; // 符号なし正数の最大値
int channel;
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

// 引数・戻り値が2次元のuint型ハッシュ関数
uvec2 uhash22(uvec2 n) {
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k.xy;
    n ^= (n.yx << u.xy);
    return n * k.xy;
}

// 引数が2次元、戻り値が1次元のfloat型ハッシュ関数
float hash21(vec2 p) {
    uvec2 n = floatBitsToUint(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}

float vnoise21(vec2 p) {
    vec2 n = floor(p);
    float[4] v;
    for (int j = 0; j < 2; j++) {
        for (int i = 0; i < 2; i++) {
            v[i+2*j] = hash21(mod(n + vec2(i, j), 10.0));
        }
    }
    vec2 f = fract(p);
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f); // 左：5次エルミート補間
    return mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]);
}

// 数値微分による勾配取得
vec2 grad(vec2 p) {
    float eps = 0.001; // 微小な増分
    float a0 = cos(u_time) / 5000.0;
    float a1 = sin(u_time) / 5000.0;
    // a = (a1, a2)としたときの勾配
    return 0.5 * (vec2(
        vnoise21(p + vec2(eps, a1)) - vnoise21(p - vec2(eps, a1)), // yをa1としたときの微分（偏微分）を中央差分による数値微分で計算する
        vnoise21(p + vec2(a0, eps)) - vnoise21(p - vec2(a0, eps))  // xをa0としたときの微分（偏微分）を中央差分による数値微分で計算する
    )) / eps;
}

void main() {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos = 2.0 * pos.xy - vec2(1.0);
    pos = xy2pol(pos);
    pos = vec2(5.0 / PI, 5.0) * pos + u_time;
    fragColor.rgb = vec3(dot(vec2(1), grad(pos)));
    fragColor.a = 1.0;
} 
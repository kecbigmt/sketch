#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

const float PI = 3.1415926;
uvec3 k = uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u); // 算術積に使う定数
uvec3 u = uvec3(1, 2, 3); // シフト数

// 引数・戻り値が2次元のuint型ハッシュ関数
uvec2 uhash22(uvec2 n) {
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k.xy;
    n ^= (n.yx << u.xy);
    return n * k.xy;
}

float gtable2(vec2 lattice, vec2 p) {
    uvec2 n = floatBitsToUint(lattice);
    uint ind = uhash22(n).x >> 29;
    float u = 0.92387953 * (ind < 4u ? p.x : p.y); // 0.92387953 ≒ cos(pi/8)
    float v = 0.38268343 * (ind < 4u ? p.y : p.x); // 0.38268343 ≒ sin(pi/8)
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u ? v : -v);
}

float periodicNoise21(vec2 p, float period) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float[4] v;
    for (int j = 0; j < 2; j++) {
        for (int i = 0; i < 2; i++) {
            // 窓関数の係数
            v[i+2*j] = gtable2(mod(n + vec2(i, j), period), f - vec2(i, j));
        }
    }
    // 5次エルミネート補間
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f.x), mix(v[2], v[3], f.x), f.y) + 0.5;
}

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

void main() {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos = 2.0 * pos.xy - vec2(1.0);
    pos = xy2pol(pos);
    pos = vec2(5.0 / PI, 5.0 / PI) * pos + u_time;
    fragColor.rgb = vec3(periodicNoise21(pos, 10.0));
    fragColor.a = 1.0;
}

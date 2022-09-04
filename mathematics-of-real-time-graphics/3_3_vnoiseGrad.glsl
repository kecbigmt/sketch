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
            v[i+2*j] = hash21(n + vec2(i, j));
        }
    }
    vec2 f = fract(p);
    if (channel == 0) {
        // 左：3次エルミート補間
        f = f * f * (3.0 - 2.0 * f);
    } else {
        // 左：5次エルミート補間
        f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    }
    return mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]);
}

// 数値微分による勾配取得
vec2 grad(vec2 p) {
    float eps = 0.001; // 微小な増分
    float a0 = 0.0;
    float a1 = 0.0;
    // a = (a1, a2)としたときの勾配
    return 0.5 * (vec2(
        vnoise21(p + vec2(eps, a1)) - vnoise21(p - vec2(eps, a1)), // yをa1としたときの微分（偏微分）を中央差分による数値微分で計算する
        vnoise21(p + vec2(a0, eps)) - vnoise21(p - vec2(a0, eps))  // xをa0としたときの微分（偏微分）を中央差分による数値微分で計算する
    )) / eps;
}

void main() {
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    channel = int(gl_FragCoord.x * 2.0 / u_resolution.x);
    pos = 5.0 * pos + u_time; // [0, 5]区間にスケールして移動
    
    fragColor.rgb = vec3(dot(vec2(1), grad(pos)));
    fragColor.a = 1.0;
}
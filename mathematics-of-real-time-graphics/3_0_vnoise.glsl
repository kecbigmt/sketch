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

// 引数・戻り値が2次元のuint型ハッシュ関数
uvec3 uhash33(uvec3 n) {
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx << u);
    return n * k;
}

// 引数が2次元、戻り値が1次元のfloat型ハッシュ関数
float hash21(vec2 p) {
    uvec2 n = floatBitsToUint(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}

// 引数が3次元、戻り値が1次元のfloat型ハッシュ関数
float hash31(vec3 p) {
    uvec3 n = floatBitsToUint(p);
    return float(uhash33(n).x) / float(UINT_MAX);
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
    if (channel == 1) { // 中央：エルミート補間
        f = f * f * (3.0 - 2.0 * f);
    }
    return mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]);
}

float vnoise31(vec3 p) {
    vec3 n = floor(p);
    float[8] v;
    for (int k = 0; k < 2; k++) {
        for (int j = 0; j < 2; j++) {
            for (int i = 0; i < 2; i++) {
                v[i+2*j+4*k] = hash31(n + vec3(i, j, k));
            }
        }
    }
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // エルミート補間
    float[2] w;
    for (int i = 0; i < 2; i++) {
        w[i] = mix(mix(v[4*i], v[4*i+1], f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]); // 底面と上面での補間
    }
    return mix(w[0], w[1], f[2]); // 高さに関する補間
}

void main() {
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    channel = int(gl_FragCoord.x * 3.0 / u_resolution.x);
    pos = 10.0 * pos + u_time; // [0, 10]区間にスケールして移動
    if (channel < 2) {
        fragColor = vec4(vnoise21(pos)); // 左・中央：2次元ノイズ
    } else {
        fragColor = vec4(vnoise31(vec3(pos, u_time))); // 右：3次元ノイズ
    }
}
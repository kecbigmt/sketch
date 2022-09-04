#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

uvec3 k = uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u); // 算術積で使う定数
uvec3 u = uvec3(1, 2, 3); // シフト数
const uint UINT_MAX = 0xffffffffu; // 符号なし正数の最大値

// 引数・戻り値が2次元のuint型ハッシュ関数
uvec3 uhash33(uvec3 n) {
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx << u);
    return n * k;
}

// 引数が3次元、戻り値が1次元のfloat型ハッシュ関数
float hash31(vec3 p) {
    uvec3 n = floatBitsToUint(p);
    return float(uhash33(n).x) / float(UINT_MAX);
}

// 引数・戻り値が3次元のfloat型ハッシュ関数
vec3 hash33(vec3 p) {
    uvec3 n = floatBitsToUint(p);
    return vec3(uhash33(n)) / vec3(UINT_MAX);
}

vec3 vnoise33(vec3 p) {
    vec3 n = floor(p);
    vec3[8] v;
    for (int k = 0; k < 2; k++) {
        for (int j = 0; j < 2; j++) {
            for (int i = 0; i < 2; i++) {
                v[i + 2*j + 4*k] = hash33(n + vec3(i, j, k));
            }
        }
    }
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    vec3[2] w;
    for (int i = 0; i < 2; i++) {
        w[i] = mix(mix(v[4*i], v[4*i + 1], f.x), mix(v[4*i + 2], v[4*i + 3], f.x), f.y);
    }
    return mix(w[0], w[1], f.z);
}

void main() {
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 10.0 * pos + u_time; // [0, 10]区間にスケールして移動
    fragColor = vec4(vnoise33(vec3(pos, u_time)), 1.0);
}
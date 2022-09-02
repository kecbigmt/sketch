#version 300 es

precision highp float;
precision highp int;

uniform float u_time;

out vec4 fragColor;

uvec3 k = uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u); // 算術積で使う定数
uvec3 u = uvec3(1, 2, 3); // シフト数
const uint UINT_MAX = 0xffffffffu; // 符号なし正数の最大値

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

// 引数・戻り値が2次元のfloat型ハッシュ関数
vec2 hash22(vec2 p) {
    uvec2 n = floatBitsToUint(p);
    return vec2(uhash22(n)) / vec2(UINT_MAX);
}

// 引数・戻り値が3次元のfloat型ハッシュ関数
vec3 hash33(vec3 p) {
    uvec3 n = floatBitsToUint(p);
    return vec3(uhash33(n)) / vec3(UINT_MAX);
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


void main() {
  float time = floor(60.0 * u_time); // 1秒に60カウント
  vec2 pos = gl_FragCoord.xy + time; // フラグメント座標をずらす
  fragColor.rgb = vec3(hash21(pos));
  fragColor.a = 1.0;
}
#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

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

// 引数・戻り値が2次元のuint型ハッシュ関数
uvec3 uhash33(uvec3 n) {
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx << u);
    return n * k;
}

float gtable2(vec2 lattice, vec2 p) {
    uvec2 n = floatBitsToUint(lattice);
    uint ind = uhash22(n).x >> 29;
    float u = 0.92387953 * (ind < 4u ? p.x : p.y); // 0.92387953 ≒ cos(pi/8)
    float v = 0.38268343 * (ind < 4u ? p.y : p.x); // 0.38268343 ≒ sin(pi/8)
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u ? v : -v);
}

float gtable3(vec3 lattice, vec3 p) { // lattice: 格子点
    uvec3 n = floatBitsToUint(lattice); // 格子点の値をビット列に変換
    uint ind = uhash33(n).x >> 28; // ハッシュ値の桁を落とす
    float u = ind < 8u ? p.x : p.y;
    float v = ind < 4u ? p.y : ind == 12u || ind == 14u ? p.x : p.z;
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u ? v : -v);
}

float pnoise21(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float[4] v;
    for (int j = 0; j < 2; j++) {
        for (int i = 0; i < 2; i++) {
            // 窓関数の係数
            v[i+2*j] = gtable2(n + vec2(i, j), f - vec2(i, j));
        }
    }
    // 5次エルミネート補間
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f.x), mix(v[2], v[3], f.x), f.y) + 0.5;
}

float pnoise31(vec3 p) {
    vec3 n = floor(p);
    vec3 f = fract(p);
    float[8] v;
    for (int k = 0; k < 2; k++) {
        for (int j = 0; j < 2; j++) {
            for (int i = 0; i < 2; i++) {
                v[i+2*j+4*k] = gtable3(n + vec3(i, j, k), f - vec3(i, j, k)) * 0.70710678;
            }
        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    float[2] w;
    for (int i = 0; i < 2; i++) {
        w[i] = mix(mix(v[4*i], v[4*i+1], f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]); // 底面と上面での補間
    }
    return 0.5 * mix(w[0], w[1], f[2]) + 0.5; // 高さに関する補間
}


void main() {
    int channel = int(2.0 * gl_FragCoord.x / u_resolution);
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 10.0 * pos + u_time;
    if (channel == 0) {
        fragColor.rgb = vec3(pnoise21(pos.xy));
    } else {
        fragColor.rgb = vec3(pnoise31(vec3(pos.xy, u_time)));
    }
    fragColor.a = 1.0;
}


#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

uvec3 k = uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u); // 算術積に使う定数
uvec3 u = uvec3(1, 2, 3); // シフト数
uvec2 uhash22(uvec2 n) {
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k.xy;
    n ^= (n.yx << u.xy);
    return n * k.xy;

}

const uint UINT_MAX = 0xffffffffu;
vec2 hash22(vec2 p) {
    uvec2 n = floatBitsToUint(p);
    return vec2(uhash22(n)) / vec2(UINT_MAX);
}

float gnoise21(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float[4] v;
    for (int j = 0; j < 2; j++) {
        for (int i = 0; i < 2; i++) {
            // 乱数ベクトルを正規化
            vec2 g = normalize(hash22(n + vec2(i, j)) - vec2(0.5));
            // 窓関数の係数
            v[i+2*j] = dot(g, f - vec2(i, j));
        }
    }
    // 5次エルミネート補間
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f.x), mix(v[2], v[3], f.x), f.y) + 0.5;
}

void main() {
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 10.0 * pos + u_time;
    fragColor.rgb = vec3(gnoise21(pos.xy));
    fragColor.a = 1.0;
}


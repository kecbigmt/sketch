#version 300 es

precision highp float;
precision highp int;

uniform float u_time;

out vec4 fragColor;

uint k = 0x456789abu; // 算術積に使う大きな桁数の定数
const uint UINT_MAX = 0xffffffffu; // 符号なし正数の最大値

uint uhash11(uint n) {
    n ^= (n << 1);
    n ^= (n >> 1);
    n *= k;
    n ^= (n << 1);
    return n * k;
}

float hash11(float p) { // 浮動小数点数のハッシュ関数
    uint n = floatBitsToUint(p);
    return float(uhash11(n)) / float(UINT_MAX); // 値の正規化
}

void main() {
  float time = floor(60.0 * u_time); // 1秒に60カウント
  vec2 pos = gl_FragCoord.xy + time; // フラグメント座標をずらす
  fragColor.rgb = vec3(hash11(pos.x));
  fragColor.a = 1.0;
}
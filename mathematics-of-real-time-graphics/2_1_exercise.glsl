#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

void main() {
    vec2 pos = gl_FragCoord.xy / u_resolution;
    pos *= vec2(32.0, 10.0); // 座標のスケール
    uint[10] a = uint[]( // 2進数表示する符号なし整数の配列
        floatBitsToUint(1.0),
        floatBitsToUint(2.0),
        floatBitsToUint(3.0),
        floatBitsToUint(4.0),
        floatBitsToUint(5.0),
        floatBitsToUint(6.0),
        floatBitsToUint(7.0),
        floatBitsToUint(8.0),
        floatBitsToUint(9.0),
        floatBitsToUint(10.0)
    );
    if (fract(pos.x) < 0.1) {
        if (floor(pos.x) == 1.0) { // 1桁目と2桁目の区切り線
            fragColor = vec4(1, 0, 0, 1);
        } else if (floor(pos.x) == 9.0)  { // 9桁目と10桁目の区切り線
            fragColor = vec4(0, 1, 0, 1);
        } else { // その他区切り線
            fragColor = vec4(0.5);
        }
    } else if (fract(pos.y) < 0.1) { // 横方向の区切り線
        fragColor = vec4(0.5);
    } else {
        uint b = a[9-int(pos.y)]; // y座標に応じてaの要素を表示（上から並べる）
        b = (b << uint(pos.x)) >> 31;
        fragColor = vec4(vec3(b), 1.0);
    }
}
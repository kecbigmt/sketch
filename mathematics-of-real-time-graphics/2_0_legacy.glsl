#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 fragColor;
int channel;

float fractSin11(float x) {
    return fract(1000.0 * sin(x));
}

float fractSin21(vec2 xy) {
    return fract(sin(dot(xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 pos = gl_FragCoord.xy;
    pos += floor(60.0 * u_time); // フラグメント座標を時間変動
    channel = int(2.0 * gl_FragCoord.x / u_resolution); // ビューポートを分割して各チャンネルを表示
    if (channel == 0) {
        fragColor = vec4(fractSin11(pos.x));
    } else {
        fragColor = vec4(fractSin21(pos.xy / u_resolution));
    }
    fragColor.a = 1.0;
}

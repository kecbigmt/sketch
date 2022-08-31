#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

const float N = 4.0;
int channel;

void main() {
    vec3[4] palette = vec3[](
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 0.0, 1.0),
        vec3(0.0, 1.0, 0.0),
        vec3(1.0, 1.0, 0.0)
    );

    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos *= N; // フラグメント座標範囲を[0, n]区間にスケール
    channel = int(2.0 * gl_FragCoord.x / u_resolution.x); // ビューポートを分割
    if (channel == 0) {
        pos = floor(pos) + step(0.5, fract(pos));
    } else {
        float thr = 0.25 * sin(u_time);
        pos = floor(pos) + smoothstep(0.25 + thr, 0.75 - thr, fract(pos));
    }
    pos /= N; // フラグメント座標範囲を[0, 1]区間に正規化しなおす
    vec3 col = mix(mix(palette[0], palette[1], pos.x), mix(palette[2], palette[3], pos.x), pos.y);
    outColor = vec4(col, 1.0);
}

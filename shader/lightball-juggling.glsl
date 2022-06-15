precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    // 現在のピクセル位置をウィンドウの中央を原点とする座標に変換(-width/2 ~ width/2, -height/2 ~ height/2)
    vec2 p = gl_FragCoord.xy * 2. - u_resolution.xy;

    // 座標を正規化
    p /= min(u_resolution.x, u_resolution.y);

    float l;
    for (float i = 0.0; i < 5.0; i++) {
        float j = i + 1.;
        vec2 q = p + vec2(sin(u_time * j), cos(u_time * j));
        l += 0.05 / length(q);
    }
    gl_FragColor = vec4(vec3(l), 1.0);
}
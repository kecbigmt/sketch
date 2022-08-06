#version 300 es

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 outColor;

float plot(vec2 st, float pct) {
    // return smoothstep(.02, .0, abs(st.y - st.x));
    return smoothstep(pct - 0.02, pct, st.y) - smoothstep(pct, pct + 0.02, st.y);
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    float y = pow(st.x, 5.);
    vec3 color = vec3(y);

    float pct = plot(st, y);
    color = (1.-pct)*color+pct*vec3(0., 1., 0.);

    outColor = vec4(color, 1.);
}
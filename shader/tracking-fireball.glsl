precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    vec2 m = u_mouse.xy * 2. - u_resolution.xy;
    vec2 p = (gl_FragCoord.xy * 2. - u_resolution.xy - m) / min(u_resolution.x, u_resolution.y);
    float l = 0.2 * abs(sin(u_time)) / length(p);

    gl_FragColor = vec4(vec3(l, 0, 0), 1.0);
}
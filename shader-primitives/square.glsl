#version 300 es

precision highp float;
precision highp int;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

// 座標を[0, 1+a]区間に正規化（短辺は最大1だが長辺は1を超える）
vec2 normalizeCoord(vec2 pos,vec2 resolution){
    return pos/min(resolution.x,resolution.y);
}

// 正規化された座標を画面中央が(0, 0)になるよう、[-1-a, 1+a]区間に座標変換
vec2 centerNormalizedCoord(vec2 pos,vec2 resolution){
    return 2.*pos.xy-normalizeCoord(resolution,resolution);
}

vec4 square(vec4 dest, vec2 pos, vec2 center, float width, float height, vec4 color) {
    if (pos.x > center.x + width / 2.) return dest;
    if (pos.x < center.x - width / 2.) return dest;
    if (pos.y > center.y + height / 2.) return dest;
    if (pos.y < center.y - height / 2.) return dest;
    return dest + color;
}

void main(){
    vec2 pos = normalizeCoord(gl_FragCoord.xy, u_resolution);
    pos = centerNormalizedCoord(pos, u_resolution);

    vec4 col = vec4(.5,.5,1,1);
    fragColor = square(fragColor, pos, vec2(0), .4, .4, col);
    fragColor = square(fragColor, pos, vec2(.5), .2, .2, col);
    fragColor = square(fragColor, pos, vec2(-.5), .2, .2, col);
    fragColor = square(fragColor, pos, vec2(.5, -.5), .2, .2, col);
    fragColor = square(fragColor, pos, vec2(-.5, .5), .2, .2, col);

}
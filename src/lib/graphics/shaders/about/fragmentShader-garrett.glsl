precision mediump float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform float time;
uniform vec2 mouse;

// float noise(vec2 uv) {
//     return fract(sin(dot(uv * 1.5, vec2(60.987, 110.654))) * 43210.1234);
// }

vec2 hexagonalGrid(vec2 pt) {
    const float scale = 3.5;
    pt *= scale;
    vec2 c = vec2(1.0, sin(time * 0.1) * 0.5 + 0.0) * 0.1;
    pt.x /= c.x;
    pt.y -= floor(pt.x) * 0.5;
    pt.y /= c.y  * 2.0;;
    vec2 grid = round(pt) * 2.0;
    vec2 fract = fract(pt);
    if (fract.x + fract.y > 1.0) {
        grid.x += sign(fract.x - 0.5);
        grid.y += sign(fract.y - 0.5);
    }
    return (grid - pt) * c.y;
}

void main() {
    vec2 position = vUv * 1.0 - 1.0;
    vec2 hex = hexagonalGrid(position);
    float dist = length(hex);
    float wave = 2.0;
    wave = sin(dist * 4.0 - time + wave);
    vec3 color = mix(color3, color1, wave);
    color = mix(color, color2, wave * wave);
    gl_FragColor = vec4(color, 1.0);
}

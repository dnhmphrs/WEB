precision mediump float;

varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec3 color4;
uniform float time;
uniform vec2 mouse;

void main() {
    vec2 pos = vUv * 4.0 - 4.0;
    pos.x += sin(pos.y * 10.0 + time * 0.2) * 0.5;
    pos.y += cos(pos.x * 10.0 + time * 0.2) * 0.5;
    
    float wave = sin(4.0 * atan(pos.y, pos.x) + time * 2.0) * 0.5 + 0.5;
    
    vec3 color = mix(color1, color2, wave);
    gl_FragColor = vec4(color, 1.0);
}

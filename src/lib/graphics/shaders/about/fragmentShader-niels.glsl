precision mediump float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform float time;
uniform vec2 mouse;

void main() {
    vec2 position = vUv * 3.0;
    float wave = 0.5 * (tan(position.x + time * 0.1 + 10.0 ) + mouse.x + sin(position.y + time +  mouse.y));
    vec3 color = mix(color1, color2, wave);
    color = mix(color, color3, wave * wave);
    gl_FragColor = vec4(color, 1.0);
}

precision mediump float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform float time;
uniform vec2 mouse;

void main() {
    float theta = sin(5.0 * vUv.y + time);
    float gamma = sin(40.0 * vUv.y + time) * cos(20.0 * vUv.x + time);
    float combined = theta * gamma + (mouse.x * mouse.y * 0.5) ;
    
    vec3 color = mix(color1, color2, combined);
    color = mix(color, color3, combined * combined);
    gl_FragColor = vec4(color, 1.0);
}

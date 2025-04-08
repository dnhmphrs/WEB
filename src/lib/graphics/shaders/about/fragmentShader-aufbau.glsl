precision mediump float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform float time;
uniform vec2 mouse;

void main() {
    vec2 c = vec2(0.156 + mouse.x * 0.3, -0.8 + mouse.y * 0.3) + vec2(sin(time * 0.1) * 0.01, sin(time * 1.0) * 0.01);
    float zoom = 1.2;  
    vec2 z = (vUv - 0.5) * 4.0 / zoom;

    float n = 0.0;
    const int maxIter = 40;
    for(int i = 0; i < maxIter; i++) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;
        if((x * x + y * y) > 4.0) break;
        z = vec2(x, y);
        n++;
    }

    float smoothColor = n;
    vec3 gradient1 = mix(color1, color2, 0.5 + 0.5 * sin(smoothColor + time * 0.1));
    vec3 gradient2 = mix(color3, gradient1, 0.5 + 0.5 * sin(time * 0.1 + smoothColor));
    gl_FragColor = vec4(gradient2, 1.0);
}

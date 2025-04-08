precision mediump float;

uniform float time;
uniform vec2 mouse;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec3 color4;

void main() {
    // Normalized coordinates
    vec2 uv = gl_FragCoord.xy / vec2(1000.0);
    
    // Create a soft grid pattern
    vec2 grid = abs(fract(uv * 10.0 - 0.5) - 0.5);
    float gridPattern = smoothstep(0.1, 0.2, min(grid.x, grid.y));
    
    // Animated waves
    float wave = sin(uv.y * 15.0 + time * 0.5 + sin(uv.x * 10.0) * 0.5) * 0.5 + 0.5;
    
    // Mouse influence
    vec2 mousePos = vec2(mouse.x * 0.5 + 0.5, mouse.y * 0.5 + 0.5);
    float mouseDist = length(uv - mousePos);
    float mouseInfluence = smoothstep(0.5, 0.0, mouseDist) * sin(time * 0.5) * 0.5 + 0.5;
    
    // Color mixing
    vec3 color = mix(color3, color4, wave);
    color = mix(color, color2, gridPattern * 0.4);
    color = mix(color, color1, mouseInfluence * 0.6);
    
    // Output
    gl_FragColor = vec4(color, 1.0);
} 
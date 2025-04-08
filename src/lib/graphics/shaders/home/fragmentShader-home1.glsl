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
    
    // Simple gradient with time-based animation
    float gradient = sin(uv.x * 3.14159 + time * 0.2) * 0.5 + 0.5;
    
    // Mouse influence on the pattern
    float mouseDistance = length(uv - vec2(mouse.x * 0.5 + 0.5, mouse.y * 0.5 + 0.5));
    float mouseInfluence = smoothstep(0.5, 0.0, mouseDistance);
    
    // Blend between two colors
    vec3 baseColor = mix(color1, color2, gradient);
    
    // Add subtle ripple effect
    float ripple = sin(mouseDistance * 20.0 - time * 2.0) * 0.5 + 0.5;
    baseColor = mix(baseColor, color3, ripple * mouseInfluence * 0.3);
    
    // Output final color
    gl_FragColor = vec4(baseColor, 1.0);
} 
precision mediump float;

uniform float time;
uniform vec2 mouse;
uniform vec3 color1; // Off-white
uniform vec3 color2; // Slightly darker off-white
uniform vec3 color3; // Light gray
uniform vec3 color4; // Dark gray
uniform vec3 color5; // Darker gray
uniform vec3 color6; // Almost black

void main() {
    // Normalized coordinates
    vec2 uv = gl_FragCoord.xy / vec2(1000.0);
    
    // Create terminal-like grid
    float terminalScale = 40.0;
    vec2 grid = floor(uv * terminalScale) / terminalScale;
    
    // Create character cells
    float cellBorder = 0.05;
    vec2 cellUv = fract(uv * terminalScale);
    float cellEdge = max(
        step(cellBorder, cellUv.x) * step(cellUv.x, 1.0 - cellBorder),
        step(cellBorder, cellUv.y) * step(cellUv.y, 1.0 - cellBorder)
    );
    
    // Generate random ASCII-like characters
    float charValue = fract(sin(dot(grid, vec2(12.9898, 78.233)) + time * 0.1) * 43758.5453);
    
    // Create punchcard-like holes
    float isPunch = step(0.7, charValue) * step(cellEdge, 0.8);
    
    // Scanlines effect
    float scanline = sin(uv.y * 100.0 + time) * 0.05 + 0.95;
    
    // CRT flicker
    float flicker = sin(time * 3.0) * 0.03 + 0.97;
    
    // Mouse interaction creates a "cursor" effect
    vec2 mousePos = vec2(mouse.x * 0.5 + 0.5, mouse.y * 0.5 + 0.5);
    float mouseDist = length(grid - mousePos);
    float cursor = step(mouseDist, 0.02) * sin(time * 10.0) * 0.5 + 0.5;
    
    // Vertical monitor distortion
    float distortion = sin(uv.y * 10.0 + time * 0.5) * 0.01;
    uv.x += distortion;
    
    // Terminal color effect (green phosphor or amber)
    vec3 terminalColor = mix(color4, color1, isPunch);
    
    // Add some "aged" effect
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233)) * 43758.5453) * 0.1);
    terminalColor = mix(terminalColor, color3, noise * 0.2);
    
    // Apply scanlines, flicker and cursor
    terminalColor *= scanline * flicker;
    terminalColor = mix(terminalColor, color2, cursor);
    
    // Output final color
    gl_FragColor = vec4(terminalColor, 1.0);
} 
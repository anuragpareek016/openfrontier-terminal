// Cyberpunk Neon Bloom Shader for OpenFrontier
// Creates an intense neon halo and glow around terminal text

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 col = texture(iChannel0, uv);
    
    vec2 px = 1.0 / iResolution.xy;
    vec3 glow = vec3(0.0);
    
    // Multi-tier sampling for rich atmospheric bloom
    float radii[5]   = float[](2.5, 6.0, 12.0, 20.0, 32.0);
    float weights[5] = float[](0.35, 0.25, 0.20, 0.12, 0.08);
    
    for (int i = 0; i < 5; i++) {
        float r = radii[i];
        float w = weights[i];
        vec3 tap = vec3(0.0);
        tap += texture(iChannel0, uv + vec2(-r * px.x, 0.0)).rgb;
        tap += texture(iChannel0, uv + vec2( r * px.x, 0.0)).rgb;
        tap += texture(iChannel0, uv + vec2(0.0, -r * px.y)).rgb;
        tap += texture(iChannel0, uv + vec2(0.0,  r * px.y)).rgb;
        tap += texture(iChannel0, uv + vec2(-r * px.x, -r * px.y) * 0.707).rgb;
        tap += texture(iChannel0, uv + vec2( r * px.x, -r * px.y) * 0.707).rgb;
        tap += texture(iChannel0, uv + vec2(-r * px.x,  r * px.y) * 0.707).rgb;
        tap += texture(iChannel0, uv + vec2( r * px.x,  r * px.y) * 0.707).rgb;
        glow += (tap * 0.125) * w;
    }
    
    // Subtle breathing glow pulse
    float pulse = 1.0 + 0.08 * sin(iTime * 2.5);
    vec3 finalRgb = col.rgb + glow * 2.4 * pulse;
    
    fragColor = vec4(finalRgb, col.a);
}

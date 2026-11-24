// OpenFrontier Physical E-Paper: Preset 4 - Library Lamp (paper-lamp.glsl)
// Ambient golden reading lamp spotlight with gentle antique edge shading

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 baseColor = texture(iChannel0, uv);
    float luma = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // Multi-octave paper grain
    float grain = hash21(floor(fragCoord * 0.90));
    float grainDelta = (grain - 0.5) * 0.055;
    
    vec3 col = baseColor.rgb * (1.0 + grainDelta);
    
    // Radial distance from center
    vec2 centered = uv - vec2(0.5, 0.5);
    float dist = length(centered);
    
    // Very gentle, wide ambient warm spotlight
    float spotlight = smoothstep(0.85, 0.05, dist);
    vec3 lampWarmth = vec3(1.04, 1.015, 0.96);
    col = mix(col, col * lampWarmth, spotlight * 0.22);
    
    // Gentle antique vignette falloff towards borders
    float vignette = smoothstep(1.1, 0.45, dist);
    col *= mix(0.86, 1.0, vignette);
    
    fragColor = vec4(clamp(col, 0.0, 1.0), baseColor.a);
}

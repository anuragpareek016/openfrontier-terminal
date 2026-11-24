// OpenFrontier Physical E-Paper: Preset 2 - Antique Subtle (paper-subtle.glsl)
// 100% Uniform Surface - Zero Center Light, Zero Vignette
// Natural organic cotton fibers + microscopic capillary ink bleed on character boundaries

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float fiberNoise(vec2 coord, float angle, float stretch) {
    float s = sin(angle);
    float c = cos(angle);
    mat2 rot = mat2(c, -s, s, c);
    vec2 p = rot * coord;
    p.x *= stretch;
    return hash21(floor(p));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 baseColor = texture(iChannel0, uv);
    float luma = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // Multi-octave paper grain & subtle cotton fibers (100% uniform across entire display)
    float grain1 = hash21(floor(fragCoord * 0.90));
    float grain2 = hash21(floor(fragCoord * 0.40));
    float fiber1 = fiberNoise(fragCoord, 0.75, 0.18);
    float fiber2 = fiberNoise(fragCoord, -0.45, 0.15);
    
    float paperTexture = (grain1 * 0.45 + grain2 * 0.25 + fiber1 * 0.15 + fiber2 * 0.15);
    float grainDelta = (paperTexture - 0.5);
    
    vec3 finalColor = baseColor.rgb;
    
    if (luma > 0.40) {
        // Light Paper Themes: Microscopic cellulose modulation (+- 3.5%)
        finalColor *= (1.0 + grainDelta * 0.07);
        
        // Capillary ink diffusion at character glyph edges
        vec2 px = 1.0 / iResolution.xy;
        float lumaL = dot(texture(iChannel0, uv - vec2(px.x, 0.0)).rgb, vec3(0.3, 0.59, 0.11));
        float lumaR = dot(texture(iChannel0, uv + vec2(px.x, 0.0)).rgb, vec3(0.3, 0.59, 0.11));
        float lumaU = dot(texture(iChannel0, uv + vec2(0.0, px.y)).rgb, vec3(0.3, 0.59, 0.11));
        float lumaD = dot(texture(iChannel0, uv - vec2(0.0, px.y)).rgb, vec3(0.3, 0.59, 0.11));
        float edgeDiff = abs(luma - lumaL) + abs(luma - lumaR) + abs(luma - lumaU) + abs(luma - lumaD);
        finalColor -= vec3(edgeDiff * 0.022);
    } else {
        // Dark Themes: Gentle matte velvet modulation
        finalColor *= (1.0 + grainDelta * 0.035);
    }
    
    fragColor = vec4(clamp(finalColor, 0.0, 1.0), baseColor.a);
}

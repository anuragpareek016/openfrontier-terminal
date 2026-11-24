// OpenFrontier Physical E-Paper Shader: Low Paper (Normal Daily Reading)
// Dual-Domain Luminance Engine: Optimized for Both Light & Dark Themes
// 100% Spatially Flat Surface - Zero Spotlight, Zero Vignette

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
    
    // Calculate perceptual luminance of the underlying pixel (BT.601)
    float luma = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // Low / Normal Paper: Gentle, clean micro-grain + subtle elongated fibers
    float grain1 = hash21(floor(fragCoord * 0.90));
    float grain2 = hash21(floor(fragCoord * 0.45));
    float fiber1 = fiberNoise(fragCoord, 0.72, 0.20);
    float fiber2 = fiberNoise(fragCoord, -0.48, 0.18);
    
    float paperTexture = (grain1 * 0.50 + grain2 * 0.25 + fiber1 * 0.13 + fiber2 * 0.12);
    float grainDelta = (paperTexture - 0.5);
    
    // Continuous Dual-Domain Weights:
    // wLight dominates on bright light-theme backgrounds (Luma -> 1.0)
    // wDark dominates on dark dark-theme backgrounds (Luma -> 0.0)
    float wLight = smoothstep(0.15, 0.70, luma);
    float wDark  = 1.0 - wLight;
    
    // 1. Light Theme Modulation: Multiplicative absorption (+- 3.2%)
    vec3 lightResult = baseColor.rgb * (1.0 + grainDelta * 0.065);
    
    // Capillary ink bleed on character boundaries in light themes
    vec2 px = 1.0 / iResolution.xy;
    float lumaL = dot(texture(iChannel0, uv - vec2(px.x, 0.0)).rgb, vec3(0.3, 0.59, 0.11));
    float lumaR = dot(texture(iChannel0, uv + vec2(px.x, 0.0)).rgb, vec3(0.3, 0.59, 0.11));
    float lumaU = dot(texture(iChannel0, uv + vec2(0.0, px.y)).rgb, vec3(0.3, 0.59, 0.11));
    float lumaD = dot(texture(iChannel0, uv - vec2(0.0, px.y)).rgb, vec3(0.3, 0.59, 0.11));
    float edgeDiff = abs(luma - lumaL) + abs(luma - lumaR) + abs(luma - lumaU) + abs(luma - lumaD);
    lightResult -= vec3(edgeDiff * 0.018);
    
    // 2. Dark Theme Modulation: Additive tactile cardstock & fiber flecks
    // Solves the 0 * x = 0 extinction barrier on dark/black backgrounds
    float darkGrain = (paperTexture - 0.38) * 0.045;
    float darkFiber = max(0.0, fiber1 - 0.45) * 0.030;
    vec3 darkResult = baseColor.rgb + vec3(darkGrain + darkFiber);
    
    // Seamless blend between light and dark regimes
    vec3 finalColor = mix(darkResult, lightResult, wLight);
    
    fragColor = vec4(clamp(finalColor, 0.0, 1.0), baseColor.a);
}

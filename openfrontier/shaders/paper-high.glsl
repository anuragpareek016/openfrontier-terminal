// OpenFrontier Physical E-Paper Shader: High Paper (Max Intense Craft & Washi Texture)
// Dual-Domain Luminance Engine: Heavy Handmade Kuro-Washi & Parchment for All Themes
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
    
    // Perceptual luminance (BT.601)
    float luma = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // High Paper: Triple-octave heavy pulp + dense intersecting fibers
    float grain1 = hash21(floor(fragCoord * 0.85));
    float grain2 = hash21(floor(fragCoord * 0.35));
    float grain3 = hash21(floor(fragCoord * 0.15));
    float fiber1 = fiberNoise(fragCoord, 0.80, 0.13);
    float fiber2 = fiberNoise(fragCoord, -0.58, 0.11);
    
    float paperTexture = (grain1 * 0.35 + grain2 * 0.25 + grain3 * 0.15 + fiber1 * 0.13 + fiber2 * 0.12);
    float grainDelta = (paperTexture - 0.5);
    
    // Continuous Dual-Domain Weights
    float wLight = smoothstep(0.15, 0.70, luma);
    float wDark  = 1.0 - wLight;
    
    // 1. Light Theme Modulation: Intense physical craft paper (+- 12.0%)
    vec3 lightResult = baseColor.rgb * (1.0 + grainDelta * 0.24);
    
    // Deep fountain pen ink absorption at character glyphs
    vec2 px = 1.0 / iResolution.xy;
    float lumaL = dot(texture(iChannel0, uv - vec2(px.x, 0.0)).rgb, vec3(0.3, 0.59, 0.11));
    float lumaR = dot(texture(iChannel0, uv + vec2(px.x, 0.0)).rgb, vec3(0.3, 0.59, 0.11));
    float lumaU = dot(texture(iChannel0, uv + vec2(0.0, px.y)).rgb, vec3(0.3, 0.59, 0.11));
    float lumaD = dot(texture(iChannel0, uv - vec2(0.0, px.y)).rgb, vec3(0.3, 0.59, 0.11));
    float edgeDiff = abs(luma - lumaL) + abs(luma - lumaR) + abs(luma - lumaU) + abs(luma - lumaD);
    lightResult -= vec3(edgeDiff * 0.050);
    
    // 2. Dark Theme Modulation: Heavy charcoal Kuro-Washi texture with tactile pulp clumps
    float darkGrain = (paperTexture - 0.32) * 0.135;
    float darkFibers = (max(0.0, fiber1 - 0.38) * 0.085) + (max(0.0, fiber2 - 0.38) * 0.075);
    vec3 darkResult = baseColor.rgb + vec3(darkGrain + darkFibers);
    
    // Seamless blend
    vec3 finalColor = mix(darkResult, lightResult, wLight);
    
    fragColor = vec4(clamp(finalColor, 0.0, 1.0), baseColor.a);
}

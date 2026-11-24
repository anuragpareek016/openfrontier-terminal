// OpenFrontier Physical E-Paper: Preset 4 - Kindle Matte Flat (paper-flat.glsl)
// Dual-Domain Uniform E-Ink Surface: Anti-Glare Matte for Light & Dark Themes

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 baseColor = texture(iChannel0, uv);
    float luma = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // Very subtle 2.5% micro-grain roughness across entire screen
    float grain = hash21(floor(fragCoord * 0.95));
    float grainDelta = (grain - 0.5) * 0.038;
    
    float wLight = smoothstep(0.15, 0.70, luma);
    
    vec3 lightResult = baseColor.rgb * (1.0 + grainDelta);
    vec3 darkResult = baseColor.rgb + vec3((grain - 0.38) * 0.035);
    
    vec3 col = mix(darkResult, lightResult, wLight);
    fragColor = vec4(clamp(col, 0.0, 1.0), baseColor.a);
}

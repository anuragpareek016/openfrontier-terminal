// Retro Phosphor Terminal Shader for OpenFrontier
// Curved screen, deep scanlines, and authentic bright monochrome green phosphor glow

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Curved screen geometry
    vec2 cc = uv - 0.5;
    float dist = dot(cc, cc);
    vec2 warpedUV = uv + cc * (dist * 0.22);
    
    if (warpedUV.x < 0.0 || warpedUV.x > 1.0 || warpedUV.y < 0.0 || warpedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    vec4 sampleCol = texture(iChannel0, warpedUV);
    
    // Intense scanline raster beam
    float scanline = sin(warpedUV.y * iResolution.y * 2.0) * 0.22;
    
    // Monochromatic green phosphor conversion
    float luma = dot(sampleCol.rgb, vec3(0.299, 0.587, 0.114));
    vec3 phosphorGreen = vec3(0.05, 1.0, 0.25) * luma * 1.35;
    
    // Add scanlines and subtle flicker
    float flicker = 0.98 + 0.02 * sin(iTime * 60.0);
    vec3 col = phosphorGreen * (1.0 - scanline) * flicker;
    
    // CRT glass vignette
    float vig = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    col *= clamp(16.0 * vig, 0.4, 1.0);
    
    fragColor = vec4(col, 1.0);
}

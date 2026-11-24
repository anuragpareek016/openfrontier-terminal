// Retro CRT Monitor Shader for OpenFrontier
// Barrel curvature, authentic phosphor scanlines, RGB shadow mask, and vignette

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Subtle CRT barrel curvature
    vec2 cc = uv - 0.5;
    float dist = dot(cc, cc);
    vec2 crtUV = uv + cc * (dist * 0.18);
    
    // Black border outside CRT screen
    if (crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    // Sample with chromatic aberration near edges
    float aberration = dist * 0.004;
    vec3 col;
    col.r = texture(iChannel0, crtUV + vec2(aberration, 0.0)).r;
    col.g = texture(iChannel0, crtUV).g;
    col.b = texture(iChannel0, crtUV - vec2(aberration, 0.0)).b;
    
    // Distinct retro scanlines
    float scanline = sin(crtUV.y * iResolution.y * 1.8) * 0.16;
    col -= scanline;
    
    // Phosphor RGB aperture grille
    float mask = 0.94 + 0.06 * sin(fragCoord.x * 3.14159);
    col *= mask;
    
    // CRT Edge vignette
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    col *= clamp(18.0 * vignette, 0.45, 1.0);
    
    fragColor = vec4(col, 1.0);
}

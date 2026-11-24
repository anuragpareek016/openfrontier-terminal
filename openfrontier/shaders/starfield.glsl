// Hyperspace Starfield Shader for OpenFrontier
// 3D warp speed starfield flowing behind terminal text

#define NUM_LAYERS 6.0

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

mat2 rotate2D(float angle) {
    float s = sin(angle), c = cos(angle);
    return mat2(c, -s, s, c);
}

vec3 starLayer(vec2 uv, float speed) {
    vec3 col = vec3(0.0);
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);
    
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            float n = hash21(id + offset);
            if (n < 0.65) continue; // Sparse distribution
            
            vec2 p = offset + vec2(n - 0.5, fract(n * 45.32) - 0.5) * 0.7;
            float d = length(gv - p);
            
            // Star size & glow
            float size = fract(n * 123.45) * 0.015 + 0.005;
            float star = size / max(d, 0.001);
            star = smoothstep(0.0, 1.0, star);
            
            // Color variation: white, cyan, and subtle gold
            vec3 starColor = mix(vec3(0.7, 0.9, 1.0), vec3(1.0, 1.0, 1.0), fract(n * 17.0));
            if (fract(n * 31.0) > 0.8) starColor = vec3(1.0, 0.85, 0.6);
            
            // Twinkle
            float twinkle = 0.7 + 0.3 * sin(iTime * 8.0 + n * 62.83);
            col += starColor * star * twinkle;
        }
    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 texUV = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, texUV);
    
    vec3 stars = vec3(0.0);
    
    // Multi-layer depth with forward motion
    for (float i = 0.0; i < 1.0; i += 1.0 / NUM_LAYERS) {
        float depth = fract(iTime * 0.12 + i);
        float scale = mix(15.0, 0.8, depth);
        float fade = depth * smoothstep(1.0, 0.85, depth);
        stars += starLayer(uv * scale + i * 23.4, depth) * fade;
    }
    
    // Subtle chromatic drift
    stars = clamp(stars, 0.0, 1.5);
    
    // Blend behind terminal text: text remains 100% readable
    float textBrightness = max(term.r, max(term.g, term.b));
    vec3 finalColor = term.rgb + stars * (1.0 - smoothstep(0.1, 0.6, textBrightness));
    
    fragColor = vec4(finalColor, max(term.a, 0.85));
}

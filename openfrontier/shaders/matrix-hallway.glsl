// 3D Matrix Hallway Shader for OpenFrontier
// Dynamic 3D Matrix code tunnel raining in perspective behind terminal text

#define SPEED_MULTIPLIER 1.2
#define GREEN_ALPHA 0.85
#define R fract(1e2 * sin(p.x * 8. + p.y))

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 term = texture(iChannel0, uv);
    
    vec3 v = vec3(fragCoord, 1.0) / iResolution - 0.5;
    vec3 s = 0.9 / abs(v);
    s.z = min(s.y, s.x);
    
    vec3 i = ceil(8e2 * s.z * (s.y < s.x ? v.xzz : v.zyz)) * 0.1;
    vec3 j = fract(i);
    i -= j;
    
    vec3 p = vec3(9.0, floor(iTime * SPEED_MULTIPLIER * (9.0 + 8.0 * sin(i).x)), 0.0) + i;
    vec3 col = vec3(0.0);
    
    float rainVal = R / max(s.z, 0.01);
    col.g = rainVal * 1.4;
    col.r = rainVal * 0.2;
    col.b = rainVal * 0.3;
    
    p *= j;
    float cond = (R > 0.45 && j.x < 0.65 && j.y < 0.82) ? GREEN_ALPHA : 0.0;
    col *= cond;
    
    // Add bright white glyph leaders
    if (R > 0.94 && cond > 0.0) {
        col = vec3(0.8, 1.0, 0.85) * 1.5;
    }

    // Blend behind terminal text
    float textBright = max(term.r, max(term.g, term.b));
    vec3 finalRgb = term.rgb + col * (1.0 - smoothstep(0.05, 0.5, textBright));

    fragColor = vec4(finalRgb, max(term.a, 0.85));
}

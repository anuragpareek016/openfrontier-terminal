// Cyber Glitch Shader for OpenFrontier
// Dynamic chromatic aberration slices, VHS scan glitches, and digital noise

#define DURATION 4.0
#define AMT 0.35

#define SS(a, b, x) (smoothstep(a, b, x) * smoothstep(b, a, x))

#define UI0 1597334673U
#define UI1 3812015801U
#define UI2 uvec2(UI0, UI1)
#define UI3 uvec3(UI0, UI1, 2798796415U)
#define UIF (1. / float(0xffffffffU))

vec3 hash33(vec3 p) {
    uvec3 q = uvec3(ivec3(p)) * UI3;
    q = (q.x ^ q.y ^ q.z) * UI3;
    return -1. + 2. * vec3(q) * UIF;
}

float gnoise(vec3 x) {
    vec3 p = floor(x);
    vec3 w = fract(x);
    vec3 u = w * w * w * (w * (w * 6. - 15.) + 10.);
    
    vec3 ga = hash33(p + vec3(0., 0., 0.));
    vec3 gb = hash33(p + vec3(1., 0., 0.));
    vec3 gc = hash33(p + vec3(0., 1., 0.));
    vec3 gd = hash33(p + vec3(1., 1., 0.));
    vec3 ge = hash33(p + vec3(0., 0., 1.));
    vec3 gf = hash33(p + vec3(1., 0., 1.));
    vec3 gg = hash33(p + vec3(0., 1., 1.));
    vec3 gh = hash33(p + vec3(1., 1., 1.));
    
    float va = dot(ga, w - vec3(0., 0., 0.));
    float vb = dot(gb, w - vec3(1., 0., 0.));
    float vc = dot(gc, w - vec3(0., 1., 0.));
    float vd = dot(gd, w - vec3(1., 1., 0.));
    float ve = dot(ge, w - vec3(0., 0., 1.));
    float vf = dot(gf, w - vec3(1., 0., 1.));
    float vg = dot(gg, w - vec3(0., 1., 1.));
    float vh = dot(gh, w - vec3(1., 1., 1.));
    
    return va + u.x * (vb - va) + 
           u.y * (vc - va) + 
           u.z * (ve - va) + 
           u.x * u.y * (va - vb - vc + vd) + 
           u.y * u.z * (va - vc - ve + vg) + 
           u.z * u.x * (va - vb - ve + vf) + 
           u.x * u.y * u.z * (-va + vb + vc - vd + ve - vf - vg + vh);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float t = iTime;

    float glitchAmount = SS(DURATION * 0.001, DURATION * AMT, mod(t, DURATION));
    vec2 eps = vec2(6.0 / iResolution.x, 0.0) * (glitchAmount * 3.0 + 0.35);

    // Analog displacement
    float y = uv.y * iResolution.y;
    float distortion = gnoise(vec3(0.0, y * 0.015, t * 400.0)) * (glitchAmount * 6.0 + 0.15);
    distortion *= gnoise(vec3(0.0, y * 0.03, t * 200.0)) * (glitchAmount * 3.0 + 0.04);

    distortion += smoothstep(0.995, 1.0, sin((uv.y + t * 2.5) * 3.0)) * 0.035;
    vec2 st = uv + vec2(distortion * 0.25, 0.0);

    // Chromatic aberration split
    vec3 col = vec3(0.0);
    col.r = texture(iChannel0, st + eps).r;
    col.g = texture(iChannel0, st).g;
    col.b = texture(iChannel0, st - eps).b;

    // Scanline distortion & grain during glitch
    float scanline = sin(uv.y * iResolution.y * 1.5 + t * 10.0) * (0.04 + 0.12 * glitchAmount);
    col -= scanline;
    col += (0.08 * glitchAmount) * hash33(vec3(fragCoord, mod(float(iFrame), 1000.0))).r;

    fragColor = vec4(col, 1.0);
}

// Cursor lightning trail for Ghostty / OpenFrontier
// Vibrant electric lightning bolts from previous to current cursor

const vec3 BOLT_CORE  = vec3(1.0, 1.0, 1.0);     // Pure white lightning core
const vec3 BOLT_GLOW  = vec3(0.1, 0.65, 1.0);    // Neon electric blue / cyan glow
const vec3 BOLT_AURA  = vec3(0.0, 0.25, 0.95);   // Deep violet aura

const float DURATION = 0.38;              // Visible arc duration
const float THRESHOLD_MIN_DISTANCE = 0.0; // Trigger on all typing movements
const float JAGGEDNESS = 0.12;           // Arc displacement
const float CORE_WIDTH = 1.6;            // Pixels
const float GLOW_WIDTH = 7.5;            // Pixels
const int BOLT_SEGMENTS = 14;

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float segmentDist(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b - a;
    float denom = max(dot(ab, ab), 0.000001);
    float t = clamp(dot(p - a, ab) / denom, 0.0, 1.0);
    return length(p - (a + ab * t));
}

vec2 boltPoint(vec2 a, vec2 b, float t, float seed) {
    vec2 delta = b - a;
    float len = length(delta);
    vec2 perp = vec2(-delta.y, delta.x) / max(len, 0.0001);
    float node = floor(t * float(BOLT_SEGMENTS) + 0.5);
    float r = hash11(node * 19.19 + seed) * 2.0 - 1.0;
    float arcProfile = sin(3.14159265 * t);
    return mix(a, b, t) + perp * r * len * JAGGEDNESS * arcProfile;
}

float boltDistance(vec2 p, vec2 a, vec2 b, float seed) {
    float d = 10000.0;
    vec2 prev = a;
    for (int i = 1; i <= BOLT_SEGMENTS; ++i) {
        float t = float(i) / float(BOLT_SEGMENTS);
        vec2 cur = boltPoint(a, b, t, seed);
        d = min(d, segmentDist(p, prev, cur));
        prev = cur;
    }
    return d;
}

float branchDistance(vec2 p, vec2 a, vec2 b, float seed) {
    float d = 10000.0;
    vec2 delta = b - a;
    float len = length(delta);
    vec2 perp = vec2(-delta.y, delta.x) / max(len, 0.0001);

    for (int i = 0; i < 3; ++i) {
        float fi = float(i);
        float t = 0.25 + fi * 0.25;
        vec2 root = boltPoint(a, b, t, seed);
        float side = hash11(seed + fi * 37.0) < 0.5 ? -1.0 : 1.0;
        float reach = len * (0.08 + 0.05 * hash11(seed + fi * 51.0));
        vec2 tip = root + perp * side * reach + normalize(delta) * reach * (hash11(seed + fi * 71.0) - 0.4);
        d = min(d, segmentDist(p, root, tip));
    }
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 terminal = texture(iChannel0, uv);
    fragColor = terminal;

    vec2 curCenter = iCurrentCursor.xy + vec2(iCurrentCursor.z * 0.5, -iCurrentCursor.w * 0.5);
    vec2 prevCenter = iPreviousCursor.xy + vec2(iPreviousCursor.z * 0.5, -iPreviousCursor.w * 0.5);
    float travel = length(curCenter - prevCenter);

    float age = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    if (travel > 1.0 && age < 1.0) {
        float seed = floor(iTimeCursorChange * 1000.0) * 0.017;
        float dMain = boltDistance(fragCoord, prevCenter, curCenter, seed);
        float dBranch = branchDistance(fragCoord, prevCenter, curCenter, seed);

        float core = 1.0 - smoothstep(0.0, CORE_WIDTH, dMain);
        float branchCore = 1.0 - smoothstep(0.0, CORE_WIDTH * 0.7, dBranch);
        float glow = exp(- (dMain * dMain) / (GLOW_WIDTH * GLOW_WIDTH));
        float branchGlow = exp(- (dBranch * dBranch) / (GLOW_WIDTH * GLOW_WIDTH * 0.6));

        float fade = pow(1.0 - age, 1.4);
        float flicker = 0.85 + 0.15 * sin(age * 80.0 + seed);
        float totalCore = max(core, branchCore * 0.75) * fade * flicker;
        float totalGlow = max(glow, branchGlow * 0.6) * fade * flicker;

        vec3 boltColor = BOLT_AURA * totalGlow * 0.8 + BOLT_GLOW * totalGlow * 1.5 + BOLT_CORE * totalCore * 2.0;
        vec3 finalRgb = terminal.rgb + boltColor;
        fragColor = vec4(finalRgb, terminal.a);

        // Keep terminal cursor sharp
        vec2 cursorMin = vec2(iCurrentCursor.x, iCurrentCursor.y - iCurrentCursor.w);
        vec2 cursorMax = vec2(iCurrentCursor.x + iCurrentCursor.z, iCurrentCursor.y);
        float insideCursor = step(cursorMin.x, fragCoord.x)
                           * step(cursorMin.y, fragCoord.y)
                           * step(fragCoord.x, cursorMax.x)
                           * step(fragCoord.y, cursorMax.y);
        fragColor = mix(fragColor, terminal, insideCursor);
    }
}

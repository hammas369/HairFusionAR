///-----------------------------------------------------------------------
/// Copyright (c) 2017 Snap Inc.
/// Modified 12/11/2018 1.7.0
///-----------------------------------------------------------------------


//-----------------------------------------------------------------------
// Standard defines
//-----------------------------------------------------------------------
#define SC_USE_USER_DEFINED_VS_MAIN
#define SC_SKIP_DUPLICATE_INCLUDES  // 06/14/2018 Compatibility: This is a special string our preprocessor looks for to know that it's safe to skip duplicate includes. It's not safe to skip in general for legacy shaders, because the first occurrence of an include might be guarded by an #ifdef and thus not actually compiled in, and a later occurrence would be compiled in. This shader and its includes are written such that the first occurrence is always compiled in.
#define SC_REMOVE_ENVMAP_FROM_AMBIENT_LIGHT_STRUCT  // 09/06/2018 HACK: Adreno GPUs can't handle textures in arrays of structs, some uniform values get corrupted, so we remove the textures from the ambient struct, since we don't use them anyway. This can be removed once we have no old uber shaders that sample envmaps from the ambient light struct.


//-----------------------------------------------------------------------
// Standard includes
//-----------------------------------------------------------------------
#include <std.glsl>
#include <std_vs.glsl>
#include <std_fs.glsl>


//-----------------------------------------------------------------------
// Global defines
//-----------------------------------------------------------------------
//#define DEBUG
#define SCENARIUM

#ifdef GL_ES
#define MOBILE
#endif

#if SC_DEVICE_CLASS >= SC_DEVICE_CLASS_C && (!defined(MOBILE) || defined(GL_FRAGMENT_PRECISION_HIGH))
#define DEVICE_IS_FAST
#endif

#if defined(ENABLE_LIGHTING) || defined(ENABLE_EMISSIVE) || defined(ENABLE_VERTEX_COLOR_EMISSIVE) || defined(ENABLE_SIMPLE_REFLECTION) || defined(ENABLE_RIM_HIGHLIGHT) || defined(ENABLE_TONE_MAPPING)
#define SC_ENABLE_SRGB_EMULATION_IN_SHADER
#endif


//-----------------------------------------------------------------------
// Varyings
//-----------------------------------------------------------------------
varying vec4 varColor;


//-----------------------------------------------------------------------
// User includes
//-----------------------------------------------------------------------
#include "includes/uber_lighting.glsl"
#include "includes/uber_surface_properties.glsl"
#include "includes/uber_debug.glsl"
#include "includes/pbr.glsl"
#include "includes/utils.glsl"
#include "includes/blend_modes.glsl"
#include "includes/fizzle.glsl"


//-----------------------------------------------------------------------
#ifdef VERTEX_SHADER
//-----------------------------------------------------------------------
attribute vec4 color;

void main() {
    sc_Vertex_t v = sc_LoadVertexAttributes();
    varColor = color;
    sc_ProcessVertex(v);
}
#endif // #ifdef VERTEX_SHADER


//-----------------------------------------------------------------------
#ifdef FRAGMENT_SHADER
//-----------------------------------------------------------------------
void main() {

#ifdef RENDER_CONSTANT_COLOR
    gl_FragColor = baseColor;

#elif defined(sc_ProjectiveShadowsCaster)
    vec4 color = vec4(0.0);
    float shadowAlpha = 1.0;
#ifdef sc_ExporterVersion
#if (sc_ExporterVersion >= 68)
    color = baseColor;
#ifdef ENABLE_BASE_TEX
    vec2 uvs[NUM_UVS];
    calculateUVs(uvs);
    SAMPLE_TEX_UBER(baseTex);
    color *= baseTexSample;
#endif // ENABLE_BASE_TEX
#ifdef ENABLE_VERTEX_COLOR_BASE
    color *= varColor;
#endif // ENABLE_VERTEX_COLOR_BASE
    shadowAlpha = getShadowAlpha(color, alphaTestThreshold);
#endif // sc_ExporterVersion >= 68
#endif // sc_ExporterVersion
    gl_FragColor = evaluateShadowCasterColor(color.rgb, shadowAlpha);
#else // endif sc_ProjectiveShadowsCaster

    DebugOptions debug = setupDebugOptions();

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // Set up surface properties

    SurfaceProperties surfaceProperties = setupSurfaceProperties(debug);

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // Evaluate lighting

#ifdef ENABLE_LIGHTING
    surfaceProperties = calculateDerivedSurfaceProperties(surfaceProperties, debug);

    LightingComponents lighting = evaluateLighting(surfaceProperties, debug);
#else // #ifdef ENABLE_LIGHTING
    LightingComponents lighting = defaultLightingComponents();
#endif // #else // #ifdef ENABLE_LIGHTING

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // Output

#ifdef sc_BlendMode_ColoredGlass
    // Colored glass implies that the surface does not diffusely reflect light, instead it transmits light.
    // The transmitted light is the background multiplied by the color of the glass, taking opacity as strength.
    lighting.directDiffuse = vec3(0.0);
    lighting.indirectDiffuse = vec3(0.0);
    vec3 framebuffer = srgbToLinear(getFramebufferColor().rgb);
    lighting.transmitted = framebuffer * mix(vec3(1.0), surfaceProperties.albedo, surfaceProperties.opacity);
    surfaceProperties.opacity = 1.0; // Since colored glass does its own multiplicative blending (above), forbid any other blending.
#endif

#ifdef sc_BlendMode_PremultipliedAlpha
    const bool enablePremultipliedAlpha = true;
#else
    const bool enablePremultipliedAlpha = false;
#endif

    // This is where the lighting and the surface finally come together.
    vec4 result = vec4(combineSurfacePropertiesWithLighting(surfaceProperties, lighting, enablePremultipliedAlpha), surfaceProperties.opacity);

    // Tone mapping
#if defined(ENABLE_TONE_MAPPING) && !defined(sc_BlendMode_Multiply)
#ifdef DEBUG
    if (debug.acesToneMapping)
        result.rgb = acesToneMapping(result.rgb);
    else if (debug.linearToneMapping)
#endif // #ifdef DEBUG
        result.rgb = linearToneMapping(result.rgb);
#endif // #if defined(ENABLE_TONE_MAPPING) && !defined(sc_BlendMode_Multiply)

    // sRGB output
    result.rgb = linearToSrgb(result.rgb);

    // Debug
#ifdef DEBUG
    result = debugOutput(result, surfaceProperties, lighting, debug);
#endif

    // Blending
#ifdef sc_BlendMode_Custom
    result = applyCustomBlend(result);
#elif defined(sc_BlendMode_MultiplyOriginal)
    result.rgb = mix(vec3(1.0), result.rgb, result.a);
#elif defined(sc_BlendMode_Screen)
    result.rgb = result.rgb * result.a;
#endif

#ifdef ENABLE_FIZZLE
    result = fizzle(result);
#endif

#ifndef MOBILE
    // GPU_BUG_011 [STUDIO-13316] 05/10/2019 Nvidia Quadro: This compiler is broken and kills huge branches of code randomly,
    // which kills some uniforms. In this case, when specular lighting is disabled, the baseTex, baseColor and normalTex
    // uniforms go away. So we force them on by adding to final result with epsilon.
    result.rgb += surfaceProperties.albedo * SC_EPSILON;
#ifdef ENABLE_LIGHTING
    result.rgb += surfaceProperties.normal * SC_EPSILON;
#endif
#endif

    gl_FragColor = result;

#endif // #ifdef RENDER_CONSTANT_COLOR
}
#endif // #ifdef FRAGMENT_SHADER



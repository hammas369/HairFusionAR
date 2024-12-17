//#include <required.glsl> // [HACK 4/6/2023] See SCC shader_merger.cpp
//SG_REFLECTION_BEGIN(100)
//attribute vec4 boneData 5
//attribute vec3 blendShape0Pos 6
//attribute vec3 blendShape0Normal 12
//attribute vec3 blendShape1Pos 7
//attribute vec3 blendShape1Normal 13
//attribute vec3 blendShape2Pos 8
//attribute vec3 blendShape2Normal 14
//attribute vec3 blendShape3Pos 9
//attribute vec3 blendShape4Pos 10
//attribute vec3 blendShape5Pos 11
//attribute vec4 position 0
//attribute vec3 normal 1
//attribute vec4 tangent 2
//attribute vec2 texture0 3
//attribute vec2 texture1 4
//attribute vec4 color 18
//attribute vec3 positionNext 15
//attribute vec3 positionPrevious 16
//attribute vec4 strandProperties 17
//sampler sampler baseTextureSmpSC 2:19
//sampler sampler customLengthTextureSmpSC 2:20
//sampler sampler endsTextureSmpSC 2:21
//sampler sampler intensityTextureSmpSC 2:22
//sampler sampler sc_EnvmapDiffuseSmpSC 2:23
//sampler sampler sc_EnvmapSpecularSmpSC 2:24
//sampler sampler sc_OITCommonSampler 2:25
//sampler sampler sc_SSAOTextureSmpSC 2:26
//sampler sampler sc_ScreenTextureSmpSC 2:27
//sampler sampler sc_ShadowTextureSmpSC 2:28
//sampler sampler shapeTextureSmpSC 2:30
//texture texture2D baseTexture 2:0:2:19
//texture texture2D customLengthTexture 2:1:2:20
//texture texture2D endsTexture 2:2:2:21
//texture texture2D intensityTexture 2:3:2:22
//texture texture2D sc_EnvmapDiffuse 2:4:2:23
//texture texture2D sc_EnvmapSpecular 2:5:2:24
//texture texture2D sc_OITAlpha0 2:6:2:25
//texture texture2D sc_OITAlpha1 2:7:2:25
//texture texture2D sc_OITDepthHigh0 2:8:2:25
//texture texture2D sc_OITDepthHigh1 2:9:2:25
//texture texture2D sc_OITDepthLow0 2:10:2:25
//texture texture2D sc_OITDepthLow1 2:11:2:25
//texture texture2D sc_OITFilteredDepthBoundsTexture 2:12:2:25
//texture texture2D sc_OITFrontDepthTexture 2:13:2:25
//texture texture2D sc_SSAOTexture 2:14:2:26
//texture texture2D sc_ScreenTexture 2:15:2:27
//texture texture2D sc_ShadowTexture 2:16:2:28
//texture texture2D shapeTexture 2:18:2:30
//SG_REFLECTION_END
#if defined VERTEX_SHADER
#if 0
NGS_BACKEND_SHADER_FLAGS_BEGIN__
NGS_BACKEND_SHADER_FLAGS_END__
#endif
#define SC_DISABLE_FRUSTUM_CULLING
#define SC_ENABLE_INSTANCED_RENDERING
#define sc_StereoRendering_Disabled 0
#define sc_StereoRendering_InstancedClipped 1
#define sc_StereoRendering_Multiview 2
#ifdef GL_ES
    #define SC_GLES_VERSION_20 2000
    #define SC_GLES_VERSION_30 3000
    #define SC_GLES_VERSION_31 3100
    #define SC_GLES_VERSION_32 3200
#endif
#ifdef VERTEX_SHADER
    #define scOutPos(clipPosition) gl_Position=clipPosition
    #define MAIN main
#endif
#ifdef SC_ENABLE_INSTANCED_RENDERING
    #ifndef sc_EnableInstancing
        #define sc_EnableInstancing 1
    #endif
#endif
#define mod(x,y) (x-y*floor((x+1e-6)/y))
#if defined(GL_ES)&&(__VERSION__<300)&&!defined(GL_OES_standard_derivatives)
#define dFdx(A) (A)
#define dFdy(A) (A)
#define fwidth(A) (A)
#endif
#if __VERSION__<300
#define isinf(x) (x!=0.0&&x*2.0==x ? true : false)
#define isnan(x) (x>0.0||x<0.0||x==0.0 ? false : true)
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef sc_EnableStereoClipDistance
        #if defined(GL_APPLE_clip_distance)
            #extension GL_APPLE_clip_distance : require
        #elif defined(GL_EXT_clip_cull_distance)
            #extension GL_EXT_clip_cull_distance : require
        #else
            #error Clip distance is requested but not supported by this device.
        #endif
    #endif
#else
    #ifdef sc_EnableStereoClipDistance
        #error Clip distance is requested but not supported by this device.
    #endif
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef VERTEX_SHADER
        #define attribute in
        #define varying out
    #endif
    #ifdef FRAGMENT_SHADER
        #define varying in
    #endif
    #define gl_FragColor sc_FragData0
    #define texture2D texture
    #define texture2DLod textureLod
    #define texture2DLodEXT textureLod
    #define textureCubeLodEXT textureLod
    #define sc_CanUseTextureLod 1
#else
    #ifdef FRAGMENT_SHADER
        #if defined(GL_EXT_shader_texture_lod)
            #extension GL_EXT_shader_texture_lod : require
            #define sc_CanUseTextureLod 1
            #define texture2DLod texture2DLodEXT
        #endif
    #endif
#endif
#if defined(sc_EnableMultiviewStereoRendering)
    #define sc_StereoRenderingMode sc_StereoRendering_Multiview
    #define sc_NumStereoViews 2
    #extension GL_OVR_multiview2 : require
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #define sc_LocalInstanceID sc_GlobalInstanceID
        #define sc_StereoViewID int(gl_ViewID_OVR)
    #endif
#elif defined(sc_EnableInstancedClippedStereoRendering)
    #ifndef sc_EnableInstancing
        #error Instanced-clipped stereo rendering requires enabled instancing.
    #endif
    #ifndef sc_EnableStereoClipDistance
        #define sc_StereoRendering_IsClipDistanceEnabled 0
    #else
        #define sc_StereoRendering_IsClipDistanceEnabled 1
    #endif
    #define sc_StereoRenderingMode sc_StereoRendering_InstancedClipped
    #define sc_NumStereoClipPlanes 1
    #define sc_NumStereoViews 2
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #ifdef sc_EnableFeatureLevelES3
            #define sc_LocalInstanceID (sc_GlobalInstanceID/2)
            #define sc_StereoViewID (sc_GlobalInstanceID%2)
        #else
            #define sc_LocalInstanceID int(sc_GlobalInstanceID/2.0)
            #define sc_StereoViewID int(mod(sc_GlobalInstanceID,2.0))
        #endif
    #endif
#else
    #define sc_StereoRenderingMode sc_StereoRendering_Disabled
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableInstancing
        #ifdef GL_ES
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)
                #define gl_InstanceID (0)
            #endif
        #else
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)&&!defined(GL_ARB_draw_instanced)&&!defined(GL_EXT_gpu_shader4)
                #define gl_InstanceID (0)
            #endif
        #endif
        #ifdef GL_ARB_draw_instanced
            #extension GL_ARB_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDARB
        #endif
        #ifdef GL_EXT_draw_instanced
            #extension GL_EXT_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDEXT
        #endif
        #ifndef sc_InstanceID
            #define sc_InstanceID gl_InstanceID
        #endif
        #ifndef sc_GlobalInstanceID
            #ifdef sc_EnableInstancingFallback
                #define sc_GlobalInstanceID (sc_FallbackInstanceID)
                #define sc_LocalInstanceID (sc_FallbackInstanceID)
            #else
                #define sc_GlobalInstanceID gl_InstanceID
                #define sc_LocalInstanceID gl_InstanceID
            #endif
        #endif
    #endif
#endif
#ifdef VERTEX_SHADER
    #if (__VERSION__<300)&&!defined(GL_EXT_gpu_shader4)
        #define gl_VertexID (0)
    #endif
#endif
#ifndef GL_ES
        #extension GL_EXT_gpu_shader4 : enable
    #extension GL_ARB_shader_texture_lod : enable
    #ifndef texture2DLodEXT
        #define texture2DLodEXT texture2DLod
    #endif
    #ifndef sc_CanUseTextureLod
    #define sc_CanUseTextureLod 1
    #endif
    #define precision
    #define lowp
    #define mediump
    #define highp
    #define sc_FragmentPrecision
#endif
#ifdef sc_EnableFeatureLevelES3
    #define sc_CanUseSampler2DArray 1
#endif
#if defined(sc_EnableFeatureLevelES2)&&defined(GL_ES)
    #ifdef FRAGMENT_SHADER
        #ifdef GL_OES_standard_derivatives
            #extension GL_OES_standard_derivatives : require
            #define sc_CanUseStandardDerivatives 1
        #endif
    #endif
    #ifdef GL_EXT_texture_array
        #extension GL_EXT_texture_array : require
        #define sc_CanUseSampler2DArray 1
    #else
        #define sc_CanUseSampler2DArray 0
    #endif
#endif
#ifdef GL_ES
    #ifdef sc_FramebufferFetch
        #if defined(GL_EXT_shader_framebuffer_fetch)
            #extension GL_EXT_shader_framebuffer_fetch : require
        #elif defined(GL_ARM_shader_framebuffer_fetch)
            #extension GL_ARM_shader_framebuffer_fetch : require
        #else
            #error Framebuffer fetch is requested but not supported by this device.
        #endif
    #endif
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        #define sc_FragmentPrecision highp
    #else
        #define sc_FragmentPrecision mediump
    #endif
    #ifdef FRAGMENT_SHADER
        precision highp int;
        precision highp float;
    #endif
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableMultiviewStereoRendering
        layout(num_views=sc_NumStereoViews) in;
    #endif
#endif
#if __VERSION__>100
    #define SC_INT_FALLBACK_FLOAT int
    #define SC_INTERPOLATION_FLAT flat
    #define SC_INTERPOLATION_CENTROID centroid
#else
    #define SC_INT_FALLBACK_FLOAT float
    #define SC_INTERPOLATION_FLAT
    #define SC_INTERPOLATION_CENTROID
#endif
#ifndef sc_NumStereoViews
    #define sc_NumStereoViews 1
#endif
#ifndef sc_CanUseSampler2DArray
    #define sc_CanUseSampler2DArray 0
#endif
    #if __VERSION__==100||defined(SCC_VALIDATION)
        #define sampler2DArray vec2
        #define sampler3D vec3
        #define samplerCube vec4
        vec4 texture3D(vec3 s,vec3 uv)                       { return vec4(0.0); }
        vec4 texture3D(vec3 s,vec3 uv,float bias)           { return vec4(0.0); }
        vec4 texture3DLod(vec3 s,vec3 uv,float bias)        { return vec4(0.0); }
        vec4 texture3DLodEXT(vec3 s,vec3 uv,float lod)      { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv)                  { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv,float bias)      { return vec4(0.0); }
        vec4 texture2DArrayLod(vec2 s,vec3 uv,float lod)    { return vec4(0.0); }
        vec4 texture2DArrayLodEXT(vec2 s,vec3 uv,float lod) { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv)                     { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv,float lod)          { return vec4(0.0); }
        vec4 textureCubeLod(vec4 s,vec3 uv,float lod)       { return vec4(0.0); }
        vec4 textureCubeLodEXT(vec4 s,vec3 uv,float lod)    { return vec4(0.0); }
        #if defined(VERTEX_SHADER)||!sc_CanUseTextureLod
            #define texture2DLod(s,uv,lod)      vec4(0.0)
            #define texture2DLodEXT(s,uv,lod)   vec4(0.0)
        #endif
    #elif __VERSION__>=300
        #define texture3D texture
        #define textureCube texture
        #define texture2DArray texture
        #define texture2DLod textureLod
        #define texture3DLod textureLod
        #define texture2DLodEXT textureLod
        #define texture3DLodEXT textureLod
        #define textureCubeLod textureLod
        #define textureCubeLodEXT textureLod
        #define texture2DArrayLod textureLod
        #define texture2DArrayLodEXT textureLod
    #endif
    #ifndef sc_TextureRenderingLayout_Regular
        #define sc_TextureRenderingLayout_Regular 0
        #define sc_TextureRenderingLayout_StereoInstancedClipped 1
        #define sc_TextureRenderingLayout_StereoMultiview 2
    #endif
    #define depthToGlobal   depthScreenToViewSpace
    #define depthToLocal    depthViewToScreenSpace
    #ifndef quantizeUV
        #define quantizeUV sc_QuantizeUV
        #define sc_platformUVFlip sc_PlatformFlipV
        #define sc_PlatformFlipUV sc_PlatformFlipV
    #endif
    #ifndef sc_texture2DLod
        #define sc_texture2DLod sc_InternalTextureLevel
        #define sc_textureLod sc_InternalTextureLevel
        #define sc_textureBias sc_InternalTextureBiasOrLevel
        #define sc_texture sc_InternalTexture
    #endif
struct sc_Vertex_t
{
vec4 position;
vec3 normal;
vec3 tangent;
vec2 texture0;
vec2 texture1;
};
struct ssGlobals
{
float gTimeElapsed;
float gTimeDelta;
float gTimeElapsedShifted;
vec3 SurfacePosition_WorldSpace;
vec3 VertexNormal_WorldSpace;
vec2 Surface_UVCoord0;
vec2 Surface_UVCoord1;
float gInstanceRatio;
};
#ifndef sc_CanUseTextureLod
#define sc_CanUseTextureLod 0
#elif sc_CanUseTextureLod==1
#undef sc_CanUseTextureLod
#define sc_CanUseTextureLod 1
#endif
#ifndef sc_StereoRenderingMode
#define sc_StereoRenderingMode 0
#endif
#ifndef sc_StereoViewID
#define sc_StereoViewID 0
#endif
#ifndef sc_RenderingSpace
#define sc_RenderingSpace -1
#endif
#ifndef sc_StereoRendering_IsClipDistanceEnabled
#define sc_StereoRendering_IsClipDistanceEnabled 0
#endif
#ifndef sc_NumStereoViews
#define sc_NumStereoViews 1
#endif
#ifndef sc_SkinBonesCount
#define sc_SkinBonesCount 0
#endif
#ifndef sc_VertexBlending
#define sc_VertexBlending 0
#elif sc_VertexBlending==1
#undef sc_VertexBlending
#define sc_VertexBlending 1
#endif
#ifndef sc_VertexBlendingUseNormals
#define sc_VertexBlendingUseNormals 0
#elif sc_VertexBlendingUseNormals==1
#undef sc_VertexBlendingUseNormals
#define sc_VertexBlendingUseNormals 1
#endif
struct sc_Camera_t
{
vec3 position;
float aspect;
vec2 clipPlanes;
};
#ifndef sc_IsEditor
#define sc_IsEditor 0
#elif sc_IsEditor==1
#undef sc_IsEditor
#define sc_IsEditor 1
#endif
#ifndef SC_DISABLE_FRUSTUM_CULLING
#define SC_DISABLE_FRUSTUM_CULLING 0
#elif SC_DISABLE_FRUSTUM_CULLING==1
#undef SC_DISABLE_FRUSTUM_CULLING
#define SC_DISABLE_FRUSTUM_CULLING 1
#endif
#ifndef sc_DepthBufferMode
#define sc_DepthBufferMode 0
#endif
#ifndef sc_ProjectiveShadowsReceiver
#define sc_ProjectiveShadowsReceiver 0
#elif sc_ProjectiveShadowsReceiver==1
#undef sc_ProjectiveShadowsReceiver
#define sc_ProjectiveShadowsReceiver 1
#endif
#ifndef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 0
#elif sc_OITDepthGatherPass==1
#undef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 1
#endif
#ifndef sc_OITCompositingPass
#define sc_OITCompositingPass 0
#elif sc_OITCompositingPass==1
#undef sc_OITCompositingPass
#define sc_OITCompositingPass 1
#endif
#ifndef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 0
#elif sc_OITDepthBoundsPass==1
#undef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 1
#endif
#ifndef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#elif UseViewSpaceDepthVariant==1
#undef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#endif
#ifndef customLengthTextureHasSwappedViews
#define customLengthTextureHasSwappedViews 0
#elif customLengthTextureHasSwappedViews==1
#undef customLengthTextureHasSwappedViews
#define customLengthTextureHasSwappedViews 1
#endif
#ifndef customLengthTextureLayout
#define customLengthTextureLayout 0
#endif
#ifndef Tweak_N164
#define Tweak_N164 0
#elif Tweak_N164==1
#undef Tweak_N164
#define Tweak_N164 1
#endif
#ifndef NODE_67_DROPLIST_ITEM
#define NODE_67_DROPLIST_ITEM 0
#endif
#ifndef NODE_167_DROPLIST_ITEM
#define NODE_167_DROPLIST_ITEM 0
#endif
#ifndef SC_USE_UV_TRANSFORM_customLengthTexture
#define SC_USE_UV_TRANSFORM_customLengthTexture 0
#elif SC_USE_UV_TRANSFORM_customLengthTexture==1
#undef SC_USE_UV_TRANSFORM_customLengthTexture
#define SC_USE_UV_TRANSFORM_customLengthTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_customLengthTexture
#define SC_SOFTWARE_WRAP_MODE_U_customLengthTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_customLengthTexture
#define SC_SOFTWARE_WRAP_MODE_V_customLengthTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_customLengthTexture
#define SC_USE_UV_MIN_MAX_customLengthTexture 0
#elif SC_USE_UV_MIN_MAX_customLengthTexture==1
#undef SC_USE_UV_MIN_MAX_customLengthTexture
#define SC_USE_UV_MIN_MAX_customLengthTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_customLengthTexture
#define SC_USE_CLAMP_TO_BORDER_customLengthTexture 0
#elif SC_USE_CLAMP_TO_BORDER_customLengthTexture==1
#undef SC_USE_CLAMP_TO_BORDER_customLengthTexture
#define SC_USE_CLAMP_TO_BORDER_customLengthTexture 1
#endif
#ifndef sc_PointLightsCount
#define sc_PointLightsCount 0
#endif
#ifndef sc_DirectionalLightsCount
#define sc_DirectionalLightsCount 0
#endif
#ifndef sc_AmbientLightsCount
#define sc_AmbientLightsCount 0
#endif
struct sc_PointLight_t
{
bool falloffEnabled;
float falloffEndDistance;
float negRcpFalloffEndDistance4;
float angleScale;
float angleOffset;
vec3 direction;
vec3 position;
vec4 color;
};
struct sc_DirectionalLight_t
{
vec3 direction;
vec4 color;
};
struct sc_AmbientLight_t
{
vec3 color;
float intensity;
};
struct sc_SphericalGaussianLight_t
{
vec3 color;
float sharpness;
vec3 axis;
};
struct sc_LightEstimationData_t
{
sc_SphericalGaussianLight_t sg[12];
vec3 ambientLight;
};
uniform vec4 sc_EnvmapDiffuseDims;
uniform vec4 sc_EnvmapSpecularDims;
uniform vec4 sc_ScreenTextureDims;
uniform mat4 sc_ModelMatrix;
uniform mat4 sc_ProjectorMatrix;
uniform vec4 sc_StereoClipPlanes[sc_NumStereoViews];
uniform vec4 sc_BoneMatrices[((sc_SkinBonesCount*3)+1)];
uniform mat3 sc_SkinBonesNormalMatrices[(sc_SkinBonesCount+1)];
uniform vec4 weights0;
uniform vec4 weights1;
uniform mat4 sc_ViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixArray[sc_NumStereoViews];
uniform sc_Camera_t sc_Camera;
uniform mat4 sc_ProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixArray[sc_NumStereoViews];
uniform float sc_DisableFrustumCullingMarker;
uniform mat4 sc_ProjectionMatrixArray[sc_NumStereoViews];
uniform mat3 sc_NormalMatrix;
uniform vec2 sc_TAAJitterOffset;
uniform vec4 intensityTextureDims;
uniform int PreviewEnabled;
uniform vec4 customLengthTextureDims;
uniform vec4 baseTextureDims;
uniform vec4 endsTextureDims;
uniform vec4 shapeTextureDims;
uniform float hairLength;
uniform vec2 Port_Default_N070;
uniform mat3 customLengthTextureTransform;
uniform vec4 customLengthTextureUvMinMax;
uniform vec4 customLengthTextureBorderColor;
uniform vec2 Port_Offset_N199;
uniform float Port_Input1_N166;
uniform float Port_Value_N253;
uniform vec2 Port_Import_N172;
uniform float Port_Input0_N173;
uniform vec2 Port_Center_N174;
uniform float Port_Input1_N175;
uniform float Port_Input1_N176;
uniform float Port_Input1_N179;
uniform float Port_Input0_N182;
uniform float Port_Import_N183;
uniform float Port_Input1_N185;
uniform float Port_Input2_N185;
uniform float Port_Input1_N188;
uniform float Port_Import_N170;
uniform float Port_RangeMinA_N196;
uniform float Port_RangeMaxB_N196;
uniform float Port_RangeMinB_N196;
uniform float Port_Input1_N198;
uniform float Port_Input2_N198;
uniform vec2 Port_Offset_N245;
uniform vec2 Port_Import_N215;
uniform float Port_Input0_N217;
uniform vec2 Port_Center_N218;
uniform float Port_Input1_N219;
uniform float Port_Input1_N220;
uniform float Port_Input1_N223;
uniform float Port_Input0_N226;
uniform float Port_Import_N227;
uniform float Port_Input1_N229;
uniform float Port_Input2_N229;
uniform float Port_Input1_N232;
uniform float Port_Import_N240;
uniform float Port_RangeMinA_N241;
uniform float Port_RangeMaxB_N241;
uniform float Port_RangeMinB_N241;
uniform float Port_Input1_N243;
uniform float Port_Input2_N243;
uniform float Port_Input1_N260;
uniform float Port_Input1_N249;
uniform float Port_Value_N252;
uniform vec2 Port_Offset_N278;
uniform vec2 Port_Import_N281;
uniform float Port_Input0_N282;
uniform vec2 Port_Center_N283;
uniform float Port_Input1_N284;
uniform float Port_Input1_N285;
uniform float Port_Input1_N288;
uniform float Port_Input0_N291;
uniform float Port_Import_N292;
uniform float Port_Input1_N294;
uniform float Port_Input2_N294;
uniform float Port_Input1_N297;
uniform float Port_Import_N305;
uniform float Port_RangeMinA_N306;
uniform float Port_RangeMaxB_N306;
uniform float Port_RangeMinB_N306;
uniform float Port_Input1_N308;
uniform float Port_Input2_N308;
uniform float Port_Input1_N264;
uniform float Port_Input1_N405;
uniform float Port_Value_N265;
uniform vec2 Port_Offset_N269;
uniform vec2 Port_Import_N272;
uniform float Port_Input0_N273;
uniform vec2 Port_Center_N274;
uniform float Port_Input1_N275;
uniform float Port_Input1_N276;
uniform float Port_Input1_N310;
uniform float Port_Input0_N314;
uniform float Port_Import_N315;
uniform float Port_Input1_N317;
uniform float Port_Input2_N317;
uniform float Port_Input1_N320;
uniform float Port_Import_N328;
uniform float Port_RangeMinA_N329;
uniform float Port_RangeMaxB_N329;
uniform float Port_RangeMinB_N329;
uniform float Port_Input1_N331;
uniform float Port_Input2_N331;
uniform vec2 Port_Import_N335;
uniform float Port_Input0_N336;
uniform vec2 Port_Center_N337;
uniform float Port_Input1_N338;
uniform float Port_Input1_N339;
uniform float Port_Input1_N342;
uniform float Port_Input0_N345;
uniform float Port_Import_N346;
uniform float Port_Input1_N348;
uniform float Port_Input2_N348;
uniform float Port_Input1_N351;
uniform float Port_Import_N359;
uniform float Port_RangeMinA_N360;
uniform float Port_RangeMaxB_N360;
uniform float Port_RangeMinB_N360;
uniform float Port_Input1_N362;
uniform float Port_Input2_N362;
uniform float Port_Input1_N366;
uniform float Port_Input1_N404;
uniform float Port_Value_N367;
uniform vec2 Port_Offset_N371;
uniform vec2 Port_Import_N374;
uniform float Port_Input0_N375;
uniform vec2 Port_Center_N376;
uniform float Port_Input1_N377;
uniform float Port_Input1_N378;
uniform float Port_Input1_N381;
uniform float Port_Input0_N384;
uniform float Port_Import_N385;
uniform float Port_Input1_N387;
uniform float Port_Input2_N387;
uniform float Port_Input1_N390;
uniform float Port_Import_N398;
uniform float Port_RangeMinA_N399;
uniform float Port_RangeMaxB_N399;
uniform float Port_RangeMinB_N399;
uniform float Port_Input1_N401;
uniform float Port_Input2_N401;
uniform float Port_Input1_N402;
uniform float customLengthBlend;
uniform float Port_Default_N211;
uniform float variationScale;
uniform float variationSharpness;
uniform float variationStrength;
uniform vec4 sc_GeometryInfo;
uniform vec3 bendDirection;
uniform int overrideTimeEnabled;
uniform float overrideTimeElapsed;
uniform vec4 sc_Time;
uniform float overrideTimeDelta;
uniform float Port_Default_N165;
uniform float Port_RangeMinA_N081;
uniform float Port_RangeMaxA_N081;
uniform float Port_RangeMaxB_N081;
uniform float Port_RangeMinB_N081;
uniform vec3 Port_VectorIn_N094;
uniform vec3 Port_VectorIn_N095;
uniform vec3 Port_VectorIn_N096;
uniform vec3 Port_VectorIn_N097;
uniform float Port_Input1_N040;
uniform sc_PointLight_t sc_PointLights[(sc_PointLightsCount+1)];
uniform sc_DirectionalLight_t sc_DirectionalLights[(sc_DirectionalLightsCount+1)];
uniform sc_AmbientLight_t sc_AmbientLights[(sc_AmbientLightsCount+1)];
uniform sc_LightEstimationData_t sc_LightEstimationData;
uniform vec4 sc_EnvmapDiffuseSize;
uniform vec4 sc_EnvmapDiffuseView;
uniform vec4 sc_EnvmapSpecularSize;
uniform vec4 sc_EnvmapSpecularView;
uniform vec3 sc_EnvmapRotation;
uniform float sc_EnvmapExposure;
uniform vec3 sc_Sh[9];
uniform float sc_ShIntensity;
uniform vec4 sc_UniformConstants;
uniform mat4 sc_ModelViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixInverseArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_PrevFrameViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelMatrixInverse;
uniform mat3 sc_NormalMatrixInverse;
uniform mat4 sc_PrevFrameModelMatrix;
uniform mat4 sc_PrevFrameModelMatrixInverse;
uniform vec3 sc_LocalAabbMin;
uniform vec3 sc_LocalAabbMax;
uniform vec3 sc_WorldAabbMin;
uniform vec3 sc_WorldAabbMax;
uniform vec4 sc_WindowToViewportTransform;
uniform float sc_ShadowDensity;
uniform vec4 sc_ShadowColor;
uniform float _sc_GetFramebufferColorInvalidUsageMarker;
uniform float shaderComplexityValue;
uniform vec4 weights2;
uniform int sc_FallbackInstanceID;
uniform float _sc_framebufferFetchMarker;
uniform float strandWidth;
uniform float strandTaper;
uniform vec4 sc_StrandDataMapTextureSize;
uniform float clumpInstanceCount;
uniform float clumpRadius;
uniform float clumpTipScale;
uniform float hairstyleInstanceCount;
uniform float hairstyleNoise;
uniform vec4 sc_ScreenTextureSize;
uniform vec4 sc_ScreenTextureView;
uniform float correctedIntensity;
uniform vec4 intensityTextureSize;
uniform vec4 intensityTextureView;
uniform mat3 intensityTextureTransform;
uniform vec4 intensityTextureUvMinMax;
uniform vec4 intensityTextureBorderColor;
uniform float reflBlurWidth;
uniform float reflBlurMinRough;
uniform float reflBlurMaxRough;
uniform int PreviewNodeID;
uniform float alphaTestThreshold;
uniform vec4 customLengthTextureSize;
uniform vec4 customLengthTextureView;
uniform float rimExponent;
uniform float rimIntensity;
uniform vec3 rimColor;
uniform vec3 baseColorRGB;
uniform vec4 baseTextureSize;
uniform vec4 baseTextureView;
uniform mat3 baseTextureTransform;
uniform vec4 baseTextureUvMinMax;
uniform vec4 baseTextureBorderColor;
uniform vec3 endsColor;
uniform vec4 endsTextureSize;
uniform vec4 endsTextureView;
uniform mat3 endsTextureTransform;
uniform vec4 endsTextureUvMinMax;
uniform vec4 endsTextureBorderColor;
uniform float Tweak_N107;
uniform float Tweak_N110;
uniform float windScale;
uniform float colorFalloff;
uniform float rainbowRingsCount;
uniform float rainbowOffset;
uniform vec3 decolorizeColor;
uniform float decolorizeSeed;
uniform float uvScaleTex;
uniform float decolorizeAreaScale;
uniform float decolorizeIntensity;
uniform vec3 subsurface;
uniform float AO;
uniform vec4 shapeTextureSize;
uniform vec4 shapeTextureView;
uniform mat3 shapeTextureTransform;
uniform vec4 shapeTextureUvMinMax;
uniform vec4 shapeTextureBorderColor;
uniform float fluffy;
uniform float hairTransparency;
uniform float featheredSmallHairs;
uniform float cutoff;
uniform vec2 Port_Import_N171;
uniform vec2 Port_Import_N125;
uniform vec2 Port_Import_N280;
uniform vec2 Port_Import_N271;
uniform vec2 Port_Import_N334;
uniform vec2 Port_Import_N373;
uniform vec3 Port_Normal_N057;
uniform vec3 Port_Value0_N123;
uniform vec3 Port_Default_N123;
uniform vec3 Port_Value0_N126;
uniform vec2 Port_Value0_N121;
uniform vec2 Port_Import_N426;
uniform float Port_Input1_N079;
uniform float Port_Import_N427;
uniform vec2 Port_Import_N429;
uniform float Port_Input1_N433;
uniform vec2 Port_Center_N434;
uniform float Port_RangeMinA_N118;
uniform float Port_RangeMaxA_N118;
uniform float Port_RangeMinB_N118;
uniform float Port_RangeMaxB_N118;
uniform vec2 Port_Default_N121;
uniform float Port_Input1_N147;
uniform float Port_Input1_N114;
uniform vec3 Port_Default_N126;
uniform vec3 Port_Default_N139;
uniform vec2 Port_Default_N256;
uniform float Port_Opacity_N049;
uniform vec3 Port_Normal_N049;
uniform float Port_Value_N151;
uniform vec3 Port_Input0_N201;
uniform float Port_RangeMinA_N056;
uniform float Port_RangeMaxA_N056;
uniform float Port_RangeMaxB_N056;
uniform vec2 Port_Scale_N437;
uniform vec2 Port_Input1_N115;
uniform float Port_Default_N064;
uniform float Port_Input0_N143;
uniform float Port_Value_N054;
uniform float Port_Input1_N138;
uniform float Port_Input2_N138;
uniform float Port_Input1_N206;
uniform float Port_Input2_N206;
uniform float Port_Input1_N048;
uniform sampler2D customLengthTexture;
varying float varClipDistance;
varying float varStereoViewID;
attribute vec4 boneData;
attribute vec3 blendShape0Pos;
attribute vec3 blendShape0Normal;
attribute vec3 blendShape1Pos;
attribute vec3 blendShape1Normal;
attribute vec3 blendShape2Pos;
attribute vec3 blendShape2Normal;
attribute vec3 blendShape3Pos;
attribute vec3 blendShape4Pos;
attribute vec3 blendShape5Pos;
attribute vec4 position;
attribute vec3 normal;
attribute vec4 tangent;
attribute vec2 texture0;
attribute vec2 texture1;
varying vec3 varPos;
varying vec3 varNormal;
varying vec4 varTangent;
varying vec4 varPackedTex;
varying vec4 varScreenPos;
varying vec2 varScreenTexturePos;
varying vec2 varShadowTex;
varying float varViewSpaceDepth;
varying vec4 varColor;
attribute vec4 color;
varying vec4 PreviewVertexColor;
varying float PreviewVertexSaved;
varying float Interpolator_gInstanceRatio;
attribute vec3 positionNext;
attribute vec3 positionPrevious;
attribute vec4 strandProperties;
void blendTargetShapeWithNormal(inout sc_Vertex_t v,vec3 position_1,vec3 normal_1,float weight)
{
vec3 l9_0=v.position.xyz+(position_1*weight);
v=sc_Vertex_t(vec4(l9_0.x,l9_0.y,l9_0.z,v.position.w),v.normal,v.tangent,v.texture0,v.texture1);
v.normal+=(normal_1*weight);
}
int sc_GetBoneIndex(int index)
{
int l9_0;
#if (sc_SkinBonesCount>0)
{
l9_0=int(boneData[index]);
}
#else
{
l9_0=0;
}
#endif
return l9_0;
}
void sc_GetBoneMatrix(int index,out vec4 m0,out vec4 m1,out vec4 m2)
{
int l9_0=3*index;
m0=sc_BoneMatrices[l9_0];
m1=sc_BoneMatrices[l9_0+1];
m2=sc_BoneMatrices[l9_0+2];
}
vec3 skinVertexPosition(int i,vec4 v)
{
vec3 l9_0;
#if (sc_SkinBonesCount>0)
{
vec4 param_1;
vec4 param_2;
vec4 param_3;
sc_GetBoneMatrix(i,param_1,param_2,param_3);
l9_0=vec3(dot(v,param_1),dot(v,param_2),dot(v,param_3));
}
#else
{
l9_0=v.xyz;
}
#endif
return l9_0;
}
int sc_GetLocalInstanceID()
{
#ifdef sc_LocalInstanceID
    return sc_LocalInstanceID;
#else
    return 0;
#endif
}
int sc_GetStereoViewIndex()
{
int l9_0;
#if (sc_StereoRenderingMode==0)
{
l9_0=0;
}
#else
{
l9_0=sc_StereoViewID;
}
#endif
return l9_0;
}
void sc_SoftwareWrapEarly(inout float uv,int softwareWrapMode)
{
if (softwareWrapMode==1)
{
uv=fract(uv);
}
else
{
if (softwareWrapMode==2)
{
float l9_0=fract(uv);
uv=mix(l9_0,1.0-l9_0,clamp(step(0.25,fract((uv-l9_0)*0.5)),0.0,1.0));
}
}
}
void sc_ClampUV(inout float value,float minValue,float maxValue,bool useClampToBorder,inout float clampToBorderFactor)
{
float l9_0=clamp(value,minValue,maxValue);
float l9_1=step(abs(value-l9_0),9.9999997e-06);
clampToBorderFactor*=(l9_1+((1.0-float(useClampToBorder))*(1.0-l9_1)));
value=l9_0;
}
void sc_SoftwareWrapLate(inout float uv,int softwareWrapMode,bool useClampToBorder,inout float clampToBorderFactor)
{
if ((softwareWrapMode==0)||(softwareWrapMode==3))
{
sc_ClampUV(uv,0.0,1.0,useClampToBorder,clampToBorderFactor);
}
}
void Node211_Switch(float Switch,float Value0,float Value1,float Value2,float Value3,float Value4,float Default,out float Result,ssGlobals Globals)
{
#if (NODE_167_DROPLIST_ITEM==0)
{
vec2 l9_0;
#if (NODE_67_DROPLIST_ITEM==0)
{
l9_0=Globals.Surface_UVCoord0;
}
#else
{
vec2 l9_1;
#if (NODE_67_DROPLIST_ITEM==1)
{
l9_1=Globals.Surface_UVCoord1;
}
#else
{
l9_1=Port_Default_N070;
}
#endif
l9_0=l9_1;
}
#endif
int l9_2;
#if (customLengthTextureHasSwappedViews)
{
l9_2=1-sc_GetStereoViewIndex();
}
#else
{
l9_2=sc_GetStereoViewIndex();
}
#endif
float l9_3=l9_0.x;
sc_SoftwareWrapEarly(l9_3,ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture).x);
float l9_4=l9_3;
float l9_5=l9_0.y;
sc_SoftwareWrapEarly(l9_5,ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture).y);
float l9_6=l9_5;
vec2 l9_7;
float l9_8;
#if (SC_USE_UV_MIN_MAX_customLengthTexture)
{
bool l9_9;
#if (SC_USE_CLAMP_TO_BORDER_customLengthTexture)
{
l9_9=ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture).x==3;
}
#else
{
l9_9=(int(SC_USE_CLAMP_TO_BORDER_customLengthTexture)!=0);
}
#endif
float l9_10=l9_4;
float l9_11=1.0;
sc_ClampUV(l9_10,customLengthTextureUvMinMax.x,customLengthTextureUvMinMax.z,l9_9,l9_11);
float l9_12=l9_10;
float l9_13=l9_11;
bool l9_14;
#if (SC_USE_CLAMP_TO_BORDER_customLengthTexture)
{
l9_14=ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture).y==3;
}
#else
{
l9_14=(int(SC_USE_CLAMP_TO_BORDER_customLengthTexture)!=0);
}
#endif
float l9_15=l9_6;
float l9_16=l9_13;
sc_ClampUV(l9_15,customLengthTextureUvMinMax.y,customLengthTextureUvMinMax.w,l9_14,l9_16);
l9_8=l9_16;
l9_7=vec2(l9_12,l9_15);
}
#else
{
l9_8=1.0;
l9_7=vec2(l9_4,l9_6);
}
#endif
vec2 l9_17;
#if (SC_USE_UV_TRANSFORM_customLengthTexture)
{
l9_17=vec2((customLengthTextureTransform*vec3(l9_7,1.0)).xy);
}
#else
{
l9_17=l9_7;
}
#endif
float l9_18=l9_17.x;
float l9_19=l9_8;
sc_SoftwareWrapLate(l9_18,ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture).x,(int(SC_USE_CLAMP_TO_BORDER_customLengthTexture)!=0)&&(!(int(SC_USE_UV_MIN_MAX_customLengthTexture)!=0)),l9_19);
float l9_20=l9_18;
float l9_21=l9_17.y;
float l9_22=l9_19;
sc_SoftwareWrapLate(l9_21,ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture).y,(int(SC_USE_CLAMP_TO_BORDER_customLengthTexture)!=0)&&(!(int(SC_USE_UV_MIN_MAX_customLengthTexture)!=0)),l9_22);
float l9_23=l9_21;
float l9_24=l9_22;
vec3 l9_25;
#if (customLengthTextureLayout==0)
{
l9_25=vec3(l9_20,l9_23,0.0);
}
#else
{
vec3 l9_26;
#if (customLengthTextureLayout==1)
{
l9_26=vec3(l9_20,(l9_23*0.5)+(0.5-(float(l9_2)*0.5)),0.0);
}
#else
{
l9_26=vec3(l9_20,l9_23,0.0);
}
#endif
l9_25=l9_26;
}
#endif
vec4 l9_27;
#if (sc_CanUseTextureLod)
{
l9_27=texture2DLod(customLengthTexture,l9_25.xy,0.0);
}
#else
{
l9_27=vec4(0.0);
}
#endif
vec4 l9_28;
#if (SC_USE_CLAMP_TO_BORDER_customLengthTexture)
{
l9_28=mix(customLengthTextureBorderColor,l9_27,vec4(l9_24));
}
#else
{
l9_28=l9_27;
}
#endif
Value0=l9_28.x;
Result=Value0;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==1)
{
vec2 l9_29=Globals.Surface_UVCoord0;
vec2 l9_30=l9_29+Port_Offset_N199;
float l9_31=l9_30.x;
vec2 l9_32=((((vec2(l9_31,l9_30.y+(abs(l9_31-Port_Input1_N166)*((Port_Value_N253+0.001)-0.001)))-Port_Center_N174)*(vec2(Port_Input0_N173)/(clamp(Port_Import_N172,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N174)*vec2(Port_Input1_N175))-vec2(Port_Input1_N176);
float l9_33=atan(l9_32.y*Port_Input1_N179,l9_32.x);
float l9_34=(Port_Input0_N182*3.1415927)/(clamp(floor(Port_Import_N183),Port_Input1_N185,Port_Input2_N185)+1.234e-06);
vec2 l9_35=(((((l9_29+Port_Offset_N245)-Port_Center_N218)*(vec2(Port_Input0_N217)/(clamp(Port_Import_N215,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N218)*vec2(Port_Input1_N219))-vec2(Port_Input1_N220);
float l9_36=atan(l9_35.y*Port_Input1_N223,l9_35.x);
float l9_37=(Port_Input0_N226*3.1415927)/(clamp(floor(Port_Import_N227),Port_Input1_N229,Port_Input2_N229)+1.234e-06);
float l9_38=clamp((((((1.0-(cos((floor((l9_36/(l9_37+1.234e-06))+Port_Input1_N232)*l9_37)-l9_36)*length(l9_35)))-Port_RangeMinA_N241)/(clamp(Port_Import_N240,0.0,1.0)-Port_RangeMinA_N241))*(Port_RangeMaxB_N241-Port_RangeMinB_N241))+Port_RangeMinB_N241)+0.001,Port_Input1_N243+0.001,Port_Input2_N243+0.001)-0.001;
float l9_39;
if (l9_38<=0.0)
{
l9_39=0.0;
}
else
{
l9_39=pow(l9_38,Port_Input1_N260);
}
Value1=(clamp((((((1.0-(cos((floor((l9_33/(l9_34+1.234e-06))+Port_Input1_N188)*l9_34)-l9_33)*length(l9_32)))-Port_RangeMinA_N196)/(clamp(Port_Import_N170,0.0,1.0)-Port_RangeMinA_N196))*(Port_RangeMaxB_N196-Port_RangeMinB_N196))+Port_RangeMinB_N196)+0.001,Port_Input1_N198+0.001,Port_Input2_N198+0.001)-0.001)-l9_39;
Result=Value1;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==2)
{
vec2 l9_40=(((((vec2(Globals.Surface_UVCoord0.x,Globals.Surface_UVCoord0.y+(abs(Globals.Surface_UVCoord0.x-Port_Input1_N249)*((Port_Value_N252+0.001)-0.001)))+Port_Offset_N278)-Port_Center_N283)*(vec2(Port_Input0_N282)/(clamp(Port_Import_N281,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N283)*vec2(Port_Input1_N284))-vec2(Port_Input1_N285);
float l9_41=atan(l9_40.y*Port_Input1_N288,l9_40.x);
float l9_42=(Port_Input0_N291*3.1415927)/(clamp(floor(Port_Import_N292),Port_Input1_N294,Port_Input2_N294)+1.234e-06);
Value2=clamp((((((1.0-(cos((floor((l9_41/(l9_42+1.234e-06))+Port_Input1_N297)*l9_42)-l9_41)*length(l9_40)))-Port_RangeMinA_N306)/(clamp(Port_Import_N305,0.0,1.0)-Port_RangeMinA_N306))*(Port_RangeMaxB_N306-Port_RangeMinB_N306))+Port_RangeMinB_N306)+0.001,Port_Input1_N308+0.001,Port_Input2_N308+0.001)-0.001;
Result=Value2;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==3)
{
vec2 l9_43=Globals.Surface_UVCoord0;
float l9_44=abs(l9_43.x-Port_Input1_N264);
float l9_45;
if (l9_44<=0.0)
{
l9_45=0.0;
}
else
{
l9_45=pow(l9_44,Port_Input1_N405);
}
vec2 l9_46=vec2(l9_43.x,l9_43.y+(l9_45*((Port_Value_N265+0.001)-0.001)))+Port_Offset_N269;
vec2 l9_47=((((l9_46-Port_Center_N274)*(vec2(Port_Input0_N273)/(clamp(Port_Import_N272,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N274)*vec2(Port_Input1_N275))-vec2(Port_Input1_N276);
float l9_48=atan(l9_47.y*Port_Input1_N310,l9_47.x);
float l9_49=(Port_Input0_N314*3.1415927)/(clamp(floor(Port_Import_N315),Port_Input1_N317,Port_Input2_N317)+1.234e-06);
vec2 l9_50=((((l9_46-Port_Center_N337)*(vec2(Port_Input0_N336)/(clamp(Port_Import_N335,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N337)*vec2(Port_Input1_N338))-vec2(Port_Input1_N339);
float l9_51=atan(l9_50.y*Port_Input1_N342,l9_50.x);
float l9_52=(Port_Input0_N345*3.1415927)/(clamp(floor(Port_Import_N346),Port_Input1_N348,Port_Input2_N348)+1.234e-06);
Value3=(clamp((((((1.0-(cos((floor((l9_48/(l9_49+1.234e-06))+Port_Input1_N320)*l9_49)-l9_48)*length(l9_47)))-Port_RangeMinA_N329)/(clamp(Port_Import_N328,0.0,1.0)-Port_RangeMinA_N329))*(Port_RangeMaxB_N329-Port_RangeMinB_N329))+Port_RangeMinB_N329)+0.001,Port_Input1_N331+0.001,Port_Input2_N331+0.001)-0.001)-(clamp((((((1.0-(cos((floor((l9_51/(l9_52+1.234e-06))+Port_Input1_N351)*l9_52)-l9_51)*length(l9_50)))-Port_RangeMinA_N360)/(clamp(Port_Import_N359,0.0,1.0)-Port_RangeMinA_N360))*(Port_RangeMaxB_N360-Port_RangeMinB_N360))+Port_RangeMinB_N360)+0.001,Port_Input1_N362+0.001,Port_Input2_N362+0.001)-0.001);
Result=Value3;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==4)
{
vec2 l9_53=Globals.Surface_UVCoord0;
float l9_54=abs(l9_53.x-Port_Input1_N366);
float l9_55;
if (l9_54<=0.0)
{
l9_55=0.0;
}
else
{
l9_55=pow(l9_54,Port_Input1_N404);
}
vec2 l9_56=(((((vec2(l9_53.x,l9_53.y+(l9_55*((Port_Value_N367+0.001)-0.001)))+Port_Offset_N371)-Port_Center_N376)*(vec2(Port_Input0_N375)/(clamp(Port_Import_N374,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N376)*vec2(Port_Input1_N377))-vec2(Port_Input1_N378);
float l9_57=atan(l9_56.y*Port_Input1_N381,l9_56.x);
float l9_58=(Port_Input0_N384*3.1415927)/(clamp(floor(Port_Import_N385),Port_Input1_N387,Port_Input2_N387)+1.234e-06);
Value4=(clamp((((((1.0-(cos((floor((l9_57/(l9_58+1.234e-06))+Port_Input1_N390)*l9_58)-l9_57)*length(l9_56)))-Port_RangeMinA_N399)/(clamp(Port_Import_N398,0.0,1.0)-Port_RangeMinA_N399))*(Port_RangeMaxB_N399-Port_RangeMinB_N399))+Port_RangeMinB_N399)+0.001,Port_Input1_N401+0.001,Port_Input2_N401+0.001)-0.001)-Port_Input1_N402;
Result=Value4;
}
#else
{
Result=Default;
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
void sc_SetClipDistancePlatform(float dstClipDistance)
{
    #if sc_StereoRenderingMode==sc_StereoRendering_InstancedClipped&&sc_StereoRendering_IsClipDistanceEnabled
        gl_ClipDistance[0]=dstClipDistance;
    #endif
}
void main()
{
PreviewVertexColor=vec4(0.5);
PreviewVertexSaved=0.0;
vec4 l9_0;
#if (sc_IsEditor&&SC_DISABLE_FRUSTUM_CULLING)
{
vec4 l9_1=position;
l9_1.x=position.x+sc_DisableFrustumCullingMarker;
l9_0=l9_1;
}
#else
{
l9_0=position;
}
#endif
vec2 l9_2;
vec2 l9_3;
vec3 l9_4;
vec3 l9_5;
vec4 l9_6;
#if (sc_VertexBlending)
{
vec2 l9_7;
vec2 l9_8;
vec3 l9_9;
vec3 l9_10;
vec4 l9_11;
#if (sc_VertexBlendingUseNormals)
{
sc_Vertex_t l9_12=sc_Vertex_t(l9_0,normal,tangent.xyz,texture0,texture1);
blendTargetShapeWithNormal(l9_12,blendShape0Pos,blendShape0Normal,weights0.x);
blendTargetShapeWithNormal(l9_12,blendShape1Pos,blendShape1Normal,weights0.y);
blendTargetShapeWithNormal(l9_12,blendShape2Pos,blendShape2Normal,weights0.z);
l9_11=l9_12.position;
l9_10=l9_12.normal;
l9_9=l9_12.tangent;
l9_8=l9_12.texture0;
l9_7=l9_12.texture1;
}
#else
{
vec3 l9_14=(((((l9_0.xyz+(blendShape0Pos*weights0.x)).xyz+(blendShape1Pos*weights0.y)).xyz+(blendShape2Pos*weights0.z)).xyz+(blendShape3Pos*weights0.w)).xyz+(blendShape4Pos*weights1.x)).xyz+(blendShape5Pos*weights1.y);
l9_11=vec4(l9_14.x,l9_14.y,l9_14.z,l9_0.w);
l9_10=normal;
l9_9=tangent.xyz;
l9_8=texture0;
l9_7=texture1;
}
#endif
l9_6=l9_11;
l9_5=l9_10;
l9_4=l9_9;
l9_3=l9_8;
l9_2=l9_7;
}
#else
{
l9_6=l9_0;
l9_5=normal;
l9_4=tangent.xyz;
l9_3=texture0;
l9_2=texture1;
}
#endif
vec3 l9_15;
vec3 l9_16;
vec4 l9_17;
#if (sc_SkinBonesCount>0)
{
vec4 l9_18;
#if (sc_SkinBonesCount>0)
{
vec4 l9_19=vec4(1.0,fract(boneData.yzw));
vec4 l9_20=l9_19;
l9_20.x=1.0-dot(l9_19.yzw,vec3(1.0));
l9_18=l9_20;
}
#else
{
l9_18=vec4(0.0);
}
#endif
int l9_21=sc_GetBoneIndex(0);
int l9_22=sc_GetBoneIndex(1);
int l9_23=sc_GetBoneIndex(2);
int l9_24=sc_GetBoneIndex(3);
vec3 l9_25=(((skinVertexPosition(l9_21,l9_6)*l9_18.x)+(skinVertexPosition(l9_22,l9_6)*l9_18.y))+(skinVertexPosition(l9_23,l9_6)*l9_18.z))+(skinVertexPosition(l9_24,l9_6)*l9_18.w);
l9_17=vec4(l9_25.x,l9_25.y,l9_25.z,l9_6.w);
l9_16=((((sc_SkinBonesNormalMatrices[l9_21]*l9_5)*l9_18.x)+((sc_SkinBonesNormalMatrices[l9_22]*l9_5)*l9_18.y))+((sc_SkinBonesNormalMatrices[l9_23]*l9_5)*l9_18.z))+((sc_SkinBonesNormalMatrices[l9_24]*l9_5)*l9_18.w);
l9_15=((((sc_SkinBonesNormalMatrices[l9_21]*l9_4)*l9_18.x)+((sc_SkinBonesNormalMatrices[l9_22]*l9_4)*l9_18.y))+((sc_SkinBonesNormalMatrices[l9_23]*l9_4)*l9_18.z))+((sc_SkinBonesNormalMatrices[l9_24]*l9_4)*l9_18.w);
}
#else
{
l9_17=l9_6;
l9_16=l9_5;
l9_15=l9_4;
}
#endif
#if (sc_RenderingSpace==3)
{
varPos=vec3(0.0);
varNormal=l9_16;
varTangent=vec4(l9_15.x,l9_15.y,l9_15.z,varTangent.w);
}
#else
{
#if (sc_RenderingSpace==4)
{
varPos=vec3(0.0);
varNormal=l9_16;
varTangent=vec4(l9_15.x,l9_15.y,l9_15.z,varTangent.w);
}
#else
{
#if (sc_RenderingSpace==2)
{
varPos=l9_17.xyz;
varNormal=l9_16;
varTangent=vec4(l9_15.x,l9_15.y,l9_15.z,varTangent.w);
}
#else
{
#if (sc_RenderingSpace==1)
{
varPos=(sc_ModelMatrix*l9_17).xyz;
varNormal=sc_NormalMatrix*l9_16;
vec3 l9_26=sc_NormalMatrix*l9_15;
varTangent=vec4(l9_26.x,l9_26.y,l9_26.z,varTangent.w);
}
#endif
}
#endif
}
#endif
}
#endif
bool l9_27=PreviewEnabled==1;
vec2 l9_28;
if (l9_27)
{
vec2 l9_29=l9_3;
l9_29.x=1.0-l9_3.x;
l9_28=l9_29;
}
else
{
l9_28=l9_3;
}
varColor=color;
bool l9_30=overrideTimeEnabled==1;
float l9_31;
if (l9_30)
{
l9_31=overrideTimeElapsed;
}
else
{
l9_31=sc_Time.x;
}
float l9_32;
if (l9_30)
{
l9_32=overrideTimeDelta;
}
else
{
l9_32=sc_Time.y;
}
vec3 l9_33=varPos;
vec3 l9_34=varNormal;
bool l9_35=sc_GeometryInfo.y>1.0;
float l9_36;
if (l9_35)
{
l9_36=float(sc_GetLocalInstanceID())/(sc_GeometryInfo.y-1.0);
}
else
{
l9_36=0.0;
}
vec3 l9_37=varNormal;
float l9_38=dot(l9_34,l9_34);
float l9_39;
if (l9_38>0.0)
{
l9_39=1.0/sqrt(l9_38);
}
else
{
l9_39=0.0;
}
vec3 l9_40=l9_34*l9_39;
ssGlobals l9_41=ssGlobals(l9_31,l9_32,0.0,l9_33,l9_34,l9_28,l9_2,l9_36);
float l9_42;
#if ((Tweak_N164)==0)
{
l9_42=hairLength;
}
#else
{
float l9_43;
#if ((Tweak_N164)==1)
{
float l9_44;
Node211_Switch(0.0,0.0,0.0,0.0,0.0,0.0,Port_Default_N211,l9_44,l9_41);
l9_43=mix(hairLength,l9_44*hairLength,customLengthBlend);
}
#else
{
l9_43=Port_Default_N165;
}
#endif
l9_42=l9_43;
}
#endif
vec2 l9_45=l9_28*10000.0;
float l9_46=floor(fract(sin(floor(dot(floor((floor(l9_45)*9.9999997e-05)*vec2(variationScale)),vec2(0.98000002,0.72000003))*10000.0)*9.9999997e-05)*437.58499)*10000.0)*9.9999997e-05;
float l9_47;
if (l9_46<=0.0)
{
l9_47=0.0;
}
else
{
l9_47=pow(l9_46,variationSharpness);
}
float l9_48=l9_47-Port_RangeMinA_N081;
float l9_49=l9_42*(((l9_48/(Port_RangeMaxA_N081-Port_RangeMinA_N081))*(Port_RangeMaxB_N081-Port_RangeMinB_N081))+Port_RangeMinB_N081);
float l9_50=l9_42+l9_49;
float l9_51=mix(l9_42,l9_50,variationStrength);
vec3 l9_52=(sc_ModelMatrix*vec4(Port_VectorIn_N094,1.0)).xyz;
float l9_53;
if (l9_35)
{
l9_53=float(sc_GetLocalInstanceID())/(sc_GeometryInfo.y-1.0);
}
else
{
l9_53=0.0;
}
vec3 l9_54=vec3(l9_53);
float l9_55;
if (l9_35)
{
l9_55=float(sc_GetLocalInstanceID())/(sc_GeometryInfo.y-1.0);
}
else
{
l9_55=0.0;
}
float l9_56;
if (l9_55<=0.0)
{
l9_56=0.0;
}
else
{
l9_56=pow(l9_55,Port_Input1_N040);
}
vec3 l9_57=vec3(l9_56);
vec3 l9_58;
vec3 l9_59;
vec3 l9_60;
if (l9_27)
{
l9_60=varTangent.xyz;
l9_59=varNormal;
l9_58=varPos;
}
else
{
l9_60=varTangent.xyz;
l9_59=l9_37;
l9_58=l9_33+(((l9_40*(vec3(l9_51)*vec3(distance(l9_52,(sc_ModelMatrix*vec4(Port_VectorIn_N095,1.0)).xyz),distance(l9_52,(sc_ModelMatrix*vec4(Port_VectorIn_N096,1.0)).xyz),distance(l9_52,(sc_ModelMatrix*vec4(Port_VectorIn_N097,1.0)).xyz))))*l9_54)+(l9_57*bendDirection));
}
varPos=l9_58;
varNormal=normalize(l9_59);
vec3 l9_61=normalize(l9_60);
varTangent=vec4(l9_61.x,l9_61.y,l9_61.z,varTangent.w);
varTangent.w=tangent.w;
#if (UseViewSpaceDepthVariant&&((sc_OITDepthGatherPass||sc_OITCompositingPass)||sc_OITDepthBoundsPass))
{
vec4 l9_62;
#if (sc_RenderingSpace==3)
{
l9_62=sc_ProjectionMatrixInverseArray[sc_GetStereoViewIndex()]*l9_17;
}
#else
{
vec4 l9_63;
#if (sc_RenderingSpace==2)
{
l9_63=sc_ViewMatrixArray[sc_GetStereoViewIndex()]*l9_17;
}
#else
{
vec4 l9_64;
#if (sc_RenderingSpace==1)
{
l9_64=sc_ModelViewMatrixArray[sc_GetStereoViewIndex()]*l9_17;
}
#else
{
l9_64=l9_17;
}
#endif
l9_63=l9_64;
}
#endif
l9_62=l9_63;
}
#endif
varViewSpaceDepth=-l9_62.z;
}
#endif
vec4 l9_65;
#if (sc_RenderingSpace==3)
{
l9_65=l9_17;
}
#else
{
vec4 l9_66;
#if (sc_RenderingSpace==4)
{
l9_66=(sc_ModelViewMatrixArray[sc_GetStereoViewIndex()]*l9_17)*vec4(1.0/sc_Camera.aspect,1.0,1.0,1.0);
}
#else
{
vec4 l9_67;
#if (sc_RenderingSpace==2)
{
l9_67=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*vec4(varPos,1.0);
}
#else
{
vec4 l9_68;
#if (sc_RenderingSpace==1)
{
l9_68=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*vec4(varPos,1.0);
}
#else
{
l9_68=vec4(0.0);
}
#endif
l9_67=l9_68;
}
#endif
l9_66=l9_67;
}
#endif
l9_65=l9_66;
}
#endif
varPackedTex=vec4(l9_28,l9_2);
#if (sc_ProjectiveShadowsReceiver)
{
vec4 l9_69;
#if (sc_RenderingSpace==1)
{
l9_69=sc_ModelMatrix*l9_17;
}
#else
{
l9_69=l9_17;
}
#endif
vec4 l9_70=sc_ProjectorMatrix*l9_69;
varShadowTex=((l9_70.xy/vec2(l9_70.w))*0.5)+vec2(0.5);
}
#endif
vec4 l9_71;
#if (sc_DepthBufferMode==1)
{
vec4 l9_72;
if (sc_ProjectionMatrixArray[sc_GetStereoViewIndex()][2].w!=0.0)
{
vec4 l9_73=l9_65;
l9_73.z=((log2(max(sc_Camera.clipPlanes.x,1.0+l9_65.w))*(2.0/log2(sc_Camera.clipPlanes.y+1.0)))-1.0)*l9_65.w;
l9_72=l9_73;
}
else
{
l9_72=l9_65;
}
l9_71=l9_72;
}
#else
{
l9_71=l9_65;
}
#endif
#if (sc_StereoRenderingMode>0)
{
varStereoViewID=float(sc_StereoViewID);
}
#endif
#if (sc_StereoRenderingMode==1)
{
float l9_74=dot(l9_71,sc_StereoClipPlanes[sc_StereoViewID]);
#if (sc_StereoRendering_IsClipDistanceEnabled==1)
{
sc_SetClipDistancePlatform(l9_74);
}
#else
{
varClipDistance=l9_74;
}
#endif
}
#endif
gl_Position=l9_71;
Interpolator_gInstanceRatio=l9_36;
}
#elif defined FRAGMENT_SHADER // #if defined VERTEX_SHADER
#if 0
NGS_BACKEND_SHADER_FLAGS_BEGIN__
NGS_BACKEND_SHADER_FLAGS_END__
#endif
#define SC_DISABLE_FRUSTUM_CULLING
#define SC_ENABLE_INSTANCED_RENDERING
#define sc_StereoRendering_Disabled 0
#define sc_StereoRendering_InstancedClipped 1
#define sc_StereoRendering_Multiview 2
#ifdef GL_ES
    #define SC_GLES_VERSION_20 2000
    #define SC_GLES_VERSION_30 3000
    #define SC_GLES_VERSION_31 3100
    #define SC_GLES_VERSION_32 3200
#endif
#ifdef VERTEX_SHADER
    #define scOutPos(clipPosition) gl_Position=clipPosition
    #define MAIN main
#endif
#ifdef SC_ENABLE_INSTANCED_RENDERING
    #ifndef sc_EnableInstancing
        #define sc_EnableInstancing 1
    #endif
#endif
#define mod(x,y) (x-y*floor((x+1e-6)/y))
#if defined(GL_ES)&&(__VERSION__<300)&&!defined(GL_OES_standard_derivatives)
#define dFdx(A) (A)
#define dFdy(A) (A)
#define fwidth(A) (A)
#endif
#if __VERSION__<300
#define isinf(x) (x!=0.0&&x*2.0==x ? true : false)
#define isnan(x) (x>0.0||x<0.0||x==0.0 ? false : true)
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef sc_EnableStereoClipDistance
        #if defined(GL_APPLE_clip_distance)
            #extension GL_APPLE_clip_distance : require
        #elif defined(GL_EXT_clip_cull_distance)
            #extension GL_EXT_clip_cull_distance : require
        #else
            #error Clip distance is requested but not supported by this device.
        #endif
    #endif
#else
    #ifdef sc_EnableStereoClipDistance
        #error Clip distance is requested but not supported by this device.
    #endif
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef VERTEX_SHADER
        #define attribute in
        #define varying out
    #endif
    #ifdef FRAGMENT_SHADER
        #define varying in
    #endif
    #define gl_FragColor sc_FragData0
    #define texture2D texture
    #define texture2DLod textureLod
    #define texture2DLodEXT textureLod
    #define textureCubeLodEXT textureLod
    #define sc_CanUseTextureLod 1
#else
    #ifdef FRAGMENT_SHADER
        #if defined(GL_EXT_shader_texture_lod)
            #extension GL_EXT_shader_texture_lod : require
            #define sc_CanUseTextureLod 1
            #define texture2DLod texture2DLodEXT
        #endif
    #endif
#endif
#if defined(sc_EnableMultiviewStereoRendering)
    #define sc_StereoRenderingMode sc_StereoRendering_Multiview
    #define sc_NumStereoViews 2
    #extension GL_OVR_multiview2 : require
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #define sc_LocalInstanceID sc_GlobalInstanceID
        #define sc_StereoViewID int(gl_ViewID_OVR)
    #endif
#elif defined(sc_EnableInstancedClippedStereoRendering)
    #ifndef sc_EnableInstancing
        #error Instanced-clipped stereo rendering requires enabled instancing.
    #endif
    #ifndef sc_EnableStereoClipDistance
        #define sc_StereoRendering_IsClipDistanceEnabled 0
    #else
        #define sc_StereoRendering_IsClipDistanceEnabled 1
    #endif
    #define sc_StereoRenderingMode sc_StereoRendering_InstancedClipped
    #define sc_NumStereoClipPlanes 1
    #define sc_NumStereoViews 2
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #ifdef sc_EnableFeatureLevelES3
            #define sc_LocalInstanceID (sc_GlobalInstanceID/2)
            #define sc_StereoViewID (sc_GlobalInstanceID%2)
        #else
            #define sc_LocalInstanceID int(sc_GlobalInstanceID/2.0)
            #define sc_StereoViewID int(mod(sc_GlobalInstanceID,2.0))
        #endif
    #endif
#else
    #define sc_StereoRenderingMode sc_StereoRendering_Disabled
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableInstancing
        #ifdef GL_ES
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)
                #define gl_InstanceID (0)
            #endif
        #else
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)&&!defined(GL_ARB_draw_instanced)&&!defined(GL_EXT_gpu_shader4)
                #define gl_InstanceID (0)
            #endif
        #endif
        #ifdef GL_ARB_draw_instanced
            #extension GL_ARB_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDARB
        #endif
        #ifdef GL_EXT_draw_instanced
            #extension GL_EXT_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDEXT
        #endif
        #ifndef sc_InstanceID
            #define sc_InstanceID gl_InstanceID
        #endif
        #ifndef sc_GlobalInstanceID
            #ifdef sc_EnableInstancingFallback
                #define sc_GlobalInstanceID (sc_FallbackInstanceID)
                #define sc_LocalInstanceID (sc_FallbackInstanceID)
            #else
                #define sc_GlobalInstanceID gl_InstanceID
                #define sc_LocalInstanceID gl_InstanceID
            #endif
        #endif
    #endif
#endif
#ifdef VERTEX_SHADER
    #if (__VERSION__<300)&&!defined(GL_EXT_gpu_shader4)
        #define gl_VertexID (0)
    #endif
#endif
#ifndef GL_ES
        #extension GL_EXT_gpu_shader4 : enable
    #extension GL_ARB_shader_texture_lod : enable
    #ifndef texture2DLodEXT
        #define texture2DLodEXT texture2DLod
    #endif
    #ifndef sc_CanUseTextureLod
    #define sc_CanUseTextureLod 1
    #endif
    #define precision
    #define lowp
    #define mediump
    #define highp
    #define sc_FragmentPrecision
#endif
#ifdef sc_EnableFeatureLevelES3
    #define sc_CanUseSampler2DArray 1
#endif
#if defined(sc_EnableFeatureLevelES2)&&defined(GL_ES)
    #ifdef FRAGMENT_SHADER
        #ifdef GL_OES_standard_derivatives
            #extension GL_OES_standard_derivatives : require
            #define sc_CanUseStandardDerivatives 1
        #endif
    #endif
    #ifdef GL_EXT_texture_array
        #extension GL_EXT_texture_array : require
        #define sc_CanUseSampler2DArray 1
    #else
        #define sc_CanUseSampler2DArray 0
    #endif
#endif
#ifdef GL_ES
    #ifdef sc_FramebufferFetch
        #if defined(GL_EXT_shader_framebuffer_fetch)
            #extension GL_EXT_shader_framebuffer_fetch : require
        #elif defined(GL_ARM_shader_framebuffer_fetch)
            #extension GL_ARM_shader_framebuffer_fetch : require
        #else
            #error Framebuffer fetch is requested but not supported by this device.
        #endif
    #endif
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        #define sc_FragmentPrecision highp
    #else
        #define sc_FragmentPrecision mediump
    #endif
    #ifdef FRAGMENT_SHADER
        precision highp int;
        precision highp float;
    #endif
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableMultiviewStereoRendering
        layout(num_views=sc_NumStereoViews) in;
    #endif
#endif
#if __VERSION__>100
    #define SC_INT_FALLBACK_FLOAT int
    #define SC_INTERPOLATION_FLAT flat
    #define SC_INTERPOLATION_CENTROID centroid
#else
    #define SC_INT_FALLBACK_FLOAT float
    #define SC_INTERPOLATION_FLAT
    #define SC_INTERPOLATION_CENTROID
#endif
#ifndef sc_NumStereoViews
    #define sc_NumStereoViews 1
#endif
#ifndef sc_CanUseSampler2DArray
    #define sc_CanUseSampler2DArray 0
#endif
    #if __VERSION__==100||defined(SCC_VALIDATION)
        #define sampler2DArray vec2
        #define sampler3D vec3
        #define samplerCube vec4
        vec4 texture3D(vec3 s,vec3 uv)                       { return vec4(0.0); }
        vec4 texture3D(vec3 s,vec3 uv,float bias)           { return vec4(0.0); }
        vec4 texture3DLod(vec3 s,vec3 uv,float bias)        { return vec4(0.0); }
        vec4 texture3DLodEXT(vec3 s,vec3 uv,float lod)      { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv)                  { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv,float bias)      { return vec4(0.0); }
        vec4 texture2DArrayLod(vec2 s,vec3 uv,float lod)    { return vec4(0.0); }
        vec4 texture2DArrayLodEXT(vec2 s,vec3 uv,float lod) { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv)                     { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv,float lod)          { return vec4(0.0); }
        vec4 textureCubeLod(vec4 s,vec3 uv,float lod)       { return vec4(0.0); }
        vec4 textureCubeLodEXT(vec4 s,vec3 uv,float lod)    { return vec4(0.0); }
        #if defined(VERTEX_SHADER)||!sc_CanUseTextureLod
            #define texture2DLod(s,uv,lod)      vec4(0.0)
            #define texture2DLodEXT(s,uv,lod)   vec4(0.0)
        #endif
    #elif __VERSION__>=300
        #define texture3D texture
        #define textureCube texture
        #define texture2DArray texture
        #define texture2DLod textureLod
        #define texture3DLod textureLod
        #define texture2DLodEXT textureLod
        #define texture3DLodEXT textureLod
        #define textureCubeLod textureLod
        #define textureCubeLodEXT textureLod
        #define texture2DArrayLod textureLod
        #define texture2DArrayLodEXT textureLod
    #endif
    #ifndef sc_TextureRenderingLayout_Regular
        #define sc_TextureRenderingLayout_Regular 0
        #define sc_TextureRenderingLayout_StereoInstancedClipped 1
        #define sc_TextureRenderingLayout_StereoMultiview 2
    #endif
    #define depthToGlobal   depthScreenToViewSpace
    #define depthToLocal    depthViewToScreenSpace
    #ifndef quantizeUV
        #define quantizeUV sc_QuantizeUV
        #define sc_platformUVFlip sc_PlatformFlipV
        #define sc_PlatformFlipUV sc_PlatformFlipV
    #endif
    #ifndef sc_texture2DLod
        #define sc_texture2DLod sc_InternalTextureLevel
        #define sc_textureLod sc_InternalTextureLevel
        #define sc_textureBias sc_InternalTextureBiasOrLevel
        #define sc_texture sc_InternalTexture
    #endif
#if sc_ExporterVersion<224
#define MAIN main
#endif
    #ifndef sc_FramebufferFetch
    #define sc_FramebufferFetch 0
    #elif sc_FramebufferFetch==1
    #undef sc_FramebufferFetch
    #define sc_FramebufferFetch 1
    #endif
    #if !defined(GL_ES)&&__VERSION__<420
        #ifdef FRAGMENT_SHADER
            #define sc_FragData0 gl_FragData[0]
            #define sc_FragData1 gl_FragData[1]
            #define sc_FragData2 gl_FragData[2]
            #define sc_FragData3 gl_FragData[3]
        #endif
        mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
        #define gl_LastFragData (getFragData())
        #if sc_FramebufferFetch
            #error Framebuffer fetch is requested but not supported by this device.
        #endif
    #elif defined(sc_EnableFeatureLevelES3)
        #if sc_FragDataCount>=1
            #define sc_DeclareFragData0(StorageQualifier) layout(location=0) StorageQualifier sc_FragmentPrecision vec4 sc_FragData0
        #endif
        #if sc_FragDataCount>=2
            #define sc_DeclareFragData1(StorageQualifier) layout(location=1) StorageQualifier sc_FragmentPrecision vec4 sc_FragData1
        #endif
        #if sc_FragDataCount>=3
            #define sc_DeclareFragData2(StorageQualifier) layout(location=2) StorageQualifier sc_FragmentPrecision vec4 sc_FragData2
        #endif
        #if sc_FragDataCount>=4
            #define sc_DeclareFragData3(StorageQualifier) layout(location=3) StorageQualifier sc_FragmentPrecision vec4 sc_FragData3
        #endif
        #ifndef sc_DeclareFragData0
            #define sc_DeclareFragData0(_) const vec4 sc_FragData0=vec4(0.0)
        #endif
        #ifndef sc_DeclareFragData1
            #define sc_DeclareFragData1(_) const vec4 sc_FragData1=vec4(0.0)
        #endif
        #ifndef sc_DeclareFragData2
            #define sc_DeclareFragData2(_) const vec4 sc_FragData2=vec4(0.0)
        #endif
        #ifndef sc_DeclareFragData3
            #define sc_DeclareFragData3(_) const vec4 sc_FragData3=vec4(0.0)
        #endif
        #if sc_FramebufferFetch
            #ifdef GL_EXT_shader_framebuffer_fetch
                sc_DeclareFragData0(inout);
                sc_DeclareFragData1(inout);
                sc_DeclareFragData2(inout);
                sc_DeclareFragData3(inout);
                mediump mat4 getFragData() { return mat4(sc_FragData0,sc_FragData1,sc_FragData2,sc_FragData3); }
                #define gl_LastFragData (getFragData())
            #elif defined(GL_ARM_shader_framebuffer_fetch)
                sc_DeclareFragData0(out);
                sc_DeclareFragData1(out);
                sc_DeclareFragData2(out);
                sc_DeclareFragData3(out);
                mediump mat4 getFragData() { return mat4(gl_LastFragColorARM,vec4(0.0),vec4(0.0),vec4(0.0)); }
                #define gl_LastFragData (getFragData())
            #endif
        #else
            #ifdef sc_EnableFeatureLevelES3
                sc_DeclareFragData0(out);
                sc_DeclareFragData1(out);
                sc_DeclareFragData2(out);
                sc_DeclareFragData3(out);
                mediump mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
                #define gl_LastFragData (getFragData())
            #endif
        #endif
    #elif defined(sc_EnableFeatureLevelES2)
        #define sc_FragData0 gl_FragColor
        mediump mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
    #else
        #define sc_FragData0 gl_FragColor
        mediump mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
    #endif
struct SurfaceProperties
{
vec3 albedo;
float opacity;
vec3 normal;
vec3 positionWS;
vec3 viewDirWS;
float metallic;
float roughness;
vec3 emissive;
vec3 ao;
vec3 specularAo;
vec3 bakedShadows;
vec3 specColor;
};
struct LightingComponents
{
vec3 directDiffuse;
vec3 directSpecular;
vec3 indirectDiffuse;
vec3 indirectSpecular;
vec3 emitted;
vec3 transmitted;
};
struct LightProperties
{
vec3 direction;
vec3 color;
float attenuation;
};
struct sc_SphericalGaussianLight_t
{
vec3 color;
float sharpness;
vec3 axis;
};
struct ssGlobals
{
float gTimeElapsed;
float gTimeDelta;
float gTimeElapsedShifted;
vec3 BumpedNormal;
vec3 ViewDirWS;
vec3 PositionWS;
vec3 VertexNormal_WorldSpace;
vec3 VertexTangent_WorldSpace;
vec3 VertexBinormal_WorldSpace;
vec3 SurfacePosition_WorldSpace;
vec2 Surface_UVCoord0;
vec2 Surface_UVCoord1;
float gInstanceRatio;
};
#ifndef sc_StereoRenderingMode
#define sc_StereoRenderingMode 0
#endif
#ifndef sc_EnvmapDiffuseHasSwappedViews
#define sc_EnvmapDiffuseHasSwappedViews 0
#elif sc_EnvmapDiffuseHasSwappedViews==1
#undef sc_EnvmapDiffuseHasSwappedViews
#define sc_EnvmapDiffuseHasSwappedViews 1
#endif
#ifndef sc_EnvmapDiffuseLayout
#define sc_EnvmapDiffuseLayout 0
#endif
#ifndef sc_EnvmapSpecularHasSwappedViews
#define sc_EnvmapSpecularHasSwappedViews 0
#elif sc_EnvmapSpecularHasSwappedViews==1
#undef sc_EnvmapSpecularHasSwappedViews
#define sc_EnvmapSpecularHasSwappedViews 1
#endif
#ifndef sc_EnvmapSpecularLayout
#define sc_EnvmapSpecularLayout 0
#endif
#ifndef sc_ScreenTextureHasSwappedViews
#define sc_ScreenTextureHasSwappedViews 0
#elif sc_ScreenTextureHasSwappedViews==1
#undef sc_ScreenTextureHasSwappedViews
#define sc_ScreenTextureHasSwappedViews 1
#endif
#ifndef sc_ScreenTextureLayout
#define sc_ScreenTextureLayout 0
#endif
#ifndef sc_NumStereoViews
#define sc_NumStereoViews 1
#endif
#ifndef sc_BlendMode_Normal
#define sc_BlendMode_Normal 0
#elif sc_BlendMode_Normal==1
#undef sc_BlendMode_Normal
#define sc_BlendMode_Normal 1
#endif
#ifndef sc_BlendMode_AlphaToCoverage
#define sc_BlendMode_AlphaToCoverage 0
#elif sc_BlendMode_AlphaToCoverage==1
#undef sc_BlendMode_AlphaToCoverage
#define sc_BlendMode_AlphaToCoverage 1
#endif
#ifndef sc_BlendMode_PremultipliedAlphaHardware
#define sc_BlendMode_PremultipliedAlphaHardware 0
#elif sc_BlendMode_PremultipliedAlphaHardware==1
#undef sc_BlendMode_PremultipliedAlphaHardware
#define sc_BlendMode_PremultipliedAlphaHardware 1
#endif
#ifndef sc_BlendMode_PremultipliedAlphaAuto
#define sc_BlendMode_PremultipliedAlphaAuto 0
#elif sc_BlendMode_PremultipliedAlphaAuto==1
#undef sc_BlendMode_PremultipliedAlphaAuto
#define sc_BlendMode_PremultipliedAlphaAuto 1
#endif
#ifndef sc_BlendMode_PremultipliedAlpha
#define sc_BlendMode_PremultipliedAlpha 0
#elif sc_BlendMode_PremultipliedAlpha==1
#undef sc_BlendMode_PremultipliedAlpha
#define sc_BlendMode_PremultipliedAlpha 1
#endif
#ifndef sc_BlendMode_AddWithAlphaFactor
#define sc_BlendMode_AddWithAlphaFactor 0
#elif sc_BlendMode_AddWithAlphaFactor==1
#undef sc_BlendMode_AddWithAlphaFactor
#define sc_BlendMode_AddWithAlphaFactor 1
#endif
#ifndef sc_BlendMode_AlphaTest
#define sc_BlendMode_AlphaTest 0
#elif sc_BlendMode_AlphaTest==1
#undef sc_BlendMode_AlphaTest
#define sc_BlendMode_AlphaTest 1
#endif
#ifndef sc_BlendMode_Multiply
#define sc_BlendMode_Multiply 0
#elif sc_BlendMode_Multiply==1
#undef sc_BlendMode_Multiply
#define sc_BlendMode_Multiply 1
#endif
#ifndef sc_BlendMode_MultiplyOriginal
#define sc_BlendMode_MultiplyOriginal 0
#elif sc_BlendMode_MultiplyOriginal==1
#undef sc_BlendMode_MultiplyOriginal
#define sc_BlendMode_MultiplyOriginal 1
#endif
#ifndef sc_BlendMode_ColoredGlass
#define sc_BlendMode_ColoredGlass 0
#elif sc_BlendMode_ColoredGlass==1
#undef sc_BlendMode_ColoredGlass
#define sc_BlendMode_ColoredGlass 1
#endif
#ifndef sc_BlendMode_Add
#define sc_BlendMode_Add 0
#elif sc_BlendMode_Add==1
#undef sc_BlendMode_Add
#define sc_BlendMode_Add 1
#endif
#ifndef sc_BlendMode_Screen
#define sc_BlendMode_Screen 0
#elif sc_BlendMode_Screen==1
#undef sc_BlendMode_Screen
#define sc_BlendMode_Screen 1
#endif
#ifndef sc_BlendMode_Min
#define sc_BlendMode_Min 0
#elif sc_BlendMode_Min==1
#undef sc_BlendMode_Min
#define sc_BlendMode_Min 1
#endif
#ifndef sc_BlendMode_Max
#define sc_BlendMode_Max 0
#elif sc_BlendMode_Max==1
#undef sc_BlendMode_Max
#define sc_BlendMode_Max 1
#endif
#ifndef sc_ProjectiveShadowsReceiver
#define sc_ProjectiveShadowsReceiver 0
#elif sc_ProjectiveShadowsReceiver==1
#undef sc_ProjectiveShadowsReceiver
#define sc_ProjectiveShadowsReceiver 1
#endif
#ifndef sc_StereoRendering_IsClipDistanceEnabled
#define sc_StereoRendering_IsClipDistanceEnabled 0
#endif
#ifndef sc_ShaderComplexityAnalyzer
#define sc_ShaderComplexityAnalyzer 0
#elif sc_ShaderComplexityAnalyzer==1
#undef sc_ShaderComplexityAnalyzer
#define sc_ShaderComplexityAnalyzer 1
#endif
#ifndef sc_UseFramebufferFetchMarker
#define sc_UseFramebufferFetchMarker 0
#elif sc_UseFramebufferFetchMarker==1
#undef sc_UseFramebufferFetchMarker
#define sc_UseFramebufferFetchMarker 1
#endif
#ifndef sc_FramebufferFetch
#define sc_FramebufferFetch 0
#elif sc_FramebufferFetch==1
#undef sc_FramebufferFetch
#define sc_FramebufferFetch 1
#endif
#ifndef sc_IsEditor
#define sc_IsEditor 0
#elif sc_IsEditor==1
#undef sc_IsEditor
#define sc_IsEditor 1
#endif
#ifndef sc_GetFramebufferColorInvalidUsageMarker
#define sc_GetFramebufferColorInvalidUsageMarker 0
#elif sc_GetFramebufferColorInvalidUsageMarker==1
#undef sc_GetFramebufferColorInvalidUsageMarker
#define sc_GetFramebufferColorInvalidUsageMarker 1
#endif
#ifndef sc_BlendMode_Software
#define sc_BlendMode_Software 0
#elif sc_BlendMode_Software==1
#undef sc_BlendMode_Software
#define sc_BlendMode_Software 1
#endif
#ifndef sc_SSAOEnabled
#define sc_SSAOEnabled 0
#elif sc_SSAOEnabled==1
#undef sc_SSAOEnabled
#define sc_SSAOEnabled 1
#endif
#ifndef sc_MotionVectorsPass
#define sc_MotionVectorsPass 0
#elif sc_MotionVectorsPass==1
#undef sc_MotionVectorsPass
#define sc_MotionVectorsPass 1
#endif
#ifndef SC_DEVICE_CLASS
#define SC_DEVICE_CLASS -1
#endif
#ifndef SC_GL_FRAGMENT_PRECISION_HIGH
#define SC_GL_FRAGMENT_PRECISION_HIGH 0
#elif SC_GL_FRAGMENT_PRECISION_HIGH==1
#undef SC_GL_FRAGMENT_PRECISION_HIGH
#define SC_GL_FRAGMENT_PRECISION_HIGH 1
#endif
#ifndef intensityTextureHasSwappedViews
#define intensityTextureHasSwappedViews 0
#elif intensityTextureHasSwappedViews==1
#undef intensityTextureHasSwappedViews
#define intensityTextureHasSwappedViews 1
#endif
#ifndef intensityTextureLayout
#define intensityTextureLayout 0
#endif
#ifndef BLEND_MODE_REALISTIC
#define BLEND_MODE_REALISTIC 0
#elif BLEND_MODE_REALISTIC==1
#undef BLEND_MODE_REALISTIC
#define BLEND_MODE_REALISTIC 1
#endif
#ifndef BLEND_MODE_FORGRAY
#define BLEND_MODE_FORGRAY 0
#elif BLEND_MODE_FORGRAY==1
#undef BLEND_MODE_FORGRAY
#define BLEND_MODE_FORGRAY 1
#endif
#ifndef BLEND_MODE_NOTBRIGHT
#define BLEND_MODE_NOTBRIGHT 0
#elif BLEND_MODE_NOTBRIGHT==1
#undef BLEND_MODE_NOTBRIGHT
#define BLEND_MODE_NOTBRIGHT 1
#endif
#ifndef BLEND_MODE_DIVISION
#define BLEND_MODE_DIVISION 0
#elif BLEND_MODE_DIVISION==1
#undef BLEND_MODE_DIVISION
#define BLEND_MODE_DIVISION 1
#endif
#ifndef BLEND_MODE_BRIGHT
#define BLEND_MODE_BRIGHT 0
#elif BLEND_MODE_BRIGHT==1
#undef BLEND_MODE_BRIGHT
#define BLEND_MODE_BRIGHT 1
#endif
#ifndef BLEND_MODE_INTENSE
#define BLEND_MODE_INTENSE 0
#elif BLEND_MODE_INTENSE==1
#undef BLEND_MODE_INTENSE
#define BLEND_MODE_INTENSE 1
#endif
#ifndef SC_USE_UV_TRANSFORM_intensityTexture
#define SC_USE_UV_TRANSFORM_intensityTexture 0
#elif SC_USE_UV_TRANSFORM_intensityTexture==1
#undef SC_USE_UV_TRANSFORM_intensityTexture
#define SC_USE_UV_TRANSFORM_intensityTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_intensityTexture
#define SC_SOFTWARE_WRAP_MODE_U_intensityTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_intensityTexture
#define SC_SOFTWARE_WRAP_MODE_V_intensityTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_intensityTexture
#define SC_USE_UV_MIN_MAX_intensityTexture 0
#elif SC_USE_UV_MIN_MAX_intensityTexture==1
#undef SC_USE_UV_MIN_MAX_intensityTexture
#define SC_USE_UV_MIN_MAX_intensityTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_intensityTexture
#define SC_USE_CLAMP_TO_BORDER_intensityTexture 0
#elif SC_USE_CLAMP_TO_BORDER_intensityTexture==1
#undef SC_USE_CLAMP_TO_BORDER_intensityTexture
#define SC_USE_CLAMP_TO_BORDER_intensityTexture 1
#endif
#ifndef BLEND_MODE_LIGHTEN
#define BLEND_MODE_LIGHTEN 0
#elif BLEND_MODE_LIGHTEN==1
#undef BLEND_MODE_LIGHTEN
#define BLEND_MODE_LIGHTEN 1
#endif
#ifndef BLEND_MODE_DARKEN
#define BLEND_MODE_DARKEN 0
#elif BLEND_MODE_DARKEN==1
#undef BLEND_MODE_DARKEN
#define BLEND_MODE_DARKEN 1
#endif
#ifndef BLEND_MODE_DIVIDE
#define BLEND_MODE_DIVIDE 0
#elif BLEND_MODE_DIVIDE==1
#undef BLEND_MODE_DIVIDE
#define BLEND_MODE_DIVIDE 1
#endif
#ifndef BLEND_MODE_AVERAGE
#define BLEND_MODE_AVERAGE 0
#elif BLEND_MODE_AVERAGE==1
#undef BLEND_MODE_AVERAGE
#define BLEND_MODE_AVERAGE 1
#endif
#ifndef BLEND_MODE_SUBTRACT
#define BLEND_MODE_SUBTRACT 0
#elif BLEND_MODE_SUBTRACT==1
#undef BLEND_MODE_SUBTRACT
#define BLEND_MODE_SUBTRACT 1
#endif
#ifndef BLEND_MODE_DIFFERENCE
#define BLEND_MODE_DIFFERENCE 0
#elif BLEND_MODE_DIFFERENCE==1
#undef BLEND_MODE_DIFFERENCE
#define BLEND_MODE_DIFFERENCE 1
#endif
#ifndef BLEND_MODE_NEGATION
#define BLEND_MODE_NEGATION 0
#elif BLEND_MODE_NEGATION==1
#undef BLEND_MODE_NEGATION
#define BLEND_MODE_NEGATION 1
#endif
#ifndef BLEND_MODE_EXCLUSION
#define BLEND_MODE_EXCLUSION 0
#elif BLEND_MODE_EXCLUSION==1
#undef BLEND_MODE_EXCLUSION
#define BLEND_MODE_EXCLUSION 1
#endif
#ifndef BLEND_MODE_OVERLAY
#define BLEND_MODE_OVERLAY 0
#elif BLEND_MODE_OVERLAY==1
#undef BLEND_MODE_OVERLAY
#define BLEND_MODE_OVERLAY 1
#endif
#ifndef BLEND_MODE_SOFT_LIGHT
#define BLEND_MODE_SOFT_LIGHT 0
#elif BLEND_MODE_SOFT_LIGHT==1
#undef BLEND_MODE_SOFT_LIGHT
#define BLEND_MODE_SOFT_LIGHT 1
#endif
#ifndef BLEND_MODE_HARD_LIGHT
#define BLEND_MODE_HARD_LIGHT 0
#elif BLEND_MODE_HARD_LIGHT==1
#undef BLEND_MODE_HARD_LIGHT
#define BLEND_MODE_HARD_LIGHT 1
#endif
#ifndef BLEND_MODE_COLOR_DODGE
#define BLEND_MODE_COLOR_DODGE 0
#elif BLEND_MODE_COLOR_DODGE==1
#undef BLEND_MODE_COLOR_DODGE
#define BLEND_MODE_COLOR_DODGE 1
#endif
#ifndef BLEND_MODE_COLOR_BURN
#define BLEND_MODE_COLOR_BURN 0
#elif BLEND_MODE_COLOR_BURN==1
#undef BLEND_MODE_COLOR_BURN
#define BLEND_MODE_COLOR_BURN 1
#endif
#ifndef BLEND_MODE_LINEAR_LIGHT
#define BLEND_MODE_LINEAR_LIGHT 0
#elif BLEND_MODE_LINEAR_LIGHT==1
#undef BLEND_MODE_LINEAR_LIGHT
#define BLEND_MODE_LINEAR_LIGHT 1
#endif
#ifndef BLEND_MODE_VIVID_LIGHT
#define BLEND_MODE_VIVID_LIGHT 0
#elif BLEND_MODE_VIVID_LIGHT==1
#undef BLEND_MODE_VIVID_LIGHT
#define BLEND_MODE_VIVID_LIGHT 1
#endif
#ifndef BLEND_MODE_PIN_LIGHT
#define BLEND_MODE_PIN_LIGHT 0
#elif BLEND_MODE_PIN_LIGHT==1
#undef BLEND_MODE_PIN_LIGHT
#define BLEND_MODE_PIN_LIGHT 1
#endif
#ifndef BLEND_MODE_HARD_MIX
#define BLEND_MODE_HARD_MIX 0
#elif BLEND_MODE_HARD_MIX==1
#undef BLEND_MODE_HARD_MIX
#define BLEND_MODE_HARD_MIX 1
#endif
#ifndef BLEND_MODE_HARD_REFLECT
#define BLEND_MODE_HARD_REFLECT 0
#elif BLEND_MODE_HARD_REFLECT==1
#undef BLEND_MODE_HARD_REFLECT
#define BLEND_MODE_HARD_REFLECT 1
#endif
#ifndef BLEND_MODE_HARD_GLOW
#define BLEND_MODE_HARD_GLOW 0
#elif BLEND_MODE_HARD_GLOW==1
#undef BLEND_MODE_HARD_GLOW
#define BLEND_MODE_HARD_GLOW 1
#endif
#ifndef BLEND_MODE_HARD_PHOENIX
#define BLEND_MODE_HARD_PHOENIX 0
#elif BLEND_MODE_HARD_PHOENIX==1
#undef BLEND_MODE_HARD_PHOENIX
#define BLEND_MODE_HARD_PHOENIX 1
#endif
#ifndef BLEND_MODE_HUE
#define BLEND_MODE_HUE 0
#elif BLEND_MODE_HUE==1
#undef BLEND_MODE_HUE
#define BLEND_MODE_HUE 1
#endif
#ifndef BLEND_MODE_SATURATION
#define BLEND_MODE_SATURATION 0
#elif BLEND_MODE_SATURATION==1
#undef BLEND_MODE_SATURATION
#define BLEND_MODE_SATURATION 1
#endif
#ifndef BLEND_MODE_COLOR
#define BLEND_MODE_COLOR 0
#elif BLEND_MODE_COLOR==1
#undef BLEND_MODE_COLOR
#define BLEND_MODE_COLOR 1
#endif
#ifndef BLEND_MODE_LUMINOSITY
#define BLEND_MODE_LUMINOSITY 0
#elif BLEND_MODE_LUMINOSITY==1
#undef BLEND_MODE_LUMINOSITY
#define BLEND_MODE_LUMINOSITY 1
#endif
#ifndef sc_SkinBonesCount
#define sc_SkinBonesCount 0
#endif
#ifndef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#elif UseViewSpaceDepthVariant==1
#undef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#endif
#ifndef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 0
#elif sc_OITDepthGatherPass==1
#undef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 1
#endif
#ifndef sc_OITCompositingPass
#define sc_OITCompositingPass 0
#elif sc_OITCompositingPass==1
#undef sc_OITCompositingPass
#define sc_OITCompositingPass 1
#endif
#ifndef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 0
#elif sc_OITDepthBoundsPass==1
#undef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 1
#endif
#ifndef sc_OITMaxLayers4Plus1
#define sc_OITMaxLayers4Plus1 0
#elif sc_OITMaxLayers4Plus1==1
#undef sc_OITMaxLayers4Plus1
#define sc_OITMaxLayers4Plus1 1
#endif
#ifndef sc_OITMaxLayersVisualizeLayerCount
#define sc_OITMaxLayersVisualizeLayerCount 0
#elif sc_OITMaxLayersVisualizeLayerCount==1
#undef sc_OITMaxLayersVisualizeLayerCount
#define sc_OITMaxLayersVisualizeLayerCount 1
#endif
#ifndef sc_OITMaxLayers8
#define sc_OITMaxLayers8 0
#elif sc_OITMaxLayers8==1
#undef sc_OITMaxLayers8
#define sc_OITMaxLayers8 1
#endif
#ifndef sc_OITFrontLayerPass
#define sc_OITFrontLayerPass 0
#elif sc_OITFrontLayerPass==1
#undef sc_OITFrontLayerPass
#define sc_OITFrontLayerPass 1
#endif
#ifndef sc_OITDepthPrepass
#define sc_OITDepthPrepass 0
#elif sc_OITDepthPrepass==1
#undef sc_OITDepthPrepass
#define sc_OITDepthPrepass 1
#endif
#ifndef ENABLE_STIPPLE_PATTERN_TEST
#define ENABLE_STIPPLE_PATTERN_TEST 0
#elif ENABLE_STIPPLE_PATTERN_TEST==1
#undef ENABLE_STIPPLE_PATTERN_TEST
#define ENABLE_STIPPLE_PATTERN_TEST 1
#endif
#ifndef sc_ProjectiveShadowsCaster
#define sc_ProjectiveShadowsCaster 0
#elif sc_ProjectiveShadowsCaster==1
#undef sc_ProjectiveShadowsCaster
#define sc_ProjectiveShadowsCaster 1
#endif
#ifndef sc_RenderAlphaToColor
#define sc_RenderAlphaToColor 0
#elif sc_RenderAlphaToColor==1
#undef sc_RenderAlphaToColor
#define sc_RenderAlphaToColor 1
#endif
#ifndef sc_BlendMode_Custom
#define sc_BlendMode_Custom 0
#elif sc_BlendMode_Custom==1
#undef sc_BlendMode_Custom
#define sc_BlendMode_Custom 1
#endif
#ifndef customLengthTextureHasSwappedViews
#define customLengthTextureHasSwappedViews 0
#elif customLengthTextureHasSwappedViews==1
#undef customLengthTextureHasSwappedViews
#define customLengthTextureHasSwappedViews 1
#endif
#ifndef customLengthTextureLayout
#define customLengthTextureLayout 0
#endif
#ifndef baseTextureHasSwappedViews
#define baseTextureHasSwappedViews 0
#elif baseTextureHasSwappedViews==1
#undef baseTextureHasSwappedViews
#define baseTextureHasSwappedViews 1
#endif
#ifndef baseTextureLayout
#define baseTextureLayout 0
#endif
#ifndef endsTextureHasSwappedViews
#define endsTextureHasSwappedViews 0
#elif endsTextureHasSwappedViews==1
#undef endsTextureHasSwappedViews
#define endsTextureHasSwappedViews 1
#endif
#ifndef endsTextureLayout
#define endsTextureLayout 0
#endif
#ifndef shapeTextureHasSwappedViews
#define shapeTextureHasSwappedViews 0
#elif shapeTextureHasSwappedViews==1
#undef shapeTextureHasSwappedViews
#define shapeTextureHasSwappedViews 1
#endif
#ifndef shapeTextureLayout
#define shapeTextureLayout 0
#endif
#ifndef sc_EnvLightMode
#define sc_EnvLightMode 0
#endif
#ifndef sc_AmbientLightMode_EnvironmentMap
#define sc_AmbientLightMode_EnvironmentMap 0
#endif
#ifndef sc_AmbientLightMode_FromCamera
#define sc_AmbientLightMode_FromCamera 0
#endif
#ifndef sc_LightEstimation
#define sc_LightEstimation 0
#elif sc_LightEstimation==1
#undef sc_LightEstimation
#define sc_LightEstimation 1
#endif
struct sc_LightEstimationData_t
{
sc_SphericalGaussianLight_t sg[12];
vec3 ambientLight;
};
#ifndef sc_LightEstimationSGCount
#define sc_LightEstimationSGCount 0
#endif
#ifndef sc_MaxTextureImageUnits
#define sc_MaxTextureImageUnits 0
#endif
#ifndef sc_HasDiffuseEnvmap
#define sc_HasDiffuseEnvmap 0
#elif sc_HasDiffuseEnvmap==1
#undef sc_HasDiffuseEnvmap
#define sc_HasDiffuseEnvmap 1
#endif
#ifndef sc_AmbientLightMode_SphericalHarmonics
#define sc_AmbientLightMode_SphericalHarmonics 0
#endif
#ifndef sc_AmbientLightsCount
#define sc_AmbientLightsCount 0
#endif
#ifndef sc_AmbientLightMode0
#define sc_AmbientLightMode0 0
#endif
#ifndef sc_AmbientLightMode_Constant
#define sc_AmbientLightMode_Constant 0
#endif
struct sc_AmbientLight_t
{
vec3 color;
float intensity;
};
#ifndef sc_AmbientLightMode1
#define sc_AmbientLightMode1 0
#endif
#ifndef sc_AmbientLightMode2
#define sc_AmbientLightMode2 0
#endif
#ifndef sc_DirectionalLightsCount
#define sc_DirectionalLightsCount 0
#endif
struct sc_DirectionalLight_t
{
vec3 direction;
vec4 color;
};
#ifndef sc_PointLightsCount
#define sc_PointLightsCount 0
#endif
struct sc_PointLight_t
{
bool falloffEnabled;
float falloffEndDistance;
float negRcpFalloffEndDistance4;
float angleScale;
float angleOffset;
vec3 direction;
vec3 position;
vec4 color;
};
#ifndef Tweak_N164
#define Tweak_N164 0
#elif Tweak_N164==1
#undef Tweak_N164
#define Tweak_N164 1
#endif
#ifndef NODE_67_DROPLIST_ITEM
#define NODE_67_DROPLIST_ITEM 0
#endif
#ifndef NODE_167_DROPLIST_ITEM
#define NODE_167_DROPLIST_ITEM 0
#endif
#ifndef SC_USE_UV_TRANSFORM_customLengthTexture
#define SC_USE_UV_TRANSFORM_customLengthTexture 0
#elif SC_USE_UV_TRANSFORM_customLengthTexture==1
#undef SC_USE_UV_TRANSFORM_customLengthTexture
#define SC_USE_UV_TRANSFORM_customLengthTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_customLengthTexture
#define SC_SOFTWARE_WRAP_MODE_U_customLengthTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_customLengthTexture
#define SC_SOFTWARE_WRAP_MODE_V_customLengthTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_customLengthTexture
#define SC_USE_UV_MIN_MAX_customLengthTexture 0
#elif SC_USE_UV_MIN_MAX_customLengthTexture==1
#undef SC_USE_UV_MIN_MAX_customLengthTexture
#define SC_USE_UV_MIN_MAX_customLengthTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_customLengthTexture
#define SC_USE_CLAMP_TO_BORDER_customLengthTexture 0
#elif SC_USE_CLAMP_TO_BORDER_customLengthTexture==1
#undef SC_USE_CLAMP_TO_BORDER_customLengthTexture
#define SC_USE_CLAMP_TO_BORDER_customLengthTexture 1
#endif
#ifndef Tweak_N160
#define Tweak_N160 0
#elif Tweak_N160==1
#undef Tweak_N160
#define Tweak_N160 1
#endif
#ifndef Tweak_N204
#define Tweak_N204 0
#elif Tweak_N204==1
#undef Tweak_N204
#define Tweak_N204 1
#endif
#ifndef SC_USE_UV_TRANSFORM_baseTexture
#define SC_USE_UV_TRANSFORM_baseTexture 0
#elif SC_USE_UV_TRANSFORM_baseTexture==1
#undef SC_USE_UV_TRANSFORM_baseTexture
#define SC_USE_UV_TRANSFORM_baseTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_baseTexture
#define SC_SOFTWARE_WRAP_MODE_U_baseTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_baseTexture
#define SC_SOFTWARE_WRAP_MODE_V_baseTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_baseTexture
#define SC_USE_UV_MIN_MAX_baseTexture 0
#elif SC_USE_UV_MIN_MAX_baseTexture==1
#undef SC_USE_UV_MIN_MAX_baseTexture
#define SC_USE_UV_MIN_MAX_baseTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_baseTexture
#define SC_USE_CLAMP_TO_BORDER_baseTexture 0
#elif SC_USE_CLAMP_TO_BORDER_baseTexture==1
#undef SC_USE_CLAMP_TO_BORDER_baseTexture
#define SC_USE_CLAMP_TO_BORDER_baseTexture 1
#endif
#ifndef Tweak_N50
#define Tweak_N50 0
#elif Tweak_N50==1
#undef Tweak_N50
#define Tweak_N50 1
#endif
#ifndef Tweak_N108
#define Tweak_N108 0
#elif Tweak_N108==1
#undef Tweak_N108
#define Tweak_N108 1
#endif
#ifndef SC_USE_UV_TRANSFORM_endsTexture
#define SC_USE_UV_TRANSFORM_endsTexture 0
#elif SC_USE_UV_TRANSFORM_endsTexture==1
#undef SC_USE_UV_TRANSFORM_endsTexture
#define SC_USE_UV_TRANSFORM_endsTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_endsTexture
#define SC_SOFTWARE_WRAP_MODE_U_endsTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_endsTexture
#define SC_SOFTWARE_WRAP_MODE_V_endsTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_endsTexture
#define SC_USE_UV_MIN_MAX_endsTexture 0
#elif SC_USE_UV_MIN_MAX_endsTexture==1
#undef SC_USE_UV_MIN_MAX_endsTexture
#define SC_USE_UV_MIN_MAX_endsTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_endsTexture
#define SC_USE_CLAMP_TO_BORDER_endsTexture 0
#elif SC_USE_CLAMP_TO_BORDER_endsTexture==1
#undef SC_USE_CLAMP_TO_BORDER_endsTexture
#define SC_USE_CLAMP_TO_BORDER_endsTexture 1
#endif
#ifndef NODE_257_DROPLIST_ITEM
#define NODE_257_DROPLIST_ITEM 0
#endif
#ifndef Tweak_N63
#define Tweak_N63 0
#elif Tweak_N63==1
#undef Tweak_N63
#define Tweak_N63 1
#endif
#ifndef SC_USE_UV_TRANSFORM_shapeTexture
#define SC_USE_UV_TRANSFORM_shapeTexture 0
#elif SC_USE_UV_TRANSFORM_shapeTexture==1
#undef SC_USE_UV_TRANSFORM_shapeTexture
#define SC_USE_UV_TRANSFORM_shapeTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_shapeTexture
#define SC_SOFTWARE_WRAP_MODE_U_shapeTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_shapeTexture
#define SC_SOFTWARE_WRAP_MODE_V_shapeTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_shapeTexture
#define SC_USE_UV_MIN_MAX_shapeTexture 0
#elif SC_USE_UV_MIN_MAX_shapeTexture==1
#undef SC_USE_UV_MIN_MAX_shapeTexture
#define SC_USE_UV_MIN_MAX_shapeTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_shapeTexture
#define SC_USE_CLAMP_TO_BORDER_shapeTexture 0
#elif SC_USE_CLAMP_TO_BORDER_shapeTexture==1
#undef SC_USE_CLAMP_TO_BORDER_shapeTexture
#define SC_USE_CLAMP_TO_BORDER_shapeTexture 1
#endif
#ifndef sc_DepthOnly
#define sc_DepthOnly 0
#elif sc_DepthOnly==1
#undef sc_DepthOnly
#define sc_DepthOnly 1
#endif
struct sc_Camera_t
{
vec3 position;
float aspect;
vec2 clipPlanes;
};
uniform vec4 sc_EnvmapDiffuseDims;
uniform vec4 sc_EnvmapSpecularDims;
uniform vec4 sc_ScreenTextureDims;
uniform vec4 sc_WindowToViewportTransform;
uniform mat4 sc_ProjectionMatrixArray[sc_NumStereoViews];
uniform float sc_ShadowDensity;
uniform vec4 sc_ShadowColor;
uniform float shaderComplexityValue;
uniform float _sc_framebufferFetchMarker;
uniform float _sc_GetFramebufferColorInvalidUsageMarker;
uniform mat4 sc_ViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_PrevFrameViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_PrevFrameModelMatrix;
uniform mat4 sc_ModelMatrixInverse;
uniform vec4 intensityTextureDims;
uniform float correctedIntensity;
uniform mat3 intensityTextureTransform;
uniform vec4 intensityTextureUvMinMax;
uniform vec4 intensityTextureBorderColor;
uniform float alphaTestThreshold;
uniform vec4 customLengthTextureDims;
uniform vec4 baseTextureDims;
uniform vec4 endsTextureDims;
uniform vec4 shapeTextureDims;
uniform sc_LightEstimationData_t sc_LightEstimationData;
uniform vec3 sc_EnvmapRotation;
uniform vec4 sc_EnvmapSpecularSize;
uniform vec4 sc_EnvmapDiffuseSize;
uniform float sc_EnvmapExposure;
uniform vec3 sc_Sh[9];
uniform float sc_ShIntensity;
uniform sc_AmbientLight_t sc_AmbientLights[(sc_AmbientLightsCount+1)];
uniform sc_DirectionalLight_t sc_DirectionalLights[(sc_DirectionalLightsCount+1)];
uniform sc_PointLight_t sc_PointLights[(sc_PointLightsCount+1)];
uniform float rimExponent;
uniform float rimIntensity;
uniform vec3 rimColor;
uniform float hairLength;
uniform vec2 Port_Default_N070;
uniform mat3 customLengthTextureTransform;
uniform vec4 customLengthTextureUvMinMax;
uniform vec4 customLengthTextureBorderColor;
uniform vec2 Port_Offset_N199;
uniform float Port_Input1_N166;
uniform float Port_Value_N253;
uniform vec2 Port_Import_N172;
uniform float Port_Input0_N173;
uniform vec2 Port_Center_N174;
uniform float Port_Input1_N175;
uniform float Port_Input1_N176;
uniform float Port_Input1_N179;
uniform float Port_Input0_N182;
uniform float Port_Import_N183;
uniform float Port_Input1_N185;
uniform float Port_Input2_N185;
uniform float Port_Input1_N188;
uniform float Port_Import_N170;
uniform float Port_RangeMinA_N196;
uniform float Port_RangeMaxB_N196;
uniform float Port_RangeMinB_N196;
uniform float Port_Input1_N198;
uniform float Port_Input2_N198;
uniform vec2 Port_Offset_N245;
uniform vec2 Port_Import_N215;
uniform float Port_Input0_N217;
uniform vec2 Port_Center_N218;
uniform float Port_Input1_N219;
uniform float Port_Input1_N220;
uniform float Port_Input1_N223;
uniform float Port_Input0_N226;
uniform float Port_Import_N227;
uniform float Port_Input1_N229;
uniform float Port_Input2_N229;
uniform float Port_Input1_N232;
uniform float Port_Import_N240;
uniform float Port_RangeMinA_N241;
uniform float Port_RangeMaxB_N241;
uniform float Port_RangeMinB_N241;
uniform float Port_Input1_N243;
uniform float Port_Input2_N243;
uniform float Port_Input1_N260;
uniform float Port_Input1_N249;
uniform float Port_Value_N252;
uniform vec2 Port_Offset_N278;
uniform vec2 Port_Import_N281;
uniform float Port_Input0_N282;
uniform vec2 Port_Center_N283;
uniform float Port_Input1_N284;
uniform float Port_Input1_N285;
uniform float Port_Input1_N288;
uniform float Port_Input0_N291;
uniform float Port_Import_N292;
uniform float Port_Input1_N294;
uniform float Port_Input2_N294;
uniform float Port_Input1_N297;
uniform float Port_Import_N305;
uniform float Port_RangeMinA_N306;
uniform float Port_RangeMaxB_N306;
uniform float Port_RangeMinB_N306;
uniform float Port_Input1_N308;
uniform float Port_Input2_N308;
uniform float Port_Input1_N264;
uniform float Port_Input1_N405;
uniform float Port_Value_N265;
uniform vec2 Port_Offset_N269;
uniform vec2 Port_Import_N272;
uniform float Port_Input0_N273;
uniform vec2 Port_Center_N274;
uniform float Port_Input1_N275;
uniform float Port_Input1_N276;
uniform float Port_Input1_N310;
uniform float Port_Input0_N314;
uniform float Port_Import_N315;
uniform float Port_Input1_N317;
uniform float Port_Input2_N317;
uniform float Port_Input1_N320;
uniform float Port_Import_N328;
uniform float Port_RangeMinA_N329;
uniform float Port_RangeMaxB_N329;
uniform float Port_RangeMinB_N329;
uniform float Port_Input1_N331;
uniform float Port_Input2_N331;
uniform vec2 Port_Import_N335;
uniform float Port_Input0_N336;
uniform vec2 Port_Center_N337;
uniform float Port_Input1_N338;
uniform float Port_Input1_N339;
uniform float Port_Input1_N342;
uniform float Port_Input0_N345;
uniform float Port_Import_N346;
uniform float Port_Input1_N348;
uniform float Port_Input2_N348;
uniform float Port_Input1_N351;
uniform float Port_Import_N359;
uniform float Port_RangeMinA_N360;
uniform float Port_RangeMaxB_N360;
uniform float Port_RangeMinB_N360;
uniform float Port_Input1_N362;
uniform float Port_Input2_N362;
uniform float Port_Input1_N366;
uniform float Port_Input1_N404;
uniform float Port_Value_N367;
uniform vec2 Port_Offset_N371;
uniform vec2 Port_Import_N374;
uniform float Port_Input0_N375;
uniform vec2 Port_Center_N376;
uniform float Port_Input1_N377;
uniform float Port_Input1_N378;
uniform float Port_Input1_N381;
uniform float Port_Input0_N384;
uniform float Port_Import_N385;
uniform float Port_Input1_N387;
uniform float Port_Input2_N387;
uniform float Port_Input1_N390;
uniform float Port_Import_N398;
uniform float Port_RangeMinA_N399;
uniform float Port_RangeMaxB_N399;
uniform float Port_RangeMinB_N399;
uniform float Port_Input1_N401;
uniform float Port_Input2_N401;
uniform float Port_Input1_N402;
uniform float customLengthBlend;
uniform float Port_Default_N211;
uniform float variationScale;
uniform float variationSharpness;
uniform float variationStrength;
uniform vec3 baseColorRGB;
uniform mat3 baseTextureTransform;
uniform vec4 baseTextureUvMinMax;
uniform vec4 baseTextureBorderColor;
uniform vec3 endsColor;
uniform float Tweak_N107;
uniform float Tweak_N110;
uniform float windScale;
uniform float Port_Input1_N079;
uniform float Port_Input1_N433;
uniform vec2 Port_Center_N434;
uniform float Port_RangeMinA_N118;
uniform float Port_RangeMaxA_N118;
uniform float Port_RangeMaxB_N118;
uniform float Port_RangeMinB_N118;
uniform vec2 Port_Value0_N121;
uniform vec2 Port_Default_N121;
uniform float Port_Input1_N147;
uniform float Port_Input1_N114;
uniform mat3 endsTextureTransform;
uniform vec4 endsTextureUvMinMax;
uniform vec4 endsTextureBorderColor;
uniform float colorFalloff;
uniform float rainbowRingsCount;
uniform float rainbowOffset;
uniform vec3 Port_Value0_N123;
uniform vec3 Port_Default_N123;
uniform vec3 Port_Value0_N126;
uniform vec3 Port_Default_N126;
uniform float Port_Default_N165;
uniform float Port_RangeMinA_N081;
uniform float Port_RangeMaxA_N081;
uniform float Port_RangeMaxB_N081;
uniform float Port_RangeMinB_N081;
uniform vec3 decolorizeColor;
uniform float decolorizeSeed;
uniform float uvScaleTex;
uniform float decolorizeAreaScale;
uniform float decolorizeIntensity;
uniform vec3 subsurface;
uniform float AO;
uniform vec2 Port_Default_N256;
uniform vec2 Port_Scale_N437;
uniform vec2 Port_Input1_N115;
uniform mat3 shapeTextureTransform;
uniform vec4 shapeTextureUvMinMax;
uniform vec4 shapeTextureBorderColor;
uniform float fluffy;
uniform float hairTransparency;
uniform float featheredSmallHairs;
uniform float cutoff;
uniform int overrideTimeEnabled;
uniform float overrideTimeElapsed;
uniform vec4 sc_Time;
uniform float overrideTimeDelta;
uniform sc_Camera_t sc_Camera;
uniform vec3 Port_Normal_N057;
uniform vec3 Port_Default_N139;
uniform float Port_Value_N151;
uniform float Port_RangeMinA_N056;
uniform float Port_RangeMaxA_N056;
uniform float Port_RangeMaxB_N056;
uniform vec3 Port_Input0_N201;
uniform float Port_Opacity_N049;
uniform vec3 Port_Normal_N049;
uniform float Port_Default_N064;
uniform float Port_Input0_N143;
uniform float Port_Value_N054;
uniform float Port_Input1_N138;
uniform float Port_Input2_N138;
uniform float Port_Input1_N206;
uniform float Port_Input2_N206;
uniform float Port_Input1_N048;
uniform int PreviewEnabled;
uniform vec4 sc_EnvmapDiffuseView;
uniform vec4 sc_EnvmapSpecularView;
uniform vec4 sc_UniformConstants;
uniform vec4 sc_GeometryInfo;
uniform mat4 sc_ModelViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixInverseArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ModelMatrix;
uniform mat3 sc_NormalMatrix;
uniform mat3 sc_NormalMatrixInverse;
uniform mat4 sc_PrevFrameModelMatrixInverse;
uniform vec3 sc_LocalAabbMin;
uniform vec3 sc_LocalAabbMax;
uniform vec3 sc_WorldAabbMin;
uniform vec3 sc_WorldAabbMax;
uniform mat4 sc_ProjectorMatrix;
uniform float sc_DisableFrustumCullingMarker;
uniform vec4 sc_BoneMatrices[((sc_SkinBonesCount*3)+1)];
uniform mat3 sc_SkinBonesNormalMatrices[(sc_SkinBonesCount+1)];
uniform vec4 weights0;
uniform vec4 weights1;
uniform vec4 weights2;
uniform vec4 sc_StereoClipPlanes[sc_NumStereoViews];
uniform int sc_FallbackInstanceID;
uniform vec2 sc_TAAJitterOffset;
uniform float strandWidth;
uniform float strandTaper;
uniform vec4 sc_StrandDataMapTextureSize;
uniform float clumpInstanceCount;
uniform float clumpRadius;
uniform float clumpTipScale;
uniform float hairstyleInstanceCount;
uniform float hairstyleNoise;
uniform vec4 sc_ScreenTextureSize;
uniform vec4 sc_ScreenTextureView;
uniform vec4 intensityTextureSize;
uniform vec4 intensityTextureView;
uniform float reflBlurWidth;
uniform float reflBlurMinRough;
uniform float reflBlurMaxRough;
uniform int PreviewNodeID;
uniform vec4 customLengthTextureSize;
uniform vec4 customLengthTextureView;
uniform vec3 bendDirection;
uniform vec4 baseTextureSize;
uniform vec4 baseTextureView;
uniform vec4 endsTextureSize;
uniform vec4 endsTextureView;
uniform vec4 shapeTextureSize;
uniform vec4 shapeTextureView;
uniform vec2 Port_Import_N171;
uniform vec2 Port_Import_N125;
uniform vec2 Port_Import_N280;
uniform vec2 Port_Import_N271;
uniform vec2 Port_Import_N334;
uniform vec2 Port_Import_N373;
uniform vec3 Port_VectorIn_N094;
uniform vec3 Port_VectorIn_N095;
uniform vec3 Port_VectorIn_N096;
uniform vec3 Port_VectorIn_N097;
uniform float Port_Input1_N040;
uniform vec2 Port_Import_N426;
uniform float Port_Import_N427;
uniform vec2 Port_Import_N429;
uniform sampler2D customLengthTexture;
uniform sampler2D baseTexture;
uniform sampler2D endsTexture;
uniform sampler2D sc_SSAOTexture;
uniform sampler2D sc_ShadowTexture;
uniform sampler2D sc_EnvmapSpecular;
uniform sampler2D sc_EnvmapDiffuse;
uniform sampler2D sc_ScreenTexture;
uniform sampler2D shapeTexture;
uniform sampler2D intensityTexture;
uniform sampler2D sc_OITFrontDepthTexture;
uniform sampler2D sc_OITDepthHigh0;
uniform sampler2D sc_OITDepthLow0;
uniform sampler2D sc_OITAlpha0;
uniform sampler2D sc_OITDepthHigh1;
uniform sampler2D sc_OITDepthLow1;
uniform sampler2D sc_OITAlpha1;
uniform sampler2D sc_OITFilteredDepthBoundsTexture;
varying float varStereoViewID;
varying vec2 varShadowTex;
varying float varClipDistance;
varying float varViewSpaceDepth;
varying vec4 PreviewVertexColor;
varying float PreviewVertexSaved;
varying vec3 varPos;
varying vec3 varNormal;
varying vec4 varTangent;
varying vec4 varPackedTex;
varying float Interpolator_gInstanceRatio;
varying vec4 varScreenPos;
varying vec2 varScreenTexturePos;
varying vec4 varColor;
void Node70_Switch(float Switch,vec2 Value0,vec2 Value1,vec2 Default,out vec2 Result,ssGlobals Globals)
{
#if (NODE_67_DROPLIST_ITEM==0)
{
Value0=Globals.Surface_UVCoord0;
Result=Value0;
}
#else
{
#if (NODE_67_DROPLIST_ITEM==1)
{
Value1=Globals.Surface_UVCoord1;
Result=Value1;
}
#else
{
Result=Default;
}
#endif
}
#endif
}
int sc_GetStereoViewIndex()
{
int l9_0;
#if (sc_StereoRenderingMode==0)
{
l9_0=0;
}
#else
{
l9_0=int(varStereoViewID);
}
#endif
return l9_0;
}
int customLengthTextureGetStereoViewIndex()
{
int l9_0;
#if (customLengthTextureHasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
void sc_SoftwareWrapEarly(inout float uv,int softwareWrapMode)
{
if (softwareWrapMode==1)
{
uv=fract(uv);
}
else
{
if (softwareWrapMode==2)
{
float l9_0=fract(uv);
uv=mix(l9_0,1.0-l9_0,clamp(step(0.25,fract((uv-l9_0)*0.5)),0.0,1.0));
}
}
}
void sc_ClampUV(inout float value,float minValue,float maxValue,bool useClampToBorder,inout float clampToBorderFactor)
{
float l9_0=clamp(value,minValue,maxValue);
float l9_1=step(abs(value-l9_0),9.9999997e-06);
clampToBorderFactor*=(l9_1+((1.0-float(useClampToBorder))*(1.0-l9_1)));
value=l9_0;
}
vec2 sc_TransformUV(vec2 uv,bool useUvTransform,mat3 uvTransform)
{
if (useUvTransform)
{
uv=vec2((uvTransform*vec3(uv,1.0)).xy);
}
return uv;
}
void sc_SoftwareWrapLate(inout float uv,int softwareWrapMode,bool useClampToBorder,inout float clampToBorderFactor)
{
if ((softwareWrapMode==0)||(softwareWrapMode==3))
{
sc_ClampUV(uv,0.0,1.0,useClampToBorder,clampToBorderFactor);
}
}
vec3 sc_SamplingCoordsViewToGlobal(vec2 uv,int renderingLayout,int viewIndex)
{
vec3 l9_0;
if (renderingLayout==0)
{
l9_0=vec3(uv,0.0);
}
else
{
vec3 l9_1;
if (renderingLayout==1)
{
l9_1=vec3(uv.x,(uv.y*0.5)+(0.5-(float(viewIndex)*0.5)),0.0);
}
else
{
l9_1=vec3(uv,float(viewIndex));
}
l9_0=l9_1;
}
return l9_0;
}
vec4 sc_SampleView(vec2 texSize,vec2 uv,int renderingLayout,int viewIndex,float bias,sampler2D texsmp)
{
return texture2D(texsmp,sc_SamplingCoordsViewToGlobal(uv,renderingLayout,viewIndex).xy,bias);
}
vec4 sc_SampleTextureBiasOrLevel(vec2 samplerDims,int renderingLayout,int viewIndex,vec2 uv,bool useUvTransform,mat3 uvTransform,ivec2 softwareWrapModes,bool useUvMinMax,vec4 uvMinMax,bool useClampToBorder,vec4 borderColor,float biasOrLevel,sampler2D texture_sampler_)
{
bool l9_0=useClampToBorder;
bool l9_1=useUvMinMax;
bool l9_2=l9_0&&(!l9_1);
sc_SoftwareWrapEarly(uv.x,softwareWrapModes.x);
sc_SoftwareWrapEarly(uv.y,softwareWrapModes.y);
float l9_3;
if (useUvMinMax)
{
bool l9_4=useClampToBorder;
bool l9_5;
if (l9_4)
{
l9_5=softwareWrapModes.x==3;
}
else
{
l9_5=l9_4;
}
float param_8=1.0;
sc_ClampUV(uv.x,uvMinMax.x,uvMinMax.z,l9_5,param_8);
float l9_6=param_8;
bool l9_7=useClampToBorder;
bool l9_8;
if (l9_7)
{
l9_8=softwareWrapModes.y==3;
}
else
{
l9_8=l9_7;
}
float param_13=l9_6;
sc_ClampUV(uv.y,uvMinMax.y,uvMinMax.w,l9_8,param_13);
l9_3=param_13;
}
else
{
l9_3=1.0;
}
uv=sc_TransformUV(uv,useUvTransform,uvTransform);
float param_20=l9_3;
sc_SoftwareWrapLate(uv.x,softwareWrapModes.x,l9_2,param_20);
sc_SoftwareWrapLate(uv.y,softwareWrapModes.y,l9_2,param_20);
float l9_9=param_20;
vec4 l9_10=sc_SampleView(samplerDims,uv,renderingLayout,viewIndex,biasOrLevel,texture_sampler_);
vec4 l9_11;
if (useClampToBorder)
{
l9_11=mix(borderColor,l9_10,vec4(l9_9));
}
else
{
l9_11=l9_10;
}
return l9_11;
}
void Node211_Switch(float Switch,float Value0,float Value1,float Value2,float Value3,float Value4,float Default,out float Result,ssGlobals Globals)
{
#if (NODE_167_DROPLIST_ITEM==0)
{
vec2 param_4;
Node70_Switch(0.0,vec2(0.0),vec2(0.0),Port_Default_N070,param_4,Globals);
Value0=sc_SampleTextureBiasOrLevel(customLengthTextureDims.xy,customLengthTextureLayout,customLengthTextureGetStereoViewIndex(),param_4,(int(SC_USE_UV_TRANSFORM_customLengthTexture)!=0),customLengthTextureTransform,ivec2(SC_SOFTWARE_WRAP_MODE_U_customLengthTexture,SC_SOFTWARE_WRAP_MODE_V_customLengthTexture),(int(SC_USE_UV_MIN_MAX_customLengthTexture)!=0),customLengthTextureUvMinMax,(int(SC_USE_CLAMP_TO_BORDER_customLengthTexture)!=0),customLengthTextureBorderColor,0.0,customLengthTexture).x;
Result=Value0;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==1)
{
vec2 l9_0=Globals.Surface_UVCoord0;
vec2 l9_1=l9_0+Port_Offset_N199;
float l9_2=l9_1.x;
vec2 l9_3=((((vec2(l9_2,l9_1.y+(abs(l9_2-Port_Input1_N166)*((Port_Value_N253+0.001)-0.001)))-Port_Center_N174)*(vec2(Port_Input0_N173)/(clamp(Port_Import_N172,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N174)*vec2(Port_Input1_N175))-vec2(Port_Input1_N176);
float l9_4=atan(l9_3.y*Port_Input1_N179,l9_3.x);
float l9_5=(Port_Input0_N182*3.1415927)/(clamp(floor(Port_Import_N183),Port_Input1_N185,Port_Input2_N185)+1.234e-06);
vec2 l9_6=(((((l9_0+Port_Offset_N245)-Port_Center_N218)*(vec2(Port_Input0_N217)/(clamp(Port_Import_N215,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N218)*vec2(Port_Input1_N219))-vec2(Port_Input1_N220);
float l9_7=atan(l9_6.y*Port_Input1_N223,l9_6.x);
float l9_8=(Port_Input0_N226*3.1415927)/(clamp(floor(Port_Import_N227),Port_Input1_N229,Port_Input2_N229)+1.234e-06);
float l9_9=clamp((((((1.0-(cos((floor((l9_7/(l9_8+1.234e-06))+Port_Input1_N232)*l9_8)-l9_7)*length(l9_6)))-Port_RangeMinA_N241)/(clamp(Port_Import_N240,0.0,1.0)-Port_RangeMinA_N241))*(Port_RangeMaxB_N241-Port_RangeMinB_N241))+Port_RangeMinB_N241)+0.001,Port_Input1_N243+0.001,Port_Input2_N243+0.001)-0.001;
float l9_10;
if (l9_9<=0.0)
{
l9_10=0.0;
}
else
{
l9_10=pow(l9_9,Port_Input1_N260);
}
Value1=(clamp((((((1.0-(cos((floor((l9_4/(l9_5+1.234e-06))+Port_Input1_N188)*l9_5)-l9_4)*length(l9_3)))-Port_RangeMinA_N196)/(clamp(Port_Import_N170,0.0,1.0)-Port_RangeMinA_N196))*(Port_RangeMaxB_N196-Port_RangeMinB_N196))+Port_RangeMinB_N196)+0.001,Port_Input1_N198+0.001,Port_Input2_N198+0.001)-0.001)-l9_10;
Result=Value1;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==2)
{
vec2 l9_11=(((((vec2(Globals.Surface_UVCoord0.x,Globals.Surface_UVCoord0.y+(abs(Globals.Surface_UVCoord0.x-Port_Input1_N249)*((Port_Value_N252+0.001)-0.001)))+Port_Offset_N278)-Port_Center_N283)*(vec2(Port_Input0_N282)/(clamp(Port_Import_N281,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N283)*vec2(Port_Input1_N284))-vec2(Port_Input1_N285);
float l9_12=atan(l9_11.y*Port_Input1_N288,l9_11.x);
float l9_13=(Port_Input0_N291*3.1415927)/(clamp(floor(Port_Import_N292),Port_Input1_N294,Port_Input2_N294)+1.234e-06);
Value2=clamp((((((1.0-(cos((floor((l9_12/(l9_13+1.234e-06))+Port_Input1_N297)*l9_13)-l9_12)*length(l9_11)))-Port_RangeMinA_N306)/(clamp(Port_Import_N305,0.0,1.0)-Port_RangeMinA_N306))*(Port_RangeMaxB_N306-Port_RangeMinB_N306))+Port_RangeMinB_N306)+0.001,Port_Input1_N308+0.001,Port_Input2_N308+0.001)-0.001;
Result=Value2;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==3)
{
vec2 l9_14=Globals.Surface_UVCoord0;
float l9_15=abs(l9_14.x-Port_Input1_N264);
float l9_16;
if (l9_15<=0.0)
{
l9_16=0.0;
}
else
{
l9_16=pow(l9_15,Port_Input1_N405);
}
vec2 l9_17=vec2(l9_14.x,l9_14.y+(l9_16*((Port_Value_N265+0.001)-0.001)))+Port_Offset_N269;
vec2 l9_18=((((l9_17-Port_Center_N274)*(vec2(Port_Input0_N273)/(clamp(Port_Import_N272,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N274)*vec2(Port_Input1_N275))-vec2(Port_Input1_N276);
float l9_19=atan(l9_18.y*Port_Input1_N310,l9_18.x);
float l9_20=(Port_Input0_N314*3.1415927)/(clamp(floor(Port_Import_N315),Port_Input1_N317,Port_Input2_N317)+1.234e-06);
vec2 l9_21=((((l9_17-Port_Center_N337)*(vec2(Port_Input0_N336)/(clamp(Port_Import_N335,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N337)*vec2(Port_Input1_N338))-vec2(Port_Input1_N339);
float l9_22=atan(l9_21.y*Port_Input1_N342,l9_21.x);
float l9_23=(Port_Input0_N345*3.1415927)/(clamp(floor(Port_Import_N346),Port_Input1_N348,Port_Input2_N348)+1.234e-06);
Value3=(clamp((((((1.0-(cos((floor((l9_19/(l9_20+1.234e-06))+Port_Input1_N320)*l9_20)-l9_19)*length(l9_18)))-Port_RangeMinA_N329)/(clamp(Port_Import_N328,0.0,1.0)-Port_RangeMinA_N329))*(Port_RangeMaxB_N329-Port_RangeMinB_N329))+Port_RangeMinB_N329)+0.001,Port_Input1_N331+0.001,Port_Input2_N331+0.001)-0.001)-(clamp((((((1.0-(cos((floor((l9_22/(l9_23+1.234e-06))+Port_Input1_N351)*l9_23)-l9_22)*length(l9_21)))-Port_RangeMinA_N360)/(clamp(Port_Import_N359,0.0,1.0)-Port_RangeMinA_N360))*(Port_RangeMaxB_N360-Port_RangeMinB_N360))+Port_RangeMinB_N360)+0.001,Port_Input1_N362+0.001,Port_Input2_N362+0.001)-0.001);
Result=Value3;
}
#else
{
#if (NODE_167_DROPLIST_ITEM==4)
{
vec2 l9_24=Globals.Surface_UVCoord0;
float l9_25=abs(l9_24.x-Port_Input1_N366);
float l9_26;
if (l9_25<=0.0)
{
l9_26=0.0;
}
else
{
l9_26=pow(l9_25,Port_Input1_N404);
}
vec2 l9_27=(((((vec2(l9_24.x,l9_24.y+(l9_26*((Port_Value_N367+0.001)-0.001)))+Port_Offset_N371)-Port_Center_N376)*(vec2(Port_Input0_N375)/(clamp(Port_Import_N374,vec2(0.0),vec2(10.0))+vec2(1.234e-06))))+Port_Center_N376)*vec2(Port_Input1_N377))-vec2(Port_Input1_N378);
float l9_28=atan(l9_27.y*Port_Input1_N381,l9_27.x);
float l9_29=(Port_Input0_N384*3.1415927)/(clamp(floor(Port_Import_N385),Port_Input1_N387,Port_Input2_N387)+1.234e-06);
Value4=(clamp((((((1.0-(cos((floor((l9_28/(l9_29+1.234e-06))+Port_Input1_N390)*l9_29)-l9_28)*length(l9_27)))-Port_RangeMinA_N399)/(clamp(Port_Import_N398,0.0,1.0)-Port_RangeMinA_N399))*(Port_RangeMaxB_N399-Port_RangeMinB_N399))+Port_RangeMinB_N399)+0.001,Port_Input1_N401+0.001,Port_Input2_N401+0.001)-0.001)-Port_Input1_N402;
Result=Value4;
}
#else
{
Result=Default;
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
void Node165_Switch(float Switch,float Value0,float Value1,float Default,out float Result,ssGlobals Globals)
{
#if ((Tweak_N164)==0)
{
Value0=hairLength;
Result=Value0;
}
#else
{
#if ((Tweak_N164)==1)
{
float param_7;
Node211_Switch(0.0,0.0,0.0,0.0,0.0,0.0,Port_Default_N211,param_7,Globals);
Value1=mix(hairLength,param_7*hairLength,customLengthBlend);
Result=Value1;
}
#else
{
Result=Default;
}
#endif
}
#endif
}
void Node216_Random_Noise(vec2 Seed,vec2 Scale,out float Random,ssGlobals Globals)
{
Seed=floor(Seed*10000.0)*9.9999997e-05;
Random=dot(floor(Seed*Scale),vec2(0.98000002,0.72000003));
Random=floor(Random*10000.0)*9.9999997e-05;
Random=sin(Random);
Random*=437.58499;
Random=fract(Random);
Random=floor(Random*10000.0)*9.9999997e-05;
}
float snoise(vec2 v)
{
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
vec2 l9_0=floor(v+vec2(dot(v,vec2(0.36602542))));
vec2 l9_1=(v-l9_0)+vec2(dot(l9_0,vec2(0.21132487)));
float l9_2=l9_1.x;
float l9_3=l9_1.y;
bvec2 l9_4=bvec2(l9_2>l9_3);
vec2 l9_5=vec2(l9_4.x ? vec2(1.0,0.0).x : vec2(0.0,1.0).x,l9_4.y ? vec2(1.0,0.0).y : vec2(0.0,1.0).y);
vec2 l9_6=(l9_1+vec2(0.21132487))-l9_5;
vec2 l9_7=l9_1+vec2(-0.57735026);
vec2 l9_8=l9_0-(floor(l9_0*0.0034602077)*289.0);
vec3 l9_9=vec3(l9_8.y)+vec3(0.0,l9_5.y,1.0);
vec3 l9_10=((l9_9*34.0)+vec3(1.0))*l9_9;
vec3 l9_11=((l9_10-(floor(l9_10*0.0034602077)*289.0))+vec3(l9_8.x))+vec3(0.0,l9_5.x,1.0);
vec3 l9_12=((l9_11*34.0)+vec3(1.0))*l9_11;
vec3 l9_13=max(vec3(0.5)-vec3(dot(l9_1,l9_1),dot(l9_6,l9_6),dot(l9_7,l9_7)),vec3(0.0));
vec3 l9_14=l9_13*l9_13;
vec3 l9_15=(fract((l9_12-(floor(l9_12*0.0034602077)*289.0))*vec3(0.024390243))*2.0)-vec3(1.0);
vec3 l9_16=abs(l9_15)-vec3(0.5);
vec3 l9_17=l9_15-floor(l9_15+vec3(0.5));
vec3 l9_18=vec3(0.0);
l9_18.x=(l9_17.x*l9_2)+(l9_16.x*l9_3);
vec2 l9_19=(l9_17.yz*vec2(l9_6.x,l9_7.x))+(l9_16.yz*vec2(l9_6.y,l9_7.y));
return 130.0*dot((l9_14*l9_14)*(vec3(1.7928429)-(((l9_17*l9_17)+(l9_16*l9_16))*0.85373473)),vec3(l9_18.x,l9_19.x,l9_19.y));
}
#else
{
return 0.0;
}
#endif
}
void Node430_Noise_Simplex(vec2 Seed,vec2 Scale,out float Noise,ssGlobals Globals)
{
Seed.x=floor(Seed.x*10000.0)*9.9999997e-05;
Seed.y=floor(Seed.y*10000.0)*9.9999997e-05;
Seed*=(Scale*0.5);
Noise=(snoise(Seed)*0.5)+0.5;
Noise=floor(Noise*10000.0)*9.9999997e-05;
}
void Node432_Noise_Simplex(vec2 Seed,vec2 Scale,out float Noise,ssGlobals Globals)
{
Seed.x=floor(Seed.x*10000.0)*9.9999997e-05;
Seed.y=floor(Seed.y*10000.0)*9.9999997e-05;
Seed*=(Scale*0.5);
Noise=(snoise(Seed)*0.5)+0.5;
Noise=floor(Noise*10000.0)*9.9999997e-05;
}
void Node434_Rotate_Coords(vec2 CoordsIn,float Rotation,vec2 Center,out vec2 CoordsOut,ssGlobals Globals)
{
float l9_0=sin(radians(Rotation));
float l9_1=cos(radians(Rotation));
CoordsOut=CoordsIn-Center;
CoordsOut=vec2(dot(vec2(l9_1,l9_0),CoordsOut),dot(vec2(-l9_0,l9_1),CoordsOut))+Center;
}
void Node121_Switch(float Switch,vec2 Value0,vec2 Value1,vec2 Default,out vec2 Result,ssGlobals Globals)
{
#if ((Tweak_N108)==0)
{
Result=Value0;
}
#else
{
#if ((Tweak_N108)==1)
{
vec2 l9_0=vec2((Globals.gTimeElapsed*Tweak_N110)*Port_Input1_N079);
vec2 l9_1=vec2(windScale);
float param_2;
Node430_Noise_Simplex(Globals.Surface_UVCoord0-l9_0,l9_1,param_2,Globals);
float param_6;
Node432_Noise_Simplex(Globals.Surface_UVCoord0+l9_0,l9_1,param_6,Globals);
vec2 param_11;
Node434_Rotate_Coords(vec2(param_2),param_6*Port_Input1_N433,Port_Center_N434,param_11,Globals);
Value1=vec2(Tweak_N107)*((((param_11-vec2(Port_RangeMinA_N118))/vec2(Port_RangeMaxA_N118-Port_RangeMinA_N118))*(Port_RangeMaxB_N118-Port_RangeMinB_N118))+vec2(Port_RangeMinB_N118));
Result=Value1;
}
#else
{
Result=Default;
}
#endif
}
#endif
}
void Node256_Switch(float Switch,vec2 Value0,vec2 Value1,vec2 Default,out vec2 Result,ssGlobals Globals)
{
#if (NODE_257_DROPLIST_ITEM==0)
{
Value0=Globals.Surface_UVCoord0;
Result=Value0;
}
#else
{
#if (NODE_257_DROPLIST_ITEM==1)
{
Value1=Globals.Surface_UVCoord1;
Result=Value1;
}
#else
{
Result=Default;
}
#endif
}
#endif
}
vec3 ssSRGB_to_Linear(vec3 value)
{
vec3 l9_0;
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
l9_0=vec3(pow(value.x,2.2),pow(value.y,2.2),pow(value.z,2.2));
}
#else
{
l9_0=value*value;
}
#endif
return l9_0;
}
vec3 evaluateSSAO(vec3 positionWS)
{
#if (sc_SSAOEnabled)
{
vec4 l9_0=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*vec4(positionWS,1.0);
return vec3(texture2D(sc_SSAOTexture,((l9_0.xyz/vec3(l9_0.w)).xy*0.5)+vec2(0.5)).x);
}
#else
{
return vec3(1.0);
}
#endif
}
vec3 fresnelSchlickSub(float cosTheta,vec3 F0,vec3 fresnelMax)
{
float l9_0=1.0-cosTheta;
float l9_1=l9_0*l9_0;
return F0+((fresnelMax-F0)*((l9_1*l9_1)*l9_0));
}
float Dggx(float NdotH,float roughness)
{
float l9_0=roughness*roughness;
float l9_1=l9_0*l9_0;
float l9_2=((NdotH*NdotH)*(l9_1-1.0))+1.0;
return l9_1/((l9_2*l9_2)+9.9999999e-09);
}
vec3 calculateDirectSpecular(SurfaceProperties surfaceProperties,vec3 L,vec3 V)
{
float l9_0=surfaceProperties.roughness;
float l9_1=max(l9_0,0.029999999);
vec3 l9_2=surfaceProperties.specColor;
vec3 l9_3=surfaceProperties.normal;
vec3 l9_4=L;
vec3 l9_5=V;
vec3 l9_6=normalize(l9_4+l9_5);
vec3 l9_7=L;
float l9_8=clamp(dot(l9_3,l9_7),0.0,1.0);
vec3 l9_9=V;
float l9_10=clamp(dot(l9_3,l9_6),0.0,1.0);
vec3 l9_11=V;
float l9_12=clamp(dot(l9_11,l9_6),0.0,1.0);
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
float l9_13=l9_1+1.0;
float l9_14=(l9_13*l9_13)*0.125;
float l9_15=1.0-l9_14;
return fresnelSchlickSub(l9_12,l9_2,vec3(1.0))*(((Dggx(l9_10,l9_1)*(1.0/(((l9_8*l9_15)+l9_14)*((clamp(dot(l9_3,l9_9),0.0,1.0)*l9_15)+l9_14))))*0.25)*l9_8);
}
#else
{
float l9_16=exp2(11.0-(10.0*l9_1));
return ((fresnelSchlickSub(l9_12,l9_2,vec3(1.0))*((l9_16*0.125)+0.25))*pow(l9_10,l9_16))*l9_8;
}
#endif
}
LightingComponents accumulateLight(LightingComponents lighting,LightProperties light,SurfaceProperties surfaceProperties,vec3 V)
{
lighting.directDiffuse+=((vec3(clamp(dot(surfaceProperties.normal,light.direction),0.0,1.0))*light.color)*light.attenuation);
lighting.directSpecular+=((calculateDirectSpecular(surfaceProperties,light.direction,V)*light.color)*light.attenuation);
return lighting;
}
float computeDistanceAttenuation(float distanceToLight,float falloffEndDistance)
{
float l9_0=distanceToLight;
float l9_1=distanceToLight;
float l9_2=l9_0*l9_1;
if (falloffEndDistance==0.0)
{
return 1.0/l9_2;
}
return max(min(1.0-((l9_2*l9_2)/pow(falloffEndDistance,4.0)),1.0),0.0)/l9_2;
}
int sc_EnvmapSpecularGetStereoViewIndex()
{
int l9_0;
#if (sc_EnvmapSpecularHasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec4 sc_EnvmapSpecularSampleViewIndexBias(vec2 uv,int viewIndex,float bias)
{
return sc_SampleView(sc_EnvmapSpecularDims.xy,uv,sc_EnvmapSpecularLayout,viewIndex,bias,sc_EnvmapSpecular);
}
vec2 calcSeamlessPanoramicUvsForSampling(vec2 uv,vec2 topMipRes,float lod)
{
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
vec2 l9_0=max(vec2(1.0),topMipRes/vec2(exp2(lod)));
return ((uv*(l9_0-vec2(1.0)))/l9_0)+(vec2(0.5)/l9_0);
}
#else
{
return uv;
}
#endif
}
vec2 sc_SamplingCoordsGlobalToView(vec3 uvi,int renderingLayout,int viewIndex)
{
if (renderingLayout==1)
{
uvi.y=((2.0*uvi.y)+float(viewIndex))-1.0;
}
return uvi.xy;
}
vec2 sc_ScreenCoordsGlobalToView(vec2 uv)
{
vec2 l9_0;
#if (sc_StereoRenderingMode==1)
{
l9_0=sc_SamplingCoordsGlobalToView(vec3(uv,0.0),1,sc_GetStereoViewIndex());
}
#else
{
l9_0=uv;
}
#endif
return l9_0;
}
int sc_ScreenTextureGetStereoViewIndex()
{
int l9_0;
#if (sc_ScreenTextureHasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec4 sc_ScreenTextureSampleViewIndexBias(vec2 uv,int viewIndex,float bias)
{
return sc_SampleView(sc_ScreenTextureDims.xy,uv,sc_ScreenTextureLayout,viewIndex,bias,sc_ScreenTexture);
}
vec4 sc_readFragData0_Platform()
{
    return getFragData()[0];
}
vec4 sc_readFragData0()
{
vec4 l9_0=sc_readFragData0_Platform();
vec4 l9_1;
#if (sc_UseFramebufferFetchMarker)
{
vec4 l9_2=l9_0;
l9_2.x=l9_0.x+_sc_framebufferFetchMarker;
l9_1=l9_2;
}
#else
{
l9_1=l9_0;
}
#endif
return l9_1;
}
vec4 sc_GetFramebufferColor()
{
vec4 l9_0;
#if (sc_FramebufferFetch)
{
l9_0=sc_readFragData0();
}
#else
{
l9_0=sc_ScreenTextureSampleViewIndexBias(sc_ScreenCoordsGlobalToView((gl_FragCoord.xy*sc_WindowToViewportTransform.xy)+sc_WindowToViewportTransform.zw),sc_ScreenTextureGetStereoViewIndex(),0.0);
}
#endif
vec4 l9_1;
#if (((sc_IsEditor&&sc_GetFramebufferColorInvalidUsageMarker)&&(!sc_BlendMode_Software))&&(!sc_BlendMode_ColoredGlass))
{
vec4 l9_2=l9_0;
l9_2.x=l9_0.x+_sc_GetFramebufferColorInvalidUsageMarker;
l9_1=l9_2;
}
#else
{
l9_1=l9_0;
}
#endif
return l9_1;
}
float srgbToLinear(float x)
{
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
return pow(x,2.2);
}
#else
{
return x*x;
}
#endif
}
float linearToSrgb(float x)
{
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
return pow(x,0.45454547);
}
#else
{
return sqrt(x);
}
#endif
}
float transformSingleColor(float original,float intMap,float target)
{
#if ((BLEND_MODE_REALISTIC||BLEND_MODE_FORGRAY)||BLEND_MODE_NOTBRIGHT)
{
return original/pow(1.0-target,intMap);
}
#else
{
#if (BLEND_MODE_DIVISION)
{
return original/(1.0-target);
}
#else
{
#if (BLEND_MODE_BRIGHT)
{
return original/pow(1.0-target,2.0-(2.0*original));
}
#endif
}
#endif
}
#endif
return 0.0;
}
vec3 RGBtoHCV(vec3 rgb)
{
vec4 l9_0;
if (rgb.y<rgb.z)
{
l9_0=vec4(rgb.zy,-1.0,0.66666669);
}
else
{
l9_0=vec4(rgb.yz,0.0,-0.33333334);
}
vec4 l9_1;
if (rgb.x<l9_0.x)
{
l9_1=vec4(l9_0.xyw,rgb.x);
}
else
{
l9_1=vec4(rgb.x,l9_0.yzx);
}
float l9_2=l9_1.x-min(l9_1.w,l9_1.y);
return vec3(abs(((l9_1.w-l9_1.y)/((6.0*l9_2)+1e-07))+l9_1.z),l9_2,l9_1.x);
}
vec3 RGBToHSL(vec3 rgb)
{
vec3 l9_0=RGBtoHCV(rgb);
float l9_1=l9_0.y;
float l9_2=l9_0.z-(l9_1*0.5);
return vec3(l9_0.x,l9_1/((1.0-abs((2.0*l9_2)-1.0))+1e-07),l9_2);
}
vec3 HUEtoRGB(float hue)
{
return clamp(vec3(abs((6.0*hue)-3.0)-1.0,2.0-abs((6.0*hue)-2.0),2.0-abs((6.0*hue)-4.0)),vec3(0.0),vec3(1.0));
}
vec3 HSLToRGB(vec3 hsl)
{
return ((HUEtoRGB(hsl.x)-vec3(0.5))*((1.0-abs((2.0*hsl.z)-1.0))*hsl.y))+vec3(hsl.z);
}
vec3 transformColor(float yValue,vec3 original,vec3 target,float weight,float intMap)
{
#if (BLEND_MODE_INTENSE)
{
return mix(original,HSLToRGB(vec3(target.x,target.y,RGBToHSL(original).z)),vec3(weight));
}
#else
{
return mix(original,clamp(vec3(transformSingleColor(yValue,intMap,target.x),transformSingleColor(yValue,intMap,target.y),transformSingleColor(yValue,intMap,target.z)),vec3(0.0),vec3(1.0)),vec3(weight));
}
#endif
}
vec3 definedBlend(vec3 a,vec3 b)
{
#if (BLEND_MODE_LIGHTEN)
{
return max(a,b);
}
#else
{
#if (BLEND_MODE_DARKEN)
{
return min(a,b);
}
#else
{
#if (BLEND_MODE_DIVIDE)
{
return b/a;
}
#else
{
#if (BLEND_MODE_AVERAGE)
{
return (a+b)*0.5;
}
#else
{
#if (BLEND_MODE_SUBTRACT)
{
return max((a+b)-vec3(1.0),vec3(0.0));
}
#else
{
#if (BLEND_MODE_DIFFERENCE)
{
return abs(a-b);
}
#else
{
#if (BLEND_MODE_NEGATION)
{
return vec3(1.0)-abs((vec3(1.0)-a)-b);
}
#else
{
#if (BLEND_MODE_EXCLUSION)
{
return (a+b)-((a*2.0)*b);
}
#else
{
#if (BLEND_MODE_OVERLAY)
{
float l9_0;
if (a.x<0.5)
{
l9_0=(2.0*a.x)*b.x;
}
else
{
l9_0=1.0-((2.0*(1.0-a.x))*(1.0-b.x));
}
float l9_1;
if (a.y<0.5)
{
l9_1=(2.0*a.y)*b.y;
}
else
{
l9_1=1.0-((2.0*(1.0-a.y))*(1.0-b.y));
}
float l9_2;
if (a.z<0.5)
{
l9_2=(2.0*a.z)*b.z;
}
else
{
l9_2=1.0-((2.0*(1.0-a.z))*(1.0-b.z));
}
return vec3(l9_0,l9_1,l9_2);
}
#else
{
#if (BLEND_MODE_SOFT_LIGHT)
{
return (((vec3(1.0)-(b*2.0))*a)*a)+((a*2.0)*b);
}
#else
{
#if (BLEND_MODE_HARD_LIGHT)
{
float l9_3;
if (b.x<0.5)
{
l9_3=(2.0*b.x)*a.x;
}
else
{
l9_3=1.0-((2.0*(1.0-b.x))*(1.0-a.x));
}
float l9_4;
if (b.y<0.5)
{
l9_4=(2.0*b.y)*a.y;
}
else
{
l9_4=1.0-((2.0*(1.0-b.y))*(1.0-a.y));
}
float l9_5;
if (b.z<0.5)
{
l9_5=(2.0*b.z)*a.z;
}
else
{
l9_5=1.0-((2.0*(1.0-b.z))*(1.0-a.z));
}
return vec3(l9_3,l9_4,l9_5);
}
#else
{
#if (BLEND_MODE_COLOR_DODGE)
{
float l9_6;
if (b.x==1.0)
{
l9_6=b.x;
}
else
{
l9_6=min(a.x/(1.0-b.x),1.0);
}
float l9_7;
if (b.y==1.0)
{
l9_7=b.y;
}
else
{
l9_7=min(a.y/(1.0-b.y),1.0);
}
float l9_8;
if (b.z==1.0)
{
l9_8=b.z;
}
else
{
l9_8=min(a.z/(1.0-b.z),1.0);
}
return vec3(l9_6,l9_7,l9_8);
}
#else
{
#if (BLEND_MODE_COLOR_BURN)
{
float l9_9;
if (b.x==0.0)
{
l9_9=b.x;
}
else
{
l9_9=max(1.0-((1.0-a.x)/b.x),0.0);
}
float l9_10;
if (b.y==0.0)
{
l9_10=b.y;
}
else
{
l9_10=max(1.0-((1.0-a.y)/b.y),0.0);
}
float l9_11;
if (b.z==0.0)
{
l9_11=b.z;
}
else
{
l9_11=max(1.0-((1.0-a.z)/b.z),0.0);
}
return vec3(l9_9,l9_10,l9_11);
}
#else
{
#if (BLEND_MODE_LINEAR_LIGHT)
{
float l9_12;
if (b.x<0.5)
{
l9_12=max((a.x+(2.0*b.x))-1.0,0.0);
}
else
{
l9_12=min(a.x+(2.0*(b.x-0.5)),1.0);
}
float l9_13;
if (b.y<0.5)
{
l9_13=max((a.y+(2.0*b.y))-1.0,0.0);
}
else
{
l9_13=min(a.y+(2.0*(b.y-0.5)),1.0);
}
float l9_14;
if (b.z<0.5)
{
l9_14=max((a.z+(2.0*b.z))-1.0,0.0);
}
else
{
l9_14=min(a.z+(2.0*(b.z-0.5)),1.0);
}
return vec3(l9_12,l9_13,l9_14);
}
#else
{
#if (BLEND_MODE_VIVID_LIGHT)
{
float l9_15;
if (b.x<0.5)
{
float l9_16;
if ((2.0*b.x)==0.0)
{
l9_16=2.0*b.x;
}
else
{
l9_16=max(1.0-((1.0-a.x)/(2.0*b.x)),0.0);
}
l9_15=l9_16;
}
else
{
float l9_17;
if ((2.0*(b.x-0.5))==1.0)
{
l9_17=2.0*(b.x-0.5);
}
else
{
l9_17=min(a.x/(1.0-(2.0*(b.x-0.5))),1.0);
}
l9_15=l9_17;
}
float l9_18;
if (b.y<0.5)
{
float l9_19;
if ((2.0*b.y)==0.0)
{
l9_19=2.0*b.y;
}
else
{
l9_19=max(1.0-((1.0-a.y)/(2.0*b.y)),0.0);
}
l9_18=l9_19;
}
else
{
float l9_20;
if ((2.0*(b.y-0.5))==1.0)
{
l9_20=2.0*(b.y-0.5);
}
else
{
l9_20=min(a.y/(1.0-(2.0*(b.y-0.5))),1.0);
}
l9_18=l9_20;
}
float l9_21;
if (b.z<0.5)
{
float l9_22;
if ((2.0*b.z)==0.0)
{
l9_22=2.0*b.z;
}
else
{
l9_22=max(1.0-((1.0-a.z)/(2.0*b.z)),0.0);
}
l9_21=l9_22;
}
else
{
float l9_23;
if ((2.0*(b.z-0.5))==1.0)
{
l9_23=2.0*(b.z-0.5);
}
else
{
l9_23=min(a.z/(1.0-(2.0*(b.z-0.5))),1.0);
}
l9_21=l9_23;
}
return vec3(l9_15,l9_18,l9_21);
}
#else
{
#if (BLEND_MODE_PIN_LIGHT)
{
float l9_24;
if (b.x<0.5)
{
l9_24=min(a.x,2.0*b.x);
}
else
{
l9_24=max(a.x,2.0*(b.x-0.5));
}
float l9_25;
if (b.y<0.5)
{
l9_25=min(a.y,2.0*b.y);
}
else
{
l9_25=max(a.y,2.0*(b.y-0.5));
}
float l9_26;
if (b.z<0.5)
{
l9_26=min(a.z,2.0*b.z);
}
else
{
l9_26=max(a.z,2.0*(b.z-0.5));
}
return vec3(l9_24,l9_25,l9_26);
}
#else
{
#if (BLEND_MODE_HARD_MIX)
{
float l9_27;
if (b.x<0.5)
{
float l9_28;
if ((2.0*b.x)==0.0)
{
l9_28=2.0*b.x;
}
else
{
l9_28=max(1.0-((1.0-a.x)/(2.0*b.x)),0.0);
}
l9_27=l9_28;
}
else
{
float l9_29;
if ((2.0*(b.x-0.5))==1.0)
{
l9_29=2.0*(b.x-0.5);
}
else
{
l9_29=min(a.x/(1.0-(2.0*(b.x-0.5))),1.0);
}
l9_27=l9_29;
}
bool l9_30=l9_27<0.5;
float l9_31;
if (b.y<0.5)
{
float l9_32;
if ((2.0*b.y)==0.0)
{
l9_32=2.0*b.y;
}
else
{
l9_32=max(1.0-((1.0-a.y)/(2.0*b.y)),0.0);
}
l9_31=l9_32;
}
else
{
float l9_33;
if ((2.0*(b.y-0.5))==1.0)
{
l9_33=2.0*(b.y-0.5);
}
else
{
l9_33=min(a.y/(1.0-(2.0*(b.y-0.5))),1.0);
}
l9_31=l9_33;
}
bool l9_34=l9_31<0.5;
float l9_35;
if (b.z<0.5)
{
float l9_36;
if ((2.0*b.z)==0.0)
{
l9_36=2.0*b.z;
}
else
{
l9_36=max(1.0-((1.0-a.z)/(2.0*b.z)),0.0);
}
l9_35=l9_36;
}
else
{
float l9_37;
if ((2.0*(b.z-0.5))==1.0)
{
l9_37=2.0*(b.z-0.5);
}
else
{
l9_37=min(a.z/(1.0-(2.0*(b.z-0.5))),1.0);
}
l9_35=l9_37;
}
return vec3(l9_30 ? 0.0 : 1.0,l9_34 ? 0.0 : 1.0,(l9_35<0.5) ? 0.0 : 1.0);
}
#else
{
#if (BLEND_MODE_HARD_REFLECT)
{
float l9_38;
if (b.x==1.0)
{
l9_38=b.x;
}
else
{
l9_38=min((a.x*a.x)/(1.0-b.x),1.0);
}
float l9_39;
if (b.y==1.0)
{
l9_39=b.y;
}
else
{
l9_39=min((a.y*a.y)/(1.0-b.y),1.0);
}
float l9_40;
if (b.z==1.0)
{
l9_40=b.z;
}
else
{
l9_40=min((a.z*a.z)/(1.0-b.z),1.0);
}
return vec3(l9_38,l9_39,l9_40);
}
#else
{
#if (BLEND_MODE_HARD_GLOW)
{
float l9_41;
if (a.x==1.0)
{
l9_41=a.x;
}
else
{
l9_41=min((b.x*b.x)/(1.0-a.x),1.0);
}
float l9_42;
if (a.y==1.0)
{
l9_42=a.y;
}
else
{
l9_42=min((b.y*b.y)/(1.0-a.y),1.0);
}
float l9_43;
if (a.z==1.0)
{
l9_43=a.z;
}
else
{
l9_43=min((b.z*b.z)/(1.0-a.z),1.0);
}
return vec3(l9_41,l9_42,l9_43);
}
#else
{
#if (BLEND_MODE_HARD_PHOENIX)
{
return (min(a,b)-max(a,b))+vec3(1.0);
}
#else
{
#if (BLEND_MODE_HUE)
{
return HSLToRGB(vec3(RGBToHSL(b).x,RGBToHSL(a).yz));
}
#else
{
#if (BLEND_MODE_SATURATION)
{
vec3 l9_44=RGBToHSL(a);
return HSLToRGB(vec3(l9_44.x,RGBToHSL(b).y,l9_44.z));
}
#else
{
#if (BLEND_MODE_COLOR)
{
return HSLToRGB(vec3(RGBToHSL(b).xy,RGBToHSL(a).z));
}
#else
{
#if (BLEND_MODE_LUMINOSITY)
{
return HSLToRGB(vec3(RGBToHSL(a).xy,RGBToHSL(b).z));
}
#else
{
vec3 l9_45=a;
vec3 l9_46=b;
float l9_47=((0.29899999*l9_45.x)+(0.58700001*l9_45.y))+(0.114*l9_45.z);
int l9_48;
#if (intensityTextureHasSwappedViews)
{
l9_48=1-sc_GetStereoViewIndex();
}
#else
{
l9_48=sc_GetStereoViewIndex();
}
#endif
vec4 l9_49=sc_SampleTextureBiasOrLevel(intensityTextureDims.xy,intensityTextureLayout,l9_48,vec2(pow(l9_47,1.0/correctedIntensity),0.5),(int(SC_USE_UV_TRANSFORM_intensityTexture)!=0),intensityTextureTransform,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture),(int(SC_USE_UV_MIN_MAX_intensityTexture)!=0),intensityTextureUvMinMax,(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0),intensityTextureBorderColor,0.0,intensityTexture);
float l9_50=((((l9_49.x*256.0)+l9_49.y)+(l9_49.z/256.0))/257.00391)*16.0;
float l9_51;
#if (BLEND_MODE_FORGRAY)
{
l9_51=max(l9_50,1.0);
}
#else
{
l9_51=l9_50;
}
#endif
float l9_52;
#if (BLEND_MODE_NOTBRIGHT)
{
l9_52=min(l9_51,1.0);
}
#else
{
l9_52=l9_51;
}
#endif
return transformColor(l9_47,l9_45,l9_46,1.0,l9_52);
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
vec4 outputMotionVectorsIfNeeded(vec3 surfacePosWorldSpace,vec4 finalColor)
{
#if (sc_MotionVectorsPass)
{
vec4 l9_0=vec4(surfacePosWorldSpace,1.0);
vec4 l9_1=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*l9_0;
vec4 l9_2=((sc_PrevFrameViewProjectionMatrixArray[sc_GetStereoViewIndex()]*sc_PrevFrameModelMatrix)*sc_ModelMatrixInverse)*l9_0;
vec2 l9_3=((l9_1.xy/vec2(l9_1.w)).xy-(l9_2.xy/vec2(l9_2.w)).xy)*0.5;
float l9_4=floor(((l9_3.x*5.0)+0.5)*65535.0);
float l9_5=floor(l9_4*0.00390625);
float l9_6=floor(((l9_3.y*5.0)+0.5)*65535.0);
float l9_7=floor(l9_6*0.00390625);
return vec4(l9_5/255.0,(l9_4-(l9_5*256.0))/255.0,l9_7/255.0,(l9_6-(l9_7*256.0))/255.0);
}
#else
{
return finalColor;
}
#endif
}
void sc_writeFragData0(vec4 col)
{
    sc_FragData0=col;
}
float getFrontLayerZTestEpsilon()
{
#if (sc_SkinBonesCount>0)
{
return 5e-07;
}
#else
{
return 5.0000001e-08;
}
#endif
}
void unpackValues(float channel,int passIndex,inout int values[8])
{
#if (sc_OITCompositingPass)
{
channel=floor((channel*255.0)+0.5);
int l9_0=((passIndex+1)*4)-1;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_0>=(passIndex*4))
{
values[l9_0]=(values[l9_0]*4)+int(floor(mod(channel,4.0)));
channel=floor(channel/4.0);
l9_0--;
continue;
}
else
{
break;
}
}
}
#endif
}
float getDepthOrderingEpsilon()
{
#if (sc_SkinBonesCount>0)
{
return 0.001;
}
#else
{
return 0.0;
}
#endif
}
int encodeDepth(float depth,vec2 depthBounds)
{
float l9_0=(1.0-depthBounds.x)*1000.0;
return int(clamp((depth-l9_0)/((depthBounds.y*1000.0)-l9_0),0.0,1.0)*65535.0);
}
float viewSpaceDepth()
{
#if (UseViewSpaceDepthVariant&&((sc_OITDepthGatherPass||sc_OITCompositingPass)||sc_OITDepthBoundsPass))
{
return varViewSpaceDepth;
}
#else
{
return sc_ProjectionMatrixArray[sc_GetStereoViewIndex()][3].z/(sc_ProjectionMatrixArray[sc_GetStereoViewIndex()][2].z+((gl_FragCoord.z*2.0)-1.0));
}
#endif
}
float packValue(inout int value)
{
#if (sc_OITDepthGatherPass)
{
int l9_0=value;
value/=4;
return floor(floor(mod(float(l9_0),4.0))*64.0)/255.0;
}
#else
{
return 0.0;
}
#endif
}
void sc_writeFragData1(vec4 col)
{
#if sc_FragDataCount>=2
    sc_FragData1=col;
#endif
}
void sc_writeFragData2(vec4 col)
{
#if sc_FragDataCount>=3
    sc_FragData2=col;
#endif
}
void main()
{
#if (sc_DepthOnly)
{
return;
}
#endif
#if ((sc_StereoRenderingMode==1)&&(sc_StereoRendering_IsClipDistanceEnabled==0))
{
if (varClipDistance<0.0)
{
discard;
}
}
#endif
bool l9_0=overrideTimeEnabled==1;
float l9_1;
if (l9_0)
{
l9_1=overrideTimeElapsed;
}
else
{
l9_1=sc_Time.x;
}
float l9_2;
if (l9_0)
{
l9_2=overrideTimeDelta;
}
else
{
l9_2=sc_Time.y;
}
vec3 l9_3=normalize(varNormal);
vec3 l9_4=normalize(varTangent.xyz);
vec3 l9_5=cross(l9_3,l9_4)*varTangent.w;
vec3 l9_6=normalize(sc_Camera.position-varPos);
ssGlobals l9_7=ssGlobals(l9_1,l9_2,0.0,vec3(0.0),l9_6,varPos,l9_3,l9_4,l9_5,varPos,varPackedTex.xy,varPackedTex.zw,Interpolator_gInstanceRatio);
float param_4;
Node165_Switch(0.0,0.0,0.0,Port_Default_N165,param_4,l9_7);
float l9_8=param_4;
vec2 l9_9=vec2(variationScale);
float param_8;
Node216_Random_Noise(varPackedTex.xy,l9_9,param_8,l9_7);
float l9_10=param_8;
float l9_11;
if (l9_10<=0.0)
{
l9_11=0.0;
}
else
{
l9_11=pow(l9_10,variationSharpness);
}
float l9_12=l9_11-Port_RangeMinA_N081;
float l9_13=Port_RangeMaxA_N081-Port_RangeMinA_N081;
float l9_14=Port_RangeMaxB_N081-Port_RangeMinB_N081;
float l9_15=mix(l9_8,l9_8+(l9_8*(((l9_12/l9_13)*l9_14)+Port_RangeMinB_N081)),variationStrength);
float l9_16=hairLength+1.234e-06;
float l9_17=l9_15/l9_16;
vec3 l9_18=vec3(l9_17);
vec3 l9_19;
#if ((Tweak_N160)==0)
{
vec3 l9_20;
#if ((Tweak_N204)==0)
{
l9_20=Port_Value0_N123;
}
#else
{
vec3 l9_21;
#if ((Tweak_N204)==1)
{
int l9_22;
#if (baseTextureHasSwappedViews)
{
l9_22=1-sc_GetStereoViewIndex();
}
#else
{
l9_22=sc_GetStereoViewIndex();
}
#endif
l9_21=sc_SampleTextureBiasOrLevel(baseTextureDims.xy,baseTextureLayout,l9_22,varPackedTex.xy,(int(SC_USE_UV_TRANSFORM_baseTexture)!=0),baseTextureTransform,ivec2(SC_SOFTWARE_WRAP_MODE_U_baseTexture,SC_SOFTWARE_WRAP_MODE_V_baseTexture),(int(SC_USE_UV_MIN_MAX_baseTexture)!=0),baseTextureUvMinMax,(int(SC_USE_CLAMP_TO_BORDER_baseTexture)!=0),baseTextureBorderColor,0.0,baseTexture).xyz;
}
#else
{
l9_21=Port_Default_N123;
}
#endif
l9_20=l9_21;
}
#endif
vec3 l9_23=baseColorRGB*l9_20;
vec3 l9_24;
#if ((Tweak_N50)==0)
{
l9_24=Port_Value0_N126;
}
#else
{
vec3 l9_25;
#if ((Tweak_N50)==1)
{
vec2 l9_26;
Node121_Switch(0.0,Port_Value0_N121,vec2(0.0),Port_Default_N121,l9_26,l9_7);
vec2 l9_27=l9_26;
float l9_28;
if (Interpolator_gInstanceRatio<=0.0)
{
l9_28=0.0;
}
else
{
l9_28=pow(Interpolator_gInstanceRatio,Port_Input1_N147);
}
vec2 l9_29=vec2(l9_28);
int l9_30;
#if (endsTextureHasSwappedViews)
{
l9_30=1-sc_GetStereoViewIndex();
}
#else
{
l9_30=sc_GetStereoViewIndex();
}
#endif
l9_25=sc_SampleTextureBiasOrLevel(endsTextureDims.xy,endsTextureLayout,l9_30,varPackedTex.xy+((l9_27*l9_29)*vec2(Port_Input1_N114)),(int(SC_USE_UV_TRANSFORM_endsTexture)!=0),endsTextureTransform,ivec2(SC_SOFTWARE_WRAP_MODE_U_endsTexture,SC_SOFTWARE_WRAP_MODE_V_endsTexture),(int(SC_USE_UV_MIN_MAX_endsTexture)!=0),endsTextureUvMinMax,(int(SC_USE_CLAMP_TO_BORDER_endsTexture)!=0),endsTextureBorderColor,0.0,endsTexture).xyz;
}
#else
{
l9_25=Port_Default_N126;
}
#endif
l9_24=l9_25;
}
#endif
vec3 l9_31=endsColor*l9_24;
float l9_32;
Node165_Switch(0.0,0.0,0.0,Port_Default_N165,l9_32,l9_7);
float l9_33=l9_32;
float l9_34;
Node216_Random_Noise(varPackedTex.xy,l9_9,l9_34,l9_7);
float l9_35=l9_34;
float l9_36;
if (l9_35<=0.0)
{
l9_36=0.0;
}
else
{
l9_36=pow(l9_35,variationSharpness);
}
float l9_37=l9_36-Port_RangeMinA_N081;
float l9_38=Interpolator_gInstanceRatio/((mix(l9_33,l9_33+(l9_33*(((l9_37/l9_13)*l9_14)+Port_RangeMinB_N081)),variationStrength)/l9_16)+1.234e-06);
float l9_39;
if (l9_38<=0.0)
{
l9_39=0.0;
}
else
{
l9_39=pow(l9_38,colorFalloff);
}
l9_19=mix(l9_23,l9_31,vec3(l9_39));
}
#else
{
vec3 l9_40;
#if ((Tweak_N160)==1)
{
float l9_41=(Interpolator_gInstanceRatio*rainbowRingsCount)+rainbowOffset;
vec4 l9_42=vec4(l9_41,1.0,1.0,0.0);
float l9_43=3.0*fract(l9_41+0.16666667);
float l9_44=2.0*fract(l9_43);
vec2 l9_45=l9_42.zz-((vec2(1.0,l9_44)-vec2(max(0.0,l9_44-1.0)))*(1.0*1.0));
vec3 l9_46=vec3(l9_42.z,l9_45.x,l9_45.y);
vec3 l9_47;
if (l9_43>=1.0)
{
l9_47=l9_46.zxy;
}
else
{
l9_47=l9_46;
}
vec3 l9_48;
if (l9_43>=2.0)
{
l9_48=l9_47.zxy;
}
else
{
l9_48=l9_47;
}
l9_40=vec4(l9_48,0.0).xyz;
}
#else
{
l9_40=Port_Default_N139;
}
#endif
l9_19=l9_40;
}
#endif
vec3 l9_49=((vec3(max(pow(1.0-abs(dot(-l9_6,mat3(l9_4,l9_5,l9_3)*Port_Normal_N057)),rimExponent),0.0)*rimIntensity)*rimColor)*l9_18)+l9_19;
vec2 param_14;
Node256_Switch(0.0,vec2(0.0),vec2(0.0),Port_Default_N256,param_14,l9_7);
vec2 l9_50=param_14;
vec2 l9_51=vec2(uvScaleTex);
vec2 param_20;
Node121_Switch(0.0,Port_Value0_N121,vec2(0.0),Port_Default_N121,param_20,l9_7);
vec2 l9_52=param_20;
bool l9_53=Interpolator_gInstanceRatio<=0.0;
float l9_54;
if (l9_53)
{
l9_54=0.0;
}
else
{
l9_54=pow(Interpolator_gInstanceRatio,Port_Input1_N147);
}
vec2 l9_55=vec2(decolorizeSeed)+((l9_50*l9_51)+(l9_52*vec2(l9_54)));
float l9_56=snoise(vec2(floor(l9_55.x*10000.0)*9.9999997e-05,floor(l9_55.y*10000.0)*9.9999997e-05)*(vec2(decolorizeAreaScale)*0.5));
float l9_57;
if (l9_53)
{
l9_57=0.0;
}
else
{
l9_57=pow(Interpolator_gInstanceRatio,(Port_Value_N151+0.001)-0.001);
}
vec3 l9_58=vec3(l9_57);
float l9_59=1.0-AO;
vec3 l9_60;
#if (!sc_ProjectiveShadowsCaster)
{
l9_60=l9_3;
}
#else
{
l9_60=vec3(0.0);
}
#endif
#if (sc_BlendMode_AlphaTest)
{
if (Port_Opacity_N049<alphaTestThreshold)
{
discard;
}
}
#endif
#if (ENABLE_STIPPLE_PATTERN_TEST)
{
if (Port_Opacity_N049<((mod(dot(floor(mod(gl_FragCoord.xy,vec2(4.0))),vec2(4.0,1.0))*9.0,16.0)+1.0)/17.0))
{
discard;
}
}
#endif
vec3 l9_61=max(mix(l9_49,decolorizeColor,vec3((floor(((l9_56*0.5)+0.5)*10000.0)*9.9999997e-05)*decolorizeIntensity)),vec3(0.0));
vec4 l9_62;
#if (sc_ProjectiveShadowsCaster)
{
l9_62=vec4(l9_61,Port_Opacity_N049);
}
#else
{
vec3 l9_63=ssSRGB_to_Linear(l9_61);
vec3 l9_64=normalize(l9_60);
vec3 l9_65=ssSRGB_to_Linear(max(l9_58*subsurface,vec3(0.0)));
vec3 l9_66;
#if (sc_SSAOEnabled)
{
l9_66=evaluateSSAO(varPos);
}
#else
{
l9_66=clamp(mix(Port_Input0_N201,vec3((((Interpolator_gInstanceRatio-Port_RangeMinA_N056)/(Port_RangeMaxA_N056-Port_RangeMinA_N056))*(Port_RangeMaxB_N056-l9_59))+l9_59),l9_18),vec3(0.0),vec3(1.0));
}
#endif
vec3 l9_67=l9_63*(1.0-0.0);
SurfaceProperties l9_68=SurfaceProperties(l9_67,Port_Opacity_N049,l9_64,varPos,l9_6,0.0,1.0,l9_65,l9_66,vec3(1.0),vec3(1.0),vec3(0.039999999));
vec4 l9_69=vec4(1.0);
vec3 l9_70;
vec3 l9_71;
vec3 l9_72;
vec3 l9_73;
vec3 l9_74;
int l9_75;
vec3 l9_76;
#if (sc_DirectionalLightsCount>0)
{
vec3 l9_77;
vec3 l9_78;
vec3 l9_79;
vec3 l9_80;
vec3 l9_81;
int l9_82;
vec3 l9_83;
l9_83=vec3(1.0);
l9_82=0;
l9_81=vec3(0.0);
l9_80=vec3(0.0);
l9_79=vec3(0.0);
l9_78=vec3(0.0);
l9_77=vec3(0.0);
LightingComponents l9_84;
LightProperties l9_85;
SurfaceProperties l9_86;
vec3 l9_87;
int l9_88=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_88<sc_DirectionalLightsCount)
{
LightingComponents l9_89=accumulateLight(LightingComponents(l9_77,l9_78,l9_83,l9_81,l9_80,l9_79),LightProperties(sc_DirectionalLights[l9_88].direction,sc_DirectionalLights[l9_88].color.xyz,sc_DirectionalLights[l9_88].color.w*l9_69[(l9_82<3) ? l9_82 : 3]),l9_68,l9_6);
l9_83=l9_89.indirectDiffuse;
l9_82++;
l9_81=l9_89.indirectSpecular;
l9_80=l9_89.emitted;
l9_79=l9_89.transmitted;
l9_78=l9_89.directSpecular;
l9_77=l9_89.directDiffuse;
l9_88++;
continue;
}
else
{
break;
}
}
l9_76=l9_83;
l9_75=l9_82;
l9_74=l9_81;
l9_73=l9_80;
l9_72=l9_79;
l9_71=l9_78;
l9_70=l9_77;
}
#else
{
l9_76=vec3(1.0);
l9_75=0;
l9_74=vec3(0.0);
l9_73=vec3(0.0);
l9_72=vec3(0.0);
l9_71=vec3(0.0);
l9_70=vec3(0.0);
}
#endif
vec3 l9_90;
vec3 l9_91;
vec3 l9_92;
#if (sc_PointLightsCount>0)
{
vec3 l9_93;
vec3 l9_94;
vec3 l9_95;
vec3 l9_96;
vec3 l9_97;
vec3 l9_98;
l9_98=l9_76;
l9_97=l9_74;
l9_96=l9_73;
l9_95=l9_72;
l9_94=l9_71;
l9_93=l9_70;
int l9_99;
vec3 l9_100;
vec3 l9_101;
vec3 l9_102;
vec3 l9_103;
vec3 l9_104;
vec3 l9_105;
int l9_106=0;
int l9_107=l9_75;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_106<sc_PointLightsCount)
{
vec3 l9_108=sc_PointLights[l9_106].position-varPos;
vec3 l9_109=normalize(l9_108);
float l9_110=l9_69[(l9_107<3) ? l9_107 : 3];
float l9_111=clamp((dot(l9_109,sc_PointLights[l9_106].direction)*sc_PointLights[l9_106].angleScale)+sc_PointLights[l9_106].angleOffset,0.0,1.0);
float l9_112=(sc_PointLights[l9_106].color.w*l9_110)*(l9_111*l9_111);
float l9_113;
if (sc_PointLights[l9_106].falloffEnabled)
{
l9_113=l9_112*computeDistanceAttenuation(length(l9_108),sc_PointLights[l9_106].falloffEndDistance);
}
else
{
l9_113=l9_112;
}
l9_99=l9_107+1;
LightingComponents l9_114=accumulateLight(LightingComponents(l9_93,l9_94,l9_98,l9_97,l9_96,l9_95),LightProperties(l9_109,sc_PointLights[l9_106].color.xyz,l9_113),l9_68,l9_6);
l9_100=l9_114.directDiffuse;
l9_101=l9_114.directSpecular;
l9_102=l9_114.indirectDiffuse;
l9_103=l9_114.indirectSpecular;
l9_104=l9_114.emitted;
l9_105=l9_114.transmitted;
l9_98=l9_102;
l9_107=l9_99;
l9_97=l9_103;
l9_96=l9_104;
l9_95=l9_105;
l9_94=l9_101;
l9_93=l9_100;
l9_106++;
continue;
}
else
{
break;
}
}
l9_92=l9_97;
l9_91=l9_95;
l9_90=l9_93;
}
#else
{
l9_92=l9_74;
l9_91=l9_72;
l9_90=l9_70;
}
#endif
vec3 l9_115;
#if (sc_ProjectiveShadowsReceiver)
{
vec3 l9_116;
#if (sc_ProjectiveShadowsReceiver)
{
vec2 l9_117=abs(varShadowTex-vec2(0.5));
vec4 l9_118=texture2D(sc_ShadowTexture,varShadowTex)*step(max(l9_117.x,l9_117.y),0.5);
l9_116=mix(vec3(1.0),mix(sc_ShadowColor.xyz,sc_ShadowColor.xyz*l9_118.xyz,vec3(sc_ShadowColor.w)),vec3(l9_118.w*sc_ShadowDensity));
}
#else
{
l9_116=vec3(1.0);
}
#endif
l9_115=l9_90*l9_116;
}
#else
{
l9_115=l9_90;
}
#endif
vec3 l9_119;
#if ((sc_EnvLightMode==sc_AmbientLightMode_EnvironmentMap)||(sc_EnvLightMode==sc_AmbientLightMode_FromCamera))
{
float l9_120=-l9_64.z;
float l9_121=l9_64.x;
vec2 l9_122=vec2((((l9_121<0.0) ? (-1.0) : 1.0)*acos(clamp(l9_120/length(vec2(l9_121,l9_120)),-1.0,1.0)))-1.5707964,acos(l9_64.y))/vec2(6.2831855,3.1415927);
float l9_123=l9_122.x+(sc_EnvmapRotation.y/360.0);
vec2 l9_124=vec2(l9_123,1.0-l9_122.y);
l9_124.x=fract((l9_123+floor(l9_123))+1.0);
vec4 l9_125;
#if (sc_EnvLightMode==sc_AmbientLightMode_FromCamera)
{
vec2 l9_126;
#if ((SC_DEVICE_CLASS>=2)&&SC_GL_FRAGMENT_PRECISION_HIGH)
{
l9_126=calcSeamlessPanoramicUvsForSampling(l9_124,sc_EnvmapSpecularSize.xy,5.0);
}
#else
{
l9_126=l9_124;
}
#endif
l9_125=sc_EnvmapSpecularSampleViewIndexBias(l9_126,sc_EnvmapSpecularGetStereoViewIndex(),13.0);
}
#else
{
vec4 l9_127;
#if ((sc_MaxTextureImageUnits>8)&&sc_HasDiffuseEnvmap)
{
vec2 l9_128=calcSeamlessPanoramicUvsForSampling(l9_124,sc_EnvmapDiffuseSize.xy,0.0);
int l9_129;
#if (sc_EnvmapDiffuseHasSwappedViews)
{
l9_129=1-sc_GetStereoViewIndex();
}
#else
{
l9_129=sc_GetStereoViewIndex();
}
#endif
l9_127=sc_SampleView(sc_EnvmapDiffuseDims.xy,l9_128,sc_EnvmapDiffuseLayout,l9_129,-13.0,sc_EnvmapDiffuse);
}
#else
{
l9_127=sc_EnvmapSpecularSampleViewIndexBias(l9_124,sc_EnvmapSpecularGetStereoViewIndex(),13.0);
}
#endif
l9_125=l9_127;
}
#endif
l9_119=(l9_125.xyz*(1.0/l9_125.w))*sc_EnvmapExposure;
}
#else
{
vec3 l9_130;
#if (sc_EnvLightMode==sc_AmbientLightMode_SphericalHarmonics)
{
vec3 l9_131=-l9_64;
float l9_132=l9_131.x;
float l9_133=l9_131.y;
float l9_134=l9_131.z;
l9_130=(((((((sc_Sh[8]*0.42904299)*((l9_132*l9_132)-(l9_133*l9_133)))+((sc_Sh[6]*0.74312502)*(l9_134*l9_134)))+(sc_Sh[0]*0.88622701))-(sc_Sh[6]*0.24770799))+((((sc_Sh[4]*(l9_132*l9_133))+(sc_Sh[7]*(l9_132*l9_134)))+(sc_Sh[5]*(l9_133*l9_134)))*0.85808599))+((((sc_Sh[3]*l9_132)+(sc_Sh[1]*l9_133))+(sc_Sh[2]*l9_134))*1.0233279))*sc_ShIntensity;
}
#else
{
l9_130=vec3(0.0);
}
#endif
l9_119=l9_130;
}
#endif
vec3 l9_135;
#if (sc_AmbientLightsCount>0)
{
vec3 l9_136;
#if (sc_AmbientLightMode0==sc_AmbientLightMode_Constant)
{
l9_136=l9_119+(sc_AmbientLights[0].color*sc_AmbientLights[0].intensity);
}
#else
{
vec3 l9_137=l9_119;
l9_137.x=l9_119.x+(1e-06*sc_AmbientLights[0].color.x);
l9_136=l9_137;
}
#endif
l9_135=l9_136;
}
#else
{
l9_135=l9_119;
}
#endif
vec3 l9_138;
#if (sc_AmbientLightsCount>1)
{
vec3 l9_139;
#if (sc_AmbientLightMode1==sc_AmbientLightMode_Constant)
{
l9_139=l9_135+(sc_AmbientLights[1].color*sc_AmbientLights[1].intensity);
}
#else
{
vec3 l9_140=l9_135;
l9_140.x=l9_135.x+(1e-06*sc_AmbientLights[1].color.x);
l9_139=l9_140;
}
#endif
l9_138=l9_139;
}
#else
{
l9_138=l9_135;
}
#endif
vec3 l9_141;
#if (sc_AmbientLightsCount>2)
{
vec3 l9_142;
#if (sc_AmbientLightMode2==sc_AmbientLightMode_Constant)
{
l9_142=l9_138+(sc_AmbientLights[2].color*sc_AmbientLights[2].intensity);
}
#else
{
vec3 l9_143=l9_138;
l9_143.x=l9_138.x+(1e-06*sc_AmbientLights[2].color.x);
l9_142=l9_143;
}
#endif
l9_141=l9_142;
}
#else
{
l9_141=l9_138;
}
#endif
vec3 l9_144;
#if (sc_LightEstimation)
{
vec3 l9_145;
l9_145=sc_LightEstimationData.ambientLight;
vec3 l9_146;
int l9_147=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_147<sc_LightEstimationSGCount)
{
float l9_148=dot(sc_LightEstimationData.sg[l9_147].axis,l9_64);
float l9_149=exp(-sc_LightEstimationData.sg[l9_147].sharpness);
float l9_150=l9_149*l9_149;
float l9_151=1.0/sc_LightEstimationData.sg[l9_147].sharpness;
float l9_152=(1.0+(2.0*l9_150))-l9_151;
float l9_153=sqrt(1.0-l9_152);
float l9_154=0.36000001*l9_148;
float l9_155=(1.0/(4.0*0.36000001))*l9_153;
float l9_156=l9_154+l9_155;
float l9_157;
if (step(abs(l9_154),l9_155)>0.5)
{
l9_157=(l9_156*l9_156)/l9_153;
}
else
{
l9_157=clamp(l9_148,0.0,1.0);
}
l9_146=l9_145+((((sc_LightEstimationData.sg[l9_147].color/vec3(sc_LightEstimationData.sg[l9_147].sharpness))*6.2831855)*((l9_152*l9_157)+(((l9_149-l9_150)*l9_151)-l9_150)))/vec3(3.1415927));
l9_145=l9_146;
l9_147++;
continue;
}
else
{
break;
}
}
l9_144=l9_141+l9_145;
}
#else
{
l9_144=l9_141;
}
#endif
float l9_158;
vec3 l9_159;
vec3 l9_160;
vec3 l9_161;
#if (sc_BlendMode_ColoredGlass)
{
l9_161=vec3(0.0);
l9_160=vec3(0.0);
l9_159=ssSRGB_to_Linear(sc_GetFramebufferColor().xyz)*mix(vec3(1.0),l9_67,vec3(Port_Opacity_N049));
l9_158=1.0;
}
#else
{
l9_161=l9_115;
l9_160=l9_144;
l9_159=l9_91;
l9_158=Port_Opacity_N049;
}
#endif
bool l9_162;
#if (sc_BlendMode_PremultipliedAlpha)
{
l9_162=true;
}
#else
{
l9_162=false;
}
#endif
vec3 l9_163=l9_160*l9_66;
vec3 l9_164=l9_161+l9_163;
vec3 l9_165=l9_67*l9_164;
vec3 l9_166=l9_92*vec3(1.0);
vec3 l9_167;
if (l9_162)
{
l9_167=l9_165*srgbToLinear(l9_158);
}
else
{
l9_167=l9_165;
}
vec3 l9_168=l9_167+(vec3(0.0)+l9_166);
vec3 l9_169=(l9_168+l9_65)+l9_159;
float l9_170=l9_169.x;
vec4 l9_171=vec4(l9_170,l9_169.yz,l9_158);
vec4 l9_172;
#if (sc_IsEditor)
{
vec4 l9_173=l9_171;
l9_173.x=l9_170+((l9_66.x*1.0)*9.9999997e-06);
l9_172=l9_173;
}
#else
{
l9_172=l9_171;
}
#endif
vec4 l9_174;
#if (!sc_BlendMode_Multiply)
{
vec3 l9_175=l9_172.xyz*1.8;
vec3 l9_176=(l9_172.xyz*(l9_175+vec3(1.4)))/((l9_172.xyz*(l9_175+vec3(0.5)))+vec3(1.5));
l9_174=vec4(l9_176.x,l9_176.y,l9_176.z,l9_172.w);
}
#else
{
l9_174=l9_172;
}
#endif
vec3 l9_177=vec3(linearToSrgb(l9_174.x),linearToSrgb(l9_174.y),linearToSrgb(l9_174.z));
l9_62=vec4(l9_177.x,l9_177.y,l9_177.z,l9_174.w);
}
#endif
vec4 l9_178=max(l9_62,vec4(0.0));
float l9_179;
#if ((Tweak_N63)==0)
{
vec2 l9_180;
Node256_Switch(0.0,vec2(0.0),vec2(0.0),Port_Default_N256,l9_180,l9_7);
vec2 l9_181=l9_180;
vec2 l9_182;
Node121_Switch(0.0,Port_Value0_N121,vec2(0.0),Port_Default_N121,l9_182,l9_7);
vec2 l9_183=l9_182;
float l9_184;
if (l9_53)
{
l9_184=0.0;
}
else
{
l9_184=pow(Interpolator_gInstanceRatio,Port_Input1_N147);
}
vec2 l9_185=(l9_181*l9_51)+(l9_183*vec2(l9_184));
l9_179=1.0-(floor(((snoise(vec2(floor(l9_185.x*10000.0)*9.9999997e-05,floor(l9_185.y*10000.0)*9.9999997e-05)*(Port_Scale_N437*0.5))*0.5)+0.5)*10000.0)*9.9999997e-05);
}
#else
{
float l9_186;
#if ((Tweak_N63)==1)
{
vec2 l9_187;
Node256_Switch(0.0,vec2(0.0),vec2(0.0),Port_Default_N256,l9_187,l9_7);
vec2 l9_188=l9_187;
int l9_189;
#if (shapeTextureHasSwappedViews)
{
l9_189=1-sc_GetStereoViewIndex();
}
#else
{
l9_189=sc_GetStereoViewIndex();
}
#endif
l9_186=sc_SampleTextureBiasOrLevel(shapeTextureDims.xy,shapeTextureLayout,l9_189,(l9_188*l9_51)+Port_Input1_N115,(int(SC_USE_UV_TRANSFORM_shapeTexture)!=0),shapeTextureTransform,ivec2(SC_SOFTWARE_WRAP_MODE_U_shapeTexture,SC_SOFTWARE_WRAP_MODE_V_shapeTexture),(int(SC_USE_UV_MIN_MAX_shapeTexture)!=0),shapeTextureUvMinMax,(int(SC_USE_CLAMP_TO_BORDER_shapeTexture)!=0),shapeTextureBorderColor,0.0,shapeTexture).x;
}
#else
{
l9_186=Port_Default_N064;
}
#endif
l9_179=l9_186;
}
#endif
float l9_190;
if (l9_179<=0.0)
{
l9_190=0.0;
}
else
{
l9_190=pow(l9_179,Interpolator_gInstanceRatio*(Port_Input0_N143/(fluffy+1.234e-06)));
}
float l9_191=l9_190+(Interpolator_gInstanceRatio*((Port_Value_N054+0.001)-0.001));
float l9_192=1.0-Interpolator_gInstanceRatio;
float l9_193=clamp(l9_17+0.001,Port_Input1_N138+0.001,Port_Input2_N138+0.001)-0.001;
float l9_194;
if (l9_193<=0.0)
{
l9_194=0.0;
}
else
{
l9_194=pow(l9_193,featheredSmallHairs);
}
float l9_195=(l9_192*hairTransparency)*l9_194;
float l9_196=float(l9_191>Interpolator_gInstanceRatio)*(l9_195*(1.0-(l9_192*((1.0-clamp(l9_17,Port_Input1_N206,Port_Input2_N206))*featheredSmallHairs))));
vec4 l9_197=vec4(l9_178.x,l9_178.y,l9_178.z,vec4(0.0).w);
l9_197.w=l9_196;
bool l9_198=(float(l9_196<Port_Input1_N048)*1.0)!=0.0;
bool l9_199;
if (!l9_198)
{
l9_199=(float(l9_15<cutoff)*1.0)!=0.0;
}
else
{
l9_199=l9_198;
}
if ((float(l9_199)*1.0)!=0.0)
{
discard;
}
vec4 l9_200;
#if (sc_ProjectiveShadowsCaster)
{
float l9_201;
#if (((sc_BlendMode_Normal||sc_BlendMode_AlphaToCoverage)||sc_BlendMode_PremultipliedAlphaHardware)||sc_BlendMode_PremultipliedAlphaAuto)
{
l9_201=l9_196;
}
#else
{
float l9_202;
#if (sc_BlendMode_PremultipliedAlpha)
{
l9_202=clamp(l9_196*2.0,0.0,1.0);
}
#else
{
float l9_203;
#if (sc_BlendMode_AddWithAlphaFactor)
{
l9_203=clamp(dot(l9_197.xyz,vec3(l9_196)),0.0,1.0);
}
#else
{
float l9_204;
#if (sc_BlendMode_AlphaTest)
{
l9_204=1.0;
}
#else
{
float l9_205;
#if (sc_BlendMode_Multiply)
{
l9_205=(1.0-dot(l9_197.xyz,vec3(0.33333001)))*l9_196;
}
#else
{
float l9_206;
#if (sc_BlendMode_MultiplyOriginal)
{
l9_206=(1.0-clamp(dot(l9_197.xyz,vec3(1.0)),0.0,1.0))*l9_196;
}
#else
{
float l9_207;
#if (sc_BlendMode_ColoredGlass)
{
l9_207=clamp(dot(l9_197.xyz,vec3(1.0)),0.0,1.0)*l9_196;
}
#else
{
float l9_208;
#if (sc_BlendMode_Add)
{
l9_208=clamp(dot(l9_197.xyz,vec3(1.0)),0.0,1.0);
}
#else
{
float l9_209;
#if (sc_BlendMode_AddWithAlphaFactor)
{
l9_209=clamp(dot(l9_197.xyz,vec3(1.0)),0.0,1.0)*l9_196;
}
#else
{
float l9_210;
#if (sc_BlendMode_Screen)
{
l9_210=dot(l9_197.xyz,vec3(0.33333001))*l9_196;
}
#else
{
float l9_211;
#if (sc_BlendMode_Min)
{
l9_211=1.0-clamp(dot(l9_197.xyz,vec3(1.0)),0.0,1.0);
}
#else
{
float l9_212;
#if (sc_BlendMode_Max)
{
l9_212=clamp(dot(l9_197.xyz,vec3(1.0)),0.0,1.0);
}
#else
{
l9_212=1.0;
}
#endif
l9_211=l9_212;
}
#endif
l9_210=l9_211;
}
#endif
l9_209=l9_210;
}
#endif
l9_208=l9_209;
}
#endif
l9_207=l9_208;
}
#endif
l9_206=l9_207;
}
#endif
l9_205=l9_206;
}
#endif
l9_204=l9_205;
}
#endif
l9_203=l9_204;
}
#endif
l9_202=l9_203;
}
#endif
l9_201=l9_202;
}
#endif
l9_200=vec4(mix(sc_ShadowColor.xyz,sc_ShadowColor.xyz*l9_197.xyz,vec3(sc_ShadowColor.w)),sc_ShadowDensity*l9_201);
}
#else
{
vec4 l9_213;
#if (sc_RenderAlphaToColor)
{
l9_213=vec4(l9_196);
}
#else
{
vec4 l9_214;
#if (sc_BlendMode_Custom)
{
vec3 l9_215=sc_GetFramebufferColor().xyz;
vec3 l9_216=mix(l9_215,definedBlend(l9_215,l9_197.xyz).xyz,vec3(l9_196));
vec4 l9_217=vec4(l9_216.x,l9_216.y,l9_216.z,vec4(0.0).w);
l9_217.w=1.0;
l9_214=l9_217;
}
#else
{
vec4 l9_218;
#if (sc_BlendMode_MultiplyOriginal)
{
l9_218=vec4(mix(vec3(1.0),l9_197.xyz,vec3(l9_196)),l9_196);
}
#else
{
vec4 l9_219;
#if (sc_BlendMode_Screen||sc_BlendMode_PremultipliedAlphaAuto)
{
float l9_220;
#if (sc_BlendMode_PremultipliedAlphaAuto)
{
l9_220=clamp(l9_196,0.0,1.0);
}
#else
{
l9_220=l9_196;
}
#endif
l9_219=vec4(l9_197.xyz*l9_220,l9_220);
}
#else
{
l9_219=l9_197;
}
#endif
l9_218=l9_219;
}
#endif
l9_214=l9_218;
}
#endif
l9_213=l9_214;
}
#endif
l9_200=l9_213;
}
#endif
vec4 l9_221;
if (PreviewEnabled==1)
{
vec4 l9_222;
if (((PreviewVertexSaved*1.0)!=0.0) ? true : false)
{
l9_222=PreviewVertexColor;
}
else
{
l9_222=vec4(0.0);
}
l9_221=l9_222;
}
else
{
l9_221=l9_200;
}
vec4 l9_223;
#if (sc_ShaderComplexityAnalyzer)
{
l9_223=vec4(shaderComplexityValue/255.0,0.0,0.0,1.0);
}
#else
{
l9_223=vec4(0.0);
}
#endif
vec4 l9_224;
if (l9_223.w>0.0)
{
l9_224=l9_223;
}
else
{
l9_224=l9_221;
}
vec4 l9_225=outputMotionVectorsIfNeeded(varPos,max(l9_224,vec4(0.0)));
vec4 l9_226=clamp(l9_225,vec4(0.0),vec4(1.0));
#if (sc_OITDepthBoundsPass)
{
#if (sc_OITDepthBoundsPass)
{
float l9_227=clamp(viewSpaceDepth()/1000.0,0.0,1.0);
sc_writeFragData0(vec4(max(0.0,1.0-(l9_227-0.0039215689)),min(1.0,l9_227+0.0039215689),0.0,0.0));
}
#endif
}
#else
{
#if (sc_OITDepthPrepass)
{
sc_writeFragData0(vec4(1.0));
}
#else
{
#if (sc_OITDepthGatherPass)
{
#if (sc_OITDepthGatherPass)
{
vec2 l9_228=sc_ScreenCoordsGlobalToView((gl_FragCoord.xy*sc_WindowToViewportTransform.xy)+sc_WindowToViewportTransform.zw);
#if (sc_OITMaxLayers4Plus1)
{
if ((gl_FragCoord.z-texture2D(sc_OITFrontDepthTexture,l9_228).x)<=getFrontLayerZTestEpsilon())
{
discard;
}
}
#endif
int l9_229=encodeDepth(viewSpaceDepth(),texture2D(sc_OITFilteredDepthBoundsTexture,l9_228).xy);
float l9_230=packValue(l9_229);
int l9_237=int(l9_226.w*255.0);
float l9_238=packValue(l9_237);
sc_writeFragData0(vec4(packValue(l9_229),packValue(l9_229),packValue(l9_229),packValue(l9_229)));
sc_writeFragData1(vec4(l9_230,packValue(l9_229),packValue(l9_229),packValue(l9_229)));
sc_writeFragData2(vec4(l9_238,packValue(l9_237),packValue(l9_237),packValue(l9_237)));
#if (sc_OITMaxLayersVisualizeLayerCount)
{
sc_writeFragData2(vec4(0.0039215689,0.0,0.0,0.0));
}
#endif
}
#endif
}
#else
{
#if (sc_OITCompositingPass)
{
#if (sc_OITCompositingPass)
{
vec2 l9_241=sc_ScreenCoordsGlobalToView((gl_FragCoord.xy*sc_WindowToViewportTransform.xy)+sc_WindowToViewportTransform.zw);
#if (sc_OITMaxLayers4Plus1)
{
if ((gl_FragCoord.z-texture2D(sc_OITFrontDepthTexture,l9_241).x)<=getFrontLayerZTestEpsilon())
{
discard;
}
}
#endif
int l9_242[8];
int l9_243[8];
int l9_244=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_244<8)
{
l9_242[l9_244]=0;
l9_243[l9_244]=0;
l9_244++;
continue;
}
else
{
break;
}
}
int l9_245;
#if (sc_OITMaxLayers8)
{
l9_245=2;
}
#else
{
l9_245=1;
}
#endif
int l9_246=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_246<l9_245)
{
vec4 l9_247;
vec4 l9_248;
vec4 l9_249;
if (l9_246==0)
{
l9_249=texture2D(sc_OITAlpha0,l9_241);
l9_248=texture2D(sc_OITDepthLow0,l9_241);
l9_247=texture2D(sc_OITDepthHigh0,l9_241);
}
else
{
l9_249=vec4(0.0);
l9_248=vec4(0.0);
l9_247=vec4(0.0);
}
vec4 l9_250;
vec4 l9_251;
vec4 l9_252;
if (l9_246==1)
{
l9_252=texture2D(sc_OITAlpha1,l9_241);
l9_251=texture2D(sc_OITDepthLow1,l9_241);
l9_250=texture2D(sc_OITDepthHigh1,l9_241);
}
else
{
l9_252=l9_249;
l9_251=l9_248;
l9_250=l9_247;
}
if (any(notEqual(l9_250,vec4(0.0)))||any(notEqual(l9_251,vec4(0.0))))
{
int l9_253[8]=l9_242;
unpackValues(l9_250.w,l9_246,l9_253);
unpackValues(l9_250.z,l9_246,l9_253);
unpackValues(l9_250.y,l9_246,l9_253);
unpackValues(l9_250.x,l9_246,l9_253);
unpackValues(l9_251.w,l9_246,l9_253);
unpackValues(l9_251.z,l9_246,l9_253);
unpackValues(l9_251.y,l9_246,l9_253);
unpackValues(l9_251.x,l9_246,l9_253);
int l9_262[8]=l9_243;
unpackValues(l9_252.w,l9_246,l9_262);
unpackValues(l9_252.z,l9_246,l9_262);
unpackValues(l9_252.y,l9_246,l9_262);
unpackValues(l9_252.x,l9_246,l9_262);
}
l9_246++;
continue;
}
else
{
break;
}
}
vec4 l9_267=texture2D(sc_OITFilteredDepthBoundsTexture,l9_241);
vec2 l9_268=l9_267.xy;
int l9_269;
#if (sc_SkinBonesCount>0)
{
l9_269=encodeDepth(((1.0-l9_267.x)*1000.0)+getDepthOrderingEpsilon(),l9_268);
}
#else
{
l9_269=0;
}
#endif
int l9_270=encodeDepth(viewSpaceDepth(),l9_268);
vec4 l9_271;
l9_271=l9_226*l9_226.w;
vec4 l9_272;
int l9_273=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_273<8)
{
int l9_274=l9_242[l9_273];
int l9_275=l9_270-l9_269;
bool l9_276=l9_274<l9_275;
bool l9_277;
if (l9_276)
{
l9_277=l9_242[l9_273]>0;
}
else
{
l9_277=l9_276;
}
if (l9_277)
{
vec3 l9_278=l9_271.xyz*(1.0-(float(l9_243[l9_273])/255.0));
l9_272=vec4(l9_278.x,l9_278.y,l9_278.z,l9_271.w);
}
else
{
l9_272=l9_271;
}
l9_271=l9_272;
l9_273++;
continue;
}
else
{
break;
}
}
sc_writeFragData0(l9_271);
#if (sc_OITMaxLayersVisualizeLayerCount)
{
discard;
}
#endif
}
#endif
}
#else
{
#if (sc_OITFrontLayerPass)
{
#if (sc_OITFrontLayerPass)
{
if (abs(gl_FragCoord.z-texture2D(sc_OITFrontDepthTexture,sc_ScreenCoordsGlobalToView((gl_FragCoord.xy*sc_WindowToViewportTransform.xy)+sc_WindowToViewportTransform.zw)).x)>getFrontLayerZTestEpsilon())
{
discard;
}
sc_writeFragData0(l9_226);
}
#endif
}
#else
{
sc_writeFragData0(l9_225);
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif // #elif defined FRAGMENT_SHADER // #if defined VERTEX_SHADER

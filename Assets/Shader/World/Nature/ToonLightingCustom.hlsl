//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

void GetLight_float(float3 WorldPos, out float3 Direction, out float3 Color, out float Attenuation)
{

#if defined( SHADERGRAPH_PREVIEW)
    Direction = float3(0.5, 0.5, 0.0);
    Color = 1;
    Attenuation = 1;

#else
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    Attenuation = mainLight.shadowAttenuation;
#endif


}


//This shader func is intended to return a radial fall off from a centre point.
void GetFalloff_float(float3 WorldPos, float3 CentrePoint, float MaxRadius, out float Falloff)
{
#if defined(SHADERGRAPH_PREVIEW)
    Falloff = 1.0;
#else
    float dist = distance(WorldPos, CentrePoint);
    //Falloff = saturate(1 - dist / MaxRadius); //This is a linear line.
    Falloff = smoothstep(MaxRadius, 0.0, dist); //Smooth gradient
#endif
}


//void GetLight_float(float3 WorldPos, out float3 Direction, out float3 Color, out float Attenuation)
//{
//
//#if defined( SHADERGRAPH_PREVIEW)
//    Direction = float3(0.5, 0.5, 0.0);
//    Color = 1;
//    Attenuation = 1;
//
//#else
//    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
//    Light mainLight = GetMainLight(shadowCoord);
//    Direction = mainLight.direction;
//    Color = mainLight.color;
//    Attenuation = mainLight.shadowAttenuation;
//#endif
//
//}
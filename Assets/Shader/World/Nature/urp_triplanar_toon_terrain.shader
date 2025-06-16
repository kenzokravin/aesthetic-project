Shader "Custom/URP/TriplanarToonTerrain"
{
    Properties
    {
        _TopTex("Top Texture", 2D) = "white" {}
        _TopSecondaryTex("Top Secondary Texture", 2D) = "white" {}
        _SideTex("Side Texture", 2D) = "white" {}
        _Control("Control Map", 2D) = "red" {}
        _Splat0("Splat 0", 2D) = "white" {}
        _Splat1("Splat 1", 2D) = "white" {}
        _Splat2("Splat 2", 2D) = "white" {}
        _Splat3("Splat 3", 2D) = "white" {}

        _NoiseTex("Noise", 2D) = "white" {}
        _NoiseTexTwo("Noise 2", 2D) = "white" {}

        _Color("Color Tint", Color) = (1,1,1,1)
        _TexturePrimScale("Primary Tex Scale", Float) = 2
        _TextureScale("Noise Tex Scale", Float) = 10
        _RotationDegrees("Secondary Tex Rotation", Float) = 70
        _SideScale("Side Scale", Float) = 0.5
        _TextureStep("Texture Step", Float) = 10
        _TexturePaintStep("Splat Paint Power", Float) = 10
        _UVDistortionStrength("UV Distortion", Float) = 0.05
        _UVDistortionStrengthTwo("UV Distortion 2", Float) = 0.05
        _NoiseScale("Noise Scale", Float) = 0.5
        _NoiseScaleTwo("Noise 2 Scale", Float) = 0.5

        _LightRamp("Toon Ramp", Float) = 0.5
        _ShadowStrength("Shadow Strength", Float) = 0.7
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos    : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv          : TEXCOORD2;
                float4 shadowCoord : TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _TexturePrimScale;
                float _TextureScale;
                float _RotationDegrees;
                float _SideScale;
                float _TextureStep;
                float _TexturePaintStep;
                float _UVDistortionStrength;
                float _UVDistortionStrengthTwo;
                float _NoiseScale;
                float _NoiseScaleTwo;
                float _LightRamp;
                float _ShadowStrength;
            CBUFFER_END

            TEXTURE2D(_TopTex);            SAMPLER(sampler_TopTex);
            TEXTURE2D(_TopSecondaryTex);   SAMPLER(sampler_TopSecondaryTex);
            TEXTURE2D(_SideTex);           SAMPLER(sampler_SideTex);
            TEXTURE2D(_Control);           SAMPLER(sampler_Control);
            TEXTURE2D(_Splat0);            SAMPLER(sampler_Splat0);
            TEXTURE2D(_Splat1);            SAMPLER(sampler_Splat1);
            TEXTURE2D(_Splat2);            SAMPLER(sampler_Splat2);
            TEXTURE2D(_Splat3);            SAMPLER(sampler_Splat3);
            TEXTURE2D(_NoiseTex);          SAMPLER(sampler_NoiseTex);
            TEXTURE2D(_NoiseTexTwo);       SAMPLER(sampler_NoiseTexTwo);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.worldNormal = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionHCS = TransformWorldToHClip(OUT.worldPos);
                OUT.uv = IN.uv;
                OUT.shadowCoord = TransformWorldToShadowCoord(OUT.worldPos);
                return OUT;
            }

            float2 RotateUV(float2 uv, float angleDeg)
            {
                float angleRad = radians(angleDeg);
                float s = sin(angleRad);
                float c = cos(angleRad);
                float2x2 rot = float2x2(c, -s, s, c);
                return mul(rot, uv - 0.5) + 0.5;
            }

            float3 Triplanar(Texture2D tex, float3 worldPos, float3 normal, SamplerState samp)
            {
                float3 blend = pow(abs(normal), _TextureStep);
                blend /= dot(blend, 1.0);
                float3 x = tex.Sample(samp, worldPos.zy).rgb;
                float3 y = tex.Sample(samp, worldPos.xz).rgb;
                float3 z = tex.Sample(samp, worldPos.xy).rgb;
                return x * blend.x + y * blend.y + z * blend.z;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normal = normalize(IN.worldNormal);
                float3 blends = abs(normal);

                float topRaw = pow(blends.y, _TextureStep);
                float sideRaw = pow(blends.x + blends.z, _TextureStep);
                float total = topRaw + sideRaw + 1e-5;
                float topBlend = topRaw / total;
                float sideBlend = sideRaw / total;

                float2 noiseUV = IN.worldPos.xz * _NoiseScale;
                float2 noiseSample = _NoiseTex.Sample(sampler_NoiseTex, noiseUV).rg * 2.0 - 1.0;
                float2 noiseUV2 = IN.worldPos.xz * _NoiseScaleTwo;
                float2 noiseSample2 = _NoiseTexTwo.Sample(sampler_NoiseTexTwo, noiseUV2).rg * 2.0 - 1.0;

                float2 distortedTopUV = IN.worldPos.xz * _TexturePrimScale;
                float2 distortedTopSecUV = IN.worldPos.xz * _TextureScale + noiseSample * _UVDistortionStrength;
                float2 distortedTopThirdUV = IN.worldPos.xz * _TextureScale + noiseSample2 * _UVDistortionStrengthTwo;

                float2 rotatedUV = RotateUV(distortedTopSecUV, _RotationDegrees);

                float3 top = _TopTex.Sample(sampler_TopTex, distortedTopUV).rgb;
                float3 top2 = _TopSecondaryTex.Sample(sampler_TopSecondaryTex, rotatedUV).rgb;
                float3 top3 = _TopTex.Sample(sampler_TopTex, distortedTopThirdUV).rgb;

                float noiseBlend1 = _NoiseTex.Sample(sampler_NoiseTex, IN.worldPos.xz * (_NoiseScale * 0.5)).r;
                float3 mixTop = lerp(top, top3, noiseBlend1);
                float noiseBlend2 = _NoiseTexTwo.Sample(sampler_NoiseTexTwo, IN.worldPos.xz * (_NoiseScaleTwo * 0.5)).r;
                float3 topFinal = lerp(mixTop, top2, noiseBlend2);

                float2 sideUV = IN.worldPos.xy * _SideScale;
                float3 side = _SideTex.Sample(sampler_SideTex, sideUV).rgb;

                float3 baseColor = lerp(side, topFinal, topBlend);

                float4 control = _Control.Sample(sampler_Control, IN.uv);

                float3 splat0 = _Splat0.Sample(sampler_Splat0, IN.uv).rgb;
                float3 splat1 = _Splat1.Sample(sampler_Splat1, IN.uv).rgb;
                float3 splat2 = _Splat2.Sample(sampler_Splat2, IN.uv).rgb;
                float3 splat3 = _Splat3.Sample(sampler_Splat3, IN.uv).rgb;

                float r = pow(control.r, _TexturePaintStep);
                float g = pow(control.g, _TexturePaintStep);
                float b = pow(control.b, _TexturePaintStep);
                float a = pow(control.a, _TexturePaintStep);

                float sum = r + g + b + a + 1e-5;
                r /= sum; g /= sum; b /= sum; a /= sum;

                float3 splatColor = baseColor * r + splat1 * g + splat2 * b + splat3 * a;
                float3 finalColor = lerp(baseColor, splatColor, saturate(control.r + control.g + control.b + control.a));

                Light mainLight = GetMainLight(IN.shadowCoord);
                float NdotL = saturate(dot(normal, mainLight.direction));
                float diff = step(0.5, NdotL);
                float fakeShadow = lerp(_ShadowStrength, 1.0, diff);
                float realShadow = lerp(_ShadowStrength, 1.0, mainLight.shadowAttenuation);
                float lighting = fakeShadow * realShadow * _LightRamp;

                float3 litColor = finalColor * mainLight.color.rgb * lighting * _Color.rgb;
                return float4(litColor, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack Off
}

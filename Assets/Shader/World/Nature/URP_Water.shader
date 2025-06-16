Shader "Custom/URPToonWater"
{
    Properties
    {
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Max Distance", Float) = 1

        _FoamColor("Foam Color", Color) = (1,1,1,1)
        _FoamColor2("Foam Secondary Color", Color) = (1,1,1,1)
        _EdgeFoamColour("Edge Foam Color", Color) = (1,1,1,1)
        _EdgeFoamThresh("Edge Foam Threshold", Float) = 0.5
        _FoamCutoff("Foam Cutoff", Float) = 0.05
        _FoamMaxDistance("Foam Max Distance", Float) = 0.4
        _FoamMinDistance("Foam Min Distance", Float) = 0.04

        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseScroll("Noise Scroll", Vector) = (0.03, 0.03, 0, 0)
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0,1)) = 0.777

        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        _SurfaceDistortionAmount("Distortion Amount", Range(0,1)) = 0.27

        _WaveAmp("Wave Amplitude", Range(0,1)) = 0.27
        _WaveFreq("Wave Frequency", Range(0,100)) = 0.27
        _Direction("Wave Direction", Vector) = (1,0,0,0)

        _ReflectionTex("Reflection Texture", 2D) = "black" {}
        _ReflectionStrength("Reflection Strength", Range(0,1)) = 0.5

        _RippleTex("Ripple Texture", 2D) = "black" {}
        _RippleSpeed("Ripple Speed", Float) = 2
        _RippleScale("Ripple Scale", Float) = 0.1
        _RippleLifetime("Ripple Lifetime", Float) = 2

        [HideInInspector] _MainTex("Base (RGB)", 2D) = "white" {}
    }

        SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 300
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _DepthGradientShallow;
                float4 _DepthGradientDeep;
                float _DepthMaxDistance;

                float4 _FoamColor;
                float4 _FoamColor2;
                float4 _EdgeFoamColour;
                float _EdgeFoamThresh;
                float _FoamCutoff;
                float _FoamMaxDistance;
                float _FoamMinDistance;

                float _WaveAmp;
                float _WaveFreq;
                float4 _Direction;

                float2 _SurfaceNoiseScroll;
                float _SurfaceNoiseCutoff;

                float _SurfaceDistortionAmount;
                float _ReflectionStrength;

                float _RippleSpeed;
                float _RippleScale;
                float _RippleLifetime;
            CBUFFER_END

            TEXTURE2D(_SurfaceNoise);       SAMPLER(sampler_SurfaceNoise);
            TEXTURE2D(_SurfaceDistortion);  SAMPLER(sampler_SurfaceDistortion);
            TEXTURE2D(_ReflectionTex);      SAMPLER(sampler_ReflectionTex);
            TEXTURE2D(_RippleTex);          SAMPLER(sampler_RippleTex);
            TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);

            Varyings vert(Attributes v)
            {
                Varyings o;
                float3 dir = normalize(_Direction.xyz);

                float defaultWavelength = 6.2831; // 2*PI
                float waveLength = defaultWavelength / _WaveFreq;
                float phase = sqrt(9.8 / waveLength);
                float disp = waveLength * (dot(dir, v.positionOS.xyz) - (phase * _Time.y));
                v.positionOS.y += _WaveAmp * sin(disp);

                float4 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                o.worldPos = worldPos.xyz;
                o.worldNormal = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.positionHCS = TransformWorldToHClip(worldPos.xyz);
                o.screenPos = ComputeScreenPos(o.positionHCS);
                o.uv = v.uv;

                UNITY_TRANSFER_FOG(o, o.positionHCS);
                return o;
            }

            float4 frag(Varyings i) : SV_Target
            {
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float existingDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
                float sceneZ = LinearEyeDepth(existingDepth, _ZBufferParams);
                float waterZ = i.screenPos.w;
                float depthDiff = sceneZ - waterZ;
                float depthLerp = saturate(depthDiff / _DepthMaxDistance);
                float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, depthLerp);

                // Foam from normal + depth variation
                float3 normal = i.worldNormal;
                float foamAmount = smoothstep(_FoamMinDistance, _FoamMaxDistance, depthDiff);
                foamAmount *= saturate(dot(normal, float3(0, 1, 0)));

                float surfaceNoise = SAMPLE_TEXTURE2D(_SurfaceNoise, sampler_SurfaceNoise,
                    i.uv + _SurfaceNoiseScroll * _Time.y).r;

                float cutoffNoise = step(_SurfaceNoiseCutoff, surfaceNoise);
                float4 foamCol = _FoamColor * cutoffNoise;
                foamCol.a *= cutoffNoise;

                float4 reflectionCol = SAMPLE_TEXTURE2D(_ReflectionTex, sampler_ReflectionTex, screenUV);
                float4 surfaceCol = lerp(waterColor, reflectionCol, _ReflectionStrength);

                float4 finalCol = foamCol + surfaceCol * (1.0 - foamCol.a);

                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }

            ENDHLSL
        }
    }
        FallBack "Hidden/Universal Render Pipeline/FallbackError"
}

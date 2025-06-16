Shader "Toon/ToonWindDisplacedWithShadows"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _RampThreshold("Ramp Threshold", Range(0,1)) = 0.5

        _WindDirection("Wind Direction", Vector) = (1,0,0,0)
        _WindSpeed("Wind Speed", Float) = 1.0
        _WindFrequency("Wind Frequency", Float) = 1.0
        _WindAmplitude("Wind Amplitude", Float) = 0.1
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200
            Pass
            {
                Tags { "LightMode" = "ForwardBase" }

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase
                #pragma multi_compile_shadowcaster
                #include "UnityCG.cginc"
                #include "Lighting.cginc"
                #include "AutoLight.cginc"

                sampler2D _MainTex;
                float4 _Color;
                float _RampThreshold;

                float4 _WindDirection;
                float _WindSpeed;
                float _WindFrequency;
                float _WindAmplitude;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 worldNormal : TEXCOORD1;
                    float3 worldPos : TEXCOORD2;
                    float4 shadowCoord : TEXCOORD3;
                };

                float3 ApplyWind(float3 worldPos)
                {
                    float3 windDir = normalize(_WindDirection.xyz);
                    float phase = dot(worldPos.xz, windDir.xz) * _WindFrequency + _Time.y * _WindSpeed;
                    return worldPos + windDir * (sin(phase) * _WindAmplitude);
                }

                v2f vert(appdata v)
                {
                    v2f o;
                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    worldPos = ApplyWind(worldPos);

                    o.worldPos = worldPos;
                    o.worldNormal = normalize(mul(v.normal, (float3x3)unity_ObjectToWorld));
                    o.uv = v.uv;
                    o.pos = UnityObjectToClipPos(float4(worldPos, 1));
                   // o.shadowCoord = UnityWorldSpaceLightDir(worldPos) * 0.5 + 0.5;
                    o.shadowCoord = mul(unity_WorldToShadow[0], float4(worldPos, 1.0)); // <-- Correct way
                    //TRANSFER_SHADOW(o)
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // Sample shadow
                   float shadow = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, i.shadowCoord);

                // Optional soft shadow attenuation
                float atten = UnitySampleShadowmap(i.shadowCoord);

                // Lighting
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = max(0, dot(i.worldNormal, lightDir));

                float3 albedo = tex2D(_MainTex, i.uv).rgb;

                float3 color = albedo * _LightColor0.rgb * NdotL * atten;

                return float4(color, 1);
                }
                ENDCG
            }

            // Shadow caster pass (to match displaced mesh)
            Pass
            {
                Name "ShadowCaster"
                Tags { "LightMode" = "ShadowCaster" }

                ZWrite On
                ZTest LEqual
                Cull Back

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_shadowcaster
                #include "UnityCG.cginc"

                float4 _WindDirection;
                float _WindSpeed;
                float _WindFrequency;
                float _WindAmplitude;

                struct appdata
                {
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                };

                float3 ApplyWind(float3 worldPos)
                {
                    float3 windDir = normalize(_WindDirection.xyz);
                    float phase = dot(worldPos.xz, windDir.xz) * _WindFrequency + _Time.y * _WindSpeed;
                    return worldPos + windDir * (sin(phase) * _WindAmplitude);
                }

                v2f vert(appdata v)
                {
                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    worldPos = ApplyWind(worldPos);

                    v2f o;
                    o.pos = UnityObjectToClipPos(float4(worldPos, 1));
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    return 0;
                }
                ENDCG
            }
        }

            FallBack "Diffuse"
}

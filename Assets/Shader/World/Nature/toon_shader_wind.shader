Shader "Custom/ToonWindLit"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color Tint", Color) = (1,1,1,1)

        _WindDirection("Wind Direction", Vector) = (1, 0, 0, 0)
        _WindSpeed("Wind Speed", Float) = 1.0
        _WindFrequency("Wind Frequency", Float) = 2.0
        _WindAmplitude("Wind Amplitude", Float) = 0.1
        _WindHeightFactor("Wind Height Factor", Float) = 1.0
        _TrunkHeight("Trunk Height", Float) = 1.0

        _RampThreshold("Toon Ramp Threshold", Range(0,1)) = 0.5
        _ShadowStrength("Shadow Strength", Range(0,1)) = 0.7
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf ToonRamp vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;

        float4 _WindDirection;
        float _WindSpeed;
        float _WindFrequency;
        float _WindAmplitude;
        float _WindHeightFactor;
        float _TrunkHeight;

        float _RampThreshold;
        float _ShadowStrength;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float4 shadowCoord : TEXCOORD1;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float3 objPos = v.vertex.xyz;
            float3 worldPos = mul(unity_ObjectToWorld, float4(objPos, 1.0)).xyz;

            float heightFactor = saturate((worldPos.y - _TrunkHeight) * _WindHeightFactor);
            float phase = _Time.y * _WindSpeed + dot(worldPos.xz, normalize(_WindDirection.xz)) * _WindFrequency;
            float windOffset = sin(phase) * _WindAmplitude * heightFactor;
            float3 windDir = normalize(_WindDirection.xyz);

            worldPos.xz += windDir.xz * windOffset;
            float4 displaced = mul(unity_WorldToObject, float4(worldPos, 1.0));
            v.vertex.xyz = displaced.xyz;

            o.worldPos = worldPos;
            TRANSFER_SHADOW(o);
        }

        inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            float ndotl = dot(s.Normal, lightDir);
            float lit = step(_RampThreshold, ndotl);
            float shadow = lerp(_ShadowStrength, 1.0, atten);

            half3 color = s.Albedo * _LightColor0.rgb * lit * shadow;
            return half4(color, 1.0);
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = tex.rgb;
            o.Alpha = tex.a;
        }
        ENDCG

        // ShadowCaster pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            float4 _WindDirection;
            float _WindSpeed;
            float _WindFrequency;
            float _WindAmplitude;
            float _WindHeightFactor;
            float _TrunkHeight;

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float heightFactor = saturate((worldPos.y - _TrunkHeight) * _WindHeightFactor);
                float phase = _Time.y * _WindSpeed + dot(worldPos.xz, normalize(_WindDirection.xz)) * _WindFrequency;
                float windOffset = sin(phase) * _WindAmplitude * heightFactor;
                worldPos.xz += normalize(_WindDirection.xz) * windOffset;

                v2f o;
                o.pos = UnityObjectToClipPos(float4(worldPos, 1.0));
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                return 0;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

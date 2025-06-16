Shader "Custom/WindOpaqueSurface"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _WindDirection("Wind Direction", Vector) = (1, 0, 0, 0)
        _WindSpeed("Wind Speed", Float) = 1.0
        _WindFrequency("Wind Frequency", Float) = 2.0
        _WindAmplitude("Wind Amplitude", Float) = 0.1
        _WindHeightFactor("Wind Height Factor", Float) = 1.0
        _TrunkHeight("Trunk Height Min", Float) = 1.0
        _LightRamp("Light Ramp", Range(0,1)) = 0.5
        _ShadowStrength("Shadow Strength", Range(0,1)) = 0.7
    }

        SubShader
        {
            Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }

            Cull Back
            ZWrite On


            //  Surface Shader
            CGPROGRAM
            #pragma surface surf ToonRamp vertex:vert noshadow
            #pragma target 3.0

       

            sampler2D _MainTex;
            fixed4 _Color;

            float4 _WindDirection;
            float _WindSpeed;
            float _WindFrequency;
            float _WindAmplitude;
            float _WindHeightFactor;
            float _TrunkHeight;

            float _LightRamp;
            float _ShadowStrength;

            inline float4 LightingToonRamp(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
            {
                float NdotL = dot(s.Normal, lightDir);
                float diff = step(0.5, NdotL);
                float fakeSelfShadow = lerp(_ShadowStrength, 1.0, diff);
                float shadowStep = step(0.5, atten);
                float realShadow = lerp(_ShadowStrength, 1.0, shadowStep);
                float lightingFactor = fakeSelfShadow * realShadow;

                float3 col = s.Albedo * _LightColor0.rgb * (lightingFactor * _LightRamp);
                return float4(col, 1.0);
            }

            struct Input
            {
                float2 uv_MainTex;
            };

            void vert(inout appdata_full v) 
            {
                float3 objPos = v.vertex.xyz;
                float3 worldPos = mul(unity_ObjectToWorld, float4(objPos, 1.0)).xyz; //Getting world coord of vertex

                float worldHeight = worldPos.y; //Getting world height of vertex.
                float3 windDir = normalize(_WindDirection.xyz);

                float windPhase = _Time.y * _WindSpeed + dot(worldPos.xz, windDir.xz) * _WindFrequency;
                float windStrength = saturate((worldHeight - _TrunkHeight) * _WindHeightFactor);
                float windOffset = sin(windPhase) * _WindAmplitude * windStrength;

                objPos.xz += windDir.xz * windOffset;
                objPos += windDir * 0.001;
               // objPos += float3(0, 0.5, 0); // Raise all vertices for test
                v.vertex.xyz = objPos;
            }

            void surf(Input IN, inout SurfaceOutput o)
            {
                fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = tex.rgb;
                o.Alpha = tex.a;
            }

          
            ENDCG

                // Manual ShadowCaster Pass (now outside CGPROGRAM block above)
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

                    struct appdata
                    {
                        float4 vertex : POSITION;
                    };

                    struct v2f
                    {
                        float4 pos : SV_POSITION;
                    };

                    v2f vert(appdata v)
                    {
                        //float3 objPos = v.vertex.xyz;
                        //float3 worldPos = mul(unity_ObjectToWorld, float4(objPos, 1.0)).xyz; //Getting world coord of vertex

                        //float worldHeight = worldPos.y; //Getting world height of vertex.
                        //float3 windDir = normalize(_WindDirection.xyz);

                        //float windPhase = _Time.y * _WindSpeed + dot(worldPos.xz, windDir.xz) * _WindFrequency;
                        //float windStrength = saturate((worldHeight - _TrunkHeight) * _WindHeightFactor);
                        //float windOffset = sin(windPhase) * _WindAmplitude * windStrength;

                        //objPos.xz += windDir.xz * windOffset;
                        //v.vertex.xyz = objPos;


                        //--------------
                        float3 objPos = v.vertex.xyz;
                        float3 worldPos = mul(unity_ObjectToWorld, float4(objPos, 1.0)).xyz;

                        float worldHeight = worldPos.y;
                        float3 windDir = normalize(_WindDirection.xyz);

                        float windPhase = _Time.y * _WindSpeed + dot(worldPos.xz, windDir.xz) * _WindFrequency;
                        float windStrength = saturate((worldHeight - _TrunkHeight) * _WindHeightFactor);
                        float windOffset = sin(windPhase) * _WindAmplitude * windStrength;

                        objPos.xz += windDir.xz * windOffset;

                        // DEBUG: artificially expand bounds in vertex shader
                        objPos += windDir * 0.001; // Tiny nudge to help Unity recalculate bounds


                       v2f o;
                       o.pos = UnityObjectToClipPos(float4(objPos, 1.0));
                        return o;
                    }

                    float4 frag(v2f i) : SV_Target
                    {
                        return 0;
                    }
                    ENDCG
                }

                Pass
                    {
                        Name "DepthOnly"
                        Tags { "LightMode" = "DepthOnly" }

                        ZWrite On
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

                        struct appdata
                        {
                            float4 vertex : POSITION;
                        };

                        struct v2f
                        {
                            float4 pos : SV_POSITION;
                        };

                        v2f vert(appdata v)
                        {
                            float3 objPos = v.vertex.xyz;
                            float3 worldPos = mul(unity_ObjectToWorld, float4(objPos, 1.0)).xyz;

                            float worldHeight = worldPos.y;
                            float3 windDir = normalize(_WindDirection.xyz);

                            float windPhase = _Time.y * _WindSpeed + dot(worldPos.xz, windDir.xz) * _WindFrequency;
                            float windStrength = saturate((worldHeight - _TrunkHeight) * _WindHeightFactor);
                            float windOffset = sin(windPhase) * _WindAmplitude * windStrength;

                            objPos.xz += windDir.xz * windOffset;

                            v2f o;
                            o.pos = UnityObjectToClipPos(float4(objPos, 1.0));
                            return o;
                        }

                        float4 frag(v2f i) : SV_Target
                        {
                            return 0; // No color output
                        }
                        ENDCG
                    }


        }

            FallBack "Diffuse"
}

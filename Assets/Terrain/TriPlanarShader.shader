Shader "Custom/TriPlanarShader"
{
    Properties
    {
        // set by terrain engine
         [HideInInspector] _Control("Control (RGBA)", 2D) = "red" {}
         [HideInInspector] _Splat3("Layer 3 (A)", 2D) = "white" {}
         [HideInInspector] _Splat2("Layer 2 (B)", 2D) = "white" {}
         [HideInInspector] _Splat1("Layer 1 (G)", 2D) = "white" {}
         [HideInInspector] _Splat0("Layer 0 (R)", 2D) = "white" {}




        _TopTex("Top Texture", 2D) = "white" {} //The texture shown on top.
        _TopSecondaryTex("Top Secondary Texture", 2D) = "white" {} //The secondary texture shown on top.
        _TexturePrimScale("Texture Primary Scale", Range(0.01,5.0)) = 2 //This value is how blended the two textures are.
        _TextureScale("Texture Scale", Range(0.01,15.0)) = 10 //This value is how blended the two textures are.
        _RotationDegrees("Top Secondary Rotation", Float) = 70
        _SideTex("Side Texture", 2D) = "white" {} //Texture shown on side.
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _TextureStep("Texture Step", Range(0.01,100.0)) = 10 //This value is how blended the two textures are.
        _TexturePaintStep("Texture Paint Step", Range(0.01,100.0)) = 10 //This value is how blended the two textures are.
        _SideScale("Side Scale", Float) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Color("Color Tint", Color) = (1,1,1,1)

        _NoiseTex("Noise Texture", 2D) = "white" {}
        _NoiseScale("Noise Scale", Float) = 0.5
        _UVDistortionStrength("UV Distortion Strength", Float) = 0.05


        _NoiseTexTwo("Noise Second Texture", 2D) = "white" {}
        _NoiseScaleTwo("Noise Second Scale", Float) = 0.5
        _UVDistortionStrengthTwo("UV Distortion Second Strength", Float) = 0.05



    }

        SubShader
        {
            Tags {
                "RenderType" = "Opaque"
                "Queue" = "Geometry"
                "SplatCount" = "4"
                "TerrainCompatible" = "True"
            }
            LOD 200

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #pragma target 3.0

            sampler2D _TopTex;
            sampler2D _TopSecondaryTex;
            sampler2D _SideTex;

            struct Input
            {
                float3 worldPos;
                float3 worldNormal;

                float2 uv_Control;
                float2 uv_Splat0;
                float2 uv_Splat1;
                float2 uv_Splat2;
                float2 uv_Splat3;

            };

            half _Glossiness;
            half _Metallic;
            half _TexturePrimScale;
            half _TextureScale;
            half _SideScale;
            half _TextureStep;
            half _TexturePaintStep;
            float _RotationDegrees;
            fixed4 _Color;

            sampler2D _NoiseTex;
            float _NoiseScale;
            float _UVDistortionStrength;

            sampler2D _NoiseTexTwo;
            float _NoiseScaleTwo;
            float _UVDistortionStrengthTwo;


            sampler2D _Control;
            sampler2D _Splat0;
            sampler2D _Splat1;
            sampler2D _Splat2;
            sampler2D _Splat3;

        

        
    
            float3 TriplanarTex(sampler2D tex, float3 worldPos, float3 blend)
            {
                float3 x = tex2D(tex, worldPos.zy).rgb;
                float3 y = tex2D(tex, worldPos.xz).rgb;
                float3 z = tex2D(tex, worldPos.xy).rgb;
                return (x * blend.x + y * blend.y + z * blend.z) / (blend.x + blend.y + blend.z);
            }

            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
            {
                Rotation = Rotation * (3.1415926f / 180.0f);
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;
                Out = UV;
            }

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                float3 normal = normalize(IN.worldNormal);
                float3 blends = abs(normal);

                float topRaw = blends.y;
                float sideRaw = blends.x + blends.z;

                topRaw = pow(topRaw, _TextureStep);
                sideRaw = pow(sideRaw, _TextureStep);

                float total = topRaw + sideRaw;
                float topBlend = topRaw / total;
                float sideBlend = sideRaw / total;

                // Calculate distorted UVs
                float2 noiseUV = IN.worldPos.xz * _NoiseScale;
                float2 noiseSample = tex2D(_NoiseTex, noiseUV).rg * 2.0 - 1.0;

                float2 noiseUV2 = IN.worldPos.xz * _NoiseScaleTwo;
                float2 noiseSample2 = tex2D(_NoiseTexTwo, noiseUV2).rg * 2.0 - 1.0;

                // Apply distortion to top texture UVs
                float2 distortedTopSecUV = IN.worldPos.xz * _TextureScale + noiseSample * _UVDistortionStrength;
                float2 distortedTopThirdUV = IN.worldPos.xz * _TextureScale + noiseSample2 * _UVDistortionStrengthTwo;
                float2 distortedTopUV = IN.worldPos.xz * _TexturePrimScale;

                float2 rotatedUV;
                Unity_Rotate_Degrees_float(distortedTopSecUV, float2(0.5, 0.5), _RotationDegrees, rotatedUV);
                float3 topTexSecondary = tex2D(_TopSecondaryTex, rotatedUV).rgb;

                float3 topTexThird = tex2D(_TopTex, distortedTopThirdUV).rgb;

                float3 topTex = tex2D(_TopTex, distortedTopUV).rgb;
                //float3 topTexSecondary = tex2D(_TopTex, IN.worldPos.xz * _TextureScale).rgb;



                float noiseBlend2 = tex2D(_NoiseTexTwo, IN.worldPos.xz * (_NoiseScaleTwo * 0.5)).r;
                float3 tT2 = lerp(topTex, topTexThird, noiseBlend2);

                float noiseBlend = tex2D(_NoiseTex, IN.worldPos.xz * (_NoiseScale * 0.5)).r;
                float3 tT = lerp(tT2, topTexSecondary, noiseBlend);

                float2 sideUVX = IN.worldPos.zy * _SideScale;
                float2 sideUVY = IN.worldPos.xy * _SideScale;

                float3 sideTexX = tex2D(_SideTex, sideUVX).rgb;
                float3 sideTexZ = tex2D(_SideTex, sideUVY).rgb;
                float3 sideColor = (sideTexX + sideTexZ) * 0.5;

                float3 baseColor = tT * topBlend + sideColor * sideBlend;

                // Sample control map
                float4 control = tex2D(_Control, IN.uv_Control);

                bool hasSplat = (control.r + control.g + control.b + control.a) >= 0.000;

                float splatSum = saturate(control.r + control.g + control.b + control.a);

                float3 finalColor = baseColor;

                if (hasSplat)
                {


                    float3 splat0 = tex2D(_Splat0, IN.uv_Splat0).rgb;
                    float3 splat1 = tex2D(_Splat1, IN.uv_Splat1).rgb;
                    float3 splat2 = tex2D(_Splat2, IN.uv_Splat2).rgb;
                    float3 splat3 = tex2D(_Splat3, IN.uv_Splat3).rgb;

                    float r = pow(control.r, _TexturePaintStep);
                    float g = pow(control.g, _TexturePaintStep);
                    float b = pow(control.b, _TexturePaintStep);
                    float a = pow(control.a, _TexturePaintStep);

                    // Normalize so the weights add to 1
                    float total = r + g + b + a + 1e-5; // prevent division by zero
                    r /= total;
                    g /= total;
                    b /= total;
                    a /= total;


                    float3 splatColor =
                        baseColor * r +
                        splat1 * g +
                        splat2 * b +
                        splat3 * a;

                    finalColor = lerp(baseColor, splatColor, splatSum);
  


                }
                
                

                o.Albedo = finalColor * _Color.rgb;
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
            }
            ENDCG
        }

            FallBack "Diffuse"
}

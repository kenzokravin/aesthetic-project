Shader "Custom/DitherEffect_Hardcoded"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ColNum("Surface Noise Cutoff", Range(0, 100)) = 10
        _Sharpness("Sharpness", Range(0, 100)) = 10
        
        
    }

        SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Overlay" }
        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _ColNum;
            float _Sharpness;
            float4 _TexelSize; // Set in C# as (1/width, 1/height, 0, 0)
            uint _IsDithering;

            float4 frag(v2f_img i) : COLOR
            {
                float2 uv = i.uv;

                // 1. Sample neighbors for sharpening
                float3 col = tex2D(_MainTex, uv).rgb;
                float3 up = tex2D(_MainTex, uv + float2(0, _TexelSize.y)).rgb;
                float3 down = tex2D(_MainTex, uv - float2(0, _TexelSize.y)).rgb;
                float3 left = tex2D(_MainTex, uv - float2(_TexelSize.x, 0)).rgb;
                float3 right = tex2D(_MainTex, uv + float2(_TexelSize.x, 0)).rgb;

                float3 sharpened = col * 5.0 - (up + down + left + right);
                sharpened = lerp(col, sharpened, _Sharpness); // Blend based on sharpness
                sharpened = saturate(sharpened); // Clamp to [0,1]

                // 2. Color quantization
                float colSteps = _ColNum - 1;
                float3 quantized = floor(sharpened * colSteps + 0.5) / colSteps;

                float3 colFin1 = quantized;

                // 3. Bayer dithering
                if (_IsDithering == 1) {
                    float2 screenUV = uv * _ScreenParams.xy;
                    int2 pixelPos = int2(floor(screenUV)) % 4;
                    int index = pixelPos.y * 4 + pixelPos.x;

                    float bayer4x4[16] = {
                        0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
                       12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
                        3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
                       15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
                    };

                    float threshold = bayer4x4[index];
                    colFin1 = step(threshold.xxx, quantized);

                }
                else {
                    //float3 dithered = quantized;
                }

                return float4(colFin1, 1.0);
            }
            ENDCG
        }
    }
}

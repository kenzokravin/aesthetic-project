Shader "Custom/DitherEffect_Hardcoded"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ColNum("Surface Noise Cutoff", Range(0, 100)) = 10
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

            float4 frag(v2f_img i) : COLOR
            {
                // Calculate screen position
                float2 screenUV = i.uv * _ScreenParams.xy;
                int2 pixelPos = int2(floor(screenUV)) % 4;

                // Bayer matrix lookup
                int index = pixelPos.y * 4 + pixelPos.x;
                float ditherThreshold = 0.0;
                float bayer4x4[16] = {
                    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
                   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
                    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
                   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
                };
                ditherThreshold = bayer4x4[index];

                float3 col = tex2D(_MainTex, i.uv).rgb;

                float colNumber = _ColNum - 1;

                float3 colFin = floor(col * colNumber + 0.5) / colNumber;

                float3 dithered = step(ditherThreshold.xxx, colFin);
                return float4(dithered, 1.0);

            }
            ENDCG
        }
    }
}

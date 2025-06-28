Shader "Custom/VineReveal"
{
    Properties{
        _BaseTex("Base Texture", 2D) = "white" {}
        _VineTex("Vine Texture", 2D) = "green" {}
        _VineMask("Vine Mask", 2D) = "black" {}
    }
        SubShader{
            Tags { "RenderType" = "Opaque" }
            Pass {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                sampler2D _BaseTex, _VineTex, _VineMask;

                struct appdata {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                v2f vert(appdata v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                float4 frag(v2f i) : SV_Target {
                    float4 baseCol = tex2D(_BaseTex, i.uv);
                    float mask = tex2D(_VineMask, i.uv).r;
                    float4 vineCol = tex2D(_VineTex, i.uv);
                    return lerp(baseCol, vineCol, mask);
                }
                ENDCG
            }
    }
}

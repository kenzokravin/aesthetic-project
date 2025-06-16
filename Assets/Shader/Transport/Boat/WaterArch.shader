Shader "Custom/WaterArch"
{
    Properties
    {
        _Color("Color", Color) = (0.4, 0.8, 1.0, 1.0)
        _Radius("Radius", Float) = 2.0
        _Height("Height", Float) = 1.0
        _Segments("Segments", Float) = 10
    }

        SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex Vert
            #pragma geometry Geom
            #pragma fragment Frag
            #pragma target 4.0

            #include "UnityCG.cginc"

            float4 _Color;
            float _Radius;
            float _Height;
            float _Segments;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2g
            {
                float4 vertex : POSITION;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            v2g Vert(appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                return o;
            }

            [maxvertexcount(32)]
            void Geom(point v2g input[1], inout TriangleStream<g2f> triStream)
            {
                float3 origin = input[0].vertex.xyz;

                int segments = (int)_Segments;
                float angleStep = UNITY_PI / segments;

                for (int i = 0; i < segments; ++i)
                {
                    float a0 = i * angleStep;
                    float a1 = (i + 1) * angleStep;

                    float3 p0 = origin + float3(sin(a0) * _Radius, sin(a0) * _Height, cos(a0) * _Radius);
                    float3 p1 = origin + float3(sin(a1) * _Radius, sin(a1) * _Height, cos(a1) * _Radius);
                    float3 base0 = origin;
                    float3 base1 = origin;

                    g2f o0, o1, o2;

                    o0.vertex = UnityObjectToClipPos(float4(p0, 1));
                    o1.vertex = UnityObjectToClipPos(float4(p1, 1));
                    o2.vertex = UnityObjectToClipPos(float4(origin, 1));

                    o0.color = _Color;
                    o1.color = _Color;
                    o2.color = _Color * 0.5;

                    triStream.Append(o0);
                    triStream.Append(o1);
                    triStream.Append(o2);
                }
            }

            fixed4 Frag(g2f i) : SV_Target
            {
                return i.color;
            }

            ENDCG
        }
    }
}

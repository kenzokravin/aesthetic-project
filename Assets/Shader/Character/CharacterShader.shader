Shader "Custom/CharacterShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

            _LightRamp("Light Ramp", Range(0,1)) = 0.5
         _ShadowStrength("Shadow Strength", Range(0,1)) = 0.7
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
         #pragma surface surf ToonRamp fullforwardshadows
         #pragma target 3.0


        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _LightRamp;
        float _ShadowStrength;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
           
           
            o.Alpha = c.a;
        }

        inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half NdotL = dot(s.Normal, lightDir);

            // Toon band for diffuse
            half diff = step(0.5, NdotL);

            // Simulated self-shadow: lower light when surface faces away from light
            // This adds 'fake' shading where real-time shadows don't apply (like self-shadowing)
            half fakeSelfShadow = lerp(_ShadowStrength, 1.0, diff);

            // Real-time shadow from other objects
            half shadowStep = step(0.5, atten);
            half realShadow = lerp(_ShadowStrength, 1.0, shadowStep);

            // Combine both
            half lightingFactor = fakeSelfShadow * realShadow;

            half3 col = s.Albedo * _LightColor0.rgb * (lightingFactor * _LightRamp);
            return half4(col, 1.0);
        }
        ENDCG


    }
       FallBack "Legacy Shaders/VertexLit"
}

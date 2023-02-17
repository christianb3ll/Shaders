Shader "Custom/LambertianLitShader"
{
    Properties
    {
        _Color("Colour", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                
                // Convert the vertices to clip space
                OUT.positionHCS = TransformObjectToHClip(IN.vertex);

                return OUT;
            }

            half4 frag (Varyings inp) : SV_Target
            {
                return half4(1,1,1,1);
            }

            ENDHLSL
        }
    }
}

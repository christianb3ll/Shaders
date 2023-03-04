Shader "Custom/GlassShader"
{
    Properties
    {
        // a colour texture map
        _MainTex("Texture", 2D) = "white" {}
        // a normal map
        _NormalTex("Normal Map", 2D) = "bump" {}
    }

    SubShader
    {
        Tags {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalRenderPipeline"
            "Transparency" = "Transparent"
        }

        ZWrite Off

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"  

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv: TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3 normalWS     : TEXCOORD1;
                half3 tangentWS    : TEXCOORD2;
                half3 bitangentWS  : TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                sampler2D _NormalTex;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS = vertexNormalInput.normalWS;
                OUT.tangentWS = vertexNormalInput.tangentWS;
                OUT.bitangentWS = vertexNormalInput.bitangentWS;

                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 col = tex2D(_MainTex, IN.uv);

                float3 normal = UnpackNormal(tex2D(_NormalTex, IN.uv));

                normal = TransformTangentToWorld(normal,
                    half3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS));

                Light mainLight = GetMainLight();
                float4 nl = max(0, dot(normal.rgb, mainLight.direction.xyz));
                float4 diffuse = float4(nl * mainLight.color, 1);

                return col * diffuse;
            }

            ENDHLSL
        }
    }
}
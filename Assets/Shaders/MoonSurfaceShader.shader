Shader "Custom/MoonSurfaceShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NormalTex("NormalMap", 2D) = "bump" {}
        _HeightTex("Height Map", 2D) = "gray" {}
        _HeightDisplace("Height Displace", Range(0,0.5)) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
        }

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
                sampler2D _HeightTex;
                float _HeightDisplace;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float height = tex2Dlod(_HeightTex, float4(IN.uv, 0, 0)).x;

                IN.positionOS.xyz += IN.normalOS * (height * _HeightDisplace);
                
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                // Get transformed normal, tangent and bitangent 
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS = vertexNormalInput.normalWS;
                OUT.tangentWS = vertexNormalInput.tangentWS;
                OUT.bitangentWS = vertexNormalInput.bitangentWS;

                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // get the colour from the colour texture
                half4 col = tex2D(_MainTex, IN.uv);

                // Unpack the normals
                float3 normal = UnpackNormal(tex2D(_NormalTex, IN.uv));

                // Transform the normal using tangent matrix
                normal = TransformTangentToWorld(normal,
                    half3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS));

                // Lighting
                Light mainLight = GetMainLight();
                float4 nl = max(0, dot(normal.rgb, mainLight.direction.xyz));
                float4 diffuse = float4(nl * mainLight.color, 1);

                return col * diffuse;
            }

            ENDHLSL
        }
    }
}
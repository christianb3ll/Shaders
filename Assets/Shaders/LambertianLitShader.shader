Shader "Custom/LambertianLitShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "White"{}
        _Color("Colour", Color) = (1,1,1,1)
        _AmbientLight("Ambient Light", Color) = (1,1,1,1)
        _HighlightColor("Highlight Colour", Color) = (1,1,1,1)
        _Glossiness("Glossiness", Range(0,50)) = 30
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
                float4 normalOS : NORMAL;
                float2 UV : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float4 positionWS : POSITION1;
                float4 normalWS : NORMAL;
                float2 UV : TEXCOORD0;
                float3 viewDirection : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                half4 _Color;
                half4 _AmbientLight;
                half4 _HighlightColor;
                float _Glossiness;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                
                // Output the world space position for lighting calculations
                OUT.positionWS = mul(UNITY_MATRIX_M, IN.vertex);

                // Setup the view direction 
                OUT.viewDirection = _WorldSpaceCameraPos.xyz - OUT.positionWS;

                // Convert the vertices to clip space
                OUT.positionHCS = TransformObjectToHClip(IN.vertex);

                OUT.normalWS = mul(UNITY_MATRIX_M, float4(IN.normalOS.xyz,0));

                return OUT;
            }

            half4 frag (Varyings inp) : SV_Target
            {
                half4 col = tex2D(_MainTex, inp.UV);

                // Normalise the view direction
                float3 viewDir = normalize(inp.viewDirection);

                float3 midPoint = normalize(_MainLightPosition + viewDir);
                float NdotMid = dot(inp.normalWS, midPoint);

                float specularIntensity = pow(NdotMid, _Glossiness);

                float4 specular = specularIntensity * _HighlightColor;

                // get the main light 
                Light mainLight = GetMainLight();

                // this is the dot product part of the lighting equation  
                float4 nl = max(0, dot(inp.normalWS.xyz, mainLight.direction.xyz));

                // Clamp the light intensity
                float lightIntensity = nl > 0 ? 1 : 0;

                // calculate the diffuse based on nl
                float lighting = float4((lightIntensity + _AmbientLight + specular) * mainLight.color, 1);

                // repeat for all of the other lights 
                int lightCount = GetAdditionalLightsCount();
                for (int i=0; i < lightCount; i++){
                    Light light = GetAdditionalLight(i, inp.positionWS);
                    float4 nl = max(0, dot(inp.normalWS.xyz, light.direction.xyz));

                    float3 midPoint = normalize(light.direction.xyz + viewDir);
                    float NdotMid = dot(inp.normalWS, midPoint);

                    float specularIntensity = pow(NdotMid, _Glossiness);

                    specular += specularIntensity * _HighlightColor;

                    float lightIntensity = nl > 0 ? 1 : 0;

                    lighting += float4((_AmbientLight + lightIntensity + specular) * light.color, 1);
                }
      
                // multiply the lighting by the object colour
                return _Color * lighting;
              
            }

            ENDHLSL
        }
    }
}

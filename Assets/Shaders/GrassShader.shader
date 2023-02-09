Shader "Custom/GrassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GrassColor ("Colour", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 vertex : POSITION;
                float4 positionOS : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 positionOS : POSITION1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _GrassColor;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.vertex = IN.vertex;

                OUT.vertex.xz *= IN.vertex.y - 0.5;
                if(IN.vertex.y > 0)
                {
                    OUT.vertex.xz += 0.5 * sin(OUT.vertex.y *_Time.y * 5) + 1.0 * 0.5;
                }
                
                

                // Convert the vertices to clip space
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);

                
                
                // get texture data 
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                // setup position in object space for fragment shader
                OUT.positionOS = IN.positionOS;

                return OUT;
            }

            fixed4 frag (Varyings inp) : SV_Target
            {
                // sample the texture 
                half4 col;
                col = tex2D(_MainTex, inp.uv);

                if(inp.positionOS.x > 0)
                {
                    col += 0.5;
                }

                col *= _GrassColor;

                return col;
            }
            ENDCG
        }
    }
}

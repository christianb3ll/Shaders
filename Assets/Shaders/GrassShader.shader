Shader "Custom/GrassShader"
{
    Properties
    {
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
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float4 positionOS : POSITION1;
            };

            float4 _GrassColor;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.vertex = IN.vertex;

                // Taper the grass to a point
                OUT.vertex.xz *= IN.vertex.y - 0.5;

                // sway the upper half of the grass
                if(IN.vertex.y > 0)
                {
                    OUT.vertex.xz += 0.5 * sin(OUT.vertex.y *_Time.y * 5) + 1.0 * 0.5;
                }
                
                // Convert the vertices to clip space
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);

                // setup position in object space for fragment shader
                OUT.positionOS = IN.positionOS;

                return OUT;
            }

            fixed4 frag (Varyings inp) : SV_Target
            {
                // sample the texture 
                half4 col;
                col = _GrassColor;

                // Grass highlight 
                if(inp.positionOS.x > 0)
                {
                    col *= 1.3;
                }

                return col;
            }
            ENDCG
        }
    }
}

Shader "Custom/FirstShader"
{
    Properties
    {
        _BubbleColor("Bubble Colour", Color) = (0.5,0.7,0.9,1)
        _WaveSize("Wave Size", range(0,5)) = 0.5
        _WaveSpeed("Wave Speed", range(0,10)) = 1.0
        _ExtrudeSize("Extrude Size", range(0,5)) = 0.1
        _OutlineColor("Outline Colour", Color) = (1,1,1,1)
        _OutlineSize("Outline Size", range(0,5)) = 0
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
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float4 positionOS : POSITION1;
            };

            fixed4 _BubbleColor;
            float _WaveSize;
            float _WaveSpeed;
            float _ExtrudeSize;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.vertex = IN.vertex;

                // Add ripple effect
                OUT.vertex.xz *= 0.5 * sin(IN.vertex.y *_Time.y * _WaveSpeed) + 1.0 * _WaveSize;

                // Extrude the normals 
                OUT.vertex += IN.normal * _ExtrudeSize;

                // Convert the vertices to clip space
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                

                // setup position in object space for fragment shader 
                OUT.positionOS = IN.positionOS;

                // Causes the bubbles to rise and fall
                OUT.vertex.y -= sin(_Time.y / 5) *10;

                return OUT;
            }

            fixed4 frag (Varyings inp) : SV_Target
            {
                // sample the texture
                half4 col = _BubbleColor;

                // Add horizontal shimmer lines
                if(fmod( (0.5* sin(inp.positionOS.x +0.5 *_Time.y)+1) * 10, 2) > 0.2 )
                {
                    col.xyz -= 0.2;
                }

                return col;
            }
            ENDCG
        }

        Pass
        {

            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
            };

            float _WaveSize;
            float _WaveSpeed;
            float _ExtrudeSize;
            fixed4 _OutlineColor;
            float _OutlineSize;


            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.vertex = IN.vertex;

                // Add ripple effect
                OUT.vertex.xz *= 0.5 * sin(IN.vertex.y *_Time.y * _WaveSpeed) + 1.0 * _WaveSize;

                // Extrude the normals 
                OUT.vertex += IN.normal * _ExtrudeSize;

                OUT.vertex = UnityObjectToClipPos(OUT.vertex * _OutlineSize);

                // Causes the bubbles to rise and fall
                OUT.vertex.y -= sin(_Time.y / 5) *10;

                return OUT;
            }

            fixed4 frag (Varyings inp) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}

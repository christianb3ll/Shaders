Shader "Custom/FirstShaderOutline"
{
    Properties
    {
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

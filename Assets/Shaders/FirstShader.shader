Shader "Custom/FirstShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveSize("Wave Size", range(0,5)) = 0.5
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
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _WaveSize;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.vertex = IN.vertex;

                OUT.vertex *= fmod(0.5 * sin(IN.vertex.x) + 1.0, _WaveSize);

                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            fixed4 frag (Varyings inp) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, inp.uv);
                return col;
            }
            ENDCG
        }
    }
}

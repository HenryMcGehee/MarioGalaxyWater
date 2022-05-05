Shader "Unlit/WaterShader"
{
    Properties
    {
        _BaseTex1 ("Base Texture", 2D) = "white" {}
        _BaseTex2 ("Second BaseTexture", 2D) = "white" {}
        _HighlightTex1 ("Highlight Texture", 2D) = "white" {}
        _HighlightTex2 ("Second Highlight Texture", 2D) = "white" {}

        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
        _Cutoff2("Alpha Cutoff 2", Range(0,1)) = 0.5
        _EdgeWeight("Edge Weight", Range(0,0.03)) = 0.5

        _SpeedX ("Speed X", Float) = 1
        _SpeedY ("Speed Y", Float) = 1
        _Speed2X ("Speed X", Float) = 1
        _Speed2Y ("Speed Y", Float) = 1

        _HighlightSpeedX ("HighlightSpeed X", Float) = 1
        _HighlightSpeedY ("HighlightSpeed Y", Float) = 1
        _HighlightSpeed2X ("HighlightSpeed X", Float) = 1
        _HighlightSpeed2Y ("HighlightSpeed Y", Float) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _BaseTex1;
            float4 _BaseTex1_ST;
            sampler2D _BaseTex2;
            float4 _BaseTex2_ST;

            float4 _Color;
            float _Cutoff;
            float _Cutoff2;
            

            float _SpeedX;
            float _SpeedY;
            float _Speed2X;
            float _Speed2Y;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex1);
                o.uv2 = TRANSFORM_TEX(v.uv2, _BaseTex2);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                _SpeedX *= _Time;
                _SpeedY *= _Time;
                _Speed2X *= _Time;
                _Speed2Y *= _Time;

                fixed4 col = _Color;

                // sample the texture
                fixed4 col1 = tex2D(_BaseTex1, i.uv + float2(_SpeedX, _SpeedY));
                fixed4 col2 = tex2D(_BaseTex2, i.uv2 + float2(_Speed2X, _Speed2Y));
                col1 *= col2;

                clip(1-col1.a - _Cutoff);
                return col1;

            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                fixed4 color : COLOR0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR0;
            };

            sampler2D _HighlightTex1;
            float4 _HighlightTex1_ST;
            sampler2D _HighlightTex2;
            float4 _HighlightTex2_ST;

            float4 _Color;
            float _Cutoff;
            float _Cutoff2;
            float _EdgeWeight;

            float _HighlightSpeedX;
            float _HighlightSpeedY;
            float _HighlightSpeed2X;
            float _HighlightSpeed2Y;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _HighlightTex1);
                o.uv2 = TRANSFORM_TEX(v.uv2, _HighlightTex2);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                _HighlightSpeedX *= _Time;
                _HighlightSpeedY *= _Time;
                _HighlightSpeed2X *= _Time;
                _HighlightSpeed2Y *= _Time;

                fixed4 col1 = tex2D(_HighlightTex1, i.uv + float2(_HighlightSpeedX, _HighlightSpeedY));
                fixed4 col2 = tex2D(_HighlightTex2, i.uv2 + float2(_HighlightSpeed2X, _HighlightSpeed2Y));

                col1 *= col2;

                clip(col1.a - _Cutoff2);
                clip(i.color - _EdgeWeight);

                fixed4 final = i.color + col1;

                return col1;
            }
            ENDCG
        }
    }
}

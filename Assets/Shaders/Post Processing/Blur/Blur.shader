//https://www.ronja-tutorials.com/2018/08/27/postprocessing-blur.html @TotallyRonja


// MUST DO REST OF THE DAMN TUTORIAL LOL
Shader "Sid/Blur"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size", Range(0, .3)) = 0

    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			float _BlurSize;

			fixed4 frag(v2f i) : SV_Target
			{
				float4 col = 0;
				for (float index = 0; index < 10; index++) {
					//get uv coordinate of sample
					float2 uv = i.uv + float2(0, (index / 9 - 0.5) * _BlurSize);
					//add color at position to color
					col += tex2D(_MainTex, uv);
				}
				col = col / 10;
                return col;
            }
            ENDCG
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			float _BlurSize;

			fixed4 frag(v2f i) : SV_Target
			{
				float invAspect = _ScreenParams.y / _ScreenParams.x;
				float4 col = 0;
				for (float index = 0; index < 10; index++) {
					//get uv coordinate of sample
					float2 uv = i.uv + float2((index / 9 - 0.5) * _BlurSize * invAspect, 0);
					//add color at position to color
					col += tex2D(_MainTex, uv);
				}
				col = col / 10;
				return col;
			}
			ENDCG
		}
    }
}

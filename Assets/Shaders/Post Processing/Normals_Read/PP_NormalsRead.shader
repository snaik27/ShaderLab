//https://www.ronja-tutorials.com/2018/07/08/postprocessing-normal.html @TotallyRonja

///<summary>
///****Note: Snow appears on both upper and lower halves of all things bc we're taking the power of the length
///                of the "up" vector at line 73. Must figure out how to cull the negative values 
///<summary>
Shader "Sid/PP_NormalsRead"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SnowThreshold("Snow Threshold", Float) = 2
    }
		SubShader{

		Cull Off
		ZWrite Off
		ZTest Always

		Pass{
			CGPROGRAM
			//include useful shader functions
			#include "UnityCG.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			//texture and transforms of the texture
			sampler2D _MainTex;
			sampler2D _CameraDepthNormalsTexture; //Generated in C# script attached to camera (PP_DepthRead.cs)
			float4x4 _viewToWorld;
			float _SnowThreshold;

			

			//the object data that's put into the vertex shader
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//the data that's used to generate fragments and can be read by the fragment shader
			struct v2f {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//the vertex shader
			v2f vert(appdata v) {
				v2f o;
				//convert the vertex positions from object space to clip space so they can be rendered
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{
				//get depth from depth texture
				float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);

				//split depthNormal into depth and normal 
				float3 normal;
				float depth;
				DecodeDepthNormal(depthNormal, depth, normal);

				//get depth as distance from camera in units
				depth = depth * _ProjectionParams.z;
				normal = mul((float3x3)_viewToWorld, normal);

				float up = dot(float3(0, 1, 0), normal);
				up = smoothstep(float3(0, 0, 0), float3(1, 1, 1), pow(length(up), _SnowThreshold));

				float4 source = tex2D(_MainTex, i.uv);
				float4 col = lerp(source, up, length(up));
				return col;
			}
			ENDCG

		}
	}
		Fallback "Diffuse"
}
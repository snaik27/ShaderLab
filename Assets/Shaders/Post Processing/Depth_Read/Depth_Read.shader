﻿//https://www.ronja-tutorials.com/2018/07/01/postprocessing-depth.html @totallyRonja

///<summary>
/// ***Note: Keep length of trail relatively small! (1.35 looks good to me) or else its too jarring of a
///                 transition from source color to wave color for large objects
/// *** Other Note: Front of wave is smoothstepped in this implementation as opposed to stepped. This negates above note. I'm writing CSS lol
///<summary>
Shader "Sid/PP_DepthRead"{
	//show values to edit in inspector
	Properties{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
		[Header(Wave)]
		_WaveDistance("Distance from player", float) = 10
		_WaveTrail("Length of the trail", Range(0,5)) = 1
		_WaveColor("Color", Color) = (1,0,0,1)
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
			sampler2D _CameraDepthTexture; //Generated in C# script attached to camera (PP_DepthRead.cs)
			
			//variables to control the wave
			float _WaveDistance;
			float _WaveTrail;
			float4 _WaveColor;

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
			float depth = tex2D(_CameraDepthTexture, i.uv).r;

			//linear depth between camera and far clipping plane
			depth = Linear01Depth(depth);

			//depth as distance from camera in units 
			depth = depth * _ProjectionParams.z;


			//get source color
			fixed4 source = tex2D(_MainTex, i.uv);
			//skip wave and return source color if we're at the skybox
			if (depth >= _ProjectionParams.z)
				return source;

			//calculate wave
			float waveFront = smoothstep(depth + _WaveTrail, _WaveDistance, depth);
			float waveTrail = smoothstep(_WaveDistance - _WaveTrail, _WaveDistance, depth);
			float wave = waveFront * waveTrail;

			//mix wave into source color
			fixed4 col = lerp(source, _WaveColor, wave);

			return col;
			}
			ENDCG

		}
	}
		Fallback "Diffuse"
}

﻿//https://www.ronja-tutorials.com/2018/08/18/stencil-buffers.html @TotallyRonja

///<summary>
/// Todo:
/// 1. Read more about Stencil Buffers
///<summary>
Shader "Sid/StencilBuffer" {
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 1)) = 0
		_Metallic("Metalness", Range(0, 1)) = 0
		[HDR] _Emission("Emission", color) = (0,0,0)

		[IntRange] _StencilRef("Stencil Reference Value", Range(0,255)) = 0
	}
		SubShader{
			Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

			Stencil{
				Ref [_StencilRef] //Marks the reference value we operate on (default is 0)
				Comp Equal		  //defines the stencil operation passes. (default is Always). 
									    //Only draw when stencil buffer at that pos is equal to the value of Ref
			}

			CGPROGRAM

			#pragma surface surf Standard fullforwardshadows
			#pragma target 3.0

			sampler2D _MainTex;
			fixed4 _Color;

			half _Smoothness;
			half _Metallic;
			half3 _Emission;

			struct Input {
				float2 uv_MainTex;
			};

			void surf(Input i, inout SurfaceOutputStandard o) {
				fixed4 col = tex2D(_MainTex, i.uv_MainTex);
				col *= _Color;
				o.Albedo = col.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;
				o.Emission = _Emission;
			}
			ENDCG
		}
			FallBack "Standard"
}

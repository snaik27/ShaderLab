//https://www.ronja-tutorials.com/2018/08/18/stencil-buffers.html @TotallyRonja

///<summary>
/// Gets drawn after other stencil buffer and replaces the values at the occluded pixels with whatever's behind it
Shader "Sid/Second_StencilBuffer"{
	//show values to edit in inspector
	Properties{
		[IntRange] _StencilRef("Stencil Reference Value", Range(0,255)) = 0
	}

		SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry-1"}

		Stencil{
			Ref [_StencilRef]
			Comp Always
			Pass Replace	//Pass declares what'll happen when the comparison with zbuffer is successful (it's
								//not occluded), here it'll replace the _StencilRef value in teh StencilBuffer 
		}


		Pass{
			Blend Zero One  //the color that is returned by the shader will be completely ignored 
									//and the color that was rendered before will be preserved completely. 
			ZWrite Off		//Dont write to zbuffer

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f {
				float4 position : SV_POSITION;
			};

			v2f vert(appdata v) {
				v2f o;
				//calculate the position in clip space to render the object
				o.position = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				//Return the color the Object is rendered in
				return 0;
			}

			ENDCG
		}
	}
}

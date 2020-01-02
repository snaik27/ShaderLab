//@TotallyRonja https://www.ronja-tutorials.com/2018/05/11/triplanar-mapping.html

Shader "Sid/Tri Planar Mapping"{
	//show values to edit in inspector
	Properties{
		_Color("Color", Color) = (0, 0, 0, 1)
		_MainTex("Albedo", 2D) = "white" {}
	_Sharpness("Blend sharpness", Range(1, 64)) = 1
	}

		SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass{
			CGPROGRAM

			//include useful shader functions
			#include "UnityCG.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			//texture and transforms of the texture
			sampler2D _MainTex;
			float4 _MainTex_ST;

			//tint of the texture
			fixed4 _Color;
			float _Sharpness;

			//the object data that's put into the vertex shader
			struct appdata {
				float4 vertex : POSITION;
				float2 normal : NORMAL;
			};

			//the data that's used to generate fragments and can be read by the fragment shader
			struct v2f {
				float4 position : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 normal   : NORMAL;
			};

			//the vertex shader
			v2f vert(appdata v) {
				v2f o;
				//calculate the position in clip space to render the ob
				o.position = UnityObjectToClipPos(v.vertex);

				//calculate world pos of vert
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos = worldPos.xyz;

				//calculate world normal
				float3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.normal = normalize(worldNormal);
				return o;
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{
				//calculate UV coords for all three projects
				float2 uv_front = TRANSFORM_TEX(i.worldPos.xy, _MainTex);
				float2 uv_side = TRANSFORM_TEX(i.worldPos.zy, _MainTex);
				float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);

				//read the textures at the uv coords we just created
				fixed4 col_front = tex2D(_MainTex, uv_front);
				fixed4 col_side = tex2D(_MainTex, uv_side);
				fixed4 col_top = tex2D(_MainTex, uv_top);

				//generate weights from world normals we calculated in vert shader
				float3 weights = i.normal;

				//show texture on both sides of object
				weights = abs(weights);

				//make transition sharper
				weights = pow(weights, _Sharpness);

				//normalize
				weights = weights / (weights.x + weights.y + weights.z);

				//combine weights
				col_front *= weights.z;
				col_side *= weights.x;
				col_top *= weights.y;

				//combine projected color
				fixed4 col = col_front + col_side + col_top;

				//multiply tex by _Color
				col *= _Color;
				return col;
			}

			ENDCG
		}
	}
		FallBack "Standard"
}

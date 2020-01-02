//https://www.ronja-tutorials.com/2018/07/15/postprocessing-outlines.html @TotallyRonja

///<summary>
/// *****Note: I've included an outline thickness that's a psuedo thickness parameter,
///<summary>
Shader "Sid/PP_Outline"
{
    Properties
    {
		[HideInInspector] _MainTex("Texture", 2D) = "white" {} 
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineThickness("Outline Thickness", Range(0, 10)) = 1
		_NormalMult ("Normal Outline Multiplier", Range(0,10)) = 1
		_NormalBias("Normal Outline Bias", Range(1,6)) = 1
		_DepthMult ("Depth Outline Multiplier", Range(0,10))= 1
		_DepthBias("Depth Outline Bias", Range(0,6)) = 1
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
			float4 _OutlineColor;
			sampler2D _CameraDepthNormalsTexture;
			float4 _CameraDepthNormalsTexture_TexelSize;
			float _OutlineThickness;

			float _NormalMult;
			float _NormalBias;
			float 	_DepthMult;
			float	_DepthBias;



			void Compare(inout float depthOutline, inout float normalOutline, 
				float baseDepth, float3 baseNormal, float2 uv, float2 offset)
			{
				//get neighbor depth from depth texture and texel size
				float4 neighborDepthNormal = tex2D(_CameraDepthNormalsTexture, uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);

				float3 neighborNormal;
				float neighborDepth;
				DecodeDepthNormal(neighborDepthNormal, neighborDepth, neighborNormal);

				//get depth as distance from camera in units
				neighborDepth = neighborDepth * _ProjectionParams.z;


				float depthDifference = baseDepth - neighborDepth;
				depthOutline = depthOutline + depthDifference;

				float3 normalDifference = baseNormal - neighborNormal;
				normalDifference = normalDifference.r + normalDifference.g + normalDifference.b;
				normalOutline = normalOutline + normalDifference;
			}


            fixed4 frag (v2f i) : SV_Target
            {
				//get depth from depth texture
				float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);

				//split depthNormal into depth and normal 
				float3 normal;
				float depth;
				DecodeDepthNormal(depthNormal, depth, normal);

				//get depth as distance from camera in units
				depth = depth * _ProjectionParams.z;

				float depthDifference = 0;
				float normalDifference = 0;

				
				
				Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(_OutlineThickness,0));
				Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(-_OutlineThickness, 0));
				Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(0, _OutlineThickness));
				Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(0, -_OutlineThickness));

				depthDifference = depthDifference * _DepthMult;
				depthDifference = saturate(depthDifference);
				depthDifference = pow(depthDifference, _DepthBias);

				normalDifference = normalDifference * _NormalMult;
				normalDifference = saturate(normalDifference);
				normalDifference = pow(normalDifference, _NormalBias);

				//float outline = step(0.00001, depthDifference + normalDifference);
				float outline = depthDifference + normalDifference;
				float4 sourceColor = tex2D(_MainTex, i.uv);
				float4 color = lerp(sourceColor, _OutlineColor, outline);
				return color;
            }

		
            ENDCG
        }
    }
}

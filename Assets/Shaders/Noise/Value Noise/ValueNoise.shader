//https://www.ronja-tutorials.com/2018/09/08/value-noise.html @TotallyRonja
Shader "Sid/ValueNoise"
{
	Properties
	{
	   _CellSize("Cell Size", Vector) = (1,1,1,0)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }


		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0


		struct Input
		{
			float3 worldPos;
		};

		float3 _CellSize;


		float rand(float3 vec) {
			float3 smallVal = sin(vec);
			float random = dot(smallVal, float3(12.9898, 78.233, 37.719));
			random = frac(sin(random) * 1343758.5453);
			return random;
		}

		//get a scalar random value from a 3d value
		float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)) {
			//make value smaller to avoid artefacts
			float3 smallValue = sin(value);
			//get scalar value from 3d vector
			float random = dot(smallValue, dotDir);
			//make value more random by making it bigger and then taking the factional part
			random = frac(sin(random) * 1758.5453);
			return random;
		}
		float3 rand3dTo3d(float3 value) {
			return float3(
				rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
				rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
				rand3dTo1d(value, float3(73.156, 52.235, 09.151))
				);
		}
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float3 value = floor(IN.worldPos / _CellSize);
			// Albedo comes from a texture tinted by color
			o.Albedo = rand3dTo3d(value);
		}
		ENDCG
	}
		FallBack "Diffuse"
}

//https://www.ronja-tutorials.com/2018/09/08/value-noise.html @TotallyRonja
Shader "Sid/ValueNoise"
{
	Properties
	{
	   _CellSize("Cell Size", Range(0,1)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }


		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		#include "NoiseFunctions.cginc"

		struct Input
		{
			float3 worldPos;
		};

		float _CellSize;

		//Quadratic easeIn
		inline float easeIn(float interpolator) {
			return interpolator * interpolator;
		}

		inline float easeOut(float interpolator) {
			return 1 - (easeIn(1 - interpolator));
		}

		float easeInOut(float interpolator) {
			float easeInValue = easeIn(interpolator);
			float easeOutValue = easeOut(interpolator);
			return lerp(easeInValue, easeOutValue, interpolator);
		}

		float ValueNoise2d(float2 value) {
			float upperLeftCell = rand2dTo1d(float2(floor(value.x), ceil(value.y)));
			float upperRightCell = rand2dTo1d(float2(ceil(value.x), ceil(value.y)));
			float lowerLeftCell = rand2dTo1d(float2(floor(value.x), floor(value.y)));
			float lowerRightCell = rand2dTo1d(float2(ceil(value.x), floor(value.y)));

			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));

			float upperCells = lerp(upperLeftCell, upperRightCell, interpolatorX);
			float lowerCells = lerp(lowerLeftCell, lowerRightCell, interpolatorX);

			float noise = lerp(lowerCells, upperCells, interpolatorY);
			return noise;
		}

		float ValueNoise3d(float3 value) {
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));
			float interpolatorZ = easeInOut(frac(value.z));

			float cellNoiseZ[2];
			[unroll]
			for (int z = 0; z <= 1; z++) {
				float cellNoiseY[2];
				[unroll]
				for (int y = 0; y <= 1; y++) {
					float cellNoiseX[2];
					[unroll]
					for (int x = 0; x <= 1; x++) {
						float3 cell = floor(value) + float3(x, y, z);
						cellNoiseX[x] = rand3dTo1d(cell);
					}
					cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
				}
				cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
			}
			float noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			return noise;
		}



		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Smooth interpolation in 1d:
			/*float value = IN.worldPos.x / _CellSize;
			float previousCellNoise = rand1dTo1d(floor(value));
			float nextCellNoise = rand1dTo1d(ceil(value));
			float interpolator = frac(value);
			interpolator = easeInOut(interpolator);
			float noise = lerp(previousCellNoise, nextCellNoise, interpolator);
			float dist = abs(noise - IN.worldPos.y);
			float pixelHeight = fwidth(IN.worldPos.y);
			float lineIntensity = smoothstep(0, pixelHeight, dist);
			o.Albedo = lineIntensity;*/

			// Smooth lerp in 2d
			/*float2 value = IN.worldPos.xy / _CellSize;
			float noise = ValueNoise2d(value);

			o.Albedo = noise;*/

			// Smooth lerp in 3d
			float3 value = IN.worldPos.xyz / _CellSize;
			float noise = ValueNoise3d(value);
			o.Albedo = noise;
		}
		ENDCG
	}
		FallBack "Diffuse"
}

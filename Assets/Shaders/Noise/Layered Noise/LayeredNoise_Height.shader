//https://www.ronja-tutorials.com/2018/09/22/layered-noise.html @TotallyRonja

///<summary>
/// Stacking multiple layers of noise on top of each other lets us keep the structure of softer noise but get the detail
/// of higher frequency noise. Works with Value and Perlin Noise
///<summary
Shader "Sid/LayeredNoise_Height"
{
	Properties
	{
		_CellSize("Cell Size", Range(0,50)) = 1
		_Roughness("Roughness", Range(0,50)) = 3
		_Persistance("Persistance", Range(0,1)) = 0.4
		_Amplitude("Amplitude", Range(0,10)) = 1

		_Color("Color", Color) = (0,0,0,0)
		_ScrollSpeed("Scroll Speed", Range(0,1)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows    vertex:vert addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "NoiseFunctions.cginc"
		struct Input
		{
			float3 worldPos;
		};

#define OCTAVES 4

		float _CellSize;
		float _Roughness;
		float _Persistance;
		float _Amplitude;

		float _ScrollSpeed;
		float4 _Color;

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

		float gradientNoise(float value) {
			float fraction = frac(value);
			float interpolator = easeInOut(fraction);
			float previousCellInclination = rand1dTo1d(floor(value)) * 2 - 1;
			float previousCellLinePoint = previousCellInclination * fraction;

			float nextCellInclination = rand1dTo1d(ceil(value)) * 2 - 1;
			float nextCellLinePoint = nextCellInclination * (fraction - 1);

			return lerp(previousCellLinePoint, nextCellLinePoint, interpolator);
		}

		float perlinNoise2d(float2 value) {
			//generate 4 verctors in the nearest 4 cells
			float2 lowerLeftDir = rand2dTo2d(float2(floor(value.x), floor(value.y))) * 2 - 1;
			float2 lowerRightDir = rand2dTo2d(float2(ceil(value.x), floor(value.y))) * 2 - 1;
			float2 upperLeftDir = rand2dTo2d(float2(floor(value.x), ceil(value.y))) * 2 - 1;
			float2 upperRightDir = rand2dTo2d(float2(ceil(value.x), ceil(value.y))) * 2 - 1;

			float2 fraction = frac(value);

			float2 lowerLeftFunctionValue = dot(lowerLeftDir, fraction - float2(0, 0));
			float2 lowerRightFunctionValue = dot(lowerRightDir, fraction - float2(1,0));
			float2 upperLeftFunctionValue = dot(upperLeftDir, fraction - float2(0,1));
			float2 upperRightFunctionValue = dot(upperRightDir, fraction - float2(1, 1));

			float interpolatorX = easeInOut(fraction.x);
			float interpolatorY = easeInOut(fraction.y);

			float lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
			float upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);

			float noise = lerp(lowerCells, upperCells, interpolatorY);
			return noise;
		}

		float perlinNoise3d(float3 value) {
			float3 fraction = frac(value);
			float interpolatorX = easeInOut(fraction.x);
			float interpolatorY = easeInOut(fraction.y);
			float interpolatorZ = easeInOut(fraction.z);

			//Generate random direction based on the cell
			//Generate comparison vector by subtracting the same value we used to get the cell from the factional vector
			//take dot product b/w the two vectors and assign to noise value that we interpolate
			float3 cellNoiseZ[2];
			[unroll]
			for (int z = 0; z <= 1; z++) {
				float3 cellNoiseY[2];
				[unroll]
				for (int y = 0; y <= 1; y++) {
					float3 cellNoiseX[2];
					[unroll]
					for (int x = 0; x <= 1; x++) {
						float3 cell = floor(value) + float3(x, y, z);
						float3 cellDirection = rand3dTo3d(cell) * 2 - 1;
						float3 compareVector = fraction - float3(x, y, z);
						cellNoiseX[x] = dot(cellDirection, compareVector);
					}
					cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
				}
				cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
			}

			float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			return noise;
		}

		float sampleLayeredNoise2O(float value) {
			float noise = gradientNoise(value);
			float highFreqNoise = gradientNoise(value * 6);
			noise = noise + highFreqNoise * 0.2;
			return noise;
		}

		float sampleLayeredNoise(float3 value) {
			float noise = 0;
			float frequency = 1;
			float factor = 1;

			[unroll]
			for(int i = 0; i < OCTAVES; i++) {
				noise = noise + perlinNoise3d(value * frequency + i * 0.72354) * factor;
				factor *= _Persistance;
				frequency *= _Roughness;
			}

			return noise;
		}

		float sampleLayeredNoise(float2 value) {
			float noise = 0;
			float frequency = 1;
			float factor = 1;

			[unroll]
			for (int i = 0; i < OCTAVES; i++) {
				noise = noise + perlinNoise2d(value * frequency + i * 0.72354) * factor;
				factor *= _Persistance;
				frequency *= _Roughness;
			}

			return noise;
		}


		void vert(inout appdata_full data) {
			//get real base position
			float3 localPos = data.vertex / data.vertex.w;

			//calculate new posiiton
			float3 modifiedPos = localPos;
			float2 basePosValue = mul(unity_ObjectToWorld, modifiedPos).xz / _CellSize;
			float basePosNoise = sampleLayeredNoise(basePosValue) + 0.5;
			modifiedPos.y += basePosNoise * _Amplitude;

			//calculate new position based on pos + tangent
			float3 posPlusTangent = localPos + data.tangent * 0.02;
			float2 tangentPosValue = mul(unity_ObjectToWorld, posPlusTangent).xz / _CellSize;
			float tangentPosNoise = sampleLayeredNoise(tangentPosValue) + 0.5;
			posPlusTangent.y += tangentPosNoise * _Amplitude;

			//calculate new position based on pos + bitangent
			float3 bitangent = cross(data.normal, data.tangent);
			float3 posPlusBitangent = localPos + bitangent * 0.02;
			float2 bitangentPosValue = mul(unity_ObjectToWorld, posPlusBitangent).xz / _CellSize;
			float bitangentPosNoise = sampleLayeredNoise(bitangentPosValue) + 0.5;
			posPlusBitangent.y += bitangentPosNoise * _Amplitude;

			//get recalculated tangent and bitangent
			float3 modifiedTangent = posPlusTangent - modifiedPos;
			float3 modifiedBitangent = posPlusBitangent - modifiedPos;

			//calculate new normal and set position + normal
			float3 modifiedNormal = cross(modifiedTangent, modifiedBitangent);
			data.normal = normalize(modifiedNormal);
			data.vertex = float4(modifiedPos.xyz, 1);
		}
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			//just for the fuck of it
			float3 value = IN.worldPos / _CellSize;
			float noise = sampleLayeredNoise(value) + 0.5;
			o.Albedo = lerp(_Color, noise, noise);

		}
		ENDCG
	}
		FallBack "Diffuse"
}

//https://www.ronja-tutorials.com/2018/09/15/perlin-noise.html @TotallyRonja
///<summary>
/// Perlin noise is one implementation of so called “gradient noise” similarly to value noise it’s based on cells so it can be easily 
/// repeated and looks smooth. What differentiates it from value noise is that instead of interpolating the values, the values are based 
/// on inclinations. 
///<summary
Shader "Sid/PerlinNoise"
{
    Properties
    {
		_CellSize("Cell Size", Range(0,50)) = 1
		_Color("Color", Color) = (0,0,0,0)
		_ScrollSpeed("Scroll Speed", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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



		float perlinNoise2D(float2 value) {
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
	

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //1d perlin noise
			/*float value = IN.worldPos.x / _CellSize;
			float noise = gradientNoise(value);
			float dist = abs(noise - IN.worldPos.y);
			float pixelHeight = fwidth(IN.worldPos.y);
			float lineIntensity = smoothstep(2 * pixelHeight, pixelHeight, dist);
			o.Albedo = lerp(1, 0, lineIntensity);*/

			//2d perlin noise
			/*float2 value = IN.worldPos.xy / _CellSize;
			float noise = perlinNoise2D(value) + 0.5;
			o.Albedo = noise;*/
			

			//3d perlin noise
			/*float3 value = IN.worldPos / _CellSize;
			float noise = perlinNoise3d(value) + 0.5;
			o.Albedo = noise;*/

			//Perlin noise itself usually just looks like weird clouds, but we can do some interresting effects with it if we know what we want.
			//As a first interresting thing, we can visualize lines where the noise has the same height, similar to height lines on maps.
			//To archieve that we multiply the noise to make the noise span a wider range.Then we take the fractional amount of that 
			//value and display it.
			float3 value = IN.worldPos / _CellSize;
			value.y += _Time.y * _ScrollSpeed;	
			value.x += tan(_Time.x * rand1dTo1d(.5)) * _ScrollSpeed;
			value.z += sin(_Time.z * rand1dTo1d(.5)) * _ScrollSpeed;
			float noise = perlinNoise3d(value) + 0.5;
			noise = frac(noise * 12);
			float pixelNoiseChange = fwidth(noise);

			float heightLine = smoothstep(1 - pixelNoiseChange, 1, noise);
			heightLine += smoothstep(pixelNoiseChange, 0, noise);

			o.Albedo = lerp(_Color, heightLine, heightLine);
			
        }
        ENDCG
    }
    FallBack "Diffuse"
}

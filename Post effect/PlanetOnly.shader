Shader "Custom/PostEffectAtmosphere/Planet Only"
{
	Properties
	{
		_BaseTex ("Base Texture", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}

		_GroundMask ("Ground Mask", 2D) = "white" {}
		_RangeGround ("Range Ground", Range(0.0,2.0)) = 0

		_SecondTex ("Second Texture", 2D) = "white" {}
		_SecondBump ("Second Normal", 2D) = "bump" {}

		_CloudsMask ("Clouds Mask", 2D) = "white" {}
		_RangeClouds ("Range Clouds", Range(0.0,2.0)) = 0

		_CloudsTex ("Clouds Texture", 2D) = "white" {}
		_CloudsBump ("Clouds Normal", 2D) = "bump" {}

		_GroundMix ("Ground Mix", Range(0.0,1.0)) = 0
		_CloudsMix ("Clouds Mix", Range(0.0,1.0)) = 0

		_AtmosphereColor ("Atmosphere Color", Color) = (1,1,1,1)
		_AtmosphereSize ("Atmosphere Size", Range (0, 2)) = 1
		_Ambient ("Ambient", Range (0, 1)) = 0
		_Intensive ("Intensive", Range (0, 1)) = 0
		_Specular ("Specular", Range (0, 100)) = 48.0
	}

	SubShader {

		Tags {"RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		//Выбираем модель освещения и версию шейдера
		#pragma surface surf Standard

		sampler2D _BaseTex;
		sampler2D _BumpMap;
		sampler2D _GroundMask;
		sampler2D _SecondTex;
		sampler2D _SecondBump;
		sampler2D _CloudsMask;
		sampler2D _CloudsTex;
		sampler2D _CloudsBump;

		float _RangeGround;
		float _RangeClouds;
		float _GroundMix;
		float _CloudsMix;
		  
		struct Input {
			float2 uv_BaseTex;
			float2 uv_BumpMap;
		};

		//Отображаем текстуры
		void surf (Input IN, inout SurfaceOutputStandard o) {
			half4 bt = tex2D (_BaseTex, IN.uv_BaseTex);
		    half4 bb = tex2D (_BumpMap, IN.uv_BumpMap);

			half4 gm = tex2D (_GroundMask, IN.uv_BaseTex);
			half4 st = tex2D (_SecondTex, IN.uv_BaseTex);
		    half4 sb = tex2D (_SecondBump, IN.uv_BumpMap);

		    half4 cm = tex2D (_CloudsMask, IN.uv_BaseTex + float2(_Time.x,0));
			half4 ct = tex2D (_CloudsTex, IN.uv_BaseTex + float2(_Time.x,0));
			half4 cb = tex2D (_CloudsBump, IN.uv_BumpMap + float2(_Time.x,0));

			half4 t;
			half4 b;

			if (gm.r > _RangeGround)
			{
				if (gm.r > _RangeGround + _GroundMix)
		    	{
		    		t = st;
		    		b = sb;
		    		o.Albedo = t;
		    		o.Normal = UnpackNormal(b);
		    	}
		    	else
		    	{
		    		float f = (gm.r - _RangeGround) / _GroundMix;
		    		t = lerp(bt, st, f);
		    		b = lerp(bb, sb, f);

		    		o.Albedo = t;
		    		o.Normal = UnpackNormal(b);
				}
			}
			else
			{
				t = bt;
		    	b = bb;
				o.Albedo = t;
		    	o.Normal = UnpackNormal(b);
			}

			if (cm.r > _RangeClouds)
			{
				if (cm.r > _RangeClouds + _CloudsMix)
		    	{
		    		o.Albedo = ct;
					o.Normal = UnpackNormal(cb);
		    	}
		    	else
		    	{
		    		float f = (cm.r - _RangeClouds) / _CloudsMix;
		    		o.Albedo = lerp(t, ct, f);
		    		o.Normal = UnpackNormal(lerp(b, cb, f));
				}
			}
		}
		ENDCG
	}
	Fallback "Diffuse"
}
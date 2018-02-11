Shader "Custom/Planet"
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
		_AtmosphereSize ("Atmosphere Size", Range (0, 1)) = 0.1
		_FalloffPlanet("Falloff Planet", Range (0.0, 10.0)) = 1
		_FalloffBack("Falloff Back", Range (0.0, 10.0)) = 0
		_TransparencyPlanet("Transparency Planet", Range (0.0, 20.0)) = 1

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

		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200

		Cull Front

		CGPROGRAM
		#pragma surface surf SimpleSpecular alpha vertex:vert

		half4 _AtmosphereColor;
      	float _AtmosphereSize;
      	float _FalloffPlanet;
      	float _FalloffBack;
        float _TransparencyPlanet;
        float _Specular;

      	struct Input {
            float3 worldPos;
    	};

    	half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
        	half3 h = normalize (lightDir + viewDir);

        	half diff = max (0, dot (s.Normal, lightDir));

        	float nh = max (0, dot (s.Normal, h));
        	float spec = pow (nh, _Specular);

        	half4 c;
        	c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
        	c.a = s.Alpha;

        	return c;
    	}

		void vert (inout appdata_full v) {

          	v.vertex.xyz += v.normal * _AtmosphereSize;
      	}

      	void surf (Input IN, inout SurfaceOutput o) {

            float3 viewdir = normalize (_WorldSpaceCameraPos - IN.worldPos);
            float4 atmo = _AtmosphereColor;

            //Рисуем плотную атмосферу (сзади) минус плотность от центра (в обратном порядке и вычитаем из плотного центра)
            atmo.a = 1 - saturate (dot (viewdir, -o.Normal));
			atmo.a = pow (atmo.a, _FalloffBack) - pow (atmo.a, _FalloffPlanet);

            //Увеличиваем яркость
            atmo.a *= _TransparencyPlanet;

            o.Albedo = atmo.rgb;
            o.Alpha = atmo.a;
      	}

		ENDCG

		Cull Back

		CGPROGRAM
		#pragma surface surf SimpleSpecular alpha vertex:vert

		half4 _AtmosphereColor;
      	float _AtmosphereSize;
      	float _FalloffPlanet;
      	float _FalloffBack;
        float _TransparencyPlanet;
        float _Specular;

      	struct Input {
            float3 worldPos;
    	};

    	half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
        	half3 h = normalize (lightDir + viewDir);

        	half diff = max (0, dot (s.Normal, lightDir));

        	float nh = max (0, dot (s.Normal, h));
        	float spec = pow (nh, _Specular);

        	half4 c;
        	c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
        	c.a = s.Alpha;

        	return c;
    	}

		void vert (inout appdata_full v) {

          	v.vertex.xyz += v.normal * _AtmosphereSize;
      	}

      	void surf (Input IN, inout SurfaceOutput o) {

            float3 viewdir = normalize (_WorldSpaceCameraPos - IN.worldPos);
            float4 atmo = _AtmosphereColor;

            //Рисуем плотную атмосферу минус плотность от центра (в обратном порядке и вычитаем из плотного центра)
            //atmo.a = pow (1 - saturate (dot (viewdir, o.Normal)), _FalloffBack) - pow (1 - saturate (dot (viewdir, o.Normal)), _FalloffPlanet);
            atmo.a = 1 - saturate (dot (viewdir, o.Normal));
			atmo.a = pow (atmo.a, _FalloffBack) - pow (atmo.a, _FalloffPlanet);

            //Увеличиваем яркость
            atmo.a *= _TransparencyPlanet;

            o.Albedo = atmo.rgb;
            o.Alpha = atmo.a;
      	}

		ENDCG
	}
	Fallback "Diffuse"
}
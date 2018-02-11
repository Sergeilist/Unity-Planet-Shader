Shader "Custom/PostEffectAtmosphere/Planet Atmosphere S"
{
	Properties
	{
		_AtmosphereColor ("Atmosphere Color", Color) = (1,1,1,1)
		_AtmosphereSize ("Atmosphere Size", float) = 0
		_Specular ("Specular", float) = 48.0
	}

	SubShader {

		Tags {"RenderType"="Opaque" "Queue" = "Transparent"}
		LOD 200

      	CGPROGRAM
      	#pragma surface surf SimpleSpecular alpha vertex:vert

      	half4 _AtmosphereColor;
      	float _AtmosphereSize;
      	float _Specular;

      	struct Input {
        	float4 color : COLOR;
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
   			o.Albedo = _AtmosphereColor.rgb;
   			o.Alpha = _AtmosphereColor.a;
      	}
      	ENDCG
	}
	Fallback "Diffuse"
}
Shader "Custom/PostEffectAtmosphere/Post Outline"
{
    Properties
    {
        //Graphics.Blit() в скрипте устанавливает переданную текстуру в свойство «_MainTex»
        _MainTex ("Main Texture", 2D) = "Black" {}
        _SceneTex ("Scene Texture", 2D) = "black" {}
        _OutlineSize ("Outline Size", int) = 0
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;

            //<SamplerName>_TexelSize - это float2, в котором указано, сколько пространства экрана занимает тексель
            float2 _MainTex_TexelSize;
            int _OutlineSize;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvs : TEXCOORD0;
            };

            v2f vert (float4 vertex : POSITION)
            {
                v2f o;

                //Несмотря на то, что мы рисуем квадрат только на экране, Unity требует, чтобы мы умножали вершины на нашу MVP-матрицу
                o.pos = UnityObjectToClipPos(vertex);

                //Также нам нужно исправить UVs, чтобы они соответствовали нашим координатам экрана. Для этого существует определение Unity, которое обычно должно использоваться
                o.uvs = o.pos.xy * 0.5 + 0.5;

                return o;
            }

            half4 frag (v2f i) : COLOR
            {
                //Произвольное количество итераций
                int NumberOfIterations = _OutlineSize;

                //Разделяем размер текселя на меньшее пространство
                float TX_x = _MainTex_TexelSize.x;

                //Конечная интенсивность, которая увеличивается на основе окружающих интенсивностей
                half4 ColorIntensityInRadius = 0;

                //Для каждой итерации нам нужно делать горизонтально
                for (int k = 0; k < NumberOfIterations; k += 1)
                {
                	//Увеличиваем наш выходной цвет на пиксели в области
                	half4 mt = tex2D (_MainTex, i.uvs.xy + float2 ((k - NumberOfIterations * 0.5) * TX_x, 0));
                	ColorIntensityInRadius += mt.rgba / NumberOfIterations;
                }

                //Выводим интенсивность
                return ColorIntensityInRadius;
            }
            ENDCG
        }
        //end pass

        GrabPass{}

        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //Нужно объявить sampler2D именем «_GrabTexture», которое Unity может записать во время GrabPass {}
            sampler2D _GrabTexture;
            sampler2D _MainTex;
            sampler2D _SceneTex;

            //<SamplerName>_TexelSize - это float2, в котором указано, сколько пространства экрана занимает тексель
            float2 _GrabTexture_TexelSize;
            int _OutlineSize;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvs : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;

                o.pos=UnityObjectToClipPos(v.vertex);
                o.uvs = o.pos.xy * 0.5 + 0.5;

                return o;
            }

            half4 frag (v2f i) : COLOR
            {
                //Произвольное количество итераций
                int NumberOfIterations = _OutlineSize;

                float TX_y=_GrabTexture_TexelSize.y;

                half4 ColorIntensityInRadius = 0;

                //Для каждой итерации делаем вертикально
                for(int j = 0; j < NumberOfIterations; j += 1)
                {
                	//Увеличиваем наш выходной цвет на пиксели в области
                	half4 gt = tex2D (_GrabTexture, float2 (i.uvs.x, 1 - i.uvs.y) + float2 (0, (j - NumberOfIterations * 0.5) * TX_y));
                	ColorIntensityInRadius += gt.rgba / NumberOfIterations;
                }

                //Это альфа-смешивание, мы не можем использовать HW-смешивание, если мы не сделаем третий проход, так что это, вероятно, дешевле.
                half4 outcolor = ColorIntensityInRadius + (1 - ColorIntensityInRadius) * tex2D (_SceneTex, float2 (i.uvs.x, i.uvs.y));
                return outcolor;
            }
            ENDCG
        }
        //end pass
    }
    //end subshader
}
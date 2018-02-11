using UnityEngine;

public class PostEffectAtmosphere : MonoBehaviour {

	[Header("Обводка планет атмосферой")]
	public Shader m_DrawAtmosphere;
	public Shader m_PostOutline;
	public LayerMask m_Layer;

	[Range(0,200)]
	public int m_Size;

	Camera m_AttachedCamera;
	Camera m_TempCam;
	Material m_PostMat;


	void Start ()
	{
		m_AttachedCamera = GetComponent<Camera> ();

		m_TempCam = new GameObject ().AddComponent<Camera> ();
		m_TempCam.enabled = false;

		m_PostMat = new Material (m_PostOutline);
	}

	//Вызывается от камеры на которой этот скрипт
	//Передает полученное изображение и не отображает его на экране
	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		//Настраиваем временную камеру
		m_TempCam.CopyFrom (m_AttachedCamera);
		m_TempCam.clearFlags = CameraClearFlags.Color;
		m_TempCam.backgroundColor = Color.black;

		//Отображаем только выбранный слой
		m_TempCam.cullingMask = m_Layer.value;

		//Создаем временную визуализацию (RenderTextureFormat.Default работает, а .R8 нет)
		RenderTexture TempRT = new RenderTexture (source.width, source.height, 0, RenderTextureFormat.Default);

		//Помещаем ее в видеопамять
		TempRT.Create ();

		//Задаем целевую текстуру камеры при рендеринге
		m_TempCam.targetTexture = TempRT;

		//Визуализируем все объекты, которые может отображать эта камера, но с нашим пользовательским шейдером
		m_TempCam.RenderWithShader (m_DrawAtmosphere, "");

		//Устанавливаем текстуру сцены в шейдер матеряла
		m_PostMat.SetTexture ("_SceneTex", source);
		m_PostMat.SetInt ("_OutlineSize", m_Size);

		//Копируем временную RT в окончательное изображение
		Graphics.Blit (TempRT, destination, m_PostMat);

		//Выпуск временной RT
		TempRT.Release ();
	}
}
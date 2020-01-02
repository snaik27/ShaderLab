using UnityEngine;
[ImageEffectAllowedInSceneView, ExecuteInEditMode]

///<summary>
/// ToDo:
/// 1. Read up on BitMasks
/// 2. Experiment with camera textures
///</summary>
public class PP_DepthRead : MonoBehaviour
{
    [SerializeField]
    private Material postProcessMaterial;
    [SerializeField]
    private float waveSpeed;
    [SerializeField]
    private bool waveActive;

    private float waveDistance;

    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        //Generate depth texture. SUPER SICK OTHER STUFF YOU CAN GENERATE: View Space Normals, per-pixel scren space Motion Vectors
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;

    }

    private void Update()
    {
        //if the wave is active, make it move away, otherwise reset it
        if (waveDistance < 300)
        {
            waveDistance = waveDistance + waveSpeed * Time.deltaTime;
        }
        else
        {
            waveDistance = 0;
        }
    }


     private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        postProcessMaterial.SetFloat("_WaveDistance", waveDistance);
        Graphics.Blit(source, destination, postProcessMaterial);
    }
}

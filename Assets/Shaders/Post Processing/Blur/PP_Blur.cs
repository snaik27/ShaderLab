//https://www.ronja-tutorials.com/2018/08/27/postprocessing-blur.html @TotallyRonja

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView, ExecuteInEditMode]
public class PP_Blur : MonoBehaviour
{
    [SerializeField]
    private Material postProcessMaterial;

    private Camera cam;

    private void Start()
    {
        //cam = GetComponent<Camera>();
        //Generate depth texture. SUPER SICK OTHER STUFF YOU CAN GENERATE: View Space Normals, per-pixel scren space Motion Vectors
        //cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;

    }



    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        var tempTexture = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(source, tempTexture, postProcessMaterial, 0);
        //Convert view normals (for normals read) to world normals using provided matrix
        Graphics.Blit(tempTexture, destination, postProcessMaterial, 1);
        RenderTexture.ReleaseTemporary(tempTexture);
    }
}

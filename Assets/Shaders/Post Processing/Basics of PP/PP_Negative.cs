using UnityEngine;
[ImageEffectAllowedInSceneView, ExecuteInEditMode]
public class PP_Negative : MonoBehaviour
{
    [SerializeField]
    private Material postProcessMaterial;

   


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postProcessMaterial);
    }
}

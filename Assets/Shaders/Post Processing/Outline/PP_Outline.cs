﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ImageEffectAllowedInSceneView, ExecuteInEditMode]

public class PP_Outline : MonoBehaviour
{
    [SerializeField]
    private Material postProcessMaterial;

    private Camera cam;

    private void Start()
    {
        cam = GetComponent<Camera>();
        //Generate depth texture. SUPER SICK OTHER STUFF YOU CAN GENERATE: View Space Normals, per-pixel scren space Motion Vectors
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;

    }



    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //Convert view normals (for normals read) to world normals using provided matrix
        Graphics.Blit(source, destination, postProcessMaterial);
    }
}

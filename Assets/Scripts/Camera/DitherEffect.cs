using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DitherEffect : MonoBehaviour
{
    public Shader ditherShader;
    private Material ditherMaterial;

    public Texture2D thresholdMap;
    [Range(1, 8)] public int ditherSize = 4;
    [Range(1, 100)] public int colNum = 4;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (ditherMaterial == null)
        {
            ditherMaterial = new Material(ditherShader);
        }

        ditherMaterial.SetTexture("_ThresholdMap", thresholdMap);
        ditherMaterial.SetFloat("_DitherSize", ditherSize);
        ditherMaterial.SetFloat("_ColNum", colNum);

        Graphics.Blit(src, dest, ditherMaterial);
    }
}


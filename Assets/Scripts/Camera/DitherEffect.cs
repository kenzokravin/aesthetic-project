using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DitherEffect : MonoBehaviour
{
    public Shader ditherShader;
    private Material ditherMaterial;

    public Texture2D thresholdMap;
    [Range(1, 8)] public int ditherSize = 4;
    [Range(1, 2048)] public int colNum = 4;

    [Range(0, 2)] public float renderScale = .5f;
    [Range(0, 2)] public float sharpScale = 1f;

    [Range(0, 1)] public int isDithering = 0;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (ditherMaterial == null)
        {
            ditherMaterial = new Material(ditherShader);
        }

        // Calculate the low-resolution size
        int width = Mathf.CeilToInt(src.width * renderScale);
        int height = Mathf.CeilToInt(src.height * renderScale);

        // Create a temporary low-res RenderTexture with point filtering
        RenderTexture lowRes = RenderTexture.GetTemporary(width, height, 0, src.format);
        lowRes.filterMode = FilterMode.Point;

        // Set source filter mode (optional but good practice)
        src.filterMode = FilterMode.Point;

        // Blit from full-res to low-res (downsampling, point-filtered)
        Graphics.Blit(src, lowRes);

        // Set shader properties
        ditherMaterial.SetFloat("_DitherSize", ditherSize);
        ditherMaterial.SetFloat("_Sharpness", sharpScale);
        ditherMaterial.SetFloat("_ColNum", colNum);
        ditherMaterial.SetInt("_IsDithering", isDithering);
        ditherMaterial.SetTexture("_ThresholdMap", thresholdMap);
        ditherMaterial.SetVector("_TexelSize", new Vector4(1.0f / width, 1.0f / height, width, height));



        // Blit from low-res to screen (upsampling, point-filtered, with dithering shader)
        Graphics.Blit(lowRes, dest, ditherMaterial);

        // Cleanup
        RenderTexture.ReleaseTemporary(lowRes);
    }

}


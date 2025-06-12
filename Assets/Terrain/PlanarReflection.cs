using UnityEngine;

[ExecuteInEditMode]
public class PlanarReflection : MonoBehaviour
{
    public Camera reflectionCamera;
    public RenderTexture reflectionTexture;
    public Shader replacementShader; // Optional: Use it for toon style if needed

    private Camera mainCamera;

    void OnEnable()
    {
        mainCamera = Camera.main;

        if (!reflectionTexture)
        {
            reflectionTexture = new RenderTexture(1024, 1024, 16);
            reflectionTexture.name = "PlanarReflectionRT";
        }

        if (!reflectionCamera)
        {
            GameObject go = new GameObject("ReflectionCamera");
            reflectionCamera = go.AddComponent<Camera>();
            reflectionCamera.enabled = false;
        }

        reflectionCamera.cullingMask = mainCamera.cullingMask & ~(1 << LayerMask.NameToLayer("Water"));

    }

    void LateUpdate()
    {
        if (!mainCamera || !reflectionCamera || !reflectionTexture) return;

        Vector3 pos = transform.position;
        Vector3 normal = transform.up;

        // Reflect camera
        Vector3 camPos = mainCamera.transform.position;
        Vector3 camDir = mainCamera.transform.forward;
        float d = -Vector3.Dot(normal, pos);
        Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

        Matrix4x4 reflectionMat = Matrix4x4.zero;
        CalculateReflectionMatrix(ref reflectionMat, reflectionPlane);

        reflectionCamera.CopyFrom(mainCamera);
        reflectionCamera.worldToCameraMatrix = mainCamera.worldToCameraMatrix * reflectionMat;

        Vector4 clipPlane = CameraSpacePlane(reflectionCamera, pos, normal, 1.0f);
        Matrix4x4 projection = mainCamera.CalculateObliqueMatrix(clipPlane);
        reflectionCamera.projectionMatrix = projection;

        reflectionCamera.targetTexture = reflectionTexture;

        Shader.SetGlobalMatrix("_MainCameraVP", mainCamera.projectionMatrix * mainCamera.worldToCameraMatrix);


        GL.invertCulling = true;
        reflectionCamera.Render();
        GL.invertCulling = false;

        Shader.SetGlobalTexture("_ReflectionTex", reflectionTexture);
    }

    // Helper methods
    private static Matrix4x4 CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = 1F - 2F * plane[0] * plane[0];
        reflectionMat.m01 = -2F * plane[0] * plane[1];
        reflectionMat.m02 = -2F * plane[0] * plane[2];
        reflectionMat.m03 = -2F * plane[3] * plane[0];

        reflectionMat.m10 = -2F * plane[1] * plane[0];
        reflectionMat.m11 = 1F - 2F * plane[1] * plane[1];
        reflectionMat.m12 = -2F * plane[1] * plane[2];
        reflectionMat.m13 = -2F * plane[3] * plane[1];

        reflectionMat.m20 = -2F * plane[2] * plane[0];
        reflectionMat.m21 = -2F * plane[2] * plane[1];
        reflectionMat.m22 = 1F - 2F * plane[2] * plane[2];
        reflectionMat.m23 = -2F * plane[3] * plane[2];

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;

        return reflectionMat;
    }

    private static Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign)
    {
        Vector3 offsetPos = pos + normal * 0.05f;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cPos = m.MultiplyPoint(offsetPos);
        Vector3 cNormal = m.MultiplyVector(normal).normalized * sideSign;

        return new Vector4(cNormal.x, cNormal.y, cNormal.z, -Vector3.Dot(cPos, cNormal));
    }
}


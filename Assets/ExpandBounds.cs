using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter))]
public class ExpandBounds : MonoBehaviour
{
    public float boundsPadding = 50f;

    void Awake()
    {
        var mf = GetComponent<MeshFilter>();
        if (mf)
        {
            var mesh = mf.sharedMesh;
            if (mesh != null)
            {
                var bounds = mesh.bounds;
                bounds.Expand(boundsPadding);
                mesh.bounds = bounds;
            }
        }
    }
}


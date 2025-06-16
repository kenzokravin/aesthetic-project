using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class GeneratePointMesh : MonoBehaviour
{
    void Awake()
    {
        Mesh m = new Mesh();
        m.vertices = new Vector3[] { Vector3.zero };
        m.SetIndices(new int[] { 0 }, MeshTopology.Points, 0);
        GetComponent<MeshFilter>().mesh = m;
    }
}

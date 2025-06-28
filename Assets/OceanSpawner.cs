using UnityEngine;

public class OceanSpawner : MonoBehaviour
{
    public Transform player;              // Reference to player (follow target)
    public Vector2 planeSize = new Vector2(10, 10); // Size of each plane
    public int centerResolution = 20;    // Highest mesh resolution
    public int rings = 2;                 // How many rings out from center (1 ring = 8 tiles)
    public Material oceanMaterial;        // Material to apply to each plane
    public float oceanHeight;
    public int baseRes = 64;
    public float baseSize = 10f;

    private Transform oceanParent;

    void Start()
    {


        GenerateOcean();
       Shader.SetGlobalVector("_PlaneSize", planeSize);
      


    }

    void LateUpdate()
    {
        if (player && oceanParent)
        {
            oceanParent.position = new Vector3(player.position.x, oceanHeight, player.position.z);
            Shader.SetGlobalVector("_OceanManagerPos", oceanParent.position);

            //  Shader.SetGlobalVector("_WaveFalloffCentre", player.transform.position);
        }
    }

    void GenerateOcean()
    {
        oceanParent = new GameObject("OceanContainer").transform;
        oceanParent.parent = this.transform;

        int totalRings = rings + 1; // including center
        for (int ring = 0; ring <= rings; ring++)
        {
            // int density = Mathf.RoundToInt(Mathf.Lerp(centerResolution, 10, (float)ring / rings));

            int density = Mathf.Max(4, centerResolution / (int)Mathf.Pow(2, ring));


            for (int x = -ring; x <= ring; x++)
            {
                for (int z = -ring; z <= ring; z++)
                {
                    // Only spawn outer ring tiles to avoid duplication
                    if (Mathf.Abs(x) != ring && Mathf.Abs(z) != ring && ring != 0) continue;

                    Vector3 spawnPosition = new Vector3(x * planeSize.x, 0, z * planeSize.y);
                    GameObject plane = GeneratePlane(density, planeSize,spawnPosition);
                    plane.transform.position = spawnPosition;
                    plane.transform.parent = oceanParent;
                }
            }
        }
    }

    GameObject GeneratePlane(int resolution, Vector2 size, Vector3 spawnPosition)
    {
        GameObject plane = new GameObject($"OceanPlane_{resolution}");
        MeshFilter mf = plane.AddComponent<MeshFilter>();
        MeshRenderer mr = plane.AddComponent<MeshRenderer>();

        if (oceanMaterial != null)
        {
            mr.material = oceanMaterial;
            // Example origin vector
            Vector3 planeOrigin = new Vector3(spawnPosition.x, 0f, spawnPosition.y);

            // Set the _PlaneOrigin property on the material
            mr.material.SetVector("_PlaneOrigin", planeOrigin);
        }


        Mesh mesh = new Mesh();
        Vector3[] vertices = new Vector3[(resolution + 1) * (resolution + 1)];
        int[] triangles = new int[resolution * resolution * 6];
        Vector2[] uvs = new Vector2[vertices.Length];

        for (int z = 0, i = 0; z <= resolution; z++)
        {
            for (int x = 0; x <= resolution; x++, i++)
            {
                float xPos = ((float)x / resolution - 0.5f) * size.x;
                float zPos = ((float)z / resolution - 0.5f) * size.y;
                vertices[i] = new Vector3(xPos, 0, zPos);
                uvs[i] = new Vector2((float)x / resolution, (float)z / resolution);
            }
        }

        for (int z = 0, ti = 0, vi = 0; z < resolution; z++, vi++)
        {
            for (int x = 0; x < resolution; x++, ti += 6, vi++)
            {
                triangles[ti] = vi;
                triangles[ti + 1] = vi + resolution + 1;
                triangles[ti + 2] = vi + 1;
                triangles[ti + 3] = vi + 1;
                triangles[ti + 4] = vi + resolution + 1;
                triangles[ti + 5] = vi + resolution + 2;
            }
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();

        mf.mesh = mesh;

        return plane;
    }
}

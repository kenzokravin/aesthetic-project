using UnityEngine;

public class OceanPlaneManager : MonoBehaviour
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

        Shader.SetGlobalVector("_PlaneSize", planeSize);



    }

    void LateUpdate()
    {
        if (player)
        {
            gameObject.transform.position = new Vector3(player.position.x, oceanHeight, player.position.z);
           /* Shader.SetGlobalVector("_OceanManagerPos", oceanParent.position);*/
            Vector4 waveCentre = new Vector4(gameObject.transform.position.x, 0f, gameObject.transform.position.z, 1.0f);
            Shader.SetGlobalVector("_WaveFalloffC", waveCentre);


           /* var mr = GetComponent<Renderer>();
            mr.sharedMaterial.SetVector("_WaveFalloffC", waveCentre);*/

            if (oceanMaterial)
            {
                //oceanMaterial.SetVector("_WaveFalloffCentre", gameObject.transform.position);
                //GetComponent<Renderer>().sharedMaterial.SetVector("_WaveFalloffCentre", gameObject.transform.position);
            }

            //  Shader.SetGlobalVector("_WaveFalloffCentre", player.transform.position);
        }
        
    }



}

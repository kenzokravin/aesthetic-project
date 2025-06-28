using UnityEngine;

public class PlayerCameraFollow : MonoBehaviour
{

    [SerializeField] Transform player; //player transform
    [SerializeField] Vector3 cameraPosition; //Position of camera relative to player.
    [SerializeField] Transform oceanPlane;
    public float baseScale = 1f;
    public float scaleFactor = 0.1f;

    void Start()
    {
        
    }

    // Update is called once per frame
    void LateUpdate()
    {
        FollowPlayer();
        ScaleOceanMesh();
        
    }

    private void FollowPlayer()
    {
        if (player)
        {

            gameObject.transform.position = (player.position + cameraPosition);

        }
    }

    private void ScaleOceanMesh()
    {
        float camY = gameObject.transform.position.y;
        float newScale = baseScale + (camY * scaleFactor);
        newScale = Mathf.Max(newScale, baseScale); // optional: prevent shrinking below base scale

        oceanPlane.localScale = new Vector3(newScale, newScale, newScale);
    }
}

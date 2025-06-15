using UnityEngine;

public class BoatRipple : MonoBehaviour
{

    [SerializeField] public GameObject waterObj;
    [SerializeField] private Material waterMat;

    private bool isMoving = true;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

  /*      waterMat.SetVector("_RippleOrigin", gameObject.transform.position);
        waterMat.SetFloat("_RippleStartTime", Time.time);
*/

    }

    // Update is called once per frame
    void Update()
    {
        RenderRipple();
        
    }

    private void RenderRipple()
    {
        if (!isMoving || waterMat == null)
        {
            return;
        }

        Debug.Log("Rippling");

        //waterMat.SetVector("_RippleOrigin", gameObject.transform.position);
       // waterMat.SetFloat("_RippleStartTime",Time.time);



    }


}

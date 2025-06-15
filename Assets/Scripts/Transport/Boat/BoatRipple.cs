using UnityEngine;

public class BoatRipple : MonoBehaviour
{

    [SerializeField] public GameObject waterObj;
    [SerializeField] private Material waterMat;

    const int MAX_RIPPLES = 10;

    Vector4[] rippleOrigins = new Vector4[MAX_RIPPLES];
    float[] rippleStartTimes = new float[MAX_RIPPLES];
    float[] rippleActives = new float[MAX_RIPPLES];


    private bool isMoving = true;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

        /*      waterMat.SetVector("_RippleOrigin", gameObject.transform.position);
              waterMat.SetFloat("_RippleStartTime", Time.time);
      */
        rippleOrigins[0] = new Vector4(0, 0, 0, 0);
        rippleStartTimes[0] = Time.time;
        rippleActives[0] = 1;

        rippleOrigins[1] = new Vector4(2, 0, 2, 0);
        rippleStartTimes[1] = Time.time + 0.02f;
        rippleActives[1] = 1;



        PushToShader();

    }

    // Update is called once per frame
    void Update()
    {
        
        
    }

    private void RenderRipple()
    {
        if (!isMoving || waterMat == null)
        {
            return;
        }

        Debug.Log("Rippling: " + Time.time);

        //waterMat.SetVector("_RippleOrigin", gameObject.transform.position);

        //Issue with sending Time.time is that it is constantly increasing, therefore it doesn't let the ripple develop.
        waterMat.SetFloat("_RippleStartTime",0.0f);


       

    }

    private void PushToShader()
    {



        waterMat.SetVectorArray("_RippleOrigins", rippleOrigins);
        waterMat.SetFloatArray("_RippleStartTimes", rippleStartTimes);
        waterMat.SetFloatArray("_RippleActives", rippleActives);

    }


}

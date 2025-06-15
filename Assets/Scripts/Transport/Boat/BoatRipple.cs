using UnityEngine;

public class BoatRipple : MonoBehaviour
{

    [SerializeField] public GameObject waterObj;
    [SerializeField] private Material waterMat;

    const int MAX_RIPPLES = 10;
    
    private float RIPPLE_LIFETIME = 1.0f;

    Vector4[] rippleOrigins = new Vector4[MAX_RIPPLES];
    float[] rippleStartTimes = new float[MAX_RIPPLES];
    float[] rippleActives = new float[MAX_RIPPLES];


    private bool isMoving = true;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

       waterMat.SetFloat("_RippleLifetime",RIPPLE_LIFETIME);
           //   waterMat.SetFloat("_RippleStartTime", Time.time);
     

        for(int i = 0; i < MAX_RIPPLES; i++)
        {
            rippleOrigins[i] = new Vector4(0, 0, 0, 0);
            rippleStartTimes[i] = Time.time + i*RIPPLE_LIFETIME/MAX_RIPPLES;
            rippleActives[i] = 1;
        }


        PushToShader();

    }

    // Update is called once per frame
    void Update()
    {
        UpdateRippleLife();
        
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
        Debug.Log("Pushing to Shader");
        waterMat.SetVectorArray("_RippleOrigins", rippleOrigins);
        waterMat.SetFloatArray("_RippleStartTimes", rippleStartTimes);
        waterMat.SetFloatArray("_RippleActives", rippleActives);
    }

    private void UpdateRippleLife()
    {
        float currentTime = Time.time;
        bool isUpdated = false;

        for (int i = 0; i < MAX_RIPPLES; i++)
        {
            // Skip inactive ripples
            if (rippleActives[i] == 0)
                continue;

            // Check ripple age
            float age = currentTime - rippleStartTimes[i];

            if (age < RIPPLE_LIFETIME) //If ripple is younger than lifetime, skip.
            {
                continue;
            }

            if (age >= RIPPLE_LIFETIME)
            {
                rippleActives[i] = 0; // Mark as inactive if older than lifetime.
            }

            Vector4 retVec = gameObject.transform.position;

            retVec.x = retVec.x + GetRandomOffset();
            retVec.y = retVec.y + GetRandomOffset();
            retVec.z = retVec.z + GetRandomOffset();

            rippleOrigins[i] = retVec;
            rippleStartTimes[i] = Time.time;
            rippleActives[i] = 1;

            Debug.Log("Updated:" + i);
            isUpdated = true;

        }

        if (isUpdated)
        {
            PushToShader();
        }
    }

    private float GetRandomOffset()
    {
        float offset = 0;


        offset = Random.Range(-1f, 1f);


        return offset;

    }


}

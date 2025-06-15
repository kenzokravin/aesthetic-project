using UnityEngine;

public class BoatRipple : MonoBehaviour
{

    [SerializeField] public GameObject waterObj;
    [SerializeField] private Material waterMat;

    const int MAX_RIPPLES = 10;
    private float rippleLifetime = 3f;

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

        rippleOrigins[2] = new Vector4(4, 0, 2, 0);
        rippleStartTimes[2] = Time.time + 0.4f;
        rippleActives[2] = 1;

        rippleOrigins[3] = new Vector4(3, 0, 3, 0);
        rippleStartTimes[3] = Time.time + 0.2f;
        rippleActives[3] = 1;

        rippleOrigins[4] = new Vector4(-1, 0, 2, 0);
        rippleStartTimes[4] = Time.time + 3f;
        rippleActives[4] = 1;

        rippleOrigins[5] = new Vector4(-3, 0, 2, 0);
        rippleStartTimes[5] = Time.time + 1.0f;
        rippleActives[5] = 1;

        rippleOrigins[6] = new Vector4(-1, 0, 23, 0);
        rippleStartTimes[6] = Time.time + 1.0f;
        rippleActives[6] = 1;

        rippleOrigins[7] = new Vector4(-2, 0, 10, 0);
        rippleStartTimes[7] = Time.time + 2.0f;
        rippleActives[7] = 1;

        rippleOrigins[8] = new Vector4(-3, 0, 5, 0);
        rippleStartTimes[8] = Time.time + 1.3f;
        rippleActives[8] = 1;

        rippleOrigins[9] = new Vector4(-1, 0, 2, 0);
        rippleStartTimes[9] = Time.time + 1.4f;
        rippleActives[9] = 1;



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

            if (age < rippleLifetime)
            {
                continue;
            }

            if (age >= rippleLifetime)
            {
                rippleActives[i] = 0; // Mark as inactive
            }

            rippleOrigins[i] = new Vector4(0, 0, 0, 0);
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

    private void UpdateRipples()
    {

        for (int i = 0; i < MAX_RIPPLES; i++)
        {
            // Skip inactive ripples
            if (rippleActives[i] == 0)
                continue;
            }

        }

    }

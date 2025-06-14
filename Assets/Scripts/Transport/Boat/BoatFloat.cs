using UnityEngine;

public class BoatFloat : MonoBehaviour
{
    public GameObject boat;
    public Rigidbody rb;
    [SerializeField] private GameObject waterObj;

    public float waveFrequency = 1.0f;  // _WaveFreq
    public float waveHeightMultiplier = 1.0f;  // _WaveFreq
    public float waveAmplitude = 1.0f;  // _WaveAmp
    public float baseWaterLevel = 13.5f; // Flat baseline Y level
    public Vector3 waveDirection = Vector3.right; // (1, 0, 0)


    // Start is called once before the first execution of Update after the MonoBehaviour is created

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        boat = this.gameObject;

        baseWaterLevel = waterObj.transform.position.y;
    }

    void Start()
    {

        baseWaterLevel = waterObj.transform.position.y;


    }

    // Update is called once per frame
    void Update()
    {

        UpdateBoatTransform();


    }

    float GetWaveHeight(Vector3 pos, float time)
    {
        Vector3 dir = waveDirection.normalized; // Set from shader
        float waveFreq = waveFrequency;
        float waveAmp = waveAmplitude;

        float defaultWavelength = 2 * Mathf.PI;
        float wavelength = defaultWavelength / waveFreq;

        float phase = Mathf.Sqrt(9.8f / wavelength);
        float disp = wavelength * (Vector3.Dot(dir, pos) - phase * time);

        return waveAmp * Mathf.Sin(disp);
    }

    Vector3 GetWaveNormal(Vector3 pos, float time)
    {
        float delta = 0.1f;

        Vector3 offsetX = new Vector3(delta, 0, 0);
        Vector3 offsetZ = new Vector3(0, 0, delta);

        float hL = GetWaveHeight(pos - offsetX, time);
        float hR = GetWaveHeight(pos + offsetX, time);
        float hD = GetWaveHeight((pos - offsetZ), time);
        float hU = GetWaveHeight(pos + offsetZ, time);

        Vector3 dx = new Vector3(2 * delta, hR - hL, 0);
        Vector3 dz = new Vector3(0, hU - hD, 2 * delta);

        Vector3 normal = Vector3.Cross(dz * waveHeightMultiplier, dx).normalized;
        return normal;
    }

    void UpdateBoatTransform()
    {
        Vector3 boatPos = boat.transform.position;
        float time = Time.time;

        // Set height
        float waveHeight = GetWaveHeight(boatPos, time);
        boatPos.y = baseWaterLevel + waveHeight;
        boat.transform.position = boatPos;

        // Set rotation to match surface normal
        Vector3 normal = GetWaveNormal(boatPos, time);

        // Maintain forward direction but tilt to match wave
        Vector3 forward = boat.transform.forward;
        Vector3 right = Vector3.Cross(normal, forward).normalized;
        forward = Vector3.Cross(right, normal).normalized;

        Quaternion targetRot = Quaternion.LookRotation(forward, normal);
        boat.transform.rotation = Quaternion.Slerp(boat.transform.rotation, targetRot, Time.deltaTime * 3f);
    }
}

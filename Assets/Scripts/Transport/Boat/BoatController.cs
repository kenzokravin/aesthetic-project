using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class BoatController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float acceleration = 10f;
    public float turnTorque = 5f;
    public float maxSpeed = 8f;
    public float waterDrag = 1f;

    public float leanMultiplier = 15f;
    public float leanMultiplierFront = 15f;  // Controls how much the boat leans
    public float maxLeanAngle = 20f;        // Max angle the boat can lean
    public float leanSmoothSpeed = 2f;      // How smoothly the boat rotates to the lean
    private Vector3 prevVelocity = Vector3.zero;

    public GameObject boatMesh;

    public bool isMoving = false;

    public Rigidbody rb;

    void Awake()
    {
        
        rb = gameObject.GetComponent<Rigidbody>();
        rb.linearDamping = waterDrag;
        rb.angularDamping = 2f; // Reduce spinning
        isMoving = false;
    }

    private void Start()
    {
        rb = gameObject.GetComponent<Rigidbody>();
    }



    void FixedUpdate()
    {
        HandleMovement();
    }

    void HandleMovement()
    {
        float moveInput = Input.GetAxis("Vertical");   // W/S
        float turnInput = Input.GetAxis("Horizontal"); // A/D

        isMoving = true;

        // Forward thrust
        Vector3 forwardForce = transform.forward * moveInput * acceleration;
        if (rb.linearVelocity.magnitude < maxSpeed)
            rb.AddForce(forwardForce, ForceMode.Acceleration);

        // Turning (torque on Y-axis)
        rb.AddTorque(Vector3.up * turnInput * turnTorque, ForceMode.Acceleration);

        HandleAngle();
    }

    void HandleAngle()
    {
        if(!isMoving)
        {

            return;

        }



        Vector3 deltaVelocity = rb.linearVelocity - prevVelocity;

        if (Vector3.Dot(deltaVelocity, boatMesh.transform.forward) < 0)
        {

        } else
        {

        }

        // How much the boat is turning (positive or negative)
        float accelAmount = (deltaVelocity).magnitude;
        float turnAmount = rb.angularVelocity.y;


        // Leaning angle based on turn speed
        float targetLeanAngleFront = -accelAmount * leanMultiplierFront; // negative = lean away
        float targetLeanAngleSide = -turnAmount * leanMultiplier; // negative = lean away

        // Clamp the lean angle to prevent extreme banking
        targetLeanAngleFront = Mathf.Clamp(targetLeanAngleFront, -maxLeanAngle, maxLeanAngle);
        targetLeanAngleSide = Mathf.Clamp(targetLeanAngleSide, -maxLeanAngle, maxLeanAngle);

        // Smoothly interpolate current rotation to the target lean
        Quaternion targetRotation = Quaternion.Euler(targetLeanAngleFront, transform.eulerAngles.y, targetLeanAngleSide);

        // Smoothly rotate the boat toward this lean angle
        boatMesh.transform.rotation = Quaternion.Slerp(boatMesh.transform.rotation, targetRotation, Time.deltaTime * leanSmoothSpeed);

        prevVelocity = rb.linearVelocity;

    }
}




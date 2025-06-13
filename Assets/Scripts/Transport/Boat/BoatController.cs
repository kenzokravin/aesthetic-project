using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class BoatController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float acceleration = 10f;
    public float turnTorque = 5f;
    public float maxSpeed = 8f;
    public float waterDrag = 1f;

    public Rigidbody rb;

    void Awake()
    {

        rb = gameObject.GetComponent<Rigidbody>();
        rb.linearDamping = waterDrag;
        rb.angularDamping = 2f; // Reduce spinning
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

        // Forward thrust
        Vector3 forwardForce = transform.forward * moveInput * acceleration;
        if (rb.linearVelocity.magnitude < maxSpeed)
            rb.AddForce(forwardForce, ForceMode.Acceleration);

        // Turning (torque on Y-axis)
        rb.AddTorque(Vector3.up * turnInput * turnTorque, ForceMode.Acceleration);
    }
}




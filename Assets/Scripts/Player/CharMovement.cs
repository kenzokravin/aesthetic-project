using UnityEngine;

public class CharMovement : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float turnSpeed = 720f; // degrees per second

    private Rigidbody rb;
    private Vector3 inputDirection;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        // Get input
        float h = Input.GetAxis("Horizontal"); // A/D or Left/Right
        float v = Input.GetAxis("Vertical");   // W/S or Up/Down

        // Direction relative to camera (optional)
        inputDirection = new Vector3(h, 0, v).normalized;
    }

    void FixedUpdate()
    {
        if (inputDirection.magnitude >= 0.1f)
        {
            // Move
            Vector3 move = inputDirection * moveSpeed;
            rb.MovePosition(rb.position + move * Time.fixedDeltaTime);

            // Face movement direction
            Quaternion targetRotation = Quaternion.LookRotation(inputDirection);
            rb.MoveRotation(Quaternion.RotateTowards(transform.rotation, targetRotation, turnSpeed * Time.fixedDeltaTime));
        }
    }
}

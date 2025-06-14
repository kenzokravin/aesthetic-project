using UnityEngine;

public class BoidComputeController : MonoBehaviour
{
    struct Boid
    {
        public Vector3 position;
        public Vector3 velocity;
    }

    [Header("Rendering")]
    public Mesh boidMesh;
    public Material boidMaterial;

    [Header("Simulation Settings")]
    public ComputeShader boidCompute;
    public int boidCount = 1024;
    public float viewRadius = 2f;
    public float avoidRadius = 1f;
    public float maxSpeed = 5f;
    public float alignmentWeight = 1f;
    public float cohesionWeight = 1f;
    public float separationWeight = 1.5f;

    ComputeBuffer boidBuffer;
    ComputeBuffer matrixBuffer;
    ComputeBuffer argsBuffer;

    Boid[] boidArray;
    int kernelID;

    void Start()
    {
        kernelID = boidCompute.FindKernel("CSMain");

        // === Init Boid Data ===
        boidArray = new Boid[boidCount];
        for (int i = 0; i < boidCount; i++)
        {
            boidArray[i].position = Random.insideUnitSphere * 10f;
            boidArray[i].velocity = Random.onUnitSphere * maxSpeed;
        }

        // === Create Buffers ===
        boidBuffer = new ComputeBuffer(boidCount, sizeof(float) * 6); // 3 pos + 3 vel
        boidBuffer.SetData(boidArray);

        matrixBuffer = new ComputeBuffer(boidCount, sizeof(float) * 16); // 4x4 matrix per boid

        argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
        uint[] args = new uint[5]
        {
            boidMesh.GetIndexCount(0), (uint)boidCount, 0, 0, 0
        };
        argsBuffer.SetData(args);
    }

    void Update()
    {
        // === Send Simulation Parameters ===
        boidCompute.SetFloat("_DeltaTime", Time.deltaTime);
        boidCompute.SetInt("_NumBoids", boidCount);
        boidCompute.SetFloat("_ViewRadius", viewRadius);
        boidCompute.SetFloat("_AvoidRadius", avoidRadius);
        boidCompute.SetFloat("_MaxSpeed", maxSpeed);
        boidCompute.SetFloat("_AlignmentWeight", alignmentWeight);
        boidCompute.SetFloat("_CohesionWeight", cohesionWeight);
        boidCompute.SetFloat("_SeparationWeight", separationWeight);

        boidCompute.SetBuffer(kernelID, "boids", boidBuffer);
        boidCompute.SetBuffer(kernelID, "boidMatrices", matrixBuffer);
        boidMaterial.SetBuffer("boidMatrices", matrixBuffer);

        // === Dispatch Compute Shader ===
        int threadGroups = Mathf.CeilToInt(boidCount / 256f);
        boidCompute.Dispatch(kernelID, threadGroups, 1, 1);

        // === Render ===
        Graphics.DrawMeshInstancedIndirect(
            boidMesh, 0, boidMaterial,
            new Bounds(Vector3.zero, Vector3.one * 1000),
            argsBuffer
        );
    }

    void OnDestroy()
    {
        boidBuffer?.Release();
        matrixBuffer?.Release();
        argsBuffer?.Release();
    }
}

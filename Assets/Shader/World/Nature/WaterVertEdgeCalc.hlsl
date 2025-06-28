void GetSeamDisplacement_float(float2 UVPosition, float3 NoisePosition, float2 PlaneSize,float2 PlaneOrigin, out float3 FinalDisplacement)
{
#if defined(SHADERGRAPH_PREVIEW)
    FinalDisplacement = (1.0, 1.0, 1.0);
#else


    /*bool isEvenU = fmod(input.uv.x * 16.0, 2.0) == 0.0;
    bool isEvenV = fmod(input.uv.y * 16wh.0, 2.0) == 0.0;
    bool isAligned = isEvenU && isEvenV;*/

  //  float frac_x = fract(UVPosition.x * 100.0) / 0.25;
   // float frac_y = fract(UVPosition.y * 100.0) / 0.25;


    //#if fract(frac_x / 2) != 0 


    //#endif

    float2 neighborUVs[4];

    // Set the reference grid resolution — use the coarsest one (e.g. 4x4 or 8x8)
    float gridSize = 16.0; // This means 8 steps between 0 and 1, so step size = 1/8 = 0.125

    float2 uvIndex = UVPosition * gridSize;

    // Detect if the current UV falls on every second grid step (e.g. 0, 2, 4, ...)
    bool isEvenX = fmod(uvIndex.x, 2.0) < 0.00001;
    bool isEvenY = fmod(uvIndex.y, 2.0) < 0.00001;

    bool isEdgeX = UVPosition.x < 0.000001 || UVPosition.x > 0.999999; //Gets edge cases for x
    bool isEdgeY = UVPosition.y < 0.000001 || UVPosition.y > 0.999999; //Gets edge cases for y

    // Final mask: true only on vertices that align to the shared grid
    bool isAligned = isEvenX && isEvenY;

    // Example usage:
    if (isAligned)
    {
        // For aligned vertices, same displacement scale
        FinalDisplacement = NoisePosition * float3(1.0, 1.0, 1.0);
    }
    else
    {
        if (isEdgeX)
        {
            // For non-aligned vertices at the edge, increase height
            FinalDisplacement = NoisePosition * float3(1.0, 3.0, 1.0);
        }
        else if (isEdgeY)
        {
            // For other non-aligned, non-edge vertices, normal displacement
            FinalDisplacement = NoisePosition * float3(1.0, 3.0, 1.0);
        }
        else
        {
            // For other non-aligned, non-edge vertices, normal displacement
            FinalDisplacement = NoisePosition * float3(1.0, 1.0, 1.0);
        }
    }



    //float dist = distance(WorldPos, CentrePoint);
    //Falloff = smoothstep(MaxRadius, 0.0, dist); //Smooth gradient

#endif

}

void HeightAtUVCoords(float2 UVPosition, out float heightY) {



}

float3 WorldPosFromUV(float2 uv, float3 planeOrigin, float2 planeSize)
{
    float x = planeOrigin.x + uv.x * planeSize.x;
    float y = planeOrigin.y;               // base height, usually 0
    float z = planeOrigin.z + uv.y * planeSize.y;

    return float3(x, y, z);
}

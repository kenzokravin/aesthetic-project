void GetSeamDisplacement_float(float3 VertHeight, float MaxRadius, out float FinalDisplacement)
{

	Distance = Length(WorldPos - CentrePoint);
	Falloff = saturate(1 - Distance / MaxRadius);

}

class KatanaCoshaderDiffuse(color diffColor = 0)
{
	public void diffuseColor(output color c)
	{
		c = diffColor * diffuse(normalize(N));
	}
	
	
}

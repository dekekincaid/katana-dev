class KatanaCoshaderSpecular(color specColor = 0; float roughness = 1)
{
	public void specularColor(output color c)
	{
		c = specColor * specular(normalize(N), normalize(-I), roughness);
	}
	
}

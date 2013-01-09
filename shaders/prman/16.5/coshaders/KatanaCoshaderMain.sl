surface  KatanaCoshaderMain(string diff = ""; color diffValue = 1; string spec = ""; color specValue = 1 )
{
	Oi = Os;
	Ci = 0;
	shader coshaderDiff = null;
	shader coshaderSpec = null;
	

	//Diffuse
	if(diff != "")
	{
		coshaderDiff = getshader(diff);
	}	

	color cd = diffValue;
	if (coshaderDiff != null)
	{
		coshaderDiff->diffuseColor(cd);
	}
	
	Ci += cd;
	
	
	//Specular
	if(spec != "")
	{
		coshaderSpec = getshader(spec);
	}

	color cs = specValue;
	if (coshaderSpec != null)
	{
		coshaderSpec->specularColor(cs);
	}

	Ci += cs;
	    
}

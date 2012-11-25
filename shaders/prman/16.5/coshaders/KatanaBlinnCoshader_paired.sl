/****************************************************************************
 * 
*   Based on a shader from 
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/

surface KatanaBlinnCoshader_paired
(
    float opacity = 1;
    float Kd = 0.7;
    color Kd_color = 1;
    string Kd_color_coshader_name = "";
    float Ks=0.0;
    color Ks_color = 1;
    string Ks_color_coshader_name = "";
    float Roughness = 0.1;
    float Ka=0.0;
    color Ka_color = 1;
    string Ka_color_coshader_name = "";
    string EnvMap="";
    float  EnvVal=1.0;
    string RefractMap="";
    float  RefractVal=1.0;
    float  RefractEta=1.003;
    float  UseFresnel = 1;
)

{
    // Init the shader values 
    normal nN = normalize(N);
    vector nI = normalize(I);
    normal Nf = faceforward(normalize(N), I);
    vector V = -normalize(I);
	shader Kd_color_coshader = null;
	shader Ks_color_coshader = null;
	shader Ka_color_coshader = null;

    // Reflection 
    color Crefl = 0;
    if (EnvMap != "")
    {
         vector Refl = normalize(reflect(nI, Nf));
        Crefl = color environment ( EnvMap, Refl);
    }
    
    // Refraction
    color Crefr = 0;
    normal Nr = nN;
    vector Refr = normalize(refract(I, Nr, RefractEta));

    if (RefractMap != "")
    {
        Crefr = color environment (RefractMap, Refr);
    } 
 
    // Fresnel
    if (UseFresnel == 1)
    {
        float Kr;
        float Kt;
         fresnel ( I, Nf, RefractEta, Kr, Kt);

        if (EnvMap != "") Crefl *= Kr;
        if (RefractMap != "") Crefr *= Kt;
    }

    // Get colors from coshaders

	// Kd_color_val
	if(Kd_color_coshader_name != "")
	{
		Kd_color_coshader = getshader(Kd_color_coshader_name);
	}	

	color Kd_color_val = Kd_color;
	if (Kd_color_coshader != null)
	{
		Kd_color_coshader->getColor(Kd_color_val);
	}

	// Ks_color_val
	if(Ks_color_coshader_name != "")
	{
		Ks_color_coshader = getshader(Ks_color_coshader_name);
	}	

	color Ks_color_val = Ks_color;
	if (Ks_color_coshader != null)
	{
		Ks_color_coshader->getColor(Ks_color_val);
	}

	// Ka_color_val
	if(Ka_color_coshader_name != "")
	{
		Ka_color_coshader = getshader(Ka_color_coshader_name);
	}	

	color Ka_color_val = Ka_color;
	if (Ka_color_coshader != null)
	{
		Ka_color_coshader->getColor(Ka_color_val);
	}

    // Calculate the shading values
    Ci = Os * (Ka_color_val * Ka * ambient() +
               Kd_color_val * Kd * diffuse(Nf) + 
               Ks_color_val * Ks * specular(Nf, V, Roughness) +
               Crefl * EnvVal +
               Crefr * RefractVal);
           
    Oi = opacity;
}


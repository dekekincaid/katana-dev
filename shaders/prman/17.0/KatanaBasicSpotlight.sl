/****************************************************************************
 * 
 *   Based on a shader from 
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/

light KatanaBasicSpotlight (
    float  Intensity = 1;
    color  Color = 1;
    float  FallOff = 1;
    float  Exposure = 0;
    float  Type = 0;
    float  OuterAngle = 70;
    float  InnerAngle = 60;
    point  from = point "shader" (0,0,0);
    point  to = point "shader" (0,0,1);
    string Shadow_File = "";
    float  shadownsamps = 16;
    float  shadowblur = 0;
    float  shadowbias = 0.001;)
{
    // Pre-calculate as uniform various values that will not vary between light samples.
    // Note: the angles given in the parameters for the cone angles are the whole angles in degrees.
    //       For internal calculations we want the half angles in radians.
    uniform vector A = normalize(to - from);
    uniform float sin_cone_outside = sin(radians(0.5*OuterAngle));
    uniform float sin_cone_inside = sin(radians(0.5*InnerAngle));

    illuminate (from, A, radians(OuterAngle))
    {
        float dist = length(L);
		float cos_angle = (L.A) / dist;
        float sin_angle = sqrt(1.0 - cos_angle*cos_angle);

        float atten = 1.0;

        // Attenuation due to cone angles
        atten *= 1.0 - smoothstep(sin_cone_inside, sin_cone_outside, sin_angle);


        // Attenuation due to shadowing
		if (Shadow_File != "") 
	    atten *= 1 - shadow(Shadow_File, Ps, "samples", shadownsamps,
				"blur", shadowblur, "bias", shadowbias);

        // Attenuation due to exposure
        if (Exposure != 0)
            atten *= pow(2.0, Exposure);

        // Calculate base colour of light
		Cl = Color;

        // Calculate effect of attenuation and intensity
        float falloff = 1.0 - min( dist / (FallOff), 1.0); 
        Cl *= atten * Intensity * falloff;
    }
}



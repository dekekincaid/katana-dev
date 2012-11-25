light KatanaBasicPointlight (
    float  Intensity = 1;
    color  Color = 1;
    float  Ambient = 0;
    float  Radius = 1;
    float  Exposure = 0;
    point  from = point "shader" (0,0,0);)
{
    float    attenuation = 0.0;


    illuminate (from)
    {
        float dist = length(L);

        float atten = 1.0;

        // Attenuation due to exposure
        if (Exposure != 0)
            atten *= pow(2.0, Exposure);

        // Calculate base colour of light
		Cl = Color;

        // Calculate effect of attenuation and intensity
        float falloff = 1.0 - min( dist / (Radius), 1.0); 
        Cl *= atten * Intensity * falloff;
    }
}



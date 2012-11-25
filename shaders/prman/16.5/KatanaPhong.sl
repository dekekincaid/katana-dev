/****************************************************************************
 * 
*   Based on a shader from 
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/

surface KatanaPhong
(
    float opacity = 1;
    float Kd = 0.7;
    color Kd_color = 1;
    float Ks=0.0;
    color Ks_color = 1;
    float SpecularExponent = 10;
    float Ka=0.0;
    color Ka_color = 1;
    string ColMap="";
    string SpecMap="";
    string BumpMap="";
    float  BumpVal=1.0;
    string EnvMap="";
    float  EnvVal=1.0;
    string RefractMap="";
    float  RefractVal=1.0;
    float  RefractEta=1.003;
    float  UseFresnel = 1;
    float  RepeatS=1;
    float  RepeatT=1; 
)

{
    // Init the shader values
    normal nN = normalize(N);
    vector nI = normalize(I);
    normal Nf = faceforward(normalize(N), nI);
    vector V = -nI;
    
    // Convert roughness to specular exponent value, with safety check if roughness == 0.0
    // float specularExponent = (Roughness > 0) ? 1.0 / Roughness : 100000.0;

    // Get texture co-ordinates
    float ss = s;
    float tt = t;

    // Texture wrapping
    if (RepeatS != 0.0) ss = mod(s*RepeatS,1.0);
    if (RepeatT != 0.0) tt = mod(t*RepeatT,1.0);

    // Bump mapping
    normal Nff = Nf;
    if (BumpMap != "")
    {
        float bumpDepth = BumpVal * texture(BumpMap, ss, tt);
        point PP = P + bumpDepth * Nf;
        N = calculatenormal(PP);
        Nff = faceforward (normalize(N), I);
    }

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

    // Get colors from Textures
    color ColorTex = 1.0;
    if (ColMap != "")  ColorTex = texture(ColMap, ss, tt);

    color ColorSpec = 1.0;
    if (SpecMap != "") ColorSpec = texture(SpecMap, ss, tt);

    // Calculate the shading values
    Ci = Os * (ColorTex * Ka_color * Ka * ambient() +
               ColorTex * Kd_color * Kd * diffuse(Nf) + 
               ColorSpec * Ks_color * Ks  * phong(Nf, V, SpecularExponent) +
               Crefl * EnvVal +
               Crefr * RefractVal);
           
    Oi = opacity;
}

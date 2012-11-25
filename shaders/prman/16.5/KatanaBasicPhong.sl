/****************************************************************************
 * 
*   Based on a shader from 
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/

surface KatanaBasicPhong
(
    float opacity = 1;
    float Kd = 0.7;
    color Kd_color = 1;
    float Ks=0.0;
    color Ks_color = 1;
    float SpecularExponent = 10;
    float Ka=0.0;
    color Ka_color = 1; )
{
    // Init the shader values
    normal nN = normalize(N);
    vector nI = normalize(I);
    normal Nf = faceforward(normalize(N), nI);
    vector V = -nI;
    
    // Calculate the shading values
    Ci = Os * (Ka_color * Ka * ambient() +
               Kd_color * Kd * diffuse(Nf) + 
               Ks_color * Ks  * phong(Nf, V, SpecularExponent) );
           
    Oi = opacity;
}

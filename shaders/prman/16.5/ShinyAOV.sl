surface ShinyAOV( float Ks=.5, Kd=.5, Ka=1, roughness=.1; color Kd_color = 1; color Ks_color=1; output varying color specChannel=0; )
{
    normal Nf;
    vector V;

    Nf = faceforward( normalize(N), I );
    V = -normalize(I);
    
    //Ambient
    color amb = Ka * ambient();
    
    //Diffuse
    color diff = Kd_color * Kd * diffuse(Nf);
    
    //Specular
    specChannel = Ks_color * Ks * specular(Nf, V, roughness);
    
    Oi = Os;
    Ci = Os * ( Cs * (amb + diff) + specChannel );
}

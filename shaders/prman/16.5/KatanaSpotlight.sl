/****************************************************************************
 * 
 *   Based on a shader from 
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/

float distInsideLine(
    float ax;
    float ay;
    float bx;
    float by;
    float px;
    float py )
{
    // get 2D vector perpendicular to line segment
    float nx = ay - by;
    float ny = bx - ax;

    // normalize the perpendicular, catching for case where it is degenerate
    float d = sqrt(nx*nx + ny*ny);
    if (d==0) return 0.0;
    nx = nx / d;
    ny = ny / d;

    // calculate distance inside the line segment using (p-a).n when n is unit normal
    return (px - ax)*nx + (py - ay)*ny;
}


light KatanaSpotlight (
    float  Intensity = 1;
    color  Color = 1;
    float  Exposure = 0;
    float  Cone_Outer_Angle = 70;
    float  Cone_Inner_Angle = 60;
    float  Type = 0;
    float  Decay_Regions_On = 0;
    float  Fall_In_Begin = 10;
    float  Fall_In_End = 20;
    float  Fall_In_Interp = 0.0;
    float  Fall_In_Exp = 1.0;
    float  Fall_In_Mult = 10.0;
    float  Fall_Out_Begin = 30;
    float  Fall_Out_End = 40;
    float  Fall_Out_Interp = 0.0;
    float  Fall_Out_Exp = 1.0;
    float  Fall_Out_Mult = 0.1;
    float  Barndoors_On = 0;
    float  Barndoor_Left_Top = 0;
    float  Barndoor_Left_Bottom = 0;
    float  Barndoor_Right_Top = 1;
    float  Barndoor_Right_Bottom = 1;
    float  Barndoor_Top_Left = 0;
    float  Barndoor_Top_Right = 0;
    float  Barndoor_Bottom_Left = 1;
    float  Barndoor_Bottom_Right = 1;
    float  Barndoor_Soft = 0.0;
    float  Slide_On = 0;
    float  Slide_SMult = 1;
    float  Slide_TMult = 1;
    float  Slide_SOffset = 0;
    float  Slide_TOffset = 0;
    float  Slide_Rotate = 0;
    float  Slide_Space = 0;
    float  Slide_Density = 1;
    float  Slide_SWrap = 1;
    float  Slide_TWrap = 1;
    string slidemapname = "";
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
    uniform float sin_cone_outside = sin(radians(0.5*Cone_Outer_Angle));
    uniform float sin_cone_inside = sin(radians(0.5*Cone_Inner_Angle));
    uniform float tan_cone_outside = tan(radians(0.5*Cone_Outer_Angle));
    uniform float sin_slide_rot = sin(radians(Slide_Rotate));
    uniform float cos_slide_rot = cos(radians(Slide_Rotate));

    illuminate (from, A, radians(Cone_Outer_Angle))
    {
        float dist = length(L);
	float cos_angle = (L.A) / dist;
        float sin_angle = sqrt(1.0 - cos_angle*cos_angle);

        float atten = 1.0;

        // Get the co-ordinates in the projection plane of the current sample.
        // This is used by barndoors or slide projection.
        // Note: The calculations are easiest if we work in the shader's co-ordinate space.
        vector Lss = vtransform("shader", L);
        float xx = 0.0;
        float yy = 0.0;
        if (zcomp(Lss) != 0)
        {
            xx = xcomp(Lss) / zcomp(Lss);
            yy = ycomp(Lss) / zcomp(Lss);
        }     

        if (Barndoors_On == 0)
            // Attenuation due to cone angles
            atten *= 1.0 - smoothstep(sin_cone_inside, sin_cone_outside, sin_angle);
        else
        {
	    // calculate co-ordinates in the projected image frustrum based on co-ordinates on projection plane at z=-1
            float px = 0.0;
            float py = 0.0;

            if (tan_cone_outside > 0 )
            {
                px = 0.5 + 0.5 * xx / tan_cone_outside;
                py = 0.5 - 0.5 * yy / tan_cone_outside;
            }

            // Attenuation due to barn doors
            if ((px > 0) && (px < 1) && (py > 0) && (py < 1))
            {
                float d1 = distInsideLine(0, Barndoor_Top_Left,
                                          1, Barndoor_Top_Right,
                                          px, py);
                float d2 = distInsideLine(Barndoor_Right_Top, 0,
                                          Barndoor_Right_Bottom, 1,
                                          px, py);
                float d3 = distInsideLine(1, Barndoor_Bottom_Right,
                                          0, Barndoor_Bottom_Left,
                                          px, py);
                float d4 = distInsideLine(Barndoor_Left_Bottom, 1,
                                          Barndoor_Left_Top, 0,
                                          px, py);

                atten *= smoothstep(0, Barndoor_Soft, d1);
                atten *= smoothstep(0, Barndoor_Soft, d2);
                atten *= smoothstep(0, Barndoor_Soft, d3);
                atten *= smoothstep(0, Barndoor_Soft, d4);
            }
            else atten = 0;
        }

        // Decay by simple smoothstep falloff from Fall_In_Mult to 1.0 over dist in [Fall_In_Begin, Fall_In_End]
        // snoothstep falloff from 1.0 to Fall_Out_Mult over dist in [Fall_Out_Begin, Fall_Out_End[
	if (Decay_Regions_On == 1)
        {
            // Attenuation due to distances in the Fall_In range
            if (dist < Fall_In_End)
                atten *= Fall_In_Mult + (1.0-Fall_In_Mult) * pow(smoothstep(Fall_In_Begin, Fall_In_End, dist), Fall_In_Exp);

            // Attenuation due to distances in the Fall_Out range
            if (dist > Fall_Out_Begin)
                atten *= 1.0 + (Fall_Out_Mult-1.0) * pow(smoothstep(Fall_Out_Begin, Fall_Out_End, dist), Fall_Out_Exp);
        }

        // Decay by inverse square falloff, setting attenuation at 1.0 when dist=Fall_In_End, switching to simple
        // quadratic C-Bx^2 falloff when dist<Fall_In_Begin, and doing an additional smooth_step falloff over
        // dist in [Fall_Out_Begin, Fall_Out_End] to get illumination to zero by Fall_Out_End
        //
        // Based on the formula:
        // f(x) = (d2 * d2) * (2.0 - x / (d1 * d1)) / (d1 * d1) when x <= d1
        // f(x) = d2 * d2 / (x * x) when d1 < x <= d3
        // f(x) = (1.0 - smoothstep(d3, d4, x)) * ( d2 * d2 / (x * x) ) when d3 < x <= d4
        // f(x) = 0 when x > d4
	if (Decay_Regions_On == 2)
        {
            if (dist < Fall_In_Begin)
            {
                atten *= Fall_In_End * Fall_In_End * (2.0 - dist * dist / (Fall_In_Begin * Fall_In_Begin)) / (Fall_In_Begin * Fall_In_Begin);
            }
            else
            {
	        if (dist < Fall_Out_End)
            	{
                    atten *= Fall_In_End * Fall_In_End / (dist * dist);
                    if (dist > Fall_Out_Begin)
                        atten *= 1.0 - smoothstep(Fall_Out_Begin, Fall_Out_End, dist);
            	}
            	else
               	    atten = 0;
            }
        }

        // Attenuation due to shadowing
	if (Shadow_File != "") 
	    atten *= 1 - shadow(Shadow_File, Ps, "samples", shadownsamps,
				"blur", shadowblur, "bias", shadowbias);

        // Attenuation due to exposure
        if (Exposure != 0)
            atten *= pow(2.0, Exposure);

        // Calculate base colour of light
	Cl = Color;

        // Calculations for effect of a slidemap
        if ((Slide_On != 0) && (slidemapname != "") && (tan_cone_outside>0))
        {
            // Calculate transforms on co-ordinates of sample on projection plane
            // Note: the tranform concatenation order (RTS) is designed to
            //       match how the Katana slide map manipulator appears to work.
            if (Slide_Rotate != 0.0)
            {
                float xx_temp = cos_slide_rot*xx - sin_slide_rot*yy;
                yy = sin_slide_rot*xx + cos_slide_rot*yy;
                xx = xx_temp;
            }
            xx += Slide_SOffset;
            yy += Slide_TOffset;
            if (Slide_SMult!=0) xx /= Slide_SMult;
            if (Slide_TMult!=0) yy /= Slide_TMult;

            // Convert from projection plane co-ordinate to texture co-ordinates
            float ss = 0.5 + 0.5 * xx / tan_cone_outside;
            float tt = 0.5 - 0.5 * yy / tan_cone_outside;

            // Handle wrapping and reflection of the slidemap texture
            if (Slide_SWrap != 0)
            {
                float ss_floor = floor(ss);
                ss = ss - ss_floor;
            }

            if (Slide_TWrap != 0)
            {
                float tt_floor = floor(tt);
                tt = tt - tt_floor;
            }

            // Look up the slide map and apply to the light color
            color slide_color = color texture(slidemapname, ss, tt) * Color;
            Cl = (1.0 - Slide_Density) * Cl + Slide_Density * slide_color;
        }

        // Calculate effect of attenuation and intensity
        Cl *= atten * Intensity;
    }
}



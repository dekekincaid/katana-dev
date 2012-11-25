class KatanaImageRead(
	string Filename = "";
    float RepeatS=1;
    float RepeatT=1;
)
{
	public void getColor(output color c)
	{
    	// Get texture co-ordinates
    	float ss = s;
    	float tt = t;

    	// Texture wrapping
    	if (RepeatS != 0.0) ss = mod(s*RepeatS,1.0);
    	if (RepeatT != 0.0) tt = mod(t*RepeatT,1.0);

		// Get color from texture
		c = texture(Filename, ss, tt);
	}
}


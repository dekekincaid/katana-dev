class KatanaColorAdd(
	color colorA = 1;
    string colorA_coshader_name = "";
	color colorB = 1;
	string colorB_coshader_name = "";
)
{
	public void getColor(output color c)
	{
		// colorA_val
		shader colorA_coshader = null;
		if(colorA_coshader_name != "")
		{
			colorA_coshader = getshader(colorA_coshader_name);
		}	

		color colorA_val = colorA;
		if (colorA_coshader != null)
		{
			colorA_coshader->getColor(colorA_val);
		}

		// colorB_val
		shader colorB_coshader = null;
		if(colorB_coshader_name != "")
		{
			colorB_coshader = getshader(colorB_coshader_name);
		}	

		color colorB_val = colorB;
		if (colorB_coshader != null)
		{
			colorB_coshader->getColor(colorB_val);
		}

		c = colorA_val + colorB_val;
	}
}


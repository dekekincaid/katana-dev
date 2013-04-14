katana-dev
==========

This is my scripts for customizing The Foundry's Katana.  Currently it mostly consists of args & lookfiles for shaders for Prman 16.5/17.0, Mtoa and SitoA shaders for Arnold 4.0.11.
==========
Easy Install Method
==========

1. Set this env variable for your prman shaders

RMAN_SHADERPATH=$RMANTREE/lib/shaders

2. Set this env variable for your arnold shaders for sitoa/mtoa
 
ARNOLD_SHADERLIB_PATH=/opt/arnold/sitoa/shaders:/opt/arnold/mtoa/shaders

3. Installing Args files

copy all .args files into the folder
$HOME/.katana/Args/


==========
More Complicated but robust install instructions:
==========

==========
Prman Notes
==========

Prman 17.0 Args are for the default shaders included in the package.  Under linux they are in these directories below.  I copy them into my directory structure.  I don't believe I have the rights to include them in this repository so you can simply copy them yourselves

/opt/pixar/RenderManProServer-17.0/lib/rsl/shaders
/opt/pixar/RenderManProServer-17.0/lib/shaders
/opt/pixar/RenderManProServer-17.0/lib/examples

==========
My Directory structure
==========

/shaders  
--/prman  
----/16.5 < prman 16.5 shaders go here  
------/Args < args for prman 16.5 shaders of the same name goes here  
----/17.0 < prman 17.0 shaders go here  
------/Args < args for prman 17 shaders of the same name goes here  
--/Arnold < default shaders inside libai.so which is included with arnold  
----/Args < args for default arnold shaders  
----/mtoa < mtoa shaders  
------/Args < mtoa args  
----/sitoa < sitoa shaders  
------/Args < sitoa args  
--/shave < shave shaders  
----/Args  <shave args  
  
==========
To use these files 
==========

The args are picked up from the following directories, in this order of precedence:

- Args subdirectory of the shader’s directory.
- ../Args directory relative to the shader’s directory.
-  ../doc directory relative to the shader’s directory (Deprecated, for backwards compatibility)
- Args subdirectories of each directory in the KATANA_RESOURCES environment variable.

==========

To get these to work you need to put the shaders in your Arnold/Prman shader path.  To get the Args for the default libai.so Arnold shader working I also had to put that path in my KATANA_RESOURCES.  The example below is using BASH.  You will need to make it slightly different if you want to use CSH or TCSH.

RMAN_SHADERPATH=$RMANTREE/lib/shaders

ARNOLD_SHADERLIB_PATH=/opt/arnold/sitoa:/opt/arnold/mtoa

KATANA_RESOURCES=$KATANA_HOME/plugins/Resources/Examples:$KATANA_HOME/plugins/Resources/PRMan17:$KATANA_HOME/plugins/Resources/Arnold4.0:/opt/arnold/mtoa/shaders:/opt/arnold/sito/shaders

**A quick note, prman shader path recursively looks down the folders and arnold does not.  So that’s why I set prman to a single folder and had to set arnold for every folder.

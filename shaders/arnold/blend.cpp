/*
 * blend.cpp - arnold shader to blend two colors together
 */

#include <ai.h>
#include <stdio.h>

AI_SHADER_NODE_EXPORT_METHODS(BlendMtd);

enum BlendParams {
    p_blend,
    p_color1,
    p_color2,
};

node_parameters
{
    AiParameterFLT( "blend"      , 0.5f    );
    AiParameterRGBA( "color1", 0, 0, 0, 1 );
    AiParameterRGBA( "color2", 0, 0, 0, 1 );
}

node_initialize
{
}

node_finish
{
}

node_update
{
}

shader_evaluate
{
    AtFloat blend = AiShaderEvalParamFlt(p_blend);
    AtRGBA color1 = AiShaderEvalParamRGBA(p_color1);
    AtRGBA color2 = AiShaderEvalParamRGBA(p_color2);

    sg->out.RGBA.r = (1.0 - blend) * color1.r + blend * color2.r;
    sg->out.RGBA.g = (1.0 - blend) * color1.g + blend * color2.g;
    sg->out.RGBA.b = (1.0 - blend) * color1.b + blend * color2.b;
    sg->out.RGBA.a = (1.0 - blend) * color1.a + blend * color2.a;
}

node_loader
{
    if (i != 0)
        return FALSE;

    node->methods     = BlendMtd;
    node->output_type = AI_TYPE_RGBA;
    node->name        = "blend";
    node->node_type   = AI_NODE_SHADER;
    sprintf(node->version, AI_VERSION);
   
    return TRUE;
}

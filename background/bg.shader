uniform texture2d bg1;

uniform bool setup_mode = true;
uniform float lines_x1 = 5;
uniform float lines_y1 = 5;


//todo: detect game, use proper flash graphic

bool inBox2(float2 uv, float4 box)
{
	return (uv.x >= box.r && 
			uv.x <= box.g && 
			uv.y >= box.b && 
			uv.y <= box.a);
}

float4 draw_setup(float2 uv)
{    
    float4 orig = image.Sample(textureSampler, uv);
    
    if (inBox2(uv, float4(lines_x1/256.0 - 1/256.0,
                          lines_x1/256.0 + 1/250.0,
                          lines_y1/256.0 - 1/240.0,
                          lines_y1/256.0 + 1/240.0  ))) {
        return (orig + float4(1,0,0,1)) / 2.0;
    }    
    
    return orig;
}

bool isWhite(float4 color)
{
    float cutoff = 0.8;
    
    return (color.r >= cutoff &&
            color.g >= cutoff &&
            color.b >= cutoff);
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    if (setup_mode) {
        return draw_setup(uv);
    }
    
    float4 flash = image.Sample(textureSampler, float2(lines_x1/256.0,lines_y1/240.0));
    
    if (isWhite(flash))
    {
        float2 uv2 = float2(uv);
        uv2.x /= 2.0;        
        float4 bright = bg1.Sample(textureSampler, uv2);
        if (bright.a < 0.1)
        {
            return image.Sample(textureSampler,uv);
        }
        return bright;
    } else {
        float2 uv2 = float2(uv);
        uv2.x /= 2.0;                
        uv2.x += 0.5;
        float4 dark = bg1.Sample(textureSampler, uv2);
        if (dark.a < 0.1)
        {
            return image.Sample(textureSampler,uv);
        }
        return dark;       
    }    
    
}

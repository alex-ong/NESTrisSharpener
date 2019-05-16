//#include "shared.shader"
uniform texture2d block_image;

uniform bool setup_mode = true;
uniform float lines_x1 = 96;
uniform float lines_y1 = 96;
uniform float lines_x2 = 110;
uniform float lines_y2 = 110;


float4 line_box() { return float4(lines_x1 / 256.0, lines_x2 / 256.0, 
                                  lines_y1 / 224.0, lines_y2 / 224.0);}
bool inBox2(float2 uv, float4 box)
{
	return (uv.x >= box.r && 
			uv.x <= box.g && 
			uv.y >= box.b && 
			uv.y <= box.a);
}
float inverseLerp(float start, float end, float val)
{
    return (val - start) / (end - start);
}

float2 inbox_inverseLerp(float2 uv, float4 box)
{
    return float2(inverseLerp(box.r,box.g, uv.x),
                  inverseLerp(box.b,box.a, uv.y));
}


float2 inbox_lerp(float2 perc, float4 box)
{
    return float2 (lerp(box.r,box.g,perc.x),
                   lerp(box.b,box.a,perc.y));
}

float4 split_box(float4 box, int size, int index)
{
    float width = box.g - box.r;
    int pixels = 8*size - 2;
    int startX = 8*index;
    int endX = startX + 7;
    float pixelSize = width / pixels;
    return float4(box.r + startX*pixelSize, 
                  box.r + endX*pixelSize, 
                  box.b,
                  box.a);
}

float myDiff(float4 a, float4 b)
{
    return (a.r - b.r) * (a.r - b.r);
}

float score_number(float4 raw_box, int i)
{
    float result = 0.0;
    
    float raw_pix_width = (raw_box.g - raw_box.r)/7.0;    
    float raw_pix_height = (raw_box.a - raw_box.b)/7.0;
    float raw_pix_width2 = raw_pix_width/2.0;
    float raw_pix_height2 = raw_pix_height/2.0;
    
    float ref_box_width = 1.0/10;
    float ref_pix_width = ref_box_width / 7.0;    
    float ref_pix_height = 1.0 / 7.0;
    float ref_pix_width2 = ref_pix_width/2.0;
    float ref_pix_height2 = ref_pix_height/2.0;
    
    for (int row = 0; row < 7; row++)
    {
        for (int col = 0; col < 7; col++)
        {            
            float4 raw_colour = image.Sample(textureSampler, float2(raw_box.r + raw_pix_width2 + col*raw_pix_width,
                                                                    raw_box.b + raw_pix_height2 + row*raw_pix_height));
            

            float4 ref_colour = block_image.Sample(textureSampler, float2(ref_box_width*i + ref_pix_width2 + ref_pix_width*col,
                                                                               ref_pix_width2 + ref_pix_height*row));
            result += myDiff(raw_colour, ref_colour);                                                                    

            
        }
    }
    
    return result;
    
}
int score_all(float4 raw_box)
{
    int result = 0;
    int min_score = 1000000;
    for (int i = 0; i < 10; i++)
    {
        float score = score_number(raw_box, i);
        if (score < min_score)
        {
            result = i;
            min_score = score;
        }
    }
    return result;
}


float4 intToColour(int result)
{
    if (result == 0)
        return float4(0.0,0.0,1.0,1.0);
    else if (result == 1)
        return float4(0.0,1.0,0.0,1.0);
    else if (result == 2)
        return float4(0.0,1.0,1.0,1.0);
    else if (result == 3)
        return float4(1.0,0.0,0.0,1.0);
    else if (result == 4)
        return float4(1.0,0.0,1.0,1.0);
    else if (result == 5)
        return float4(1.0,1.0,0.0,1.0);
    else if (result == 6)
        return float4(1.0,1.0,1.0,1.0);
    else if (result == 7)
        return float4(1.0,0.5,1.0,1.0);
    else if (result == 8)
        return float4(1.0,1.0,0.5,1.0);
    else// (result == 9)
        return float4(0.5,1.0,1.0,1.0);
}

float4 draw_setup(float2 uv)
{    
    float4 orig = image.Sample(textureSampler, uv);
     
    for (int i = 0; i < 3; i++) {
        float4 box = split_box(line_box(),3,i);
        if (inBox2(uv, box)) {
            int result = score_all(box);                           
            return (intToColour(result) + orig) / 2.0;
        }
    }
       
    
    return image.Sample(textureSampler, uv);
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    if (setup_mode) {
        return draw_setup(uv);
    }
    
    if (inBox2(uv, line_box())) {
        for (int i = 0; i < 3; i++)
        {
            float4 box = split_box(line_box(), 3, i);
            
            if (inBox2(uv, box)) {
                int result = score_all(box);            
                float2 pos = inbox_inverseLerp(uv,box);
                float4 targetBox = float4(result/10.0,(result+1)/10.0,0.0,1.0);
                float2 target = inbox_lerp(pos,targetBox);
                return block_image.Sample(textureSampler, target);            
            }
        }
        return float4(0.0,0.0,0.0,1.0);
    }
	return image.Sample(textureSampler, uv);
}

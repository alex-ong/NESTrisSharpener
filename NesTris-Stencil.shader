uniform texture2d block_image;

uniform bool setup_mode = true;
uniform float field_left_x = 62;
uniform float field_right_x = 112.5;
uniform float field_top_y = 40;
uniform float field_bottom_y = 199;

uniform bool stat_palette_white = true;

uniform float paletteA_x1 = 19;
uniform float paletteA_y1 = 102;
uniform float paletteA_x2 = 19;
uniform float paletteA_y2 = 157;

uniform float paletteB_x1 = 19;
uniform float paletteB_y1 = 119;
uniform float paletteB_x2 = 19;
uniform float paletteB_y2 = 172;

uniform bool sharpen_preview = true;
uniform float preview_left_x = 123;
uniform float preview_right_x = 143;
uniform float preview_top_y = 111;
uniform float preview_bottom_y = 128;

uniform bool skip_detect_game;
uniform bool skip_detect_game_over;

uniform float game_black_x1 = 64;
uniform float game_black_y1 = 20;
uniform float game_black_x2 = 152;
uniform float game_black_y2 = 20;
uniform float game_grey_x1 = 23.5;
uniform float game_grey_y1 = 218.6;


sampler_state defaultSampler {
        Filter      = Point;
        AddressU    = Clamp;
        AddressV    = Clamp;
};

float myLerp(float start, float end, float perc)
{
    return start + (end-start) * perc;
}

float distPoints(float2 a, float2 b)
{
	return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)*20.43;
	//4.5 is inverse aspect ratio of stats png... square it to get 20.43
	//we have to multiply to convert from uv to pixel distance.
}

float3 closest_stat(float2 uv)
{
    const float2 test[28] = {
    float2(0.195, 0.023), //T
    float2(0.456, 0.023),
    float2(0.727, 0.023),
    float2(0.456, 0.080),

    float2(0.334, 0.486),//O
    float2(0.594, 0.486),
    float2(0.334, 0.546),
    float2(0.594, 0.546),

    float2(0.109, 0.976), //I
    float2(0.370, 0.976),
    float2(0.631, 0.976),
    float2(0.892, 0.976),

    float2(0.195, 0.165),//J
    float2(0.456, 0.165),
    float2(0.727, 0.165),
    float2(0.727, 0.220),

    float2(0.456, 0.637), //S
    float2(0.727, 0.637),
    float2(0.195, 0.695),
    float2(0.456, 0.695),

    float2(0.195, 0.329),//Z
    float2(0.456, 0.329),
    float2(0.456, 0.386),
    float2(0.727, 0.386),

    float2(0.195, 0.782),//L
    float2(0.456, 0.782),
    float2(0.727, 0.782),
    float2(0.195, 0.840)};


    float min_dist = distPoints(uv,test[0]);
    int result = 0;

    for (int i = 1; i < 28; i++)
    {
        float dist = distPoints(uv,test[i]);
        if (dist < min_dist)
        {
            min_dist = dist;
            result = i;
        }
    }
    return float3(test[result].x,test[result].y,result/4);
}
bool blockStatIsWhite(int id)
{
    return id < 3;
}

bool blockStatIsCol1(int id)
{
    return 3 <= id && id <= 4 ;
}

bool blockStatIsCol2(int id)
{
    return id > 4;
}

//width as portion of full screen width.
float blockWidth() {
	return (field_right_x - field_left_x) / 10.0 / 256.0;
}

float blockHeight() {
	return (field_bottom_y - field_top_y) / 20.0 / 224.0;
}

float pixelWidthUV()
{
	float bw = blockWidth();
	return bw/8.0;
}

float pixelHeightUV()
{
	float bh = blockHeight();
	return bh/8.0;
}

float2 pixelUV()
{
	return float2(pixelWidthUV(),pixelHeightUV());
}

bool inBox(float2 uv) {
	float startX = field_left_x / 256.0;
	float endX = field_right_x / 256.0;
	float startY = field_top_y / 224.0;
	float endY = field_bottom_y / 224.0;
	return (uv.x > startX && uv.x < endX && uv.y > startY && uv.y < endY);
}

bool inBox2(float2 uv, float4 box)
{
	return (uv.x >= box.r &&
			uv.x <= box.g &&
			uv.y >= box.b &&
			uv.y <= box.a);
}

float4 pixBox(float2 uv, int pixels)
{
	return float4(uv.x - (pixels / 256.0), uv.x + (pixels/256.0),
				  uv.y - (pixels / 224.0), uv.y + (pixels/224.0));
}

float4 pixBoxStat(float2 uv, int pixels)
{
	return float4(uv.x - pixels / 23.0, uv.x + pixels/23.0,
				  uv.y - pixels / 104.0, uv.y + pixels/104.0);
}

float2 paletteA1_uv(){ return float2(paletteA_x1 / 256.0, paletteA_y1 / 224.0);}
float2 paletteA2_uv(){ return float2(paletteA_x2 / 256.0, paletteA_y2 / 224.0);}
float2 paletteB1_uv(){ return float2(paletteB_x1 / 256.0, paletteB_y1 / 224.0);}
float2 paletteB2_uv(){ return float2(paletteB_x2 / 256.0, paletteB_y2 / 224.0);}

float4 paletteA1_box(){	return pixBox(paletteA1_uv(), 1);}
float4 paletteA2_box(){	return pixBox(paletteA2_uv(), 1);}
float4 paletteB1_box(){	return pixBox(paletteB1_uv(), 1);}
float4 paletteB2_box(){	return pixBox(paletteB2_uv(), 1);}

float2 gameBlack1_uv() { return float2(game_black_x1 / 256.0, game_black_y1 / 224.0); }
float2 gameBlack2_uv() { return float2(game_black_x2 / 256.0, game_black_y2 / 224.0); }
float2 gameGrey1_uv() { return float2(game_grey_x1 / 256.0, game_grey_y1 / 224.0); }

float4 gameBlack1_box(){ return pixBox(gameBlack1_uv(), 2);}
float4 gameBlack2_box(){ return pixBox(gameBlack2_uv(), 2);}
float4 gameGrey1_box() { return pixBox(gameGrey1_uv(), 2);}


float4 preview_box() { return float4(preview_left_x / 256.0,
                                     preview_right_x / 256.0,
                                     preview_top_y / 224.0,
                                     preview_bottom_y / 224.0); }

float2 prev_offset1() { return float2(myLerp(preview_left_x,preview_right_x, 0.30) / 256.0,
                                      myLerp(preview_top_y,preview_bottom_y, 0.875) / 224.0); }
float2 prev_offset2() { return float2(myLerp(preview_left_x,preview_right_x, 0.4375) / 256.0,
                                      myLerp(preview_top_y,preview_bottom_y, 0.875) / 224.0); }
float2 prev_offset3() { return float2(myLerp(preview_left_x,preview_right_x, 0.6875) / 256.0,
                                      myLerp(preview_top_y,preview_bottom_y, 0.875) / 224.0); }

float4 blockTex(bool white, float2 uv, float4 base) {
	if (!white) {
		uv = float2(uv.x / 2.0, uv.y);
	} else {
		uv = float2(uv.x / 2.0 + 0.5, uv.y);
	}

	float4 result = block_image.Sample(defaultSampler, uv);
	if (result.a == 0.0) {
		return base;
	} else {
		return result;
	}

}

bool isWhite(float4 rgba) {
	float limit = 0.6;
	return (rgba.r >= limit &&
			rgba.g >= limit &&
			rgba.b >= limit);
}
bool isBlack(float4 rgba) {
	float limit = 0.20;
	return (rgba.r <= limit &&
			rgba.g <= limit &&
			rgba.b <= limit);
}
bool isGrey(float4 rgba) {
	float limit = 0.30;
	return (rgba.r >= 0.5 - limit && rgba.r <= 0.5 + limit &&
			rgba.g >= 0.5 - limit && rgba.g <= 0.5 + limit &&
			rgba.b >= 0.5 - limit && rgba.b <= 0.5 + limit);

}

float4 palette1(float2 pixelSize)
{
	return (sampleBlock(paletteA1_uv(), pixelSize) +
			sampleBlock(paletteA2_uv(), pixelSize)) / 2.0;  //S Piece
}

float4 palette2(float2 pixelSize)
{
	return (sampleBlock(paletteB1_uv(), pixelSize) +
	        sampleBlock(paletteB2_uv(), pixelSize)) / 2.0; // L piece
}

float4 matchPalette(float4 p1, float4 p2, float4 col)
{
	float dist1 = colorDist(p1,col);
	float dist2 = colorDist(p2,col);
	if (dist1 < dist2) {
		return p1;
	} else {
		return p2;
	}
}

//Simple 4 sample of centre of 3x3 block
float4 sampleBlock(float2 uv, float2 pixelSize)
{
	float4 centre = image.Sample(textureSampler, uv);
	//float4 tl = image.Sample(textureSampler,float2(uv.x - pixelSize.x, uv.y - pixelSize.y));
	float4 tr = image.Sample(textureSampler,float2(uv.x + pixelSize.x, uv.y - pixelSize.y));
	float4 r = image.Sample(textureSampler,float2(uv.x + pixelSize.x, uv.y));
	float4 bl = image.Sample(textureSampler,float2(uv.x - pixelSize.x, uv.y + pixelSize.y));
	float4 br = image.Sample(textureSampler,float2(uv.x + pixelSize.x, uv.y + pixelSize.y));
	float4 avg = (tr + bl + br + centre + r) / 5.0;
	//avg = centre;
	return avg;
}


//Simple top/bottom edge sample of 8x8 block.
float4 sampleEdge(float2 uv, float2 pixelSize)
{
	float topyUv = uv.y + 2.5 * pixelSize.y;
	float bottomyUv = uv.y - 3.5 * pixelSize.y;
	float4 top = image.Sample(textureSampler, float2(uv.x, topyUv));
	float4 bottom = image.Sample(textureSampler, float2(uv.x, bottomyUv));
	return (top + bottom) / 2.0;
}

float4 sampleEdgeStat(float2 uv, float2 pixelSize)
{
	float topyUv = uv.y + 1.5 * pixelSize.y;
	float bottomyUv = uv.y - 2.5 * pixelSize.y;
	float4 top = image.Sample(textureSampler, float2(uv.x, topyUv));
	float4 bottom = image.Sample(textureSampler, float2(uv.x, bottomyUv));
	return (top + bottom) / 2.0;
}

bool isInGame(float2 pixelSize)
{
	float4 black1 = sampleBlock(gameBlack1_uv(), pixelSize); //black box next to "LINES";
	float4 black2 = sampleBlock(gameBlack2_uv(), pixelSize); //black box of "TOP/SCORE"
	float4 grey1 = sampleBlock(gameGrey1_uv(), pixelSize); //grey box of bottom middle left
	return (isBlack(black1) && isBlack(black2) && (isGrey(grey1) || isWhite(grey1)));
}

//if top edge is not black, we assume game over.

bool isGameOver(float2 pixelSize)
{
	//field is 80 pixels wide
	//field is 160 pixels tall.
	float startX = field_left_x/256 + 4*pixelSize.x;
	float startY = field_top_y/224 + 4*pixelSize.y;

	float4 topleft =  sampleBlock(float2(startX,                  startY), pixelSize);
	float4 topmid =   sampleBlock(float2(startX + 40*pixelSize.x, startY), pixelSize);
	float4 topright = sampleBlock(float2(startX + 70*pixelSize.x, startY), pixelSize);

	if (isBlack(topleft) || isBlack(topmid) || isBlack(topright)) {
		return false;
	} else {
		return true;
	}

}


//Low cost color distance
//https://www.compuphase.com/cmetric.htm
float colorDist(float4 e1, float4 e2)
{
	float r = (e1.r-e2.r);
	float g = (e1.g-e2.g);
	float b = (e1.b-e2.b);
	float rMean = (e1.r+e2.r)/2.0;
	if (rMean > 0.5) {
		return 3*r*r + 4*g*g + 2*b*b;
	} else {
		return 2*r*r + 4*g*g + 3*b*b;
	}
}

float4 setupDraw(float2 uv)
{
	float2 pixelSize = pixelUV();

	float4 orig = image.Sample(textureSampler, uv);
	if (inBox(uv))
	{
		return (float4(1.0,0.0,0.0,1.0) + orig) / 2.0;
	}

	if (stat_palette_white) {
		if (inBox2(uv, paletteA1_box()))
		{
			return (float4(0.0,1.0,0.0,1.0));
		}
		else if (inBox2(uv, paletteA2_box()))
		{
			return (float4(0.0,1.0,0.0,1.0));
		}
		else if (inBox2(uv, paletteB1_box()))
		{
			return (float4(1.0,0.0,0.0,1.0));
		}
		else if (inBox2(uv, paletteB2_box()))
		{
			return (float4(1.0,0.0,0.0,1.0));
		}
	}

    if (sharpen_preview)
    {
        if (inBox2(uv, preview_box()))
        {
            if (inBox2(uv, pixBox(prev_offset1(),1))) {
                return float4(1.0,0.8,0.0,1.0);
            } else if (inBox2(uv, pixBox(prev_offset2(),1))) {
                return float4(1.0,0.0,0.0,1.0);
            } else if (inBox2(uv, pixBox(prev_offset3(),1))) {
                return float4(1.0,0.0,1.0,1.0);
            } else {
                return (float4(0.3,1.0,0.3,1.0) + orig) / 2.0;
            }
        }
    }

	if (!skip_detect_game)
	{
		if (inBox2(uv, gameBlack1_box())) {
			return float4(0.0,0.0,1.0,1.0);
		} else if (inBox2(uv, gameBlack2_box())) {
			return float4(0.0,0.0,1.0,1.0);
		} else if (inBox2(uv, gameGrey1_box())) {
			return float4(0.0,0.0,1.0,1.0);
		}
	}

	return image.Sample(textureSampler, uv);

}


int whichPiece(bool o, bool r, bool p)
{
    //0123456
    //TJZOSLI
    if (o)
    {
        if (r) {
            if (p) {
                return 3; //O
            }
            return 4; //S
        }
        return 5; //L
    } else if (r) {
        if (p) {
            return 2; //z
        }
        return 0; //t
    } else if (p) {
        return 1; //j
    } else {
        return 6; //i
    }
}

float4 do_sharpen_preview(float2 uv)
{
    bool o = !isBlack(image.Sample(textureSampler, prev_offset1()));
    bool r = !isBlack(image.Sample(textureSampler, prev_offset2()));
    bool p = !isBlack(image.Sample(textureSampler, prev_offset3()));

    //figure out which result.
    int result = whichPiece(o,r,p);
    //TJZOSLI = 0->6;
    float bw = blockWidth();
    float bh = blockHeight();
    float fblx = preview_left_x/256.0;
    float fbty = preview_top_y /224.0;

    //every piece but o and i are offset on x.
    if (result != 3 && result != 6) {
        fblx += bw / 2.0;
        float limit = (preview_right_x / 256.0) - (bw * 0.625);
		float limit2 = (preview_left_x / 256.0) + (bw * 0.5);
        if (uv.x > limit || uv.x < limit2)
        {
            return float4(0.0,0.0,0.0,1.0);
        }
    }

    if (result == 6) //i piece offset on y.
    {
        fbty += blockHeight() / 2.0;
    }

    float centrexUv = floor((uv.x - fblx) / bw) * bw + fblx + bw/2.0;
    float centreyUv = floor((uv.y - fbty) / bh) * bh + fbty + bh/2.0;
    float2 centre = float2(centrexUv,centreyUv);

    return drawBlock(uv, centre, fblx, fbty);
}

float my_mod(float a, float b)
{
    return a - (b * floor(a/b));
}

float4 drawBlock(float2 uv, float2 centre, float gridCornerX, float gridCornerY)
{
    float bw = blockWidth();
    float bh = blockHeight();

    float blockxUv = my_mod((uv.x - gridCornerX) * 256.0 , bw * 256.0) / (bw * 256.0);
    float blockyUv = my_mod((uv.y - gridCornerY) * 224.0 , bh * 224.0) / (bh * 224.0);
    float2 pixelSize = pixelUV();
    float2 blockUv = float2(blockxUv,blockyUv);
    float4 avg = sampleBlock(centre, pixelSize);

    //now we have two scenarios - centre is white, or not
    if (isBlack(avg)) {
        return float4(0.0,0.0,0.0,1.0);
    } else if (isWhite(avg)) {
        if (stat_palette_white) {
            avg = palette1(pixelSize);
        } else {
            avg = sampleEdge(centre, pixelSize);
        }

        return blockTex(true, blockUv, avg);
    } else {
        return blockTex(false, blockUv, avg);
    }
}

float4 mainImage(VertData v_in) : TARGET
{
	float2 uv = v_in.uv;
	float2 pixelSize = pixelUV();

	if (setup_mode) {
		return setupDraw(uv);
	}

	if (!skip_detect_game)
	{
		if (!isInGame(pixelSize)) {
			return image.Sample(textureSampler,uv);
		}
	}

	if (!skip_detect_game_over)
	{
		if (isGameOver(pixelSize)) {
			return image.Sample(textureSampler,uv);
		}
	}


	if (inBox(uv)) { //in play area

		float bw = blockWidth();
        float bh = blockHeight();

		float fblx = field_left_x/256.0;
		float fbty = field_top_y /224.0;

		float centrexUv = floor((uv.x - fblx) / bw) * bw + fblx + bw/2.0;
		float centreyUv = floor((uv.y - fbty) / bh) * bh + fbty + bh/2.0;
		float2 centre = float2(centrexUv,centreyUv);

        return drawBlock(uv, centre, fblx, fbty);

    } else if (sharpen_preview && inBox2(uv,preview_box())) {
        return do_sharpen_preview(uv);

    } else {
		return image.Sample(textureSampler, v_in.uv);
	}
}

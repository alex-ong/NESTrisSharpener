uniform texture2d block_image;
uniform bool setup_mode;
uniform float field_left_x;
uniform float field_right_x;
uniform float field_top_y;
uniform float field_bottom_y;

uniform bool stat_palette_white;
uniform bool stat_palette;

uniform float paletteA_x1;
uniform float paletteA_y1;
uniform float paletteA_x2;
uniform float paletteA_y2;

uniform float paletteB_x1;
uniform float paletteB_y1;
uniform float paletteB_x2;
uniform float paletteB_y2;

uniform bool skip_detect_game;
uniform bool skip_detect_game_over;

uniform float game_black_x1;
uniform float game_black_y1;
uniform float game_black_x2;
uniform float game_black_y2;
uniform float game_grey_x1;
uniform float game_grey_y1;

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
	return float4(uv.x - pixels / 256.0, uv.x + pixels/256.0,
				  uv.y - pixels / 224.0, uv.y + pixels/224.0);
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

//width as portion of full screen width.
float blockWidth() {
	return (field_right_x - field_left_x) / 10.0 / 256.0;
}

float blockHeight() {
	return (field_bottom_y - field_top_y) / 20.0 / 224.0;
}

float4 blockTex(bool white, float2 uv, float4 base) {	
	if (!white) {	
		uv = float2(uv.x / 2.0, uv.y);
	} else {
		uv = float2(uv.x / 2.0 + 0.5, uv.y);
	}

	float4 result = block_image.Sample(textureSampler, uv);
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
	float limit = 0.2;
	return (rgba.r <= limit &&
			rgba.g <= limit &&
			rgba.b <= limit);
}
bool isGrey(float4 rgba) {
	float limit = 0.15;
	return (rgba.r >= 0.5 - limit && rgba.r <= 0.5 + limit &&
			rgba.g >= 0.5 - limit && rgba.g <= 0.5 + limit &&
			rgba.b >= 0.5 - limit && rgba.b <= 0.5 + limit);
	
}

float4 palette1() {
	return (sampleBlock(paletteA1_uv()) +
			sampleBlock(paletteA2_uv())) / 2.0;  //S Piece
}
float4 palette2() {
	return (sampleBlock(paletteB1_uv()) +
	        sampleBlock(paletteB2_uv())) / 2.0; // L piece
}

//Simple 4 sample of centre of 8x8 block
float4 sampleBlock(float2 uv)
{	
	float4 centre = image.Sample(textureSampler, uv);
	//float4 tl = image.Sample(textureSampler,float2(uv.x - 1/256.0, uv.y - 1/224.0));
	float4 tr = image.Sample(textureSampler,float2(uv.x + 1/256.0, uv.y - 1/224.0));
	float4 r = image.Sample(textureSampler,float2(uv.x + 1/256.0, uv.y));
	float4 bl = image.Sample(textureSampler,float2(uv.x - 1/256.0, uv.y + 1/224.0));
	float4 br = image.Sample(textureSampler,float2(uv.x + 1/256.0, uv.y + 1/224.0));
	float4 avg = (tr + bl + br + centre + r) / 5.0;
	//avg = centre;
	return avg;
}

//Simple top/bottom edge sample of 8x8 block.
float4 sampleEdge(float2 uv)
{
	float topyUv = uv.y + 2.5/224.0;
	float bottomyUv = uv.y - 3.5/224.0;
	float4 top = image.Sample(textureSampler, float2(uv.x, topyUv));
	float4 bottom = image.Sample(textureSampler, float2(uv.x, bottomyUv));			
	return (top + bottom) / 2.0;
}

bool isInGame()
{
	float4 black1 = sampleBlock(gameBlack1_uv()); //black box next to "LINES";
	float4 black2 = sampleBlock(gameBlack2_uv()); //black box of "TOP/SCORE"
	float4 grey1 = sampleBlock(gameGrey1_uv()); //grey box of bottom middle left
	return (isBlack(black1) && isBlack(black2) && isGrey(grey1));
}

//if top edge is not black, we assume game over.

bool isGameOver()
{	
	float startX = 12/32.0;
	float startY = 5/28.0 + 1/56.0;	
		
	float4 topleft = sampleBlock(float2(startX + 1/64.0, startY + 1/56.0));
	float4 topmid = sampleBlock(float2(startX + 11/64.0, startY + 1/56.0));
	float4 topright = sampleBlock(float2(startX + 19/64.0, startY + 1/56.0));
	
	if (isBlack(topleft) || isBlack(topmid) || isBlack(topright)) {
		return false;
	} else {
		return true;
	}
	
}
float colorDist(float4 a, float4 b)
{
	float rDist = ((a.r-b.r)) * ((a.r-b.r));
	float gDist = ((a.g-b.g)) * ((a.g-b.g));
	float bDist = ((a.b-b.b)) * ((a.b-b.b));
	return rDist+gDist+bDist;
}

float4 setupDraw(float2 uv)
{
	float4 orig = image.Sample(textureSampler, uv);
	if (inBox(uv))
	{		
		return (float4(1.0,0.0,0.0,1.0) + orig) / 2.0;	
	} 
	
	if (stat_palette || stat_palette_white) {
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
			return (float4(1.0,1.0,0.0,1.0));	
		}
		else if (inBox2(uv, paletteB2_box()))	
		{
			return (float4(1.0,1.0,0.0,1.0));	
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

float4 mainImage(VertData v_in) : TARGET
{	
	float2 uv = v_in.uv;
	if (setup_mode) {
		return setupDraw(uv);
	} 
	
	if (!skip_detect_game) 
	{	
		if (!isInGame()) {
			return image.Sample(textureSampler,uv);	
		}			
	}
	
	if (!skip_detect_game_over) 
	{		
		if (isGameOver()) {
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
		
		float blockxUv = (((uv.x - fblx) * 256.0) % (bw * 256.0)) / (bw * 256.0);
		float blockyUv = (((uv.y - fbty) * 224.0) % (bh * 224.0)) / (bh * 224.0);
		float2 blockUv = float2(blockxUv,blockyUv);
		float4 avg = sampleBlock(float2(centrexUv,centreyUv));
		
		//now we have two scenarios - centre is white, or not
		if (isBlack(avg)) {
			return float4(0.0,0.0,0.0,1.0);
		} else if (isWhite(avg)) {
			if (stat_palette_white) {
				avg = palette1();				
			} else {
				avg = sampleEdge(float2(centrexUv,centreyUv));
			}
			return blockTex(true, blockUv, avg);
		} else {							
			if (stat_palette) {
				float4 p1 = palette1();
				float4 p2 = palette2();
				float dist1 = colorDist(p1,avg);
				float dist2 = colorDist(p2,avg);
				if (dist1 < dist2) {
					avg = p1;
				} else {
					avg = p2;
				}
			}
			return blockTex(false, blockUv, avg);
		}
		
	} else { //not in play area.	
		return image.Sample(textureSampler, v_in.uv);
	}	
}

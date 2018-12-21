uniform texture2d other_image;
uniform bool skip_detect_game;
uniform bool skip_detect_game_over;
uniform bool stat_palette_white;
uniform bool stat_palette;
bool inBox(float2 uv) {	
	float startX = 12/32.0;
	float endX = startX + 10/32.0;
	float startY = 5/28.0;
	float endY = startY + 20/28.0;
	return (uv.x > startX && uv.x < endX && uv.y > startY && uv.y < endY);
}

bool inBox2(float2 uv, float4 box)
{
	return (uv.x >= box.r && 
			uv.x <= box.g && 
			uv.y >= box.b && 
			uv.y <= box.a);
}

float4 blockTex(bool white, float2 uv, float4 base) {	
	if (!white) {	
		uv = float2(uv.x / 2.0, uv.y);
	} else {
		uv = float2(uv.x / 2.0 + 0.5, uv.y);
	}

	float4 result = other_image.Sample(textureSampler, uv);
	if (result.a == 0.0) {
		return base;
	} else {
		return result;
	}		
	
}

bool isWhite(float4 rgba) {
	float limit = 0.5;
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
	return (sampleBlock(float2(0.137,0.459)));
	//return (sampleBlock(float2(0.137,0.459)) + //J piece in statistics.
	//		sampleBlock(float2(0.138,0.677))) / 2.0;  //S Piece
}
float4 palette2() {
	return (sampleBlock(float2(0.138,0.526)));
	//return (sampleBlock(float2(0.138,0.529)) + //z piece in statistics.
	//      sampleBlock(float2(0.138,0.743))) / 2.0; // L piece
}

//Simple 4 sample of centre of 8x8 block
float4 sampleBlock(float2 uv)
{	
	float4 centre = image.Sample(textureSampler, uv);
	//float4 tl = image.Sample(textureSampler,float2(centrexUv - 1/256.0, centreyUv - 1/224.0));
	float4 tr = image.Sample(textureSampler,float2(uv.x + 1/256.0, uv.y - 1/224.0));
	float4 bl = image.Sample(textureSampler,float2(uv.x - 1/256.0, uv.y + 1/224.0));
	float4 br = image.Sample(textureSampler,float2(uv.x + 1/256.0, uv.y + 1/224.0));
	float4 avg = (tr + bl + br + centre) / 4.0;
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
	float4 black1 = sampleBlock(float2(0.384,0.086)); //black box next to "LINES";
	float4 black2 = sampleBlock(float2(0.928,0.074)); //black box of "TOP/SCORE"
	float4 grey1 = sampleBlock(float2(0.049,0.977)); //grey box of bottom middle left
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
	float rDist = ((a.r-b.r)*0.30) * ((a.r-b.r)*0.30);
	float gDist = ((a.g-b.g)*0.59) * ((a.g-b.g)*0.59);
	float bDist = ((a.b-b.b)*0.11) * ((a.b-b.b)*0.11);
	return rDist+gDist+bDist;
}
float4 mainImage(VertData v_in) : TARGET
{	
	float2 uv = v_in.uv;
	
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
		float centrexUv = floor(uv.x * 32.0)*1/32.0 + 1/64.0;
		float centreyUv = floor(uv.y * 28.0)*1/28.0 + 1/56.0;		
		float2 centre = float2(centrexUv,centreyUv);
		
		float blockxUv = ((uv.x * 256.0) % 8.0) / 8.0;
		float blockyUv = ((uv.y * 224.0) % 8.0) / 8.0;
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

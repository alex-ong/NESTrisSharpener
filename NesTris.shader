uniform texture2d other_image;

bool inBox(float2 uv) {	
	float startX = 12/32.0;
	float endX = startX + 10/32.0;
	float startY = 5/28.0;
	float endY = startY + 20/28.0;
	return (uv.x > startX && uv.x < endX && uv.y > startY && uv.y < endY);
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
	float limit = 0.8;
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

float4 mainImage(VertData v_in) : TARGET
{	
	
	float2 uv = v_in.uv;
	if (inBox(uv)) { //in play area		
		float centrexUv = floor(uv.x * 32.0)*1/32.0 + 1/64.0;
		float centreyUv = floor(uv.y * 28.0)*1/28.0 + 1/56.0;
		
		float blockxUv = ((uv.x * 256.0) % 8.0) / 8.0;
		float blockyUv = ((uv.y * 224.0) % 8.0) / 8.0;
		float4 centre = image.Sample(textureSampler, float2(centrexUv, centreyUv));

		//now we have two scenarios - centre is white, or not
		if (isBlack(centre)) {
			return float4(0.0,0.0,0.0,1.0);
		} else if (isWhite(centre)) {
			float topyUv = centreyUv + 2.5/224.0;
			float bottomyUv = centreyUv - 3.5/224.0;
			float4 top = image.Sample(textureSampler, float2(centrexUv, topyUv));
			float4 bottom = image.Sample(textureSampler, float2(centrexUv, bottomyUv));			
			float4 avg = top + bottom / 2.0;
			return blockTex(true, float2(blockxUv, blockyUv), avg);
		} else {				
			//return centre;
			return blockTex(false, float2(blockxUv,blockyUv),centre);
		}
		
	} else { //not in play area.	
		return image.Sample(textureSampler, v_in.uv);
	}	
}

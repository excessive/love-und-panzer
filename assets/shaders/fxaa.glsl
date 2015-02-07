#extension GL_EXT_gpu_shader4 : enable

const vec3 white_point = vec3(1.0, 1.0, 1.0);
uniform float u_exposure = 1.0;

uniform int u_fxaa = 0;
uniform int u_tonemap = 1;
uniform int u_color_correct = 0;

// Sort of a hack: LOVE doesn't expose 3D textures, so we have to sample them
// as 2D and interpolate the samples ourselves.
uniform sampler2D u_lut_primary;
uniform sampler2D u_lut_secondary;
uniform float u_factor = 0.0;

// this is a Timothy Lottes FXAA 3.11
// check out the following link for detailed information:
// http://timothylottes.blogspot.ch/2011/07/fxaa-311-released.html
//
// the shader source has been stripped with a preprocessor for
// brevity reasons (it's still pretty long for inlining...).
// the used defines are:
// #define FXAA_PC 1
// #define FXAA_GLSL_130 1
// #define FXAA_QUALITY__PRESET 13

float FxaaLuma(vec4 rgba) {
	return rgba.w;
}

vec4 FxaaPixelShader(
	vec2 pos,
	sampler2D tex,
	vec2 fxaaQualityRcpFrame,
	float fxaaQualitySubpix,
	float fxaaQualityEdgeThreshold,
	float fxaaQualityEdgeThresholdMin
) {
	vec2 posM;
	posM.x = pos.x;
	posM.y = pos.y;
	vec4 rgbyM = texture2DLod(tex, posM, 0.0);
	float lumaS = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2( 0, 1)));
	float lumaE = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2( 1, 0)));
	float lumaN = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2( 0,-1)));
	float lumaW = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2(-1, 0)));
	float maxSM = max(lumaS, rgbyM.w);
	float minSM = min(lumaS, rgbyM.w);
	float maxESM = max(lumaE, maxSM);
	float minESM = min(lumaE, minSM);
	float maxWN = max(lumaN, lumaW);
	float minWN = min(lumaN, lumaW);
	float rangeMax = max(maxWN, maxESM);
	float rangeMin = min(minWN, minESM);
	float rangeMaxScaled = rangeMax * fxaaQualityEdgeThreshold;
	float range = rangeMax - rangeMin;
	float rangeMaxClamped = max(fxaaQualityEdgeThresholdMin, rangeMaxScaled);

	bool earlyExit = range < rangeMaxClamped;
	if(earlyExit)
		return rgbyM;

	float lumaNW = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2(-1,-1)));
	float lumaSE = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2( 1, 1)));
	float lumaNE = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2( 1,-1)));
	float lumaSW = FxaaLuma(texture2DLodOffset(tex, posM, 0.0, ivec2(-1, 1)));
	float lumaNS = lumaN + lumaS;
	float lumaWE = lumaW + lumaE;
	float subpixRcpRange = 1.0/range;
	float subpixNSWE = lumaNS + lumaWE;
	float edgeHorz1 = (-2.0 * rgbyM.w) + lumaNS;
	float edgeVert1 = (-2.0 * rgbyM.w) + lumaWE;
	float lumaNESE = lumaNE + lumaSE;
	float lumaNWNE = lumaNW + lumaNE;
	float edgeHorz2 = (-2.0 * lumaE) + lumaNESE;
	float edgeVert2 = (-2.0 * lumaN) + lumaNWNE;
	float lumaNWSW = lumaNW + lumaSW;
	float lumaSWSE = lumaSW + lumaSE;
	float edgeHorz4 = (abs(edgeHorz1) * 2.0) + abs(edgeHorz2);
	float edgeVert4 = (abs(edgeVert1) * 2.0) + abs(edgeVert2);
	float edgeHorz3 = (-2.0 * lumaW) + lumaNWSW;
	float edgeVert3 = (-2.0 * lumaS) + lumaSWSE;
	float edgeHorz = abs(edgeHorz3) + edgeHorz4;
	float edgeVert = abs(edgeVert3) + edgeVert4;
	float subpixNWSWNESE = lumaNWSW + lumaNESE;
	float lengthSign = fxaaQualityRcpFrame.x;
	bool horzSpan = edgeHorz >= edgeVert;
	float subpixA = subpixNSWE * 2.0 + subpixNWSWNESE;
	if(!horzSpan) lumaN = lumaW;
	if(!horzSpan) lumaS = lumaE;
	if(horzSpan) lengthSign = fxaaQualityRcpFrame.y;
	float subpixB = (subpixA * (1.0/12.0)) - rgbyM.w;
	float gradientN = lumaN - rgbyM.w;
	float gradientS = lumaS - rgbyM.w;
	float lumaNN = lumaN + rgbyM.w;
	float lumaSS = lumaS + rgbyM.w;
	bool pairN = abs(gradientN) >= abs(gradientS);
	float gradient = max(abs(gradientN), abs(gradientS));
	if(pairN) lengthSign = -lengthSign;
	float subpixC = clamp(abs(subpixB) * subpixRcpRange, 0.0, 1.0);
	vec2 posB;
	posB.x = posM.x;
	posB.y = posM.y;
	vec2 offNP;
	offNP.x = (!horzSpan) ? 0.0 : fxaaQualityRcpFrame.x;
	offNP.y = ( horzSpan) ? 0.0 : fxaaQualityRcpFrame.y;
	if(!horzSpan) posB.x += lengthSign * 0.5;
	if( horzSpan) posB.y += lengthSign * 0.5;
	vec2 posN;
	posN.x = posB.x - offNP.x * 1.0;
	posN.y = posB.y - offNP.y * 1.0;
	vec2 posP;
	posP.x = posB.x + offNP.x * 1.0;
	posP.y = posB.y + offNP.y * 1.0;
	float subpixD = ((-2.0)*subpixC) + 3.0;
	float lumaEndN = FxaaLuma(texture2DLod(tex, posN, 0.0));
	float subpixE = subpixC * subpixC;
	float lumaEndP = FxaaLuma(texture2DLod(tex, posP, 0.0));
	if(!pairN) lumaNN = lumaSS;
	float gradientScaled = gradient * 1.0/4.0;
	float lumaMM = rgbyM.w - lumaNN * 0.5;
	float subpixF = subpixD * subpixE;
	bool lumaMLTZero = lumaMM < 0.0;
	lumaEndN -= lumaNN * 0.5;
	lumaEndP -= lumaNN * 0.5;
	bool doneN = abs(lumaEndN) >= gradientScaled;
	bool doneP = abs(lumaEndP) >= gradientScaled;
	if(!doneN) posN.x -= offNP.x * 1.5;
	if(!doneN) posN.y -= offNP.y * 1.5;
	bool doneNP = (!doneN) || (!doneP);
	if(!doneP) posP.x += offNP.x * 1.5;
	if(!doneP) posP.y += offNP.y * 1.5;
	if(doneNP) {
		if(!doneN) lumaEndN = FxaaLuma(texture2DLod(tex, posN.xy, 0.0));
		if(!doneP) lumaEndP = FxaaLuma(texture2DLod(tex, posP.xy, 0.0));
		if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
		if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
		doneN = abs(lumaEndN) >= gradientScaled;
		doneP = abs(lumaEndP) >= gradientScaled;
		if(!doneN) posN.x -= offNP.x * 2.0;
		if(!doneN) posN.y -= offNP.y * 2.0;
		doneNP = (!doneN) || (!doneP);
		if(!doneP) posP.x += offNP.x * 2.0;
		if(!doneP) posP.y += offNP.y * 2.0;
		if(doneNP) {
			if(!doneN) lumaEndN = FxaaLuma(texture2DLod(tex, posN.xy, 0.0));
			if(!doneP) lumaEndP = FxaaLuma(texture2DLod(tex, posP.xy, 0.0));
			if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
			if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
			doneN = abs(lumaEndN) >= gradientScaled;
			doneP = abs(lumaEndP) >= gradientScaled;
			if(!doneN) posN.x -= offNP.x * 2.0;
			if(!doneN) posN.y -= offNP.y * 2.0;
			doneNP = (!doneN) || (!doneP);
			if(!doneP) posP.x += offNP.x * 2.0;
			if(!doneP) posP.y += offNP.y * 2.0;
			if(doneNP) {
				if(!doneN) lumaEndN = FxaaLuma(texture2DLod(tex, posN.xy, 0.0));
				if(!doneP) lumaEndP = FxaaLuma(texture2DLod(tex, posP.xy, 0.0));
				if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
				if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
				doneN = abs(lumaEndN) >= gradientScaled;
				doneP = abs(lumaEndP) >= gradientScaled;
				if(!doneN) posN.x -= offNP.x * 4.0;
				if(!doneN) posN.y -= offNP.y * 4.0;
				doneNP = (!doneN) || (!doneP);
				if(!doneP) posP.x += offNP.x * 4.0;
				if(!doneP) posP.y += offNP.y * 4.0;
				if(doneNP) {
					if(!doneN) lumaEndN = FxaaLuma(texture2DLod(tex, posN.xy, 0.0));
					if(!doneP) lumaEndP = FxaaLuma(texture2DLod(tex, posP.xy, 0.0));
					if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
					if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
					doneN = abs(lumaEndN) >= gradientScaled;
					doneP = abs(lumaEndP) >= gradientScaled;
					if(!doneN) posN.x -= offNP.x * 12.0;
					if(!doneN) posN.y -= offNP.y * 12.0;
					doneNP = (!doneN) || (!doneP);
					if(!doneP) posP.x += offNP.x * 12.0;
					if(!doneP) posP.y += offNP.y * 12.0;
				}
			}
		}
	}

	float dstN = posM.x - posN.x;
	float dstP = posP.x - posM.x;
	if(!horzSpan) dstN = posM.y - posN.y;
	if(!horzSpan) dstP = posP.y - posM.y;

	bool goodSpanN = (lumaEndN < 0.0) != lumaMLTZero;
	float spanLength = (dstP + dstN);
	bool goodSpanP = (lumaEndP < 0.0) != lumaMLTZero;
	float spanLengthRcp = 1.0/spanLength;

	bool directionN = dstN < dstP;
	float dst = min(dstN, dstP);
	bool goodSpan = directionN ? goodSpanN : goodSpanP;
	float subpixG = subpixF * subpixF;
	float pixelOffset = (dst * (-spanLengthRcp)) + 0.5;
	float subpixH = subpixG * fxaaQualitySubpix;

	float pixelOffsetGood = goodSpan ? pixelOffset : 0.0;
	float pixelOffsetSubpix = max(pixelOffsetGood, subpixH);
	if(!horzSpan) posM.x += pixelOffsetSubpix * lengthSign;
	if( horzSpan) posM.y += pixelOffsetSubpix * lengthSign;

	return vec4(texture2DLod(tex, posM, 0.0).xyz, rgbyM.w);
}

// http://frictionalgames.blogspot.com/2012/09/tech-feature-hdr-lightning.html
vec3 Uncharted2Tonemap(vec3 x) {
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;

	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

// Thanks Google.
vec4 _texture3D(sampler2D tex, vec3 texCoord, float size) {
	float sliceSize = 1.0 / size;                         // space of 1 slice
	float slicePixelSize = sliceSize / size;              // space of 1 pixel
	float sliceInnerSize = slicePixelSize * (size - 1.0); // space of size pixels
	float zSlice0 = min(floor(texCoord.z * size), size - 1.0);
	float zSlice1 = min(zSlice0 + 1.0, size - 1.0);
	float xOffset = slicePixelSize * 0.5 + texCoord.x * sliceInnerSize;
	float s0 = xOffset + (zSlice0 * sliceSize);
	float s1 = xOffset + (zSlice1 * sliceSize);
	vec4 slice0Color = texture2D(tex, vec2(s0, texCoord.y));
	vec4 slice1Color = texture2D(tex, vec2(s1, texCoord.y));
	float zOffset = mod(texCoord.z * size, 1.0);
	return mix(slice0Color, slice1Color, zOffset);
}

vec3 ColorCorrect(in vec3 raw_color, in vec2 coords) {
	float threshold = 1.0/255.0;
	vec4 color;

	float lut_size = textureSize2D(u_lut_primary, 0).y;

	// correct for clamping from the texture lookup, from GPU Gems 2 ch24
	// http://http.developer.nvidia.com/GPUGems2/gpugems2_chapter24.html
	float scale = (lut_size - 1.0) / lut_size;
	float offset = 1.0 / (lut_size * 2.0);

	raw_color *= scale;
	raw_color += offset;

	if (u_factor <= threshold) {
		color = _texture3D(u_lut_primary, raw_color.rgb, lut_size);
	} else if (u_factor >= 1.0 - threshold) {
		color = _texture3D(u_lut_secondary, raw_color.rgb, lut_size);
	} else {
		color = mix(
			_texture3D(u_lut_primary, raw_color.rgb, lut_size),
			_texture3D(u_lut_secondary, raw_color.rgb, lut_size),
			u_factor
		);
	}

	return color.rgb;
}

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 out_color = vec4(1.0);
	vec2 coords = texture_coords * vec2(1.0, -1.0) + vec2(0.0, 1.0);

	if (u_fxaa == 1) {
		out_color = FxaaPixelShader(
			coords,
			texture,
			1.0 / textureSize2D(texture,0),
			0.75,
			0.166,
			0.0625
		);
	} else {
		out_color = texture2D(texture, coords);
	}

	if (u_tonemap == 1) {
		// XXX: I think this should happen *before* the AA step...
		out_color.rgb = Uncharted2Tonemap(out_color.rgb * u_exposure) / Uncharted2Tonemap(white_point);
	}

	if (u_color_correct == 1) {
		out_color.rgb = ColorCorrect(out_color.rgb, texture_coords);
	}

	return out_color;
}

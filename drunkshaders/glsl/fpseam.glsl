/* ------------------------------------------------------------------------- */
/* --------- FEEL FREE TO CHANGE THE NUMBERS AND true/false VALUES --------- */
/* ---------- (the settings were introduced by drunkshaders mod) ----------- */

const bool uhCatmullRom		= false;

const lowp float uhSharpen	=  0.0;	// 0.0 - default, positive - sharpen, negative - blur, play with +-0.2 steps to see difference
const lowp float uhGamma	=  1.0;	// gamma correction (1.0 is default, play with +-20% steps to see difference)
const lowp float uhContrast	=  1.0;	// contrast multiplier (1.0 is default, play with +-20% steps to see difference)
const lowp float uhBright	=  0.0;	// brightness offset (0.0 is default, +-0.005 is noticable already)
const lowp float uhSat		=  1.0;	// saturation multiplier (1.0 is default, play with +-20% steps to see difference)
const lowp float uhHueDeg	=  0.0;	// hue rotation in YIQ space in degrees, play with +-5deg steps, 180deg means opposite

const mediump float uhOutlineSize	= 0.0;	// up to 3.5; 0.0 to disable; default for fpsprite: 2.0, default for fpselect: 3.5

const lowp float uhFontHackGamma	= 0.0;	// dirty hack for UI mods that affect stack count rendering (Dragonspear UI++, Infinity UI); fpdraw-only; 0.0 means disabled; usually DON'T SET

/* - CHANGING THE CODE BELOW MIGHT REQUIRE GLSL KNOWLEDGE / BREAK THE GAME - */
/* ------------------------------------------------------------------------- */


const lowp vec3 uhSatNV		= vec3(1.0 - uhSat);

const lowp float uhHueU		= cos(uhHueDeg * 3.14159265 / 180.0);
const lowp float uhHueW		= sin(uhHueDeg * 3.14159265 / 180.0);
const lowp mat3  uhHueM		= mat3(
	0.299 + 0.701 * uhHueU + 0.168 * uhHueW,
	0.299 - 0.299 * uhHueU - 0.328 * uhHueW,
	0.299 - 0.300 * uhHueU + 1.250 * uhHueW,
	0.587 - 0.587 * uhHueU + 0.330 * uhHueW,
	0.587 + 0.413 * uhHueU + 0.035 * uhHueW,
	0.587 - 0.588 * uhHueU - 1.050 * uhHueW,
	0.114 - 0.114 * uhHueU - 0.497 * uhHueW,
	0.114 - 0.114 * uhHueU + 0.292 * uhHueW,
	0.114 + 0.886 * uhHueU - 0.203 * uhHueW
);

const lowp vec3 rgbWeights  = vec3(0.299, 0.587, 0.114);

#define HAS_U_COLOR_TONE 1
#define HAS_BLUR_AMOUNT 0
#define HAS_VREF 1
#define OUTLINE_COLOR vec3(0.0)
#define VCOLOR_MUL 2

uniform lowp	sampler2D	uTex;
#if HAS_BLUR_AMOUNT
uniform lowp	float		uSpriteBlurAmount;
#endif
uniform mediump vec2		uTcScale;
#if HAS_U_COLOR_TONE
uniform highp	vec4		uColorTone;
#endif
varying mediump	vec2		vTc;
#if HAS_VREF
varying highp	vec2		vRef;
#endif
varying lowp	vec4		vColor;


lowp vec3 uhToLinear(in lowp vec3 srgb)
{
	lowp vec3 cutoff = vec3(lessThanEqual(srgb, vec3(0.039285714)));
	lowp vec3 higher = pow(srgb * 0.947867299 + 0.052132701, vec3(2.4));
	lowp vec3 lower = srgb * 0.077380154;
	return mix(higher, lower, cutoff);
}

lowp vec3 uhFromLinear(in lowp vec3 rgb)
{
	lowp vec3 cutoff = vec3(lessThanEqual(rgb, vec3(0.0030399346)));
	lowp vec3 higher = pow(rgb, vec3(0.4166666667)) * 1.055 - 0.055;
	lowp vec3 lower = rgb * 12.9232101808;
	return mix(higher, lower, cutoff);
}

lowp vec3 uhFetchPixel(in ivec2 pos)
{
	return uhToLinear(texelFetch(uTex, pos, 0).rgb);
}

lowp vec3[16] uhFetchRegion(in ivec2 posUb)
{
	return vec3[16](
		uhFetchPixel(posUb + ivec2(-1, -1)),
		uhFetchPixel(posUb + ivec2( 0, -1)),
		uhFetchPixel(posUb + ivec2( 1, -1)),
		uhFetchPixel(posUb + ivec2( 2, -1)),
		uhFetchPixel(posUb + ivec2(-1,  0)),
		uhFetchPixel(posUb),
		uhFetchPixel(posUb + ivec2( 1,  0)),
		uhFetchPixel(posUb + ivec2( 2,  0)),
		uhFetchPixel(posUb + ivec2(-1,  1)),
		uhFetchPixel(posUb + ivec2( 0,  1)),
		uhFetchPixel(posUb + ivec2( 1,  1)),
		uhFetchPixel(posUb + ivec2( 2,  1)),
		uhFetchPixel(posUb + ivec2(-1,  2)),
		uhFetchPixel(posUb + ivec2( 0,  2)),
		uhFetchPixel(posUb + ivec2( 1,  2)),
		uhFetchPixel(posUb + ivec2( 2,  2))
	);
}

lowp vec3 uhApplyWeightsMat(in lowp vec3 region[16], in lowp mat4 mat)
{
	return (
		region[ 0] * mat[0][0] +
		region[ 1] * mat[0][1] +
		region[ 2] * mat[0][2] +
		region[ 3] * mat[0][3] +
		region[ 4] * mat[1][0] +
		region[ 5] * mat[1][1] +
		region[ 6] * mat[1][2] +
		region[ 7] * mat[1][3] +
		region[ 8] * mat[2][0] +
		region[ 9] * mat[2][1] +
		region[10] * mat[2][2] +
		region[11] * mat[2][3] +
		region[12] * mat[3][0] +
		region[13] * mat[3][1] +
		region[14] * mat[3][2] +
		region[15] * mat[3][3]
	);
}

lowp mat4 uhCamtullRomMat(in mediump vec2 posFr)
{
	lowp mat2x4 axes = transpose(mat4x2(
		posFr * (posFr * (posFr * -0.5 + 1.0) - 0.5),
		posFr *  posFr * (posFr *  1.5 - 2.5) + 1.0,
		posFr * (posFr * (posFr * -1.5 + 2.0) + 0.5),
		posFr *  posFr * (posFr *  0.5 - 0.5)
	));

	return outerProduct(axes[0], axes[1]);
}

lowp vec3 uhCatmullRomInterp(in lowp vec3 region[16], in mediump vec2 posFr)
{
	return uhApplyWeightsMat(region, uhCamtullRomMat(posFr));
}

mediump float uhNormCDF(in mediump float x, in mediump float invScale)
{
	mediump float sx = x * invScale;
	mediump float emx2 = exp(sx * sx * -0.5);
	return sign(x) * 0.56418958 * sqrt(1.0 - emx2) * (0.88622692 + emx2 * (emx2 * -0.042625 + 0.155)) + 0.5;
}

lowp mat4 uhGaussianBlurMat(in mediump vec2 posFr, in mediump float scale)
{
	mediump float invScale = 1.0 / scale;
	lowp float stopsX[5] = float[5](
		uhNormCDF(-1.5 + posFr.x, invScale),
		uhNormCDF(-0.5 + posFr.x, invScale),
		uhNormCDF( 0.5 + posFr.x, invScale),
		uhNormCDF( 1.5 + posFr.x, invScale),
		uhNormCDF( 2.5 + posFr.x, invScale)
	);
	lowp float mulX = 1.0 / (stopsX[4] - stopsX[0]);
	lowp float stopsY[5] = float[5](
		uhNormCDF(-1.5 + posFr.y, invScale),
		uhNormCDF(-0.5 + posFr.y, invScale),
		uhNormCDF( 0.5 + posFr.y, invScale),
		uhNormCDF( 1.5 + posFr.y, invScale),
		uhNormCDF( 2.5 + posFr.y, invScale)
	);
	lowp float mulY = 1.0 / (stopsY[4] - stopsY[0]);
	lowp mat2x4 axes = mat2x4(
		(stopsX[1] - stopsX[0]) * mulX,
		(stopsX[2] - stopsX[1]) * mulX,
		(stopsX[3] - stopsX[2]) * mulX,
		(stopsX[4] - stopsX[3]) * mulX,
		(stopsY[1] - stopsY[0]) * mulY,
		(stopsY[2] - stopsY[1]) * mulY,
		(stopsY[3] - stopsY[2]) * mulY,
		(stopsY[4] - stopsY[3]) * mulY
	);
	return outerProduct(axes[1], axes[0]);
}

lowp vec3 uhGaussianBlur(in lowp vec3 region[16], in mediump vec2 posFr, in mediump float scale)
{
	return uhApplyWeightsMat(region, uhGaussianBlurMat(posFr, scale));
}

lowp vec3 uhYIQRotate(in lowp vec3 color)
{
	if (uhHueDeg == 0.0)
	{
		return color;
	}
	return uhHueM * color;
}

lowp vec4 uhMakeFragColor(in lowp vec3 rgb, in lowp float alpha, in lowp float gamma)
{
	lowp vec3 color = uhYIQRotate(rgb);
	lowp float grey = dot(color, rgbWeights);

	color = color * uhSat + uhSatNV * grey;
	#if HAS_U_COLOR_TONE
	lowp vec3 tone = grey * uhToLinear(uColorTone.rgb);
	color = mix(color, tone, uColorTone.a);
	#endif
	
	color = uhContrast * (color - 0.5) + 0.5 + uhBright;
	color = pow(color, vec3(gamma));

	return vec4(uhFromLinear(color), alpha);
}

#define OUTLINE_SEARCH_RADIUS 3
#define OUTLINE_MAT_COLS (OUTLINE_SEARCH_RADIUS + 2 + 1)

mediump vec2 uhOutlineData(in mediump vec2 uVTc, in ivec2 posUb)
{
	bool inside[OUTLINE_MAT_COLS * OUTLINE_MAT_COLS];
	mediump float dist2 = uhOutlineSize * uhOutlineSize;
	lowp float maxAlpha = 0.0;
	for (int y = -OUTLINE_SEARCH_RADIUS; y <= OUTLINE_SEARCH_RADIUS; ++y)
	{
		for (int x = -OUTLINE_SEARCH_RADIUS; x <= OUTLINE_SEARCH_RADIUS; ++x)
		{
			ivec2 posXY = posUb + ivec2(x, y);
			float alpha = texelFetch(uTex, posXY, 0).a;
			bool mark = alpha >= 0.0625;
			inside[(y + OUTLINE_SEARCH_RADIUS) * OUTLINE_MAT_COLS + x + OUTLINE_SEARCH_RADIUS] = mark;
			maxAlpha = max(maxAlpha, alpha);
			if (x != -OUTLINE_SEARCH_RADIUS && mark != inside[(y + OUTLINE_SEARCH_RADIUS) * OUTLINE_MAT_COLS + x + OUTLINE_SEARCH_RADIUS - 1])
			{
				lowp vec2 rel = uVTc - posXY;
				rel *= rel;
				dist2 = min(dist2, rel.y + rel.x);
			}
			if (y != -OUTLINE_SEARCH_RADIUS && mark != inside[(y + OUTLINE_SEARCH_RADIUS - 1) * OUTLINE_MAT_COLS + x + OUTLINE_SEARCH_RADIUS])
			{
				lowp vec2 rel = uVTc - posXY;
				rel *= rel;
				dist2 = min(dist2, rel.y + rel.x);
			}
		}
	}
	return vec2(sqrt(dist2), maxAlpha);
}

lowp float uhBoundMul(in lowp float x, in lowp float low, in lowp float high, in lowp float margin)
{
	if(x <= low - margin)
	{
		return 0.0;
	}
	else if(x < low)
	{
		return (low - x) / margin;
	}
	else if(x <= high)
	{
		return 1.0;
	}
	else if(x < high + margin)
	{
		return (high + margin - x) / margin;
	}
	else
	{
		return 0.0;
	}
}


void main()
{
	mediump vec2 iUTcScale = 1.0 / uTcScale;
	mediump vec2 uVTc = vTc * iUTcScale - 0.5;
	ivec2 posUb = ivec2(uVTc);
	mediump vec2 posFr = uVTc - posUb;

	lowp vec4 lSample = texture(uTex, vTc);
	lowp vec3 region[16] = uhFetchRegion(posUb);
	lowp float gamma = uhGamma;

	bool borderT = (posUb.y <= 0);
	bool borderB = (posUb.y >= iUTcScale.y - 2);
	bool borderB2 = (posUb.y >= iUTcScale.y - 1);
	bool borderL = (posUb.x <= 0);
	bool borderR = (posUb.x >= iUTcScale.x - 2);
	bool borderR2 = (posUb.x >= iUTcScale.x - 1);

	#if HAS_VREF
	ivec2 texCoordTileLoc = (posUb - ivec2(vRef * iUTcScale - 0.5)) & 63;
	borderT  = borderT  || (texCoordTileLoc.y == 0);
	borderB  = borderB  || (texCoordTileLoc.y >= 62);
	borderB2 = borderB2 || (texCoordTileLoc.y >= 63);
	borderL  = borderL  || (texCoordTileLoc.x == 0);
	borderR  = borderR  || (texCoordTileLoc.x >= 62);
	borderR2 = borderR2 || (texCoordTileLoc.x >= 63);
	#endif

	if (borderT)
	{
		region[0 * 4 + 0] = region[1 * 4 + 0];
		region[0 * 4 + 1] = region[1 * 4 + 1];
		region[0 * 4 + 2] = region[1 * 4 + 2];
		region[0 * 4 + 3] = region[1 * 4 + 3];
	}
	if (borderB2)
	{
		region[2 * 4 + 0] = region[1 * 4 + 0];
		region[2 * 4 + 1] = region[1 * 4 + 1];
		region[2 * 4 + 2] = region[1 * 4 + 2];
		region[2 * 4 + 3] = region[1 * 4 + 3];
	}
	if (borderB)
	{
		region[3 * 4 + 0] = region[2 * 4 + 0];
		region[3 * 4 + 1] = region[2 * 4 + 1];
		region[3 * 4 + 2] = region[2 * 4 + 2];
		region[3 * 4 + 3] = region[2 * 4 + 3];
	}
	if (borderL)
	{
		region[0 * 4 + 0] = region[0 * 4 + 1];
		region[1 * 4 + 0] = region[1 * 4 + 1];
		region[2 * 4 + 0] = region[2 * 4 + 1];
		region[3 * 4 + 0] = region[3 * 4 + 1];
	}
	if (borderR2)
	{
		region[0 * 4 + 2] = region[0 * 4 + 1];
		region[1 * 4 + 2] = region[1 * 4 + 1];
		region[2 * 4 + 2] = region[2 * 4 + 1];
		region[3 * 4 + 2] = region[3 * 4 + 1];
	}
	if (borderR)
	{
		region[0 * 4 + 3] = region[2 * 4 + 2];
		region[1 * 4 + 3] = region[2 * 4 + 2];
		region[2 * 4 + 3] = region[2 * 4 + 2];
		region[3 * 4 + 3] = region[2 * 4 + 2];
	}

	lowp vec3 outColor;

	if (uhCatmullRom && !(VCOLOR_MUL == 2 && all(equal(region[4 * 2 + 2], vec3(0.0)))))
	{
		outColor = uhCatmullRomInterp(region, posFr);
	}
	else
	{
		outColor = uhToLinear(lSample.rgb);
	}

	if (uhSharpen != 0.0)
	{
		lowp vec3 average = uhGaussianBlur(region, posFr, 2.5);
		outColor = outColor * (1.0 + uhSharpen) - average * uhSharpen;
	}

	#if VCOLOR_MUL == 1
	lSample.a = vColor.a * outColor.r;
	outColor = uhToLinear(vColor.rgb);
	#elif VCOLOR_MUL == 2
	outColor *= uhToLinear(vColor.rgb);
	lSample.a *= vColor.a;
	lSample.a *= lSample.a;
	#endif

	if (uhFontHackGamma > 0.0 && uhFontHackGamma != uhGamma)
	{
		lowp vec3 lRGB = uhToLinear(lSample.rgb);
		lowp float fontHackMatch = 1.0;
		fontHackMatch *= uhBoundMul(lRGB[0], 0.07, 1.00, 0.1);
		fontHackMatch *= uhBoundMul(lRGB[1] / lRGB[0], 0.84, 1.05, 0.1);
		fontHackMatch *= uhBoundMul(lRGB[2] / lRGB[0], 0.43, 0.63, 0.1);
		gamma = uhFontHackGamma * fontHackMatch + uhGamma * (1.0 - fontHackMatch);
	}

	if (uhOutlineSize <= 1.0)
	{
		gl_FragColor = uhMakeFragColor(outColor, lSample.a, gamma);
		return;
	}

	mediump vec2 outlineData = uhOutlineData(uVTc + 0.5, posUb);
	mediump float minDist = max(0.70710678, outlineData[0]);
	mediump float outlineAlpha = (1.0 - pow((minDist - 0.70710678) / (uhOutlineSize - 0.70710678) + 0.00001, 0.33333333)) * (outlineData[1] + 3.0) * 0.25;
	outColor = (uhToLinear(OUTLINE_COLOR) * outlineAlpha * (1.0 - lSample.a) + outColor * lSample.a) / (outlineAlpha * (1.0 - lSample.a) + lSample.a);
	lSample.a = 1.0 - (1.0 - lSample.a) * (1.0 - outlineAlpha);
	gl_FragColor = uhMakeFragColor(outColor, lSample.a, gamma);
}

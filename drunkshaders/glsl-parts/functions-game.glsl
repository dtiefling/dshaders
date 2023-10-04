uniform lowp	sampler2D	uTex;
#if UH_HAS_BLUR_AMOUNT
uniform lowp	float		uSpriteBlurAmount;
#endif
uniform mediump vec2		uTcScale;
#if UH_HAS_U_COLOR_TONE
uniform highp	vec4		uColorTone;
#endif
varying mediump	vec2		vTc;
#if UH_HAS_VREF
varying highp	vec2		vRef;
#endif
varying lowp	vec4		vColor;


const lowp vec3 uhRGBWeights	= vec3(0.299, 0.587, 0.114);
const lowp vec3 uhGFTextColor	= vec3(1.00, 0.95, 0.55);


#define UH_REG_WIDTH			(UH_REG_RADIUS * 2)
#define UH_REG_HEIGHT			UH_REG_WIDTH
#define UH_REG_SIZE				(UH_REG_WIDTH * UH_REG_WIDTH)
#define UH_REG_INDEX_OFFSET		((UH_REG_RADIUS - 1) * (UH_REG_WIDTH + 1))


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


lowp vec4 uhColorToLinear(in lowp vec4 color)
{
	return vec4(uhToLinear(color.rgb), color.a);
}


lowp vec4 uhColorFromLinear(in lowp vec4 color)
{
	return vec4(uhFromLinear(color.rgb), color.a);
}


lowp vec4 uhFetchTexel(in ivec2 pos, in ivec2 uhPosUb, in ivec2 uhPosMin, in ivec2 uhPosMax)
{
	vec2 tPos = vec2(clamp(uhPosUb + pos, uhPosMin, uhPosMax));
	return uhColorToLinear(texelFetch(uTex, ivec2(tPos), 0));
}


void uhFetchRegion(in ivec2 uhPosUb, inout lowp vec4 uhRegion[UH_REG_SIZE], in ivec2 uhPosMin, in ivec2 uhPosMax)
{
	int idx = 0;
	for (int y = -(UH_REG_RADIUS - 1); y <= UH_REG_RADIUS; ++y)
	{
		for (int x = -(UH_REG_RADIUS - 1); x <= UH_REG_RADIUS; ++x)
		{
			uhRegion[++idx] = uhFetchTexel(ivec2(x, y), uhPosUb, uhPosMin, uhPosMax);
		}
	}
}


lowp vec4 uhFetchPixelFast(in ivec2 pos, in lowp vec4 uhRegion[UH_REG_SIZE])
{
	return uhRegion[pos.y * UH_REG_WIDTH + pos.x + UH_REG_INDEX_OFFSET];
}


lowp vec4 uhFetchPixel(in ivec2 pos, in ivec2 uhPosUb, in lowp vec4 uhRegion[UH_REG_SIZE], in ivec2 uhPosMin, in ivec2 uhPosMax)
{
	if (
			pos.y < -(UH_REG_RADIUS - 1) ||
			pos.y > UH_REG_RADIUS ||
			pos.x < -(UH_REG_RADIUS - 1) ||
			pos.x > UH_REG_RADIUS)
	{
		return uhFetchTexel(pos, uhPosUb, uhPosMin, uhPosMax);
	}
	return uhFetchPixelFast(pos, uhRegion);
}


lowp vec4 uhFetchNN(in mediump vec2 uhPosFr, in lowp vec4 uhRegion[UH_REG_SIZE])
{
	return uhFetchPixelFast(ivec2(uhPosFr + vec2(0.5)), uhRegion);
}


lowp vec4 uhFetchLinear(in mediump vec2 uhPosFr, in lowp vec4 uhRegion[UH_REG_SIZE])
{
	return (
		uhFetchPixelFast(ivec2(0, 0), uhRegion) * (1.0 - uhPosFr.y) * (1.0 - uhPosFr.x) +
		uhFetchPixelFast(ivec2(1, 0), uhRegion) * (1.0 - uhPosFr.y) * uhPosFr.x +
		uhFetchPixelFast(ivec2(0, 1), uhRegion) * uhPosFr.y         * (1.0 - uhPosFr.x) +
		uhFetchPixelFast(ivec2(1, 1), uhRegion) * uhPosFr.y         * uhPosFr.x);
}


lowp vec4 uhFetchCatmullRom(in mediump vec2 uhPosFr, in lowp vec4 uhRegion[UH_REG_SIZE])
{
	lowp mat4x2 axes = mat4x2(
		uhPosFr * (uhPosFr * (uhPosFr * -0.5 + 1.0) - 0.5),
		uhPosFr *  uhPosFr * (uhPosFr *  1.5 - 2.5) + 1.0,
		uhPosFr * (uhPosFr * (uhPosFr * -1.5 + 2.0) + 0.5),
		uhPosFr *  uhPosFr * (uhPosFr *  0.5 - 0.5)
	);

	return (
			(
				uhFetchPixelFast(ivec2( 2,  2), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1,  2), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1,  2), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0,  2), uhRegion) * axes[1][0]) * axes[3][1] +
			(
				uhFetchPixelFast(ivec2( 2, -1), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1, -1), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1, -1), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0, -1), uhRegion) * axes[1][0]) * axes[0][1] +
			(
				uhFetchPixelFast(ivec2( 2,  1), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1,  1), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1,  1), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0,  1), uhRegion) * axes[1][0]) * axes[2][1] +
			(
				uhFetchPixelFast(ivec2( 2,  0), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1,  0), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1,  0), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0,  0), uhRegion) * axes[1][0]) * axes[1][1]
		);
}


lowp float uhNormCDF(in mediump float x, in mediump float invScale)
{
	mediump float sx = x * invScale;
	mediump float emx2 = exp(sx * sx * -0.5);
	return sign(x) * 0.56418958 * sqrt(1.0 - emx2) * (0.88622692 + emx2 * (emx2 * -0.042625 + 0.155)) + 0.5;
}


lowp vec4 uhFetchBlurry(in mediump float scale, in mediump vec2 uhPosFr, in lowp vec4 uhRegion[UH_REG_SIZE])
{
	mediump float invScale = 1.0 / scale;
	lowp float stopsX[5] = float[5](
		uhNormCDF(uhPosFr.x - 1.5, invScale),
		uhNormCDF(uhPosFr.x - 0.5, invScale),
		uhNormCDF(uhPosFr.x + 0.5, invScale),
		uhNormCDF(uhPosFr.x + 1.5, invScale),
		uhNormCDF(uhPosFr.x + 2.5, invScale)
	);
	lowp float mulX = 1.0 / (stopsX[4] - stopsX[0]);
	lowp float stopsY[5] = float[5](
		uhNormCDF(uhPosFr.y - 1.5, invScale),
		uhNormCDF(uhPosFr.y - 0.5, invScale),
		uhNormCDF(uhPosFr.y + 0.5, invScale),
		uhNormCDF(uhPosFr.y + 1.5, invScale),
		uhNormCDF(uhPosFr.y + 2.5, invScale)
	);
	lowp float mulY = 1.0 / (stopsY[4] - stopsY[0]);
	lowp mat4x2 axes = mat4x2(
		(stopsX[1] - stopsX[0]) * mulX,
		(stopsY[1] - stopsY[0]) * mulY,
		(stopsX[2] - stopsX[1]) * mulX,
		(stopsY[2] - stopsY[1]) * mulY,
		(stopsX[3] - stopsX[2]) * mulX,
		(stopsY[3] - stopsY[2]) * mulY,
		(stopsX[4] - stopsX[3]) * mulX,
		(stopsY[4] - stopsY[3]) * mulY
	);

	return (
			(
				uhFetchPixelFast(ivec2( 2,  2), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1,  2), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1,  2), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0,  2), uhRegion) * axes[1][0]) * axes[3][1] +
			(
				uhFetchPixelFast(ivec2( 2, -1), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1, -1), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1, -1), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0, -1), uhRegion) * axes[1][0]) * axes[0][1] +
			(
				uhFetchPixelFast(ivec2( 2,  1), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1,  1), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1,  1), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0,  1), uhRegion) * axes[1][0]) * axes[2][1] +
			(
				uhFetchPixelFast(ivec2( 2,  0), uhRegion) * axes[3][0] +
				uhFetchPixelFast(ivec2(-1,  0), uhRegion) * axes[0][0] +
				uhFetchPixelFast(ivec2( 1,  0), uhRegion) * axes[2][0] +
				uhFetchPixelFast(ivec2( 0,  0), uhRegion) * axes[1][0]) * axes[1][1]
		);
}


lowp vec4 uhFetchRefTexColor(in mediump vec2 uhPosFr, in lowp vec4 uhRegion[UH_REG_SIZE])
{
	return uhColorToLinear(
		uhColorFromLinear(uhFetchPixelFast(ivec2(0, 0), uhRegion)) * (1.0 - uhPosFr.y) * (1.0 - uhPosFr.x) +
		uhColorFromLinear(uhFetchPixelFast(ivec2(1, 0), uhRegion)) * (1.0 - uhPosFr.y) * uhPosFr.x +
		uhColorFromLinear(uhFetchPixelFast(ivec2(0, 1), uhRegion)) * uhPosFr.y         * (1.0 - uhPosFr.x) +
		uhColorFromLinear(uhFetchPixelFast(ivec2(1, 1), uhRegion)) * uhPosFr.y         * uhPosFr.x);
}


lowp vec3 uhYIQRotate(in lowp vec3 color)
{
	if (uhHueDeg == 0.0)
	{
		return color;
	}
	return uhHueM * color;
}


lowp vec4 uhMakeFragColor(in lowp vec4 pixel, in lowp float gamma)
{
	lowp vec3 color = uhYIQRotate(pixel.rgb);
	lowp float grey = dot(color, uhRGBWeights);

	color = color * uhSat + grey * (1.0 - uhSat);
	#if UH_HAS_U_COLOR_TONE
	lowp vec3 tone = grey * uhToLinear(uColorTone.rgb);
	color = mix(color, tone, uColorTone.a);
	#endif
	
	color = (color - 0.5) * uhContrast + 0.5 + uhBright;
	color = pow(color, vec3(gamma));

	return vec4(uhFromLinear(color), pixel.a);
}


lowp float uhRGBDist(in lowp vec3 x, in lowp vec3 y)
{
	lowp float rMean = (x.r + y.r) * 0.5;
	lowp vec3 diff = x - y;
	diff *= diff;
	return sqrt(diff.r * (2.0 + rMean) + diff.g * 4.0 + diff.b * (3.0 - rMean));
}


lowp float uhRelColorDist(in lowp vec3 x, in lowp vec3 y)
{
	return uhRGBDist(x, y) / (max(uhRGBDist(x, vec3(0.0)), uhRGBDist(vec3(0.0), y)) + 0.00001);
}


lowp float uhCosineSimilarity(in lowp vec3 x, in lowp vec3 y)
{
	return dot(x, y) / sqrt(dot(x, x) * dot(y, y) + 0.00001);
}


lowp float uhBoundMul(in lowp float x, in lowp float low, in lowp float high, in lowp float margin)
{
	lowp float mid = (high + low) * 0.5;
	lowp float mdist0 = mid - low;
	lowp float mdist = clamp(abs(x - mid) - mdist0, 0.0, margin);
	return 1.0 - mdist / margin;
}


#if HAS_OUTLINE_PARAMS
mediump vec2 uhOutlineData(in int radius, in ivec2 uhPosUb, in mediump vec2 uhPosFr, in lowp vec4 uhRegion[UH_REG_SIZE], in ivec2 uhPosMin, in ivec2 uhPosMax)
{
	mediump float dist2 = uhOutlineSize * uhOutlineSize;
	lowp float maxAlpha = 0.0;
	for (int y = -radius; y <= radius; ++y)
	{
		for (int x = -radius; x <= radius; ++x)
		{
			float alpha = uhFetchPixel(ivec2(x, y), uhPosUb, uhRegion, uhPosMin, uhPosMax).a;
			bool mark = alpha >= 0.0625;
			maxAlpha = max(maxAlpha, alpha);
			if (
					(x != -radius && (uhFetchPixel(ivec2(x - 1, y), uhPosUb, uhRegion, uhPosMin, uhPosMax).a > 0.0625) != mark) ||
					(y != -radius && (uhFetchPixel(ivec2(x, y - 1), uhPosUb, uhRegion, uhPosMin, uhPosMax).a > 0.0625) != mark))
			{
				lowp vec2 rel = uhPosFr - vec2(x, y) - UVTC_SHIFT;
				rel *= rel;
				dist2 = min(dist2, rel.y + rel.x);
			}
		}
	}
	return vec2(sqrt(dist2), maxAlpha);
}
#endif


bool uhProbableCircle(in lowp vec4 uhRegion[UH_REG_SIZE])
{
	int idx = 0;
	if (max(max(vColor.r, vColor.g), vColor.b) < 0.015625)
	{
		return false;
	}

	int allWhite = (
		int(all(equal(uhRegion[                       UH_REG_INDEX_OFFSET], vec4(1.0)))) +
		int(all(equal(uhRegion[                   1 + UH_REG_INDEX_OFFSET], vec4(1.0)))) +
		int(all(equal(uhRegion[    UH_REG_WIDTH +     UH_REG_INDEX_OFFSET], vec4(1.0)))) +
		int(all(equal(uhRegion[    UH_REG_WIDTH + 1 + UH_REG_INDEX_OFFSET], vec4(1.0)))));

	return allWhite == 4;
}


void main()
{
	mediump vec2 uhIUTcScale = 1.0 / uTcScale;
	mediump vec2 uhUVTc = vTc * uhIUTcScale + UVTC_SHIFT;
	ivec2 uhPosUb = ivec2(uhUVTc);
	mediump vec2 uhPosFr = fract(uhUVTc);
	lowp vec4 uhRegion[UH_REG_SIZE];
	ivec2 uhPosMin = ivec2(0);
	ivec2 uhPosMax = ivec2(uhIUTcScale) - 1;

	#if UH_HAS_VREF
	ivec2 tileStart = ivec2(vRef * uhIUTcScale);
	uhPosMin = max(uhPosMin, tileStart);
	uhPosMax = min(uhPosMax, tileStart + 63);
	#endif

	uhFetchRegion(uhPosUb, uhRegion, uhPosMin, uhPosMax);

	lowp vec4 nnColor = uhFetchNN(uhPosFr, uhRegion);
	lowp vec4 texColor = uhColorToLinear(texture(uTex, vTc));
	lowp vec4 outColor = uhCatmullRom ? uhFetchCatmullRom(uhPosFr, uhRegion) : texColor;
	lowp vec4 refTexColor = uhFetchRefTexColor(uhPosFr, uhRegion);

	if (uhSharpen != 0.0)
	{
		lowp vec4 average = uhFetchBlurry(2.5, uhPosFr, uhRegion);
		outColor.rgb = outColor.rgb * (1.0 + uhSharpen) - average.rgb * uhSharpen;
	}

	// Prevent visible edges of blended object tiles
	#if UH_NEEDS_HEURISTIC_BORDER
	lowp float texRelError = uhRelColorDist(refTexColor.rgb, texColor.rgb);
	lowp vec3 darkColor = min(
			min(uhFetchPixelFast(ivec2(0, 0), uhRegion).rgb, uhFetchPixelFast(ivec2(1, 0), uhRegion).rgb),
			min(uhFetchPixelFast(ivec2(0, 1), uhRegion).rgb, uhFetchPixelFast(ivec2(1, 1), uhRegion).rgb));
	outColor.rgb = mix(outColor.rgb, darkColor.rgb, clamp(texRelError - 0.6875, 0.0, 0.0625) * 16.0);
	#endif

	// Prevent visible edges of overlay object tiles
	#if UH_NEEDS_HEURISTIC_BORDER
	if (uhCatmullRom)
	{
		lowp float texError = uhRGBDist(refTexColor.rgb, texColor.rgb);
		outColor = mix(outColor, texColor, clamp(texError - 0.013671875, 0.0, 0.001953125) * 512.0);
	}
	#endif

	// Prevent edges of transparent animations
	#if NEEDS_HEURISTIC_BORDER
	lowp vec4 lowChannels = min(nnColor, texColor);
	if (lowChannels.a == 0.0)
	{
		outColor.a = 0.0;
	}
	else
	{
		outColor.a = mix(outColor.a, lowChannels.a, clamp(outColor.a - 0.09375, 0.0, 0.03125) * 32.0);
	}
	if (all(equal(lowChannels.rgb, vec3(0.0))))
	{
		outColor.rgb = vec3(0.0);
	}
	#endif

	// Different vColor modes
	#if UH_VCOLOR_MODE == 1
	// Font
	outColor = vec4(uhToLinear(vColor.rgb), vColor.a * outColor.r);
	#elif UH_VCOLOR_MODE == 2 && !HAS_DRAW_PARAMS
	// Colorized output (fog of war, time of the day)
	outColor *= uhColorToLinear(vColor);
	#elif UH_VCOLOR_MODE == 2 && HAS_DRAW_PARAMS
	// Colorized output (fog of war, time of the day) + fixed alpha gamma for cases such as selection circles
	if (uhSelectionGamma == 1.0 || !uhProbableCircle(uhRegion))
	{
		outColor *= uhColorToLinear(vColor);
	}
	else
	{
		outColor.rgb *= uhToLinear(vColor.rgb);
		outColor.a *= pow(vColor.a, uhSelectionGamma);
	}
	#endif

	lowp float gamma = uhGamma;

    #if HAS_DRAW_PARAMS
	// Font gamma hack for Infinity UI++
	if (uhFontHackGamma > 0.0 && uhFontHackGamma != uhGamma)
	{
		lowp float cosSim = uhCosineSimilarity(texColor.rgb, uhGFTextColor);
		lowp float fontHackMatch = 1.0;
		fontHackMatch *= uhBoundMul(texColor.r, 0.07, 1.0, 0.1);
		fontHackMatch *= uhBoundMul(cosSim, 0.997, 1.0, 0.002);
		gamma = uhFontHackGamma * fontHackMatch + uhGamma * (1.0 - fontHackMatch);
	}
	#endif

    #if !HAS_OUTLINE_PARAMS
	gl_FragColor = uhMakeFragColor(outColor, gamma);
    #else
	if (uhOutlineSize <= 0.70710678)
	{
		gl_FragColor = uhMakeFragColor(outColor, gamma);
		return;
	}

	// Outline implementation
	mediump vec2 outlineData = uhOutlineData(3, uhPosUb, uhPosFr, uhRegion, uhPosMin, uhPosMax);
	mediump float minDist = max(0.70710678, outlineData[0]);
	mediump float outlineAlpha = (1.0 - pow(max(0.0, (minDist - 0.70710678) / (uhOutlineSize - 0.70710678)), 0.33333333)) * (outlineData[1] + 3.0) * 0.25;
	outColor.rgb = (uhToLinear(UH_OUTLINE_COLOR) * outlineAlpha * (1.0 - outColor.a) + outColor.rgb * outColor.a) / (outlineAlpha * (1.0 - outColor.a) + outColor.a);
	outColor.a = 1.0 - (1.0 - outColor.a) * (1.0 - outlineAlpha);
	gl_FragColor = uhMakeFragColor(outColor, gamma);
	#endif
}

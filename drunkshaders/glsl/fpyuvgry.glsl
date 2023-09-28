/* ------------------------------------------------------------------------- */
/* --------- FEEL FREE TO CHANGE THE NUMBERS AND true/false VALUES --------- */
/* ---------- (the settings were introduced by drunkshaders mod) ----------- */

const bool uhCatmullRom		= true;

const lowp float uhSharpen	=  0.0;	// 0.0 - default, positive - sharpen, negative - blur, play with +-0.2 steps to see difference
const lowp float uhGamma	=  1.6;	// gamma correction (1.0 is default, play with +-20% steps to see difference)
const lowp float uhContrast	=  1.0;	// contrast multiplier (1.0 is default, play with +-20% steps to see difference)
const lowp float uhBright	=  0.0;	// brightness offset (0.0 is default, +-0.005 is noticable already)
const lowp float uhSat		=  1.0;	// saturation multiplier (1.0 is default, play with +-20% steps to see difference)
const lowp float uhHueDeg	=  0.0;	// hue rotation in YIQ space in degrees, play with +-5deg steps, 180deg means opposite

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
#define HAS_UTEX2 1

uniform lowp	sampler2D	uTex;
#if HAS_UTEX2
uniform lowp	sampler2D	uTex2;
#endif
uniform mediump vec2		uTcScale;
#if HAS_U_COLOR_TONE
uniform mediump	vec4		uColorTone;
#endif
varying mediump	vec2		vTc;
varying mediump	vec2		vTcU;
varying mediump	vec2		vTcV;
varying lowp	vec4		vColor;

mediump vec2	uhIUTcScale;
mediump vec2	uhUVTcY;
mediump vec2	uhUVTcU;
mediump vec2	uhUVTcV;
ivec2			uhPosUbY;
ivec2			uhPosUbU;
ivec2			uhPosUbV;

const lowp mat3		uhYUVMat = mat3(
	1.00000,  1.00000,  1.00000,
	0.00000, -0.21482,  2.12798,
	1.28033, -0.38059,  0.00000
);
const lowp vec3		uhYUVOff = vec3(-0.06250, -0.50000, -0.50000);


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
    ivec2 posY = uhPosUbY + pos;
    ivec2 posU = uhPosUbU + pos;
    ivec2 posV = uhPosUbV + pos;
    posY.x = min(max(1, posY.x), int(uhIUTcScale.x) - 1);
    posY.y = min(max(1, posY.y), (int(uhIUTcScale.y) * 2) / 3 - 1);
    posU.x = min(max(1, posU.x), int(uhIUTcScale.x) - 1);
    posU.y = min(max((int(ceil(uhIUTcScale.y)) * 2 + 2) / 3 + 1, posU.y), int(uhIUTcScale.y) - 1);
    posV.x = min(max(1, posV.x), int(uhIUTcScale.x) - 1);
    posV.y = min(max((int(ceil(uhIUTcScale.y)) * 2 + 2) / 3 + 1, posV.y), int(uhIUTcScale.y) - 1);
	lowp vec3 yuv = vec3(
		texelFetch(uTex, posY, 0)[0],
		texelFetch(uTex, posU, 0)[0],
		texelFetch(uTex, posV, 0)[0]
	) + uhYUVOff;
	return uhYUVMat * yuv;
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

void main()
{
	uhIUTcScale	= 1.0 / uTcScale;
	uhUVTcY		= vTc  * uhIUTcScale - 0.5;
	uhUVTcU		= vTcU * uhIUTcScale - 0.5;
	uhUVTcV		= vTcV * uhIUTcScale - 0.5;
	uhPosUbY	= ivec2(uhUVTcY);
	uhPosUbU	= ivec2(uhUVTcU);
	uhPosUbV	= ivec2(uhUVTcV);

	mediump vec2 posFr = uhUVTcY - uhPosUbY;
	lowp vec3 region[16] = uhFetchRegion(ivec2(0, 0));
	lowp vec3 outColor;

	if (uhCatmullRom)
	{
		outColor = uhCatmullRomInterp(region, posFr);
	}
	else
	{
		outColor = region[1 * 4 + 1];
	}

	if (uhSharpen != 0.0)
	{
		lowp vec3 average = uhGaussianBlur(region, posFr, 2.5);
		outColor = outColor * (1.0 + uhSharpen) - average * uhSharpen;
	}

	outColor *= uhToLinear(vColor.rgb);

	#if HAS_UTEX2
	gl_FragColor = uhMakeFragColor(outColor, texture(uTex2, vTc)[0], uhGamma);
	#else
	gl_FragColor = uhMakeFragColor(outColor, 1.0, uhGamma);
	#endif
}

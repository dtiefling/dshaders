/* ------------------------------------------------------------------------- */
/* --------- FEEL FREE TO CHANGE THE NUMBERS AND true/false VALUES --------- */
/* ---------- (the settings were introduced by drunkshaders mod) ----------- */

const bool			uhCatmullRom		=  false;

const lowp float	uhSharpen			=  0.0;	// 0.0 - default, positive - sharpen, negative - blur, play with +-0.2 steps to see difference
const lowp float	uhGamma				=  1.0;	// gamma correction (1.0 is default, play with +-20% steps to see difference)
const lowp float	uhContrast			=  1.0;	// contrast multiplier (1.0 is default, play with +-20% steps to see difference)
const lowp float	uhBright			=  0.0;	// brightness offset (0.0 is default, +-0.005 is noticable already)
const lowp float	uhSat				=  1.0;	// saturation multiplier (1.0 is default, play with +-20% steps to see difference)
const lowp float	uhHueDeg			=  0.0;	// hue rotation in YIQ space in degrees, play with +-5deg steps, 180deg means opposite

const mediump float	uhOutlineSize		=  0.0;	// up to 3.5; 0.0 to disable; default for fpsprite: 2.0, default for fpselect: 3.5

/* - CHANGING THE CODE BELOW MIGHT REQUIRE GLSL KNOWLEDGE / BREAK THE GAME - */
/* ------------------------------------------------------------------------- */

#define HAS_DRAW_PARAMS		0
#define HAS_OUTLINE_PARAMS	1



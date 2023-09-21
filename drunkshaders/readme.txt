# drunktiefling's shaders

Readme last updated at version: *0.1*+git.

This mod aims to use more consistent color operations, sharpening
and alternative scaling filters via shader files introduced in BG(2)EE.

If this `readme` is too long to read, skip to
[Options overview](#options-overview), [Manual settings](#manual-settings),
or [Preview](#preview) section.

### License

This distribution of the project is provided on MIT License, which you
can read in `license.txt` file, which is located alongside this `readme`.

### Scope

This mods makes it possible to configure rendering of different elements
on the screen other than videos. Every setting is optional. This includes:
* Brightness / contrast / gamma correction.
* Hue correction by rotation of linear RGB matrix
  (using YIQ-like approach rather than HSV).
* Saturation correction.
* Gausian image sharpening based on 4x4 surrounding.
* Catmull-Rom interpolation for scaling.
* Removal or change of the outlines for default/selected sprites
  (BGEE v1.3-style).
* All the changes and color mixing performed in linear RGB space.

The only component that is required for everything else is the main piece
of the shader code itself. It was rewritten to be mostly consistent for
all the shaders touched by this mod. With the common changes, linear scaling
is enforced (even for maps). All the color information (other than
transparency, which actually should be linear) is fetched directly from
the texels (rather than from the sampler). Rendering of the sprite outlines
is mostly redesigned, as the original code lacked the consistency this mod
is aiming at. The default settings are roughly similar to the original
BG(2)EE 2.6, but in some scenarios (such as transparent sprites) differences
can be observable. While the author believes the newly introduced behavior
to be outright better, such things are always disputable, which makes this
explanation necessary.

### Thanks to Argent77

I mean, really, it would not be possible without Argent77's work
on [Shader Pack](https://github.com/Argent77/A7-LightingPackEE). Showcase
of such potential and detailed README on what each shader file does
has been crucial for the development of this mod.

Since many ideas were redesigned rather than extended, this is a rewrite
of said *Shader Pack*. As such, these two mods are **not compatible**.

### Requirements

BG2EE with 2.6-series patch. As it's all about engine, mods such as EET
are compatible by default.

**Note:** Some settings in the game may indirectly disable some features
of this mod. On Windows platform, you should **disable** "Alternate Renderer"
in the graphic options of the games in order to see anything that this mod
provides. If you want Catmull-Rom interpolation to work, you also need
to **disable** "Nearest Neighbor Scaling".

### Conflicts

*Shader Pack* by Argent77. It simply replaces it.

Anything that replaces `fpDraw`, `FPFONT`, `fpSeam`, `FPSELECT`
or `FPSPRITE` shader.

For now, said files are not patched, but replaced. It is mostly justified
by different approach to color mixing, which - while perhaps possible -
would be remarkably hard to implement otherwise.

### Installation

This is a [WeiDU](https://github.com/WeiDUorg/weidu/releases) mod. Extract
it in the game installation directory.

Unless you know extra WeiDU options you might want to specify,
`weinstall drunkshaders`
would do. Make sure to have weinstall in your `PATH` (or use absolute path,
whatever).

On Windows, you might find it convenient to make yet another copy
of WeiDU (`weidu.exe`) and name it `Setup-drunkshaders.exe`.
Then you can as well remove it and make new copy before
uninstalling/reinstalling. This file is never modified otherwise.

If you need this, get archive with your `weidu.exe`
on https://github.com/WeiDUorg/weidu/releases .

## Options overview

Please note that each subcomponent also includes an option not to change
anything.

 - **Quick menu** - it offers you some predefined setups, so you can avoid
   answering that many questions, some of them somewhat technical.
 - **Adjustable shaders coded by a drunk tiefling [Main component]** - you
   need it in order to install any functions provided by the mod. It makes
   all the color fixing based on linear RGB and replaces the implementation
   of sprite outlines.
 - *Scaling filter* - for now it lets you choose which shaders should use
   Catmull-Rom interpolation algorithm. BGEE 1.3 was famous for using it,
   but it was there only for sprites. With this mod, you can apply it in
   more places (which makes a remarkable difference for maps).
	 - **Use Catmull-Rom interpolation for sprites only**
	 - **Use Catmull-Rom interpolation for maps and sprites only**
	 - **Use Catmull-Rom interpolation in all shaders**
	   (this involves UI and fonts too).
 - *Outline changes* - the default settings imitate BG(2)EE 2.6 behavior.
   You can change it. BGEE 1.3 didn't render any sprite outlines at all.
	 - **Disable sprite outlines in non-selected sprites** - so it's like
	   BGEE 1.3 + selection outlines, which can be considered as a quality
	   of life addidtion of further patches.
	 - **Disable sprite outlines in non-selected sprites, make them thinner
	 for selected ones** - similar to the option above, but colorful outlines
	 of the selected sprites are thinner. It makes them slightly more
	 consistent with other objects in the game.
	 - **Disable sprite outlines in all sprites** - as it was in BGEE 1.3.
 - *Color fixes*
	 - **Use recommended color adjustments (gamma 1.1, contrast 1.2,
	   brightness +0.1), maps and sprites only** - similar to the recommended
	   setting of *Shader Pack*, but only for the main content of the game
	   (no UI or fonts). UI mods can design any colors they want to, so
	   the need to adjust it might be reduced. Also, this settings avoids
	   gamma increase for fonts.
	 - **Use recommended color adjustments (gamma 1.1, contrast 1.2,
	   brightness +0.1), all shaders** - just similar to the recommended
	   setting of *Shader Pack*.
 - *Sharpening / blur*
	 - **Sharpen slightly (+0.25), maps and sprites only** -
	   recommended if you don't want to touch UI.
	 - **Sharpen slightly (+0.25), all shaders** -
	   recommended if you are alright with changing everything on the screen.
	 - **Sharpen more (+0.50), maps and sprites only**
	 - **Sharpen more (+0.50), all shaders**
	 - **Blur slightly (-0.25 sharpen), maps and sprites only**
	 - **Blur slightly (-0.25 sharpen), all shaders**
	 - **Blur more (-0.50 sharpen), maps and sprites only**
	 - **Blur more (-0.50 sharpen), all shaders**
 - *Font fixes* - the main shader responsible for fonts is `fpfont.glsl`,
   but some pieces of text are rendered by `fpdraw.glsl` alongside the UI.
   Text is known to be easier to read with somehat lower gamma (such as 0.8),
   but such a low setting might be suboptimal for the UI. As such,
   the suggested options are:
	 - **Lower gamma for fonts shader only (set to 0.8)**
	 - **Lower gamma for fonts and UI (fonts shader: 0.8, UI: 0.9)**
 - *Hue change* - initially, some change seemed to be beneficial.
   However, after going through more areas, I believe that no change should
   be included in the recommended setups. If you want to play with it,
   just choose an option for this subcomponent specifically
   (or edit the files).
	 - **Make colors warmer (hue +3.0 deg), maps and sprites only**
	 - **Make colors warmer (hue +3.0 deg), all shaders**
	 - **Make colors remarkably warmer (hue +5.0 deg), maps and sprites only**
	 - **Make colors remarkably warmer (hue +5.0 deg), all shaders**
	 - **Make colors colder (hue -3.0 deg), maps and sprites only**
	 - **Make colors colder (hue -3.0 deg), all shaders**
	 - **Make colors remarkably colder (hue -5.0 deg), maps and sprites only**
	 - **Make colors remarkably colder (hue -5.0 deg), all shaders**

## Manual settings

This version of the mod just puts some example setup in your game files.

You are going to have `fpdraw.glsl`, `fpfont.glsl`, `fpseam.glsl`,
`fpselect.glsl` and `fpsprite.glsl` in your `override` folder. And you can
play with them using text editor such as `vim`/`notepad`/`Notepad++`/...
They are written in *OpenGL Shading Language*.

If you are not familiar with *OpenGL Shading Language*, some changes might
get you a black screen, game crash or unexpected colors. But you can keep
it mostly safe by modifying the top 15 lines of each file only.

Most likely, you want to have similar values in `fpsprite.glsl`
and `fpselect.glsl`. Otherwise, each file describes another
part of a screen. I will post my observations, which are slightly different
from [Argent77's research](https://argent77.github.io/A7-LightingPackEE/).

* `fpfont.glsl`     - Font rendering (everything but item counts/uses
                      on stacks).
* `fpseam.glsl`     - Map background.
* `fpdraw.glsl`     - User interface including inventory (and item counts
                    on stacks, which are **not affected** by `fpfont.glsl`).
                      Also the fog of war.
* `fpsprite.glsl`   - Character sprites, software cursors, ground icons, ...
* `fpselect.glsl`   - Some of the content from `fpsprite.glsl` when
                      it's selected.
                      Or when something close is selected.
                      Not really consistent, but that's how the game
                      seems to use it.

#### Setup recommendations

Technical suggestions on what values to use are in the files.

Otherwise, some settings I would recommend for most displays are:
* Gamma lower than 1.0 in `fpfont.glsl` (fonts are known to look good
  with gamma 1.8 rather than ~2.2 of *sRGB*, so values close to 1.8/2.2
  might make sense).
* Something like: gamma: 1.1, contrast: x1.2, brightness: +0.1 for
  `fpseam.glsl`, `fpsprite.glsl`, and `fpselect.glsl`. Such numbers are
   inspired by the recommended option of Argent77's *Shader Pack*.
* Minor changes to `fpdraw.glsl` unless you want to consistently adjust
  the whole screen. This shader describes the small digits of stack/use
  counts of items, so gamma lower than 1.0 might make it easier to read.
*  `fpsprite.glsl` and `fpselect.glsl` contain extra parameter, that can
  be used to disable normal and selected sprite outlines, respectively.
  The attached setup disables black outlines (`fpsprite.glsl`), yet keeps
  the colored versions on selection.
  For the most BGEE v1.3-like experience (some people seem to miss it),
  make sure to keep Catmull-Rom setting enabled and disable all outlines.

Note: this mod **doesn't include** `fptone.glsl`, as I have found
no use for it with 2.6 patch (in tested scenarios it
**doesn't do anything** with disabled icons, time stop or pause).

## Preview

 - Scaling:
	 - [Default (no mod)](https://github.com/dtiefling/dshaders/assets/145703648/5a429ab9-cc2a-4553-b3ea-d389abef264c)
	 - [Nearest neighbor (no mod)](https://github.com/dtiefling/dshaders/assets/145703648/79aec940-22d5-4032-a9a0-59c0055d73e8)
	 - [BGEE 1.3 (obviously no mod)](https://github.com/dtiefling/dshaders/assets/145703648/5492e51e-4def-442c-8cf0-49c2b5c5c52e)
	 - [Empty mod setting](https://github.com/dtiefling/dshaders/assets/145703648/1a5d24f6-32c4-4102-b1ea-e160ec557207)
	 - [Catmull-Rom for sprites](https://github.com/dtiefling/dshaders/assets/145703648/8f028e21-80bf-4109-a732-810a8ccb14dc)
	 - [Catmull-Rom everywhere](https://github.com/dtiefling/dshaders/assets/145703648/56d09666-076d-4390-8300-48f1e158ccfc)
 - Outlines:
	 - [Default (no mod)](https://github.com/dtiefling/dshaders/assets/145703648/5a429ab9-cc2a-4553-b3ea-d389abef264c)
	 - [Empty mod setting](https://github.com/dtiefling/dshaders/assets/145703648/1a5d24f6-32c4-4102-b1ea-e160ec557207)
	 - [BGEE 1.3 (obviously no mod)](https://github.com/dtiefling/dshaders/assets/145703648/5492e51e-4def-442c-8cf0-49c2b5c5c52e)
	 - [Disabled via shaders](https://github.com/dtiefling/dshaders/assets/145703648/a9c92379-0cfa-4359-9c73-57c73f4132d3)
 - Selection outlines:
	 - [Default (no mod)](https://github.com/dtiefling/dshaders/assets/145703648/64eb68d0-f580-49d4-a2a1-166fd407ac0f)
	 - [Empty mod setting](https://github.com/dtiefling/dshaders/assets/145703648/8294556f-97d1-49d1-be0a-174c35e8b94f)
	 - [Thinner selection outlines](https://github.com/dtiefling/dshaders/assets/145703648/0b119bc4-380b-4914-849b-57c078a84477)
 - Colors:
	 - [Empty mod setting](https://github.com/dtiefling/dshaders/assets/145703648/1a5d24f6-32c4-4102-b1ea-e160ec557207)
	 - [Color changes](https://github.com/dtiefling/dshaders/assets/145703648/1ed9298a-fb63-4937-b1e0-d570e9a5febf)
	 - [Color changes + Catmull-Rom](https://github.com/dtiefling/dshaders/assets/145703648/5d54a0b8-afd7-43db-b6da-caf2d189c89a)
	 - ["Author's choice" (also no outlines without selections)](https://github.com/dtiefling/dshaders/assets/145703648/04eeb0ab-5834-4b7e-943a-4c8122cfaa0d)
 - BGEE 1.3 imitation:
	 - Actual [BGEE 1.3 (obviously no mod)](https://github.com/dtiefling/dshaders/assets/145703648/5492e51e-4def-442c-8cf0-49c2b5c5c52e)
	 - BGEE 1.3-like overly simple setup, which means
	   [Catmull-Rom for sprites](https://github.com/dtiefling/dshaders/assets/145703648/8f028e21-80bf-4109-a732-810a8ccb14dc)
	 - [Catmull-Rom everywhere](https://github.com/dtiefling/dshaders/assets/145703648/56d09666-076d-4390-8300-48f1e158ccfc)
	 - And since the old games made it possible to adjust image properties,
	   consider [Color changes + Catmull-Rom](https://github.com/dtiefling/dshaders/assets/145703648/5d54a0b8-afd7-43db-b6da-caf2d189c89a)


[](https://github.com/dtiefling/dshaders/assets/145703648/04eeb0ab-5834-4b7e-943a-4c8122cfaa0d)

### Resources

* [Shader Pack](https://github.com/Argent77/A7-LightingPackEE) by Argent77
* Community suggestions
* Infinity Engine from Baldur's Gate 2: Enhanced Edition v2.6
* [OpenGL docs](https://www.khronos.org/opengl/wiki/)
* Pluma - The MATE text editordrunktiefling's shaders
* https://gist.github.com/TheRealMJP/c83b8c0f46b63f3a88a5986f4fa982b1

This mod aims to use more consistent color operations, sharpening
and alternative scaling filters via shader files introduced in BG(2)EE.


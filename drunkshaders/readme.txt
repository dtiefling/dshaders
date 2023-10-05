
# drunktiefling's shaders

Readme last updated at version: *0.3.4*.

This mod aims to use more consistent color operations, sharpening
and alternative scaling filters via shader files introduced in BG(2)EE.

Further work resulted in a comprehensive attempt to improve or alter the game
behavior via GLSL shaders that provice extra functionality, yet attempt
to keep the performance as good as technically possible.

If this `readme` is too long to read, skip to
[Options overview](#options-overview), [Manual settings](#manual-settings),
or [Preview](#preview) section.

The main platform used to gather the community opinion is
[a thread on Beamdog Forums](https://forums.beamdog.com/discussion/87794/mod-sharpening-filter-bgee1-3-like-look-and-more-via-shaders/).
The project is hosted [on GitHub](https://github.com/dtiefling/dshaders),
so you are welcome to reach the author and describe your issues there as well.

## License

This distribution of the project is provided on MIT License, which you
can read in `license.txt` file, which is located alongside this `readme`.

## Scope

This mod makes it possible to configure rendering of different elements
on the screen other than videos. Every setting but the main component
is optional. This includes:
* Brightness / contrast / gamma correction.
* Hue correction by rotation of linear RGB matrix
  (using YIQ-based approach rather than HSV).
* Saturation correction.
* Gausian image sharpening based on 4x4 surrounding.
* Catmull-Rom interpolation for scaling.
* Removal or change of the outlines for default/selected sprites
  (BGEE v1.3-style).
* Appearance of the selection outlines and coloring of selected objects.
* Handling of selected technical issues.

The main component, required for any other change, makes sure that:
* The shaders are reimplemented in a consistent way.
	* Notably, rendering of sprite outlines is approached differently,
	  even though some configurations yield results that are visually similar
	  to the unmodded game.
* All the color mixing operations are performed in linear RGB space.
* Besides the error check, the data comes straight from the texels.
  By default, no texel is probed from the texture more than once.
* Shaders configuration can be adjusted with a text editor such as notepad.

From version 0.3.3, this mod is maintained with special performance-related
features in mind, which include:
* Avoiding conditional statements in the implementation.
* Extra component that runs
  [GLSL optimizer](https://github.com/jamienicol/glsl-optimizer) over
  all the shaders, after their content (coming from the installer,
  its presets and manual edition) can be considered final.

## Thanks to Argent77

I mean, really, it would not be possible without Argent77's work
on [Shader Pack](https://github.com/Argent77/A7-LightingPackEE). Showcase
of such potential and detailed README on what each shader file does
has been crucial for the development of this mod.

Since many ideas were redesigned rather than extended, this is a rewrite
of said *Shader Pack*. As such, these two mods are **not compatible**.

## Requirements

BG2EE with 2.6-series patch. As it's all about engine, mods such as EET
are compatible by default.

**Note:** Some settings in the game may indirectly disable some features
of this mod. On Windows platform, you should **disable** "Alternate Renderer"
in the graphic options of the games in order to see anything that this mod
provides. If you want Catmull-Rom interpolation to work, you also need
to **disable** "Nearest Neighbor Scaling".

As it comes to the game settings, one non-obligatory recommendation is
to **disable** the hardware cursor. It doesn't scale like the cursors
used to in the traditional game, and it might be confusing when it moves
faster than some objects.

## Conflicts

*Shader Pack* by Argent77. It simply replaces it.

Anything that replaces `fpDraw`, `FPFONT`, `fpSeam`, `FPSELECT`, `FPSPRITE`,
`fpTone`, `fpYUV` or `fpYUVGRY` shader.

For now, said files are not patched, but replaced. It is mostly justified
by different approach to color mixing, which - while perhaps possible -
would be remarkably hard to implement otherwise.

## Installation

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

#### Quick menu

This mod has 11 distinct optional components. To save time, you can choose
what to do with them at a high level rather than being asked about each one.

Whatever you choose, you will be asked about
[Shaders optimization](#shaders-optimization) separately, as you might want to
install that specific component later or keep reinstalling it multiple times.

Each preset contains the [Main component](#main-component). In details, you can
save some typing if you are interested in one of the following:

 1. No specific settings, just templates for manual edit
	 * Nothing but the main component
 2. BGEE 1.3-like setup (Catmull-Rom everywhere)
	 * [Use Catmull-Rom interpolation in all shaders](#scaling-filters)
	 * [Disable sprite outlines in all sprites](#outline-changes)
 3. BGEE 1.3-like overly simple setup
	 * [Use Catmull-Rom interpolation for sprites only](#scaling-filters)
	 * [Disable sprite outlines in all sprites](#outline-changes)
 4. Intense color adjustments only
	 * [Use intense color adjustments (gamma +2%, contrast +20%, brightness +10%), all shaders](#color-intensity-adjustments)
	 * [Sharpen slightly (+0.25), all shaders](#gaussian-sharpening--blur)
	 * [Lower gamma for fonts shader only (set to 0.8)](#font-gamma-fixes)
 5. Intense color adjustments + BGEE 1.3-like setup (C-R everywhere)
	 * [Use Catmull-Rom interpolation in all shaders](#scaling-filters)
	 * [Disable sprite outlines in all sprites](#outline-changes)
	 * [Use intense color adjustments (gamma +2%, contrast +20%, brightness +10%), all shaders](#color-intensity-adjustments)
	 * [Sharpen slightly (+0.25), all shaders](#gaussian-sharpening--blur)
	 * [Lower gamma for fonts shader only (set to 0.8)](#font-gamma-fixes)
 6. Moderate color adjustments only
	 * [Use moderate color adjustments (gamma +2%, contrast +10%, brightness +5%), all shaders](#color-intensity-adjustments)
	 * [Sharpen slightly (+0.25), all shaders](#gaussian-sharpening--blur)
	 * [Lower gamma for fonts shader only (set to 0.8)](#font-gamma-fixes)
 7. Moderate color adjustments + BGEE 1.3-like setup (C-R everywhere)
	 * [Use Catmull-Rom interpolation in all shaders](#scaling-filters)
	 * [Disable sprite outlines in all sprites](#outline-changes)
	 * [Use moderate color adjustments (gamma +2%, contrast +10%, brightness +5%), all shaders](#color-intensity-adjustments)
	 * [Sharpen slightly (+0.25), all shaders](#gaussian-sharpening--blur)
	 * [Lower gamma for fonts shader only (set to 0.8)](#font-gamma-fixes)
 8. drunktiefling's choice
	 * [Use Catmull-Rom interpolation in all shaders](#scaling-filters)
	 * [Disable sprite outlines in non-selected sprites, make them thinner for selected ones](#outline-changes)
	 * [Use moderate color adjustments (gamma +2%, contrast +10%, brightness +5%), all shaders](#color-intensity-adjustments)
	 * [Sharpen slightly (+0.25), all shaders](#gaussian-sharpening--blur)
	 * [Lower gamma for fonts shader only (set to 0.8)](#font-gamma-fixes)
 9. drunktiefling's choice for Infinity UI++
	 * [Use Catmull-Rom interpolation in all shaders](#scaling-filters)
	 * [Disable sprite outlines in non-selected sprites, make them thinner for selected ones](#outline-changes)
	 * [Use moderate color adjustments (gamma +2%, contrast +10%, brightness +5%), all shaders](#color-intensity-adjustments)
	 * [Sharpen slightly (+0.25), all shaders](#gaussian-sharpening--blur)
	 * [Lower gamma for fonts shader (set to 0.8) + use color-based hack to lower fonts gamma in some UIs (Dragonspear UI++, Infinity UI++)](#font-gamma-fixes)
 10. BGEE 1.3-like setup (Catmull-Rom everywhere) + thinner selection circles (@Parys)
	 * [Use Catmull-Rom interpolation in all shaders](#scaling-filters)
	 * [Disable sprite outlines in all sprites](#outline-changes)
	 * [Make sprite selection circles thinner and object selection highlight more transparent](#selection-circles)
	 * [[Experimental] Disable anti-glitch methods (makes advanced interpolation more consistent inside objects and animations, but causes visible line-shaped glitches at the edges of their tiles)](#anti-glitch-policy)

#### Main component
This is required for any other component to work. Replaces the shaders with
versions from the mod. The default setup should be roughly similar
to BG2EE 2.6.

#### Scaling filters

For now, this component lets you decide between the default texture sampler
(if you skip this) and Catmull-Rom interpolation. Available options are:

 1. Use Catmull-Rom interpolation for sprites only
 2. Use Catmull-Rom interpolation in all shaders

#### Outline changes

The mod reimplements the algorithm that controls how to draw sprite outlines.
Skipping this component makes the values that yield thickness similar
to BG2EE 2.6 remain. Alternatively, you can choose to:

 1. Disable sprite outlines in non-selected sprites
 2. Disable sprite outlines in non-selected sprites,
    make them thinner for selected ones
 3. Disable sprite outlines in all sprites

#### Color intensity adjustments

Like int the *Shader Pack*, you can make changes to gamma, contrast
and brightness displayed by the game. Gamma and contrast are multipliers
(with default of 1.0), while brightness is an offset. As the changes
are performed in linear color space, the output is very sensitive to
the brightness changes. In general, if you want to add *x* brightness (could
be negative), you should also apply *(1+2x)* contrast.

One the recommended setup of the _Shader Pack_ involved +10% gamma
+10% brightness and +20% contrast, but it didn't involve color space
linearization. With approach of this mod, each parameter is more sensitive,
so the recommended changes are lower. For some displays and players,
even slighter, "moderate" changes can be an even better choice. You can also
skip this component.

Available options are:

 1. Use moderate color adjustments (gamma +2%, contrast +10%,
    brightness +5%), sprites only
 2. Use moderate color adjustments (gamma +2%, contrast +10%,
    brightness +5%), all shaders
 3. Use intense color adjustments (gamma +2%, contrast +20%,
    brightness +10%), sprites only
 4. Use intense color adjustments (gamma +2%, contrast +20%,
    brightness +10%), all shaders

#### Gaussian sharpening / blur

Based on 4x4 surrounding pixels of each sample (which is especially useful
when used together with Catmull-Rom, as that would be all the probed pixels
and they would be shared for both functions), neat kernels based on sub-pixel
position and normal distribution with derivation 2.5 can be computed.

I mean, the image can look smoothly blurred or properly sharpened.

If you want to use this component, you can choose from the following options:

 1. Sharpen slightly (+0.25), sprites only
 2. Sharpen slightly (+0.25), all shaders
 3. Sharpen more (+0.50), sprites only
 4. Sharpen more (+0.50), all shaders
 5. Blur slightly (-0.25 sharpen), sprites only
 6. Blur slightly (-0.25 sharpen), all shaders
 7. Blur more (-0.50 sharpen), sprites only
 8. Blur more (-0.50 sharpen), all shaders

#### Font gamma fixes

In general, it would be a poor practice to return back to ~2.2 gamma
of sRGB color space when rendering fonts. Freetype library, very popular
and reference implementation of rendering fonts on screens, has an inspiring
[docs section](https://freetype.org/freetype2/docs/hinting/text-rendering-general.html)
on that topic. For fonts, gamma should be closer to 1.8, which is roughly
80% of the sRGB gamma.

Most of the text in the game is rendered using a separate shader named
`fpfont`, so changing the setting there specifically reduces the most
of the problem. Among the rare pieces of text that are rendered with
`fpdraw` instead, there are stack  / quick item use counts. In the default UI,
the rectangular bitmap font is used, so the readability is not a big issue.
However, with UI mods such as
[Dragonspear UI++](https://github.com/anongit/DragonspearUI/)
and [Infinity UI++](https://github.com/Renegade0/InfinityUI), typical font
is used. And that digits are small, thus hard to read with high gamma.
As an user of said mods, I have implemented an optional hack that detects
that pieces of text by color. It catches some false positives
(cosine similarity is used, as this color fades into black at the edges
of the digits), but it makes sure to handle their surroundings smoothly.

Hence you get this optional component that makes the text more readable,
with the following options:

 1. Lower gamma for fonts shader only (set to 0.8)
 2. Lower gamma for fonts shader (set to 0.8) + use color-based hack
    to lower fonts gamma in some UIs (Dragonspear UI++, Infinity UI++)

#### Hue change

If your display, lighting of your room or ~~kinks~~preferences justify it,
you might want to shift the color hue of some elements displayed by the game.
The options included in the installer involve slight changes, but editing
shaders manually lets you define virtually any angle. To achieve this, the
linear RGB cube is rotated in space (which makes it YIQ-based change,
rather than HSV).

If you want this, you can pick one of the following actions:

 1. Make colors warmer (hue +3.0 deg), sprites only
 2. Make colors warmer (hue +3.0 deg), all shaders
 3. Make colors remarkably warmer (hue +5.0 deg), sprites only
 4. Make colors remarkably warmer (hue +5.0 deg), all shaders
 5. Make colors colder (hue -3.0 deg), sprites only
 6. Make colors colder (hue -3.0 deg), all shaders
 7. Make colors remarkably colder (hue -5.0 deg), sprites only
 8. Make colors remarkably colder (hue -5.0 deg), all shaders

#### Selection circles

Some bloke I met down the pub... I mean, Parys from Beamdog Forums, remarked
that he likes the look of character sprites from version 0.2.3. Which were
thinner due to a design I haven't given enough thought to, essentially
a bug - at this version it caused some undesirable effects, like unidentified
items being much less blue to the point of being hard to notice.

However, since the selection circles change from that version might
be desirable, I was able to separate such scenarios. In result,
it is possible to get thinner selection circles together with fainter
look of selected map objects (doors, containers, etc.). Both elements
remain visible, simply look different.

So you might install this optional change as well.

 1. Make sprite selection circles thinner and object selection highlight more
    transparent

#### Anti-glitch policy

The default linear interpolation that is omnipresent in the game already causes
some glitches on some GPUs. Some of them are being worked on as a part
of [The Enhanced Edition Fixpack (EEFP)](https://www.gibberlings3.net/mods/fixes/eefp/),
which is not released yet. Some are even harder to avoid with theaks such as
[EE AI Denoised Areas](https://forums.beamdog.com/discussion/83893/mod-beta-ee-ai-denoised-areas/)
and [Baldur's Gate Graphics Overhaul for EET](https://github.com/SpellholdStudios/BGGOEET)
(which I love and use anyways).

Most glitches are related to `fpdraw`/`fptone` shaders, so there is a special
mechanic there to avoid them. Some of it is straightforward, but some
is not - the shader is not provided information on where does the texture
tile end, so there is no proven way to avoid probing out of bounds. And things
that might occur them are not always transparent black, but sometimes
the shader gets uninitialized memory trash instead. Such scenarions are
handled with heuristic methods.

Said heuristic methods catch the most of glitches that would be caused
by this mod (and even some that would happen in the original game).
Still, I don't believe there is a way to catch them all. And with heuristic
approach, there are some false positives. They are approached with continuous
functions, so they shouldn't stand out, but the main tester (Parys) described
some of the objects as "sharper" because of this.

So, with this component you can accept the glitches at object borders,
yet ensure that nothing special ever happens to the pixels inside the objects.

 1. [Experimental] Disable anti-glitch methods (makes advanced interpolation
    more consistent inside objects and animations, but causes visible
    line-shaped glitches at the edges of their tiles)

#### Shaders optimization

This component is separate from the quick menu. The point is that you should
be able to uninstall and reinstall it at need whenever you choose to.

After this component is installed, you will be no more able to change shader
parameters with a text editor. Instead, the shaders will be optimized
for the parameters that have been there, using
[GLSL optimizer](https://github.com/jamienicol/glsl-optimizer) that was built
specifically for this mod. The advantages include total elimination
of conditional statements from the code of all shaders without outlines (some
gometry code related to them is an exception from that rule), which is already
an indication that they sould run faster.

At the moment, there is no Mac OS X build, so this component works only
on Windows and Linux (either x86 or x86_64 for either platform).

 1. Process shaders with GLSL Optimizer
    [WARINIG: manual editing won't be possible after this step]

## Manual settings

The mod brings way too many possibilities to reliable include include them
in the [installer options](#options-overview). You may want to achieve
something completely different from from any of the options, and that
is alright. You can even fork this code and use it to implement something
new to the shaders, or use it as inspiration to start from scratch. However,
there is a middle ground, which would require next no GLSL knowledge - you can
just adjust the parameters.

You need to do this after the [Main component](#main-component) is installed,
but without [Shaders optimization](#shaders-optimization). If the modified
files in the `override` directory seem to work, you can install Shaders
optimization component, so it would work on them.

Files that are going to be directly accessible in the `override` directory
and can be played with using text editor (e.g. notepad) are:
 - `fpfont.glsl`
	 - Most of the text displayed in the game. One known exception
	   is item stack / use count, which is handled by `fpdraw`.
 - `fpdraw.glsl`
	 - UI components.
	 - Spell animations.
	 - Objects on the map (tiles with bathtubs, stoves, light torches, etc.).
 - `fptone.glsl`
	 - Stuff from `fpdraw.glsl` that is on the map (so no UI) at
	 the pause / time stop grayscale.
 - `fpseam.glsl`
	 - Most of the content on the map that doesn't move and needs
	   no special overlays.
	 - Elements you can interact with such as doors and containers.
 - `fpsprite.glsl`
	 - Sprites of characters and objects lying on the ground.
 - `fpselect.glsl`
	 - Sprites selected with mouse cursor that might have different outlines.
 - `fpyuv.glsl`
	 - Movies and map elements implemented as such (like big areas
	   of water in SoD).
 - `fpyuvgry.glsl`
	 - Map elements that would be handled by `fpyuv.glsl` switch to this
	   at the pause / time stop grayscale.

The scope of each file was largely determined thanks to the help of Argent77
- both in documentation of *Shader Pack* and active help.

Options that you can play with in the not-(yet)-optimized shader files are:

 - `uhCatmullRom`
	 - Whether to use Catmull-Rom interpolation in that shader.
	 - Default: `false` (would use the same sampler as original shaders).
	 - `true` means Camtull-Rom!
 - `uhSharpen`
	 - How much to sharpen (or, in the case of negative values, blur) the output.
	 - Default: `0.0` (no change).
	 - +-`0.2` steps should be noticable.
	 - Going outside `0.6`..`2.4`  might look bad.
	 - `-1.0` means using Gaussian Blur with 2.5 derivation instead of
	   the interpolated color.
 - `uhGamma`
	 - Extra gamma correction.
	 - Default: `1.0` (no change).
	 - +-`0.05` steps should be noticable.
	 - Going outside `0.8`..`1.6`  might look bad.
 - `uhContrast`
	 - Contrast multiplier.
	 - Default: `1.0` (no change).
	 - +-`0.1` steps should be noticable.
	 - Going outside `0.5`..`2.0`  might look bad.
 - `uhBright`
	 - Extra brightness component.
	 - Default: `0.0` (no change).
	 - +-`0.002` steps should be noticable.
	 - Going multiple steps away from *(`uhContrast`-1)/2* might look bad.
 - `uhSat`
	 - Color saturation multiplier.
	 - Default: `1.0` (no change).
	 - +-`0.1` steps should be noticable.
	 - Going outside `0.6`..`1.8`  might look bad.
 - `uhHueDeg`
	 - Color hue shift angle (in degree).
	 - Default: `0.0` (no change).
	 - +-`3.0` steps should be noticable.
	 - Going outside `-15.0`..`15.0`  might look atypical.
 - `uhOutlineSize` (in `fpsprite.glsl` and `fpselect.glsl`)
	 - Sprite outline thickness.
	 - The default imitates BG2EE 2.6, which in this case is
	   `1.5` for `fpsprite.glsl` and `3.5` for `fpselect.glsl`.
	 - `0.0` means no outline.
	 - Going below `1.0` might look inconsistent.
	   Going below *sqrt(2)* means no outline.
	 - Going above `4.0` might result in the outline being cropped.
 - `uhFontHackGamma` (in `fpdraw.glsl` and `fptone.glsl`)
	 - Designed for Dragonspear UI++/Infinity UI++.
	   Without UI mods that might need this particularly, you probably
	   shouldn't use it.
	 - Default: `0.0` (it means that the option is disabled,
	   `0.0` gamma would be undefined anyways).
	 - Other lower than `1.0` are useful.
	 - Going below `0.4` might look bad.
	 - Going above `1.0` will make fonts thinner and less readable.
	 - `0.8` is what you can enable with [Font gamma fixes](#font-gamma-fixes)
	   advanced selection.
 - `uhSelectionGamma`
	 - Default: `1.0` (game behaves normally).
	 - You can set greater value if you want thinner selection circles.
	   It will also make highlihting of selected objects
	   (doors, containers, etc.) fainter.
	 - `2.0` imitates a bug from 0.2.3 that became popular.
	   [Selection circles](#selection-circles) component sets that.
 - `#define UH_NEEDS_HEURISTIC_BORDER	1` in `fpdraw.glsl` and `fptone.glsl`.
	 - You can set it to `0` to manually control the custom selection from
	   [Anti-glitch policy](#anti-glitch-policy) component.

## Preview

Each image has a link below for larger preview. The presented thumbnails
are downscaled, thus way less meaningful than the images you can get
by clicking.

### Main component

Installing the main component already indicates a change to how things
are displayed. The intention was to make the changes slight. Compare two
images on the left (BG2EE v2.6 with EET and nothing more) with the two
on the right (this mod with no specific config). Reworked outlines are roughly
similar, but you can see a difference if you try to. Also - the original map
rendered uses linear blending programatically rather than via sampler. This
means that the default (non-Catmull-Rom) map rendering is more pixelated
than BG2EE v2.6.

|                                                                                                                 |                                                                                                                           |                                                                                                                      |                                                                                                                                |
|-----------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| ![BG2EE 2.6 (EET)](https://github.com/dtiefling/dshaders/assets/145703648/e1ac667b-6f03-43f5-83ca-2bc0d3f7708f) | ![BG2EE 2.6 (EET), selected](https://github.com/dtiefling/dshaders/assets/145703648/8f3bf409-808f-4f95-8a04-14b52b8a8fe3) | ![Mod without settings](https://github.com/dtiefling/dshaders/assets/145703648/43e51a7d-9bde-4fd3-9434-ed1bce0a65e1) | ![Mod without settings, selected](https://github.com/dtiefling/dshaders/assets/145703648/1df282aa-b8ba-4469-9df5-ee332ccc4066) |
| [EET on 2.6](https://github.com/dtiefling/dshaders/assets/145703648/98ad9575-078b-4a4a-8fd8-f7dbc6352749)       | [EET on 2.6, selected](https://github.com/dtiefling/dshaders/assets/145703648/556169d6-f96f-4d9e-8266-951608767945)       | [Mod default](https://github.com/dtiefling/dshaders/assets/145703648/9149cc7f-d743-4e6f-8574-2cbd5058f5e4)           | [Mod default, selected](https://github.com/dtiefling/dshaders/assets/145703648/929cdd0b-5b07-4e28-8268-1f43acaa99bd)           |

### Catmull-Rom

Catmull-Rom interponation is one of the key features of this mod.
Top to bottom: no Catmull-Rom, Catmull-Rom for sprites only,
Catmull-Rom everywhere. Extra images on the right also have no outlines,
which I believe makes the C-R interpolation look as intended.

|                                                                                                                                       |                                                                                                                                         |
|---------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| ![Mod without settings](https://github.com/dtiefling/dshaders/assets/145703648/43e51a7d-9bde-4fd3-9434-ed1bce0a65e1)                  |                                                                                                                                         |
| [Default](https://github.com/dtiefling/dshaders/assets/145703648/9149cc7f-d743-4e6f-8574-2cbd5058f5e4)                                |                                                                                                                                         |
| ![C-R for sprites](https://github.com/dtiefling/dshaders/assets/145703648/a143c094-1393-4e2a-81a3-4fb02935f69f)                       | ![Catmull-Rom for sprites, no outline](https://github.com/dtiefling/dshaders/assets/145703648/bcabe226-2f58-4e7e-9a53-eedbb19f2741)     |
| [C-R for sprites](https://github.com/dtiefling/dshaders/assets/145703648/2fde0139-2855-407e-b278-ccc678acb138)                        | [C-R for sprites, no lines](https://github.com/dtiefling/dshaders/assets/145703648/f8c7ae7d-9347-42ac-abf7-50fa40e625e4)                |
| ![Catmull-Rom for all shaders](https://github.com/dtiefling/dshaders/assets/145703648/c74d8acb-a4f4-461e-8d7d-f4eb9de5c6a9)           | ![Catmull-Rom for all shaders, no outline](https://github.com/dtiefling/dshaders/assets/145703648/1718701d-3a12-4b40-ac56-21dd451b0a20) |
| [C-R for all](https://github.com/dtiefling/dshaders/assets/145703648/86b909cd-ec98-4322-ba18-2d65aff1c375)                            | [C-R for all, no lines](https://github.com/dtiefling/dshaders/assets/145703648/65f6b9ad-b5b6-478b-b03a-9addada6056c)                    |

### Color intensity

Left to right: no adjustment, moderate adjustment, intense adjustment.

|                                                                                                                                   |                                                                                                                                     |                                                                                                                                     |
|-----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| ![Mod without settings](https://github.com/dtiefling/dshaders/assets/145703648/43e51a7d-9bde-4fd3-9434-ed1bce0a65e1)              | ![Moderate color intensity adjustment](https://github.com/dtiefling/dshaders/assets/145703648/dd050b29-8dfe-4bb9-aa08-665819cb3f95) | ![Intense color intensity adjustment](https://github.com/dtiefling/dshaders/assets/145703648/ec36ab61-3cf4-4fee-a6fa-a0a97bf21f76)  |
| [Mod default](https://github.com/dtiefling/dshaders/assets/145703648/9149cc7f-d743-4e6f-8574-2cbd5058f5e4)                        | [Moderate](https://github.com/dtiefling/dshaders/assets/145703648/4bb13fca-8e47-4006-a8e5-f5afe1dbfc12)                             | [Intense](https://github.com/dtiefling/dshaders/assets/145703648/02dd88d0-7ac5-4202-90cd-449b50a888bd)                              |

### Sharpening

Sharpening options from the installer: none, slight, "more".

|                                                                                                                      |                                                                                                                      |                                                                                                                      |
|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| ![Mod without settings](https://github.com/dtiefling/dshaders/assets/145703648/43e51a7d-9bde-4fd3-9434-ed1bce0a65e1) | ![Slight sharpening](https://github.com/dtiefling/dshaders/assets/145703648/3116ca48-2ae6-4f7d-b149-aec8bb36cb35)    | ![More sharpening](https://github.com/dtiefling/dshaders/assets/145703648/5d359691-fba9-47c9-b253-756fdf16445f)      |
| [Default](https://github.com/dtiefling/dshaders/assets/145703648/9149cc7f-d743-4e6f-8574-2cbd5058f5e4)               | [Slight](https://github.com/dtiefling/dshaders/assets/145703648/ec342cf2-0a58-41ca-859c-bd18ddf4b846)                | [More](https://github.com/dtiefling/dshaders/assets/145703648/22daa272-88de-44ed-b4d3-d63af8589619)                  |

### Hue change

Display of 5 degree warmer colors, no change to the hue, and 5 degree
colder colors.

|                                                                                                                      |                                                                                                                      |                                                                                                                      |
|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| ![Warmer colors](https://github.com/dtiefling/dshaders/assets/145703648/6181f6da-ffeb-45fa-a149-784d91019b03)        | ![Mod without settings](https://github.com/dtiefling/dshaders/assets/145703648/43e51a7d-9bde-4fd3-9434-ed1bce0a65e1) | ![Colder colors](https://github.com/dtiefling/dshaders/assets/145703648/ccfed8c2-5d83-44ff-aac8-97cf2426b325)        |
| [Warm](https://github.com/dtiefling/dshaders/assets/145703648/ea5b7b8a-79ef-430b-bd56-fd0e2ec296d6)                  | [Default](https://github.com/dtiefling/dshaders/assets/145703648/9149cc7f-d743-4e6f-8574-2cbd5058f5e4)               | [Cold](https://github.com/dtiefling/dshaders/assets/145703648/a3d71927-f461-4d47-a775-4b2f5996529f)                  |

### Thinner selection circles

Mod default vs 0.2.3 bug turned into an optional feature.

|                                                                                                                       |                                                                                                                      |
|-----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
|  ![Mod without settings](https://github.com/dtiefling/dshaders/assets/145703648/43e51a7d-9bde-4fd3-9434-ed1bce0a65e1) | ![Thinner circle](https://github.com/dtiefling/dshaders/assets/145703648/cd315b0c-94b3-40d4-9b13-97b3ce2fb7c1)       |
| [Default](https://github.com/dtiefling/dshaders/assets/145703648/9149cc7f-d743-4e6f-8574-2cbd5058f5e4)                | [Thinner](https://github.com/dtiefling/dshaders/assets/145703648/ce5ce43c-35c7-4eda-9afe-fc90e7a4dd70)               |

### BGEE 1.3

Some peple out there miss BGEE 1.3. So let's compare the acutal BGEE 1.3 (left)
with the mod preset [BGEE 1.3-like setup (Catmull-Rom everywhere)](#quick-menu)
(right).

|                                                                                                                                  |                                                                                                                                  |
|----------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| ![BGEE 1.3, actual stuff](https://github.com/dtiefling/dshaders/assets/145703648/486814ce-fae9-4db5-81d5-ed603be74785)           | ![Mod setup that imitates BGEE 1.3](https://github.com/dtiefling/dshaders/assets/145703648/dfab3e24-565a-46f0-84fb-a9923f69237b) |
| [BGEE 1.3](https://github.com/dtiefling/dshaders/assets/145703648/c747015f-54ff-46a9-9fc4-54e19c2b3c8a)                          | [This mod](https://github.com/dtiefling/dshaders/assets/145703648/03a9cea0-7493-4bc4-b413-933805fee4dd)                          |

### More complex setup

It cannot be ommited that the actual beauty of this mod starts when you pick
your options and parameters by your taste. I happen to use my own stuff.
That's how [drunktiefling's choice](#quick-menu) looks like:

|                                                                                                                        |
|------------------------------------------------------------------------------------------------------------------------|
| ![drunktiefling's choice](https://github.com/dtiefling/dshaders/assets/145703648/980bcfb1-0a99-47a6-a6d4-8604957ecf05) |
| [drunktiefling's choice](https://github.com/dtiefling/dshaders/assets/145703648/b4ee18e6-11cf-4708-a204-ae8c761c7961)  |

## Resources

* Infinity Engine from Baldur's Gate 2: Enhanced Edition v2.6.
  [Please support the original release.](https://www.gog.com/en/game/baldurs_gate_2_enhanced_edition)
* [Baldur's Gate: Enhanced Edition v1.3](https://steamdb.info/app/228280/depots/?branch=bgee_1.3)
  engine was an important reference as well. I wish all the [Beamdog](https://www.beamdog.com/)
  developers that started working on this feature only to drop it
  in the further releases to have a good sleep, regular income and no crunches.
* [Shader Pack](https://github.com/Argent77/A7-LightingPackEE) by Argent77.
  It was the main inspiration, proving that changes to the shaders can provide
  a gameplay improvement on multiple PC platforms.
* Community suggestions by
  [Parys](https://forums.beamdog.com/profile/Parys) (!!!),
  [Allanon81](https://forums.beamdog.com/profile/Allanon81)
  et al.
  Testing of this mod and very presence of most of the features happened
  thanks to that folks.
* [WeiDU](https://weidu.org/) Infinity Engine Utility introduced
  by Westley Weimer and its pedantically organized
  [docs](https://weidu.org/~thebigg/README-WeiDU.html).
  It's not only about making it easier to distribute this specific mod,
  configure it via installer and make it compatible with tools such as
  [Project Infinity](https://github.com/ALIENQuake/ProjectInfinity).
  I believe that the whole decades of the modding community happened largely
  thanks to WeiDU.
* [NearInfinity](https://github.com/Argent77/NearInfinity), remarkably useful
  for everything in life, which includes extraction of the original shaders.
* [OpenGL docs](https://www.khronos.org/opengl/wiki/). GLSL is not even my main
  area of experience on the daily basis. Great docs made it approachable
  to figure out.
* Catmull, E. and Rom, R., (1974),
  "[A class of local interpolating splines](https://sci-hub.se/10.1016/b978-0-12-079050-0.50020-5)",
  in Barnhill, R. E.; Riesenfeld, R. F. (eds.),
  _Computer Aided Geometric Design_, New York: Academic Press, pp. 317–326.
  Yes, it is a [Sci-Hub](https://sci-hub.se/) link. Love the researchers,
  not the publishers.
* [Affine color manipulation](http://beesbuzz.biz/code/16-hsv-color-transforms)
  post by [fluffy-critter](https://github.com/fluffy-critter) that inspired
  the hue modification implemented in this mod.
* [GLSL optimizer](https://github.com/jamienicol/glsl-optimizer) introduced by
  [Aras Pranckevičius](https://github.com/aras-p), in a branch forked by
  [Jamie Nicol](https://github.com/jamienicol).
  The included builds were prepared using tools such as:
	 - [GCC](https://gcc.gnu.org/),
	 - [MSYS2](https://www.msys2.org/),
	 - [MinGW](https://www.mingw-w64.org/),
	 - [CMake](https://cmake.org/).
* [Pluma](https://github.com/mate-desktop/pluma) -
  The [MATE](https://mate-desktop.org/) text editor.

#### Drunk Tiefling, 2023.

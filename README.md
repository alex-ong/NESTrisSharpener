![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/hero-image.png)
# NESTrisSharpener
A simple OBS shader for upscaling graphics.

# Download and installation
1) Installing obs-shader-filter
* Info/Install: [\[read this\]](https://github.com/Oncorporation/obs-shaderfilter) [\[download here\]](https://github.com/Oncorporation/obs-shaderfilter/releases/download/v1.0/obs-shaderfilter-win.zip) (tl;dr unzip to correct place and override)
* Do not use the latest release; use the one linked
* Alternate clarification images: https://imgur.com/a/vWVJ2Sy

Do not proceed to step 2 until you have confirmed that obs-shader-filter is installed.

**You should be able to right click a source (or scene) -> Filters -> "+" -> "User-defined shader".**

2) Installing NESTrisSharpener:
* Download NESTrisSharpener by clicking this [link](https://github.com/alex-ong/NESTrisSharpener/archive/master.zip), and then unzipping it somewhere.
* Open OBS. Set up a [stencil-ready](http://bit.ly/TheStencil) **scene**.
* Right click the **scene** (*not the video source*), and select **Filters**
* Add a filter by pressing the "+" on the bottom right
* Add a new "User-defined shader"
* Shader Text file -> Browse -> **nestris-stencil.shader**
* Scroll down to "block_image", and select **blocks.png**
* Calibrate (look below for instructions)
* Untick "**setup mode**"

# Applying directly to capture card

If you want to apply the sharpener directly to your capture card; or want sharpened stats blocks, refer to this diagram:
![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/which-shader.png)



# Interlacing
Note that this shader assumes a perfectly deinterlaced image.
Below is a problem that is not solvable if your image is interlaced - we can't figure out the block because the image isn't clean:
![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/interlaced.png)

* The easiest way to de-interlace your image is to select your video source, choose de-interlace, and select "yadif-2x".
* Next, if the game image bobs up and down violently, you'll have to select the "first" field and change it.


# Calibration (quick-setup)
Now, we will quickly calibrate the image
* First, make sure your video source is only game image, with no borders. If it isn't aligned properly, try to add a crop/pad filter before this in the chain, so that it lines up.
* Next, we have to set all the appropriate values. Below are descriptions of sections and some default values that work well.

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/calibration.png)
# setup_mode
This is ticked by default, to set calibration up. when you are done, untick it.

# Field
This section defines where your field is. Values range from 0 to 256. You can use fractions of pixels.

| Name           | default value | 
| -------------  |---------------|
| field_left_x   | 96            |
| field_right_x  | 176           |
| field_top_y    | 43            |
| field_bottom_y | 196           |

You want the field to skirt the block-grid (not the board) perfectly.
This means there should be a clear 1-2 nes pixel gap between the bottom of the field and the field border.

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/field-indepth.png)


# stat_palette_white, stat_palette, fixed_palette
Enabling stat_palette_white means white blocks with coloured borders get their color from the statistics bar on the left.
This results in uniform looking white blocks.

stat_palette is the same thing, but for fully coloured blocks.

fixed_palette uses a pre-defined palette to compare against. 

Look at palette options (bottom of this page) for more details.


| Name                 | default value    | 
| -------------        |---------------   |
| stat_palette_white   | <ul><li>- [x] </li></ul>   |
| stat_palette         | <ul><li>- [ ] </li></ul> |
| fixed_palette        | <ul><li>- [ ] </li></ul> |

# paletteA1, paletteA2, paletteB1, paletteB2
If you have stat_palette_white, stat_palette or fixed_palette enabled, you can set the locations of some reference blocks in the image.

| Name           | default value | 
| -------------  |---------------|
| paletteA_x1    | 30            |
| paletteA_y1    | 104           |
| paletteA_x2    | 30            |
| paletteA_y2    | 156           |

| Name           | default value | 
| -------------  |---------------|
| paletteB_x1    | 30            |
| paletteB_y1    | 120           |
| paletteB_x2    | 30            |
| paletteB_y2    | 170           |

These palette settings are used to determine the colors of your blocks. You'll want to select a pixel of "pure color"

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/pure-color.png)

# sharpen_stats
This section enables the sharpening of your statistics window

| Name           | default value   |
| -------------- | -------------   |
| sharpen_stats  | <ul><li>- [ ] </li></ul>   |
| stats_image    | blocks-stat.png |
| stat_t_top_y   | 87              |
| stat_i_left_x  | 24              |
| stat_i_right_x | 47              |
| stat_t_bottom_y| 185             |


The algorithm for sharpening stats is the same as for your field. This means for best results, use and calibrate fixed_palette.

# sharpen_preview
This section enables the sharpening of your preview window

| Name                 | default value   |
| --------------       | -------------   |
| sharpen_preview      | <ul><li>- [x] </li></ul>   |
| preview_left_x       | 192             |
| preview_right_x      | 223             |
| preview_top_y        | 112             |
| preview_bottom_y     | 128             |

The preview window expects you to hug 2x4 tile preview area as perfectly as possible:

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/preview.png)

The algorithm for sharpening preview is the same as for your field. This means for best results, use and calibrate fixed_palette.

# game / menu detection
skip_detect_game - if you tick this, we will always be in game mode. if it is un-ticked, we check for menus.
skip_detect_game_over - if you tick this, we will always be in game mode. if it is un-ticked, we check for game-overs.

| Name                  | default value   | 
| -------------         |-----------------|
| skip_detect_game      | <ul><li>- [ ] </li></ul>|
| skip_detect_game_over | <ul><li>- [ ] </li></ul>|

The next settings are the locations of a few squares that we use to figure out if we are in game mode:

| Name                  | default value   | 
| -------------         |-----------------|
| game_black_x1         | 98|
| game_black_y1         | 26|
| game_black_x2         | 240|
| game_black_y2         | 24|
| game_grey_x1          | 36|
| game_grey_y1          | 214|

If we detect black in both locations specified as well as grey in the bottom left corner, we assume that we aren't in a menu.
When you are in menus, you will notice that these specific blocks change color from grey to black. We use a combination of these
to calculate which exact scene we are in.

# Palette options (advanced, higher quality)

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/palette-comparison.png)

Here is a more detailed explanation of how the palette options work.

* stat_palette_white - "white" blocks get their border color from the statistics window to the left of playfield. Disabling this attemps to calculate border color from the block itself, though usually ends up being too grey.
* stat_palette - non-white blocks get their fill color from the statistics window to the left of playfield. Enabling this will lead to more uniform colors. Disabling this will lead to more variance in block colors.
* fixed_palette - First, looks at statistics window to figure out which level we are on. Compares colors in statistics window to fixed_palette_image. After this, looks at the block and matches it between the valid colors for that level. Note that for this option to work correctly, you should first record a video of the first ten levels. Then get the block colors for each of your levels and calibrate the fixed_palette file.

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/palette-calibrate.png)

# menu overlay
* menu_overlay - image that you want to display during menu screens
* show_menu_overlay - whether to enable the overlay during menus

# Conclusion
I hope that this project helped sharpen your video capture / streaming! If you liked this project, please star this project!

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/doc/starme.png)


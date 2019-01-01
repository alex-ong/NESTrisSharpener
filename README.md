# NESTrisSharpener
A simple OBS shader for upscaling graphics.

# Download and installation
1) Download and install this plugin:
* Download: https://github.com/nleseul/obs-shaderfilter/releases
* Install: read this - https://github.com/nleseul/obs-shaderfilter/
2) Download this repository by clicking this [link](https://github.com/alex-ong/NESTrisSharpener/archive/master.zip), and then unzipping it somewhere.
3) Open OBS. Add your video source (i.e. NES Tetris composite AV signal, or youtube screen capture, or whatever)
3) Add filter... (right click on video source, hit "filter")
5) Add a new "User-defined shader"
6) Shader Text file -> Browse -> Nestris.shader
7) block_image  -> Browse -> blocks.png
8) fixed_palette_image -> Browse -> fixed_palette.png

# Interlacing
Note that this shader assumes a perfectly deinterlaced image.
Below is a problem that is not solvable if your image is interlaced - we can't figure out the block because the image isn't clean:
![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/interlaced.png)

* The easiest way to de-interlace your image is to select your video source, choose de-interlace, and select "retro".
* Next, if the game image bobs up and down violently, you'll have to select the "first" field and change it.


# Calibration (quick-setup)
Now, we will quickly calibrate the image
* First, make sure your video source is only game image, with no borders. If it isn't aligned properly, try to add a crop/pad filter before this in the chain, so that it lines up.
* Next, we have to set all the appropriate values. Below are descriptions of sections and some default values that work well.

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/calibration.png)
# setup_mode
tick this to set calibration up. when you are done, untick it.

# Field
This section defines where your field is. Values range from 0 to 256. You can use fractions of pixels.

| Name           | default value | 
| -------------  |---------------|
| field_left_x   | 97            |
| field_right_x  | 176           |
| field_top_y    | 39            |
| field_bottom_y | 200           |

# stat_palette_white, stat_palette, fixed_palette
Enabling stat_palette_white means white blocks with coloured borders get their color from the statistics bar on the left.
This results in uniform looking white blocks.
stat_palette is the same thing, but for fully coloured blocks.

| Name                 | default value    | 
| -------------        |---------------   |
| stat_palette_white   | true (ticked)    |
| stat_palette         | false (unticked) |
| fixed_palette        | false (unticked) |

# paletteA1, paletteA2, paletteB1, paletteB2
If you have stat_palette_white, stat_palette or fixed_palette enabled, you can set the locations of some reference blocks in the image.

| Name           | default value | 
| -------------  |---------------|
| paletteA_x1    | 30            |
| paletteA_y1    | 103           |
| paletteA_x2    | 30            |
| paletteA_y2    | 158           |

| Name           | default value | 
| -------------  |---------------|
| paletteB_x1    | 30            |
| paletteB_y1    | 120           |
| paletteB_x2    | 30            |
| paletteB_y2    | 167           |

# game / menu detection
skip_detect_game - if you tick this, we will always be in game mode. if it is un-ticked, we check for menus.
skip_detect_game_over - if you tick this, we will always be in game mode. if it is un-ticked, we check for game-overs.

| Name                  | default value   | 
| -------------         |-----------------|
| skip_detect_game      | false (unticked)|
| skip_detect_game_over | false (unticked)|

The next settings are the locations of a few squares that we use to figure out if we are in game mode:

| Name                  | default value   | 
| -------------         |-----------------|
| game_black_x1         | 98|
| game_black_y1         | 19|
| game_black_x2         | 238|
| game_black_y2         | 16|
| game_grey_x1          | 13|
| game_grey_y1          | 219|

If we detect black in both locations specified as well as grey in the bottom left corner, we assume that we aren't in a menu.


# Palette options (advanced, higher quality)
Here is a more detailed explanation of how the palette options work.

* stat_palette_white - "white" blocks get their border color from the statistics window to the left of playfield. Disabling this attemps to calculate border color from the block itself, though usually ends up being too grey.
* stat_palette - non-white blocks get their fill color from the statistics window to the left of playfield. Enabling this will lead to more uniform colors. Disabling this will lead to more variance in block colors.
* fixed_palette - First, looks at statistics window to figure out which level we are on. Compares colors in statistics window to fixed_palette_image. After this, looks at the block and matches it between the valid colors for that level. Note that for this option to work correctly, you should first record a video of the first ten levels. Then get the block colors for each of your levels and calibrate the fixed_palette file.

![image](https://github.com/alex-ong/NESTrisSharpener/raw/master/palette-calibrate.png)




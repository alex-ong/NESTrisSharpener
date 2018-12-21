# NESTrisSharpener
A simple OBS shader for upscaling graphics.

#TODO full guide

1) Download and install this plugin:
* Download: https://github.com/nleseul/obs-shaderfilter/releases
* Install: read this - https://github.com/nleseul/obs-shaderfilter/

2) Add your video source (i.e. NES Tetris composite AV signal)
3) Add filter... (right click on video source, hit "filter")
4) Add a new "User-defined shader"
5) Shader Text file -> Browse -> Nestris.shader
6) other_image  -> Browse -> blocks.png

Should all be working now. If it isn't aligned properly, try to add a crop/pad filter before this in the chain, so that it lines up.

#!/bin/sh
set -e
cd "$(dirname "$0")"
R="android/app/src/main/res"
I="ios/Runner/Assets.xcassets/AppIcon.appiconset"
M="macos/Runner/Assets.xcassets/AppIcon.appiconset"

# Master PNG
rsvg-convert -w 1024 -h 1024 assets/icon/icon.svg -o assets/icon/icon.png

# Android launcher mipmaps
rsvg-convert -w 48  -h 48  assets/icon/icon.svg -o $R/mipmap-mdpi/ic_launcher.png
rsvg-convert -w 72  -h 72  assets/icon/icon.svg -o $R/mipmap-hdpi/ic_launcher.png
rsvg-convert -w 96  -h 96  assets/icon/icon.svg -o $R/mipmap-xhdpi/ic_launcher.png
rsvg-convert -w 144 -h 144 assets/icon/icon.svg -o $R/mipmap-xxhdpi/ic_launcher.png
rsvg-convert -w 192 -h 192 assets/icon/icon.svg -o $R/mipmap-xxxhdpi/ic_launcher.png

# iOS AppIcon set
rsvg-convert -w 20   -h 20   assets/icon/icon.svg -o $I/Icon-App-20x20@1x.png
rsvg-convert -w 40   -h 40   assets/icon/icon.svg -o $I/Icon-App-20x20@2x.png
rsvg-convert -w 60   -h 60   assets/icon/icon.svg -o $I/Icon-App-20x20@3x.png
rsvg-convert -w 29   -h 29   assets/icon/icon.svg -o $I/Icon-App-29x29@1x.png
rsvg-convert -w 58   -h 58   assets/icon/icon.svg -o $I/Icon-App-29x29@2x.png
rsvg-convert -w 87   -h 87   assets/icon/icon.svg -o $I/Icon-App-29x29@3x.png
rsvg-convert -w 40   -h 40   assets/icon/icon.svg -o $I/Icon-App-40x40@1x.png
rsvg-convert -w 80   -h 80   assets/icon/icon.svg -o $I/Icon-App-40x40@2x.png
rsvg-convert -w 120  -h 120  assets/icon/icon.svg -o $I/Icon-App-40x40@3x.png
rsvg-convert -w 120  -h 120  assets/icon/icon.svg -o $I/Icon-App-60x60@2x.png
rsvg-convert -w 180  -h 180  assets/icon/icon.svg -o $I/Icon-App-60x60@3x.png
rsvg-convert -w 76   -h 76   assets/icon/icon.svg -o $I/Icon-App-76x76@1x.png
rsvg-convert -w 152  -h 152  assets/icon/icon.svg -o $I/Icon-App-76x76@2x.png
rsvg-convert -w 167  -h 167  assets/icon/icon.svg -o $I/Icon-App-83.5x83.5@2x.png
rsvg-convert -w 1024 -h 1024 assets/icon/icon.svg -o $I/Icon-App-1024x1024@1x.png

# Web
rsvg-convert -w 16  -h 16  assets/icon/icon.svg -o web/favicon.png
rsvg-convert -w 192 -h 192 assets/icon/icon.svg -o web/icons/Icon-192.png
rsvg-convert -w 512 -h 512 assets/icon/icon.svg -o web/icons/Icon-512.png
rsvg-convert -w 192 -h 192 assets/icon/icon_maskable.svg -o web/icons/Icon-maskable-192.png
rsvg-convert -w 512 -h 512 assets/icon/icon_maskable.svg -o web/icons/Icon-maskable-512.png

# Android adaptive-icon foreground (108dp layer: 1x/1.5x/2x/3x/4x)
rsvg-convert -w 108 -h 108 assets/icon/icon_foreground.svg -o $R/mipmap-mdpi/ic_launcher_foreground.png
rsvg-convert -w 162 -h 162 assets/icon/icon_foreground.svg -o $R/mipmap-hdpi/ic_launcher_foreground.png
rsvg-convert -w 216 -h 216 assets/icon/icon_foreground.svg -o $R/mipmap-xhdpi/ic_launcher_foreground.png
rsvg-convert -w 324 -h 324 assets/icon/icon_foreground.svg -o $R/mipmap-xxhdpi/ic_launcher_foreground.png
rsvg-convert -w 432 -h 432 assets/icon/icon_foreground.svg -o $R/mipmap-xxxhdpi/ic_launcher_foreground.png

# Google Play Store listing icon (512x512, full-bleed, no transparency)
rsvg-convert -w 512 -h 512 assets/icon/icon.svg -o assets/icon/play_store_512.png

# macOS
rsvg-convert -w 16   -h 16   assets/icon/icon.svg -o $M/app_icon_16.png
rsvg-convert -w 32   -h 32   assets/icon/icon.svg -o $M/app_icon_32.png
rsvg-convert -w 64   -h 64   assets/icon/icon.svg -o $M/app_icon_64.png
rsvg-convert -w 128  -h 128  assets/icon/icon.svg -o $M/app_icon_128.png
rsvg-convert -w 256  -h 256  assets/icon/icon.svg -o $M/app_icon_256.png
rsvg-convert -w 512  -h 512  assets/icon/icon.svg -o $M/app_icon_512.png
rsvg-convert -w 1024 -h 1024 assets/icon/icon.svg -o $M/app_icon_1024.png

# Windows .ico
mkdir -p /tmp/wico
for s in 16 24 32 48 64 128 256; do rsvg-convert -w $s -h $s assets/icon/icon.svg -o /tmp/wico/$s.png; done
magick /tmp/wico/16.png /tmp/wico/24.png /tmp/wico/32.png /tmp/wico/48.png /tmp/wico/64.png /tmp/wico/128.png /tmp/wico/256.png windows/runner/resources/app_icon.ico

rm -f icon_preview.png
echo "ALL GENERATED"

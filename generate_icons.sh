#!/bin/bash

# Script to generate app icons for Android and macOS from a source image
# Usage: ./generate_icons.sh <source_image.png>

set -e

SOURCE_IMAGE="$1"
APP_ICONS_DIR="AppIcons memoreader"

if [ -z "$SOURCE_IMAGE" ]; then
    echo "Usage: $0 <source_image.png>"
    echo "Example: $0 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png"
    exit 1
fi

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image not found: $SOURCE_IMAGE"
    exit 1
fi

echo "Generating icons from: $SOURCE_IMAGE"

# Create directories
mkdir -p "$APP_ICONS_DIR/android/mipmap-mdpi"
mkdir -p "$APP_ICONS_DIR/android/mipmap-hdpi"
mkdir -p "$APP_ICONS_DIR/android/mipmap-xhdpi"
mkdir -p "$APP_ICONS_DIR/android/mipmap-xxhdpi"
mkdir -p "$APP_ICONS_DIR/android/mipmap-xxxhdpi"
mkdir -p "$APP_ICONS_DIR/macos"

# Generate Android icons
echo "Generating Android icons..."
sips -z 48 48 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/android/mipmap-mdpi/ic_launcher.png"
sips -z 72 72 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/android/mipmap-hdpi/ic_launcher.png"
sips -z 96 96 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/android/mipmap-xhdpi/ic_launcher.png"
sips -z 144 144 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/android/mipmap-xxhdpi/ic_launcher.png"
sips -z 192 192 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/android/mipmap-xxxhdpi/ic_launcher.png"

# Generate macOS icons
echo "Generating macOS icons..."
sips -z 16 16 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_16.png"
sips -z 32 32 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_32.png"
sips -z 64 64 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_64.png"
sips -z 128 128 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_128.png"
sips -z 256 256 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_256.png"
sips -z 512 512 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_512.png"
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$APP_ICONS_DIR/macos/app_icon_1024.png"

echo "Icons generated successfully in: $APP_ICONS_DIR"
echo ""
echo "To use these icons:"
echo "1. Copy Android icons: cp -r \"$APP_ICONS_DIR/android/mipmap-*\" android/app/src/main/res/"
echo "2. Copy macOS icons: cp \"$APP_ICONS_DIR/macos/app_icon_*.png\" macos/Runner/Assets.xcassets/AppIcon.appiconset/"


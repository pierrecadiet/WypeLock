#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="WypeLock"
VERSION="${VERSION:-$(sed -n 's/^MARKETING_VERSION *= *//p' Config.xcconfig)}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"
BUILD_DIR="build"
STAGING_DIR="$BUILD_DIR/dmg"
APP_PATH="$STAGING_DIR/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME-$VERSION.dmg"

command -v create-dmg >/dev/null || { echo "create-dmg is required: brew install create-dmg" >&2; exit 1; }

rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"

echo "Building $APP_NAME $VERSION"
xcodebuild \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -destination "generic/platform=macOS" \
    MARKETING_VERSION="$VERSION" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    -quiet \
    build

cp -R "$BUILD_DIR/DerivedData/Build/Products/Release/$APP_NAME.app" "$APP_PATH"

echo "Signing with identity: $SIGN_IDENTITY"
if [[ "$SIGN_IDENTITY" == "-" ]]; then
    codesign --force --options runtime --sign - "$APP_PATH"
else
    codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP_PATH"
fi
codesign --verify --strict "$APP_PATH"

echo "Creating $DMG_PATH"
create-dmg \
    --volname "$APP_NAME" \
    --background "dmg/background.tiff" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 128 \
    --icon "$APP_NAME.app" 150 190 \
    --hide-extension "$APP_NAME.app" \
    --app-drop-link 450 190 \
    --no-internet-enable \
    "$DMG_PATH" \
    "$STAGING_DIR"

if [[ "$SIGN_IDENTITY" != "-" ]]; then
    codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG_PATH"
fi

if [[ -n "${APPLE_ID:-}" && -n "${APPLE_TEAM_ID:-}" && -n "${APPLE_APP_PASSWORD:-}" ]]; then
    echo "Notarizing"
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_APP_PASSWORD" \
        --wait
    xcrun stapler staple "$DMG_PATH"
fi

echo "Done: $DMG_PATH"

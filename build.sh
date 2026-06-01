#!/usr/bin/env bash
set -euo pipefail

APP_NAME="微信双开助手.app"
ZIP_NAME="微信双开助手.zip"
SOURCE="wechat_duo_launcher.applescript"

osacompile -o "$APP_NAME" "$SOURCE"
codesign --force --deep --sign - "$APP_NAME"
ditto -c -k --sequesterRsrc --keepParent "$APP_NAME" "$ZIP_NAME"

echo "Built $APP_NAME and $ZIP_NAME"

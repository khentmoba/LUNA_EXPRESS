#!/bin/bash
set -e

echo "============================================"
echo "  Luna Express — Build & Deploy"
echo "============================================"
echo

cd "$(dirname "$0")"

echo "Building from ROOT directory (active codebase)..."
flutter build web --release

echo
echo "Deploying to Firebase Hosting..."
npx --no-install firebase deploy --only hosting

echo
echo "============================================"
echo "  Deploy complete!"
echo "  https://lunaexpress.web.app"
echo "============================================"

#!/bin/bash
set -e

echo "=== Starting Flutter Web Build on Vercel ==="

# Check if Flutter SDK already exists (cached)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter Stable SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
else
  echo "Flutter SDK already cached, updating..."
  cd flutter && git pull && cd ..
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

echo "=== Flutter Environment ==="
flutter doctor

echo "=== Installing Dependencies ==="
flutter pub get

echo "=== Compiling Flutter Web for Release ==="
flutter build web --release

echo "=== Flutter Web Build Completed Successfully! ==="

#!/bin/bash
set -e

# Setup git safe directory
git config --global --add safe.directory /vercel/path0/flutter

# Download and extract Flutter 3.24.0
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz | tar -xJ

# Setup Flutter PATH
export PATH="$PWD/flutter/bin:$PATH"

# Configure Flutter
flutter config --no-analytics

# Install dependencies
flutter pub get

# Build for web
flutter build web --release 
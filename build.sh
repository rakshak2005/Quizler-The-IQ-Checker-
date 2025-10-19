#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# This script tells the Vercel build environment how to build your Flutter app.

# 1. Clone the stable channel of the Flutter SDK from GitHub.
# --depth 1 makes the clone faster by only getting the latest commit.
git clone https://github.com/flutter/flutter.git --depth 1 --branch stable

# 2. Add the Flutter bin directory to the system's PATH variable.
# This allows the build environment to find and run flutter commands.
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Run flutter doctor to verify the installation and download any missing tools.
flutter doctor

# 4. Enable web support for the project.
flutter config --enable-web

# 5. Get all the project dependencies listed in your pubspec.yaml file.
flutter pub get

# 6. Build the optimized, release version of your web app.
# The --base-href flag is important for routing in a single-page application.
# The output will be placed in the build/web directory, which Vercel will then deploy.
flutter build web --release --base-href /


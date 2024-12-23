#!/bin/bash -i

#using shebang with -i to enable interactive mode (auto load .bashrc)

# Stop imediately if error occurs
set -e


yes | sdkmanager "platform-tools" "platforms;android-33" "emulator"
yes | sdkmanager "system-images;android-33;google_apis;x86_64"
emulator -version

echo "INSTALL ANDROID SDK DONE!"
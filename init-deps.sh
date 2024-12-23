#!/bin/bash -i

#using shebang with -i to enable interactive mode (auto load .bashrc)

# Stop imediately if error occurs
set -e

# Install sdk
apt update && apt upgrade -y
apt install openjdk-17-jdk -y
java -version

# Install android tools
cd ~ && mkdir android-tools
cd android-tools
wget -O cmdline.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
wget -O platform.zip https://dl.google.com/android/repository/platform-tools-latest-linux.zip

ANDROID_HOME=/opt/androidsdk
mkdir -p $ANDROID_HOME
apt install unzip -y 
unzip cmdline.zip -d $ANDROID_HOME
unzip platform.zip -d $ANDROID_HOME
mkdir -p $ANDROID_HOME/cmdline-tools/tools
mv $ANDROID_HOME/cmdline-tools/ $ANDROID_HOME/cmdline-tools/tools

echo "export ANDROID_HOME=/opt/androidsdk" >> ~/.bashrc
echo "export ANDROID_SDK_ROOT=$ANDROID_HOME" >> ~/.bashrc
echo "export SDK=$ANDROID_HOME" >> ~/.bashrc
echo "export PATH=$SDK/emulator:$SDK/cmdline-tools/tools:$SDK/cmdline-tools/tools/bin:$SDK/platform-tools:$PATH" >> ~/.bashrc
source ~/.bashrc

chown -R $USER:$USER $ANDROID_HOME

yes | sdkmanager "platform-tools" "platforms;android-33" "emulator"
yes | sdkmanager "system-images;android-33;google_apis;x86_64"
emulator -version

echo "INSTALL ANDROID SDK DONE!"
echo "run 01.emulator-up.sh [new device name] to start emulator"
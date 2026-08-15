#!/data/data/com.termux/files/usr/bin/bash
set -e

REPO_URL="https://github.com/YOUR_USERNAME/sdl3-android-termux"
INSTALL_DIR="$HOME/sdl3-android-builder"

echo "=========================================="
echo "  SDL3 Android Build Environment for Termux"
echo "=========================================="
echo ""

if [ -d "$INSTALL_DIR" ]; then
    echo "[!] Already installed at $INSTALL_DIR"
    echo "    Run: $INSTALL_DIR/uninstall.sh  to remove"
    exit 1
fi

echo "[1/6] Installing dependencies..."
pkg install -y openjdk-21 git wget unzip which xz-utils \
    aapt aapt2 aidl android-tools apksigner d8 gradle \
    ndk-multilib ndk-multilib-native-static ndk-multilib-native-stubs

echo "[2/6] Creating directories..."
mkdir -p "$INSTALL_DIR"/{sdk,project}

echo "[3/6] Downloading Android SDK cmdline-tools..."
cd "$INSTALL_DIR"
wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-12266719_latest.zip
unzip -q commandlinetools-linux-12266719_latest.zip
mkdir -p sdk/cmdline-tools/latest
mv cmdline-tools/* sdk/cmdline-tools/latest/
rm -rf cmdline-tools commandlinetools-linux-12266719_latest.zip

echo "[4/6] Downloading NDK r29 (aarch64)..."
wget -q --show-progress https://github.com/lzhiyong/termux-ndk/releases/download/android-ndk/android-ndk-r29-aarch64.tar.xz
xz -d android-ndk-r29-aarch64.tar.xz
tar -xf android-ndk-r29-aarch64.tar
mkdir -p sdk/ndk
mv android-ndk-r29 sdk/ndk/29.0.14206865
rm -f android-ndk-r29-aarch64.tar

echo "[5/6] Installing platform android-34..."
cat > env.sh << 'ENVEOF'
#!/data/data/com.termux/files/usr/bin/bash
export JAVA_HOME="$PREFIX/lib/jvm/java-21-openjdk"
export ANDROID_HOME="$HOME/sdl3-android-builder/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.14206865"
export PATH="$HOME/sdl3-android-builder/bin:$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-aarch64/bin"
ENVEOF
chmod +x env.sh
source env.sh
yes | sdkmanager --licenses >/dev/null 2>&1
sdkmanager "platforms;android-34" "build-tools;35.0.0"

echo "[6/6] Setting up sample project..."
cp -r "$INSTALL_DIR"/sdl3/SDL/android-project "$INSTALL_DIR"/project/testapp 2>/dev/null || true

echo ""
echo "=========================================="
echo "  Installation complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  source $INSTALL_DIR/env.sh"
echo "  cd $INSTALL_DIR/project/testapp"
echo "  sdl3-build"
echo ""
echo "Or create your own project from the template:"
echo "  cp -r $INSTALL_DIR/project/testapp ~/mygame"
echo ""
echo "To uninstall:"
echo "  $INSTALL_DIR/uninstall.sh"

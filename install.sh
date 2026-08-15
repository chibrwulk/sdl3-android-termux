#!/data/data/com.termux/files/usr/bin/bash
set -e

INSTALL_DIR="$HOME/sdl3-android-builder"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "  SDL3 Android Builder for Termux"
echo "=========================================="
echo ""

if [ -d "$INSTALL_DIR" ]; then
    echo "[!] Already installed at $INSTALL_DIR"
    echo "    Remove it first: rm -rf $INSTALL_DIR"
    exit 1
fi

echo "[1/7] Installing dependencies..."
pkg install -y openjdk-21 git wget unzip which xz-utils \
    aapt aapt2 aidl android-tools apksigner d8 gradle \
    ndk-multilib ndk-multilib-native-static ndk-multilib-native-stubs

echo "[2/7] Creating directories..."
mkdir -p "$INSTALL_DIR"/{sdk,project,bin}

echo "[3/7] Downloading Android SDK cmdline-tools..."
cd "$INSTALL_DIR"
wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-12266719_latest.zip
unzip -q commandlinetools-linux-12266719_latest.zip
mkdir -p sdk/cmdline-tools/latest
mv cmdline-tools/* sdk/cmdline-tools/latest/
rm -rf cmdline-tools commandlinetools-linux-12266719_latest.zip

echo "[4/7] Downloading NDK r29 (aarch64)..."
wget -q --show-progress https://github.com/lzhiyong/termux-ndk/releases/download/android-ndk/android-ndk-r29-aarch64.tar.xz
xz -d android-ndk-r29-aarch64.tar.xz
tar -xf android-ndk-r29-aarch64.tar
mkdir -p sdk/ndk
mv android-ndk-r29 sdk/ndk/29.0.14206865
rm -f android-ndk-r29-aarch64.tar

echo "[5/7] Installing platform android-34..."
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

echo "[6/7] Setting up sample project..."
cp -r "$SCRIPT_DIR/template" "$INSTALL_DIR/project/testapp"
git clone --depth 1 https://github.com/libsdl-org/SDL.git "$INSTALL_DIR/project/testapp/app/jni/SDL"

# Fix NDK for aarch64 host
NDK_BIN="$INSTALL_DIR/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin"
mkdir -p "$NDK_BIN"
cp "$INSTALL_DIR/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-aarch64/bin"/*-linux-android*-clang* "$NDK_BIN/" 2>/dev/null || true
cat > "$NDK_BIN/clang-21" << 'CLANGEOF'
#!/data/data/com.termux/files/usr/bin/bash
exec /data/data/com.termux/files/usr/bin/clang "$@"
CLANGEOF
chmod +x "$NDK_BIN/clang-21"
ln -sf clang-21 "$NDK_BIN/clang"
ln -sf clang "$NDK_BIN/clang++"

# Fix cmake
rm -rf "$INSTALL_DIR/sdk/cmake"
mkdir -p "$INSTALL_DIR/sdk/cmake/3.22.1/bin"
ln -s /data/data/com.termux/files/usr/bin/cmake "$INSTALL_DIR/sdk/cmake/3.22.1/bin/cmake"
ln -s /data/data/com.termux/files/usr/bin/ninja "$INSTALL_DIR/sdk/cmake/3.22.1/bin/ninja"

# Fix sysroot
SYSROOT="$INSTALL_DIR/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
rm -f "$SYSROOT"
mkdir -p "$SYSROOT/usr/include" "$SYSROOT/usr/lib/aarch64-linux-android/21"
cp -r /data/data/com.termux/files/usr/include/* "$SYSROOT/usr/include/" 2>/dev/null
cp /data/data/com.termux/files/usr/aarch64-linux-android/lib/* "$SYSROOT/usr/lib/aarch64-linux-android/21/" 2>/dev/null

# Fix aapt2
for a in "$INSTALL_DIR/sdk/build-tools"/*/aapt2; do
    cp /data/data/com.termux/files/usr/bin/aapt2 "$a"
done

# Gradle properties
echo "android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2" >> "$INSTALL_DIR/project/testapp/gradle.properties"

# Install commands
cp "$SCRIPT_DIR/bin"/* "$INSTALL_DIR/bin/"

# Create global wrappers in $PREFIX/bin (no need to source env.sh manually)
for cmd in sdl3-build sdl3-install; do
    cat > "$PREFIX/bin/$cmd" << WRAPPER
#!/data/data/com.termux/files/usr/bin/bash
source "$INSTALL_DIR/env.sh"
exec "$INSTALL_DIR/bin/$cmd" "\$@"
WRAPPER
    chmod +x "$PREFIX/bin/$cmd"
done

echo "[7/7] Done!"
echo ""
echo "=========================================="
echo "  Installation complete!"
echo "=========================================="
echo ""
echo "Commands available globally (no source needed):"
echo "  sdl3-build              # build debug APK"
echo "  sdl3-build release      # build release APK"
echo "  sdl3-install            # install APK"
echo ""
echo "Quick start:"
echo "  cd $INSTALL_DIR/project/testapp"
echo "  sdl3-build"
echo "  sdl3-install"
echo ""
echo "Create your own project:"
echo "  cp -r $INSTALL_DIR/project/testapp ~/mygame"
echo ""
echo "Uninstall:"
echo "  rm -rf $INSTALL_DIR"
echo "  rm -f \$PREFIX/bin/sdl3-build \$PREFIX/bin/sdl3-install"

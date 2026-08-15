#!/data/data/com.termux/files/usr/bin/bash
echo "[!] This will delete ALL files in ~/sdl3-android-build/"
echo "[!] This includes: SDK, NDK, SDL3, projects, env.sh"
read -p "Are you sure? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/sdl3-android-build
    rm -f "$PREFIX/bin/sdl3-build" "$PREFIX/bin/sdl3-install"
    sed -i '/sdl3-android-build/d' ~/.bashrc 2>/dev/null
    echo "[+] Removed."
    echo "    To also remove installed packages:"
    echo "    pkg uninstall aapt aapt2 aidl android-tools apksigner d8 gradle openjdk-21 xz-utils ndk-multilib ndk-multilib-native-static ndk-multilib-native-stubs"
else
    echo "[-] Cancelled"
fi

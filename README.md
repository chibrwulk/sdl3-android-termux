# SDL3 Android Builder (Termux)

Build SDL3 C++ apps into Android APK directly on your phone — no PC needed.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/chibrwulk/sdl3-android-termux/main/install.sh | bash
sdl3-build
sdl3-install
```

That's it. No `source`, no `.bashrc` edits.

## What It Does

- Downloads Android SDK, NDK r29, SDL3
- Sets up a sample project with working C++ → APK pipeline
- Installs global commands: `sdl3-build`, `sdl3-install`
- Targets Android API 21+ (Android 5.0+), arm64-v8a

## Commands

| Command | Description |
|---|---|
| `sdl3-build` | Build debug APK in current project |
| `sdl3-build release` | Build release APK (unsigned) |
| `sdl3-build ~/mygame` | Build project at specific path |
| `sdl3-install` | Install APK (Shizuku → ADB → system installer) |
| `sdl3-build help` | Show full usage |

Commands are available globally after installation. No `source env.sh` needed.

## Project Structure

```
~/sdl3-android-builder/
├── env.sh              # environment (auto-sourced by wrappers)
├── bin/
│   ├── sdl3-build      # build script
│   └── sdl3-install    # install script
├── build.sh            # legacy wrapper (debug)
├── build-release.sh    # legacy wrapper (release)
├── uninstall.sh        # remove everything
└── project/testapp/    # sample SDL3 project
    └── app/
        ├── build.gradle
        ├── src/main/
        │   ├── AndroidManifest.xml
        │   ├── java/org/libsdl/app/   # SDL Java shim
        │   └── res/                   # icons, strings
        └── jni/
            ├── CMakeLists.txt
            ├── SDL/                   # SDL3 source (git)
            └── src/
                ├── CMakeLists.txt
                └── main.cpp           # your code here
```

## Adding Your Code

Edit `~/sdl3-android-builder/project/testapp/app/jni/src/main.cpp`, then:

```bash
sdl3-build
```

For multiple files, edit `app/jni/src/CMakeLists.txt`.

## New Project from Template

```bash
cp -r ~/sdl3-android-builder/project/testapp ~/mygame
cd ~/mygame
# edit app/jni/src/main.cpp
sdl3-build
```

## Shizuku Setup (recommended for Android 11+)

Shizuku lets you install APKs without ADB and without tapping through system dialogs.

1. Install **Shizuku** app (Play Store / F-Droid)
2. Start it: **"Start via Wireless Debugging"**
3. In Shizuku app: **"Use Shizuku in terminal apps"** → **"Export"**
4. Copy files to Termux:
   ```bash
   cp /sdcard/rish $PREFIX/bin/rish && chmod +x $PREFIX/bin/rish
   cp /sdcard/rish_shizuku.dex $HOME/rish_shizuku.dex && chmod 400 $HOME/rish_shizuku.dex
   ```
5. Done. `sdl3-install` will use Shizuku automatically.

## ADB Wireless (alternative)

```bash
# Settings > Developer options > Wireless debugging > Pair
adb pair IP:PORT
adb connect IP:PORT
sdl3-install
```

## Target

- **minSdk:** 21 (Android 5.0)
- **targetSdk:** 34
- **ABI:** arm64-v8a
- **Graphics:** OpenGL ES, Vulkan
- **Size:** ~2 GB installed

## Requirements

- Termux from F-Droid or GitHub (not Play Store)
- `pkg` working
- ~2 GB free storage
- Internet for initial download

## Uninstall

```bash
~/sdl3-android-builder/uninstall.sh
```

Removes `~/sdl3-android-builder/` and global commands.

---

*Code and README written with assistance from AI (Kimi K2.6).*

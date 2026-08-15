# SDL3 Android Build Environment (Termux)

## Quick Start

```bash
cd ~/sdl3-android-build
source env.sh
sdl3-build
```

APK will be at: `project/testapp/app/build/outputs/apk/debug/app-debug.apk`

## Commands

After `source env.sh`, these are available in PATH:

- `sdl3-build [release] [project-dir]` — build APK (default: debug, current dir)
- `sdl3-install [apk-path]` — install APK via adb or system installer
- `sdl3-build help` — show full usage

Legacy scripts (also work):
- `./build.sh` — build debug APK in `project/testapp/`
- `./build-release.sh` — build release APK (unsigned)

## Files

- `env.sh` — environment variables (JAVA_HOME, ANDROID_HOME, NDK, PATH)
- `bin/sdl3-build` — universal build command
- `bin/sdl3-install` — install command
- `build.sh` / `build-release.sh` — legacy wrappers
- `uninstall.sh` — remove everything
- `project/testapp/` — sample SDL3 Android project

## Project Structure

```
project/testapp/
├── app/
│   ├── build.gradle          # Android build config (compileSdk 34, NDK r29)
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/org/libsdl/app/   # SDL Java shim
│   │   └── res/                   # Android resources
│   └── jni/
│       ├── CMakeLists.txt    # Top-level CMake
│       ├── SDL/              # SDL3 source (copied)
│       └── src/
│           ├── CMakeLists.txt
│           └── main.cpp      # Your C++ code
```

## Adding Your Own Code

Edit `project/testapp/app/jni/src/main.cpp` and run `sdl3-build`.

For multiple files, edit `project/testapp/app/jni/src/CMakeLists.txt`.

## Creating a New Project from Template

```bash
cp -r ~/sdl3-android-build/project/testapp ~/mygame
cd ~/mygame
# edit app/jni/src/main.cpp
sdl3-build
```

## Target

- Android API 21+ (Android 5.0+)
- arm64-v8a only
- SDL3 with OpenGL ES + Vulkan
- compileSdk 34, targetSdk 34, minSdk 21

## Requirements

- Termux with `pkg` working
- ~2 GB free space
- Internet for initial SDK/NDK download

## Cleanup

```bash
./uninstall.sh
```

This removes everything in `~/sdl3-android-build/`.

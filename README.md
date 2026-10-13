# StormOverEuropeMobile

A free, original Godot 4 3D mobile prototype inspired by classic isometric city strategy games. It is not a copy of the original game's code or assets.

## Prototype features
- Procedurally created small city, roads and buildings
- Touch/click to set a movement destination
- Basic 3D character and isometric-style camera
- A yellow mission marker and simple completion message
- No third-party assets or paid dependencies

## Open in Godot
1. Install Godot 4.x.
2. Open the project manager and import this folder by selecting `project.godot`.
3. Open `Main.tscn` and run the project.
4. Tap/click a point on the ground to move the character.

## Build an Android APK with GitHub Actions
1. Create a **public** repository named `StormOverEuropeMobile` on GitHub.
2. Upload the contents of this folder to the repository root (not the enclosing ZIP folder).
3. Open **Actions** and enable workflows if GitHub asks.
4. The workflow runs on pushes to `main`, or choose **Build Android APK → Run workflow**.
5. Open the successful workflow run and download the `StormOverEuropeMobile-APK` artifact.
6. Extract the artifact ZIP to get `StormOverEuropeMobile.apk`.

## Important build notes
- The workflow uses the Godot CI container image `barichello/godot-ci:4.3.0`.
- Android export depends on the container's Godot export templates and Android toolchain being available and compatible with the preset.
- The first workflow run may fail if the image/preset's Android SDK or export-template configuration changes. Read the exact log and adjust the image/preset together rather than assuming a successful build.
- This is a debug APK for testing, not a Play Store release.
- Do not commit private signing keys or passwords.
- The project and workflow have not been built or tested in this delivery environment.

## License and assets
The code in this repository starter is provided under the MIT License. The project uses procedural placeholder geometry and contains no original commercial game assets. Use only assets you have permission to distribute.

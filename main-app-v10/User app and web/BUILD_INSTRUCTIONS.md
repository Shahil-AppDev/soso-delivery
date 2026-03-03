# Build Instructions

## Web Build

### Building for Production (with Wasm warnings)
```bash
flutter build web
```

### Building for Production (without Wasm warnings)
```bash
flutter build web --no-wasm-dry-run
```

### Running Web Locally
```bash
# Option 1: Run in Chrome
flutter run -d chrome --web-port 8080

# Option 2: Serve the built files
cd build/web
python -m http.server 8080
```

## Android Build

### Build APK (for testing/direct installation)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Build Split APKs (smaller file sizes)
```bash
flutter build apk --split-per-abi --release
```
Output: Multiple APKs in `build/app/outputs/flutter-apk/`

## About Wasm Warnings

The WebAssembly warnings occur because these packages use `dart:html` and `dart:js`:
- `flutter_secure_storage_web`
- `get_thumbnail_video`
- `flutter_facebook_auth_web`
- `universal_html`

### Solutions:

1. **Disable Wasm warnings** (recommended for now):
   ```bash
   flutter build web --no-wasm-dry-run
   ```

2. **Wait for package updates**: These packages need to migrate to `dart:js_interop` and `package:web` for Wasm support.

3. **Current impact**: None - your app builds successfully with JavaScript compilation. Wasm is optional and provides performance benefits but isn't required.

## Testing

### Web Testing
- Local: `flutter run -d chrome`
- Production build: Serve `build/web` directory

### Android Testing
- Install APK: `flutter install` or manually install the APK
- Test on emulator: `flutter run`

## Notes

- Web builds use JavaScript by default (not Wasm)
- Wasm support is experimental and optional
- Your app works perfectly without Wasm
- The warnings don't affect functionality

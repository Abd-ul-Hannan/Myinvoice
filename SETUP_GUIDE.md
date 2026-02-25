# My Invoice - Setup Guide

This guide will help you set up and run the My Invoice Flutter application.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Dart SDK** (comes with Flutter)

3. **Android Studio** or **Xcode** (for iOS development)

4. **Git** (for cloning the repository)

## Setup Steps

### 1. Navigate to Project Directory

```bash
cd my_invoice
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will download all the required packages specified in `pubspec.yaml`.

### 3. Generate Isar Database Files

The Isar database schema files (`.g.dart`) are already included in the repository. However, if you need to regenerate them:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Check Flutter Doctor

Verify that your Flutter environment is properly set up:

```bash
flutter doctor
```

Fix any issues that are reported.

### 5. Run the Application

#### For Android:

```bash
flutter run
```

or specify the device:

```bash
flutter run -d <device-id>
```

#### For iOS (macOS only):

```bash
flutter run -d ios
```

#### For Web:

```bash
flutter run -d chrome
```

## Project Configuration

### Android Configuration

The Android configuration is already set up in:
- `android/app/build.gradle` - Build configuration
- `android/app/src/main/AndroidManifest.xml` - Permissions and app configuration

**Minimum SDK Version**: 21 (Android 5.0)

### iOS Configuration

The iOS configuration is already set up in:
- `ios/Runner/Info.plist` - Permissions and app configuration

**Minimum iOS Version**: 11.0

## Permissions

The app requires the following permissions:

### Android
- `READ_EXTERNAL_STORAGE` - For reading PDFs
- `WRITE_EXTERNAL_STORAGE` - For saving PDFs
- `CAMERA` - For company logo upload
- `INTERNET` - For any future online features

### iOS
- `NSPhotoLibraryUsageDescription` - For accessing photo library
- `NSCameraUsageDescription` - For accessing camera

## Troubleshooting

### Issue: Build fails with Isar errors

**Solution**: Regenerate Isar files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Android build fails

**Solution**:
1. Check `android/app/build.gradle` for correct SDK versions
2. Update Gradle if needed: `cd android && ./gradlew wrapper --gradle-version=7.5`
3. Clean and rebuild: `flutter clean && flutter pub get`

### Issue: iOS build fails

**Solution**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select a development team in signing settings
3. Clean build folder in Xcode: Product → Clean Build Folder
4. Try building again

### Issue: Signature package not working

**Solution**: Ensure you have the latest version:
```bash
flutter pub upgrade signature
```

### Issue: PDF generation fails

**Solution**: Check that you have write permissions and storage access granted.

## Building for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then open Xcode to archive and upload to App Store.

## Development Tips

### Hot Reload

During development, use hot reload to see changes instantly:
- Press `r` in terminal
- Or use IDE shortcuts

### State Management

This app uses GetX for state management. Key controllers:
- `InvoiceController` - Manages invoices
- `CompanyController` - Manages company settings

### Database

The app uses Isar for local storage. Database location:
- Android: `data/data/com.myinvoice.app/app_flutter`
- iOS: Application Documents Directory

### Adding New Features

1. Create model in `lib/models/` if needed
2. Add business logic to controller in `lib/controllers/`
3. Create screen in `lib/views/screens/`
4. Add route in `lib/routes/app_routes.dart`
5. Update navigation as needed

## Testing

### Run Tests

```bash
flutter test
```

### Manual Testing Checklist

- [ ] Create new invoice
- [ ] Edit existing invoice
- [ ] Delete invoice
- [ ] Generate PDF
- [ ] Share PDF
- [ ] Search invoices
- [ ] Filter invoices
- [ ] Update settings
- [ ] Toggle dark mode
- [ ] Add signature

## Performance Optimization

For better performance:

1. **Enable Code Optimization**:
   ```bash
   flutter build apk --release --split-per-abi
   ```

2. **Analyze App Size**:
   ```bash
   flutter build apk --analyze-size
   ```

3. **Profile Performance**:
   ```bash
   flutter run --profile
   ```

## Useful Commands

```bash
# Check Flutter version
flutter --version

# List all devices
flutter devices

# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Check for outdated packages
flutter pub outdated
```

## Support

For additional help:
- Flutter Documentation: https://flutter.dev/docs
- GetX Documentation: https://pub.dev/packages/get
- Isar Documentation: https://isar.dev

## Next Steps

1. Customize the app with your branding
2. Add additional features as needed
3. Test on multiple devices
4. Prepare for release on Google Play Store / Apple App Store

---

Happy coding! 🚀

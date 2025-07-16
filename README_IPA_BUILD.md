# Frail Unsigned IPA Build Guide

This branch (`frail-ipa-build`) is dedicated to building unsigned iOS IPA files for the Frail fitness app. These IPAs are suitable for testing and development purposes.

## 🚀 Quick Start

### Prerequisites
- macOS computer (required for iOS development)
- Xcode installed and updated
- Apple Developer Account (optional for unsigned builds)
- Valid provisioning profile (optional for unsigned builds)
- Valid code signing certificate (optional for unsigned builds)

### Building the IPA

1. **Clone and switch to the branch:**
   ```bash
   git clone https://github.com/Sharkem11111111/frail.git
   cd frail
   git checkout frail-ipa-build
   ```

2. **Make the build script executable:**
   ```bash
   chmod +x build_ipa.sh
   ```

3. **Export options (already configured for unsigned builds):**
   - The `ios/exportOptions.plist` is already configured for unsigned development builds
   - No Team ID or certificates required for unsigned builds

4. **Run the build script:**
   ```bash
   ./build_ipa.sh
   ```

## 📁 Output

The IPA file will be created in:
```
build/ios/ipa/Runner.ipa
```

## ⚙️ Configuration Files

### `ios/exportOptions.plist`
Configuration for unsigned IPA export settings:
- **method**: `development` (for development/testing distribution)
- **signingStyle**: `manual` (manual code signing - no signing required)
- **provisioningProfiles**: Empty (no provisioning profiles needed)
- **signingCertificate**: Empty (no certificates needed)

### `build_ipa.sh`
Automated build script that:
1. Cleans previous builds
2. Builds Flutter for iOS (unsigned)
3. Archives the app with Xcode (unsigned)
4. Exports the unsigned IPA

## 🔧 Manual Build Steps

If you prefer to build manually:

1. **Clean and get dependencies:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build Flutter for iOS (unsigned):**
   ```bash
   flutter build ios --release --no-codesign
   ```

3. **Archive with Xcode (unsigned):**
   ```bash
   xcodebuild -workspace ios/Runner.xcworkspace \
              -scheme Runner \
              -configuration Release \
              -archivePath build/ios/archive/Runner.xcarchive \
              -allowProvisioningUpdates \
              -allowProvisioningDeviceRegistration \
              archive
   ```

4. **Export IPA (unsigned):**
   ```bash
   xcodebuild -exportArchive \
              -archivePath build/ios/archive/Runner.xcarchive \
              -exportOptionsPlist ios/exportOptions.plist \
              -exportPath build/ios/ipa \
              -allowProvisioningUpdates
   ```

## 🐛 Troubleshooting

### Common Issues

1. **"Xcode is not installed"**
   - Install Xcode from the Mac App Store
   - Accept the license agreement

2. **"Team ID not found"**
   - Update `ios/exportOptions.plist` with your correct Team ID
   - Find your Team ID in Apple Developer portal

3. **Code signing errors**
   - Ensure you have a valid provisioning profile
   - Check that your certificate is valid and installed
   - Verify your Apple Developer account status

4. **Archive fails**
   - Clean the project: `flutter clean`
   - Delete derived data in Xcode
   - Check for any iOS-specific errors in the build

### For Unsigned Builds

No Team ID, provisioning profiles, or certificates are required for unsigned builds. The configuration is already set up for development/testing purposes.

## 📱 App Information

- **Bundle Identifier**: `com.example.frail` (update in Xcode)
- **App Name**: Frail
- **Version**: 1.0.0+1 (from pubspec.yaml)
- **Minimum iOS Version**: 12.0

## 🔄 Updating the App

To update the app version:

1. **Update pubspec.yaml:**
   ```yaml
   version: 1.0.1+2  # Increment version and build number
   ```

2. **Update iOS version in Xcode:**
   - Open `ios/Runner.xcodeproj`
   - Update version in project settings

3. **Rebuild:**
   ```bash
   ./build_ipa.sh
   ```

## 📋 Distribution

### Development/Testing Distribution
1. Build the unsigned IPA using the script
2. Use for internal testing and development
3. Can be installed on devices for testing (with appropriate provisioning)

### Converting to Signed IPA (if needed)
To create a signed IPA for App Store or TestFlight:
1. Update `ios/exportOptions.plist` method to `app-store`
2. Add your Team ID and provisioning profiles
3. Run the build script again

## 🛠️ Development

This branch is specifically for IPA building. For development:
- Use the `main` branch for feature development
- Merge to `frail-ipa-build` when ready to build IPA
- Keep this branch clean and focused on builds only

## 📞 Support

For issues with the build process:
1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Check Xcode console for detailed error messages
4. Ensure your Apple Developer account is active 
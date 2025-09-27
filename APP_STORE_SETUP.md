# App Store Connect Setup Instructions

This document explains how to set up your Flutter app for automatic deployment to the Apple App Store using GitHub Actions.

## Prerequisites

1. **Apple Developer Account** - You need a paid Apple Developer account
2. **App Store Connect App** - Your app must be created in App Store Connect
3. **Code Signing Certificates** - Distribution certificates and provisioning profiles
4. **App Store Connect API Key** - For authentication

## Setup Steps

### 1. Configure Your Bundle ID

Your bundle ID is already configured as: `com.pakperegrine.hayya-alal-salah`

The following files have been updated with your bundle ID:
- `ios/fastlane/Fastfile`
- `.github/workflows/ios-release.yml`

### 2. Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to Users and Access → Keys
3. Click the "+" button to create a new key
4. Give it a name and select "App Manager" role
5. Download the `.p8` file and note the Key ID and Issuer ID

### 3. Export Code Signing Certificate

1. Open Keychain Access on your Mac
2. Find your "Apple Distribution" certificate
3. Right-click and export as `.p12` file with a password
4. Convert to base64: `base64 -i certificate.p12 | pbcopy`

### 4. Set GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

- `APP_STORE_CONNECT_ISSUER_ID`: Your Issuer ID from App Store Connect API
- `APP_STORE_CONNECT_KEY_ID`: Your Key ID from App Store Connect API  
- `APP_STORE_CONNECT_API_KEY`: Content of your `.p8` file
- `IOS_DIST_SIGNING_KEY`: Base64 encoded `.p12` certificate
- `IOS_DIST_SIGNING_KEY_PASSWORD`: Password for your `.p12` certificate
- `FASTLANE_USER`: Your Apple ID email
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`: App-specific password from Apple ID

### 5. Install Fastlane Locally (Optional)

```bash
cd ios
sudo gem install fastlane
fastlane init
```

### 6. Test Local Build

```bash
flutter build ios --release
cd ios
fastlane beta  # For TestFlight
fastlane release  # For App Store
```

## Usage

### Automatic Deployment

1. **Create a new tag**: `git tag v1.0.0 && git push origin v1.0.0`
2. **Manual trigger**: Go to Actions tab in GitHub and run "iOS Release to App Store"

### Manual Deployment

```bash
# TestFlight
cd ios && fastlane beta

# App Store
cd ios && fastlane release
```

## Troubleshooting

1. **Provisioning Profile Issues**: Make sure your bundle ID matches exactly
2. **Certificate Issues**: Ensure your distribution certificate is valid and not expired
3. **API Key Issues**: Check that your App Store Connect API key has proper permissions

## Additional Configuration

You may need to update:
- App version in `pubspec.yaml`
- App icons and splash screens
- App Store metadata and screenshots
- Privacy policy and terms of service

For more details, visit:
- [Flutter iOS Deployment Guide](https://docs.flutter.dev/deployment/ios)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions for iOS](https://github.com/Apple-Actions)

Apple Distribution Certicate .p12 password: Naeem123*
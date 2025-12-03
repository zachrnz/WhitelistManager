# Build Instructions for Safari Whitelist Manager

## Quick Start

1. **Open the project in Xcode:**
   ```bash
   cd WhitelistManager
   open WhitelistManager.xcodeproj
   ```

2. **Configure code signing:**
   - Select the `WhitelistManager` target in the project navigator
   - Go to the "Signing & Capabilities" tab
   - Select your Apple Developer team from the dropdown
   - Ensure "Automatically manage signing" is checked

3. **Build and run:**
   - Press `⌘R` (Cmd+R) to build and run
   - Or select `Product > Run` from the menu

## Building for Distribution

### Development Build

The app will be built to:
```
~/Library/Developer/Xcode/DerivedData/WhitelistManager-<hash>/Build/Products/Debug/WhitelistManager.app
```

### Release Build

1. Select `Product > Archive` from Xcode
2. Once archived, the Organizer window will open
3. Click "Distribute App"
4. Choose your distribution method:
   - **Development**: For testing on your Mac
   - **Ad Hoc**: For distribution to specific Macs
   - **App Store**: For App Store submission (requires App Store Connect setup)
   - **Export**: For direct distribution

## Code Signing Requirements

### For Development

- Free Apple Developer account is sufficient
- Xcode will automatically create a development certificate
- The app will run on your Mac

### For Distribution

- Paid Apple Developer Program membership ($99/year)
- Distribution certificate
- App Store Connect account (if distributing via App Store)

## Entitlements

The app uses the following entitlements (configured in `WhitelistManager.entitlements`):

- **App Sandbox**: Enabled (required for App Store)
- **User Selected File Access**: Read-write (for saving profiles)
- **Downloads Folder**: Read-write (for saving profiles to Desktop)

## Troubleshooting Build Issues

### "No signing certificate found"

1. Go to Xcode > Settings > Accounts
2. Add your Apple ID
3. Select your team
4. Xcode will automatically create certificates

### "Code signing is required"

1. Ensure you've selected a team in Signing & Capabilities
2. Check that "Automatically manage signing" is enabled
3. Try cleaning the build folder: `Product > Clean Build Folder` (⇧⌘K)

### Build errors related to Swift version

- The project uses Swift 5.0+
- Ensure Xcode 16.3+ is installed
- Check macOS deployment target is 15.4+

## Testing the App

### First Launch

1. Build and run the app
2. The app will create a whitelist JSON file automatically
3. Add some test URLs (e.g., `google.com`)
4. Click "Update Safari Whitelist"
5. Enter your admin password when prompted

### Verifying Profile Installation

1. Open Terminal
2. Run: `profiles -P`
3. Look for `com.arendsee.WhitelistManager.SafariWhitelist` in the output

### Testing Profile Removal

1. In Terminal, run: `profiles -R -identifier com.arendsee.WhitelistManager.SafariWhitelist`
2. Enter admin password
3. Verify removal: `profiles -P`

## File Locations

After running the app:

- **Whitelist JSON**: `~/Library/Application Support/com.arendsee.WhitelistManager/whitelist.json`
- **Generated Profile**: `~/Desktop/SchoolWhitelist.mobileconfig` (when installation fails)

## Next Steps After Building

1. **Test the app** on your Mac
2. **Customize the bundle identifier** if needed (currently `com.arendsee.WhitelistManager`)
3. **Add app icon** if desired (replace files in `Assets.xcassets/AppIcon.appiconset/`)
4. **Test profile installation** with admin credentials
5. **Distribute** to other Macs if needed

## Notes

- The app requires admin privileges only when installing/removing profiles
- Profile installation may require manual approval in System Settings on first use
- The app is designed to work from non-admin accounts (child's account)
- Safari must be configured to use "Allowed Websites Only" mode for the profile to take effect


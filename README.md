# Safari Whitelist Manager

A macOS app that allows parents (or children with admin approval) to easily manage a Safari URL whitelist enforced through configuration profiles. This enables Safari to be restricted to school-approved websites while keeping Chrome and other browsers available for entertainment (subject to Screen Time limits).

## Features

- **Simple GUI**: View, add, and remove URLs from the Safari whitelist
- **Bulk URL Import**: Paste multiple URLs at once (supports commas, newlines, spaces as separators)
- **Multi-Select Deletion**: Select multiple URLs with Cmd+click or Shift+click and delete them in bulk
- **Automatic Profile Generation**: Creates `.mobileconfig` files with the updated whitelist
- **Privileged Installation**: Handles profile installation with admin authentication
- **Non-Admin Friendly**: Usable from child's account, prompts for admin password only when needed
- **Persistent Storage**: Whitelist stored in JSON format in Application Support

## Architecture

The app consists of several key components:

1. **WhitelistManager**: Manages the JSON whitelist file storage
2. **ProfileGenerator**: Generates `.mobileconfig` files from the whitelist
3. **ProfileInstaller**: Handles privileged operations for installing/removing profiles
4. **ContentView**: SwiftUI interface for managing URLs

## Building the App

### Prerequisites

- macOS 15.4 or later
- Xcode 16.3 or later
- Apple Developer account (for code signing)

### Build Steps

1. **Open the Project**
   ```bash
   cd WhitelistManager
   open WhitelistManager.xcodeproj
   ```

2. **Configure Signing**
   - Select the `WhitelistManager` target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Ensure "Automatically manage signing" is enabled

3. **Build the App**
   - Press `Cmd+B` to build, or
   - Select `Product > Build` from the menu
   - The built app will be in `DerivedData` or use `Product > Archive` for distribution

4. **Run the App**
   - Press `Cmd+R` to run, or
   - Select `Product > Run` from the menu

### Finding the Built App

After building, the `.app` bundle can be found at:
```
~/Library/Developer/Xcode/DerivedData/WhitelistManager-<hash>/Build/Products/Debug/WhitelistManager.app
```

Or use Xcode's `Product > Show Build Folder in Finder` option.

## Usage

### First Time Setup

1. Launch the app
2. Add URLs to the whitelist (e.g., `google.com`, `khanacademy.org`)
3. Click "Update Safari Whitelist"
4. Enter admin credentials when prompted
5. If automatic installation fails, double-click the `SchoolWhitelist.mobileconfig` file on your Desktop

### Adding URLs

#### Single URL
1. Enter a domain name in the text field (e.g., `classroom.google.com`)
2. Click "Add" or press Enter
3. The URL will be normalized (protocol, www, and paths removed)

#### Bulk Import (Multiple URLs)
1. Paste multiple URLs into the text field, separated by:
   - Commas (`,`)
   - Newlines
   - Spaces or tabs
   
   Example formats:
   ```
   google.com, classroom.google.com, khanacademy.org
   ```
   
   or
   ```
   google.com
   classroom.google.com
   khanacademy.org
   ```

2. Click "Add" - the app will automatically parse and add all valid URLs
3. You'll see a summary of how many URLs were added and how many were skipped (duplicates or invalid)
4. All URLs are normalized automatically (protocol, www, and paths removed)

### Removing URLs

#### Single URL
1. Click the trash icon next to any URL in the list
2. The URL is immediately removed from the whitelist

#### Multiple URLs (Bulk Deletion)
1. **Select individual URLs**: Click the checkbox next to each URL you want to delete
2. **Select with keyboard shortcuts**:
   - **Cmd+click**: Select multiple individual URLs
   - **Shift+click**: Select a range of URLs (click first item, then Shift+click last item)
3. **Select All**: Click the "Select All" button to select all URLs at once
4. **Deselect**: Click "Deselect" to clear all selections
5. **Delete Selected**: Click the "Delete Selected" button (shows count of selected items)
6. All selected URLs will be removed at once

**Note**: The checkboxes provide visual feedback for selected items. You can also use standard macOS list selection behavior (Cmd+click, Shift+click) for familiar multi-select interaction.

### Updating the Profile

1. Click "Update Safari Whitelist"
2. Enter admin username and password when prompted
3. The app will:
   - Generate a new `.mobileconfig` file
   - Remove the old profile (if installed)
   - Install the new profile
   - If installation fails, the profile is saved to Desktop for manual installation

**Important**: The profile is NOT automatically installed when you launch the app. You must click "Update Safari Whitelist" to install it.

**Note on Admin Credentials**: Even if you're logged in as an admin user, macOS will still prompt for your password when installing/removing profiles. This is a security feature. However, macOS caches your authorization for approximately 5 minutes, so if you perform multiple operations within that window, you'll only be prompted once.

### Removing the Profile (For Testing)

To undo the Safari restriction and remove the profile:

#### Option 1: Using the App (Easiest)
1. Click the "Remove Profile" button in the app
2. Enter admin credentials when prompted (even if you're an admin user, macOS requires confirmation)
3. The profile will be removed and Safari will no longer be restricted

#### Option 2: Using Terminal
```bash
sudo profiles -R -identifier com.arendsee.WhitelistManager.SafariWhitelist
```

#### Option 3: Using System Settings
1. Open **System Settings** (or System Preferences on older macOS)
2. Go to **Privacy & Security** > **Profiles**
3. Find "Safari School Whitelist" profile
4. Click the **-** button to remove it
5. Enter admin password when prompted

## File Locations

- **Whitelist JSON**: `~/Library/Application Support/com.arendsee.WhitelistManager/whitelist.json`
- **Generated Profile**: `~/Desktop/SchoolWhitelist.mobileconfig` (when installation fails)

## Profile Format

The app generates configuration profiles with:
- **Payload Type**: `com.apple.webcontent-filter`
- **Filter Type**: Whitelist
- **Filter Browsers**: Safari only (browser ID 1)
- **Permitted URLs**: Array of HTTPS URLs from the whitelist

## Security Considerations

- The app uses Authorization Services for privileged operations
- Admin password is only requested when installing/removing profiles
- Whitelist file is stored in user's Application Support directory
- Profile installation may require manual approval in System Settings

## Troubleshooting

### Profile Installation Fails with CPDomainPlugIn:101 Error

**macOS Sequoia Limitation**: On macOS Sequoia (15.0+), web content filter profiles (`com.apple.webcontent-filter`) may require device supervision (MDM enrollment) and cannot be installed manually by users. This is a macOS security restriction.

**If you encounter this error:**
1. The profile file is generated correctly, but macOS blocks manual installation
2. Web content filter profiles on Sequoia typically require:
   - Device supervision via Apple Configurator or MDM
   - Or deployment through an MDM solution (Jamf, Mosyle, etc.)

**Alternative Solutions:**
- Use Screen Time restrictions (requires Family Sharing setup)
- Use a third-party content filtering solution
- Deploy via MDM if you have access to one
- Consider using an earlier macOS version if manual profile installation is required

### Profile Installation Fails (Other Errors)

If automatic installation fails with other errors:
1. Check that the profile file was created on Desktop/Downloads
2. Double-click `SchoolWhitelist.mobileconfig`
3. Follow the prompts in System Settings
4. Enter admin password when requested

### App Won't Launch

- Ensure you're running macOS 15.4 or later
- Check that the app is properly code signed
- Try building from Xcode to see any error messages

### Profile Not Working

- Verify the profile is installed: `profiles -P` in Terminal
- Check System Settings > Privacy & Security > Profiles
- Ensure Safari is set to "Allowed Websites Only" mode

## Development Notes

### Entitlements

The app requires:
- App Sandbox (enabled)
- User-selected file access (read-write)
- Downloads folder access (read-write)

### Profile Installation Methods

The app attempts installation in this order:
1. Direct installation via `profiles` command with admin privileges (using AppleScript)
2. Fallback to GUI installation (opens the `.mobileconfig` file)

### URL Normalization

URLs are normalized to domain names only:
- Removes `http://` or `https://`
- Removes `www.` prefix
- Removes trailing slashes
- Removes path components
- Converts to lowercase

## License

This project is provided as-is for personal use.

## Support

For issues or questions, please check:
- Xcode console for error messages
- System Settings > Privacy & Security > Profiles
- Terminal: `profiles -P` to list installed profiles


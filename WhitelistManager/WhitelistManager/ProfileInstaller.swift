//
//  ProfileInstaller.swift
//  WhitelistManager
//
//  Handles installation and removal of configuration profiles using Authorization Services
//

import Foundation
import Security
import AppKit
import OSLog

/// Handles privileged operations for installing and removing configuration profiles
class ProfileInstaller {
    static let profileIdentifier = ProfileGenerator.profileIdentifier
    private static let logger = Logger(subsystem: "com.arendsee.WhitelistManager", category: "ProfileInstaller")
    
    /// Installs a configuration profile
    /// Note: macOS no longer allows programmatic profile installation via the profiles command.
    /// This opens the profile file, which macOS will handle via System Settings.
    /// - Parameters:
    ///   - profilePath: Path to the .mobileconfig file
    ///   - completion: Callback with success status and optional error message
    static func installProfile(at profilePath: String, completion: @escaping (Bool, String?) -> Void) {
        // macOS no longer supports programmatic profile installation
        // We must use the GUI method (opening the file opens System Settings)
        logger.info("Opening profile file - macOS will handle installation via System Settings")
        installProfileViaGUI(at: profilePath, completion: completion)
    }
    
    /// Attempts direct installation using the profiles command with admin privileges
    private static func installProfileDirectly(at profilePath: String, completion: @escaping (Bool, String?) -> Void) {
        // Verify file exists
        guard FileManager.default.fileExists(atPath: profilePath) else {
            print("Profile file does not exist at: \(profilePath)")
            completion(false, "Profile file not found")
            return
        }
        
        let command = "/usr/bin/profiles"
        // Modern syntax: profiles -I -F /path/to/profile.mobileconfig
        let arguments = ["-I", "-F", profilePath]
        
        print("Attempting to install profile at: \(profilePath)")
        print("File exists: \(FileManager.default.fileExists(atPath: profilePath))")
        
        executePrivilegedCommand(command: command, arguments: arguments) { success, output, error in
            if success {
                logger.info("Profile installed successfully via profiles command")
                logger.debug("Command output: \(output ?? "none")")
                completion(true, nil)
            } else {
                let errorMsg = error ?? "Failed to install profile"
                logger.error("Direct installation failed: \(errorMsg)")
                logger.debug("Command output: \(output ?? "none")")
                // Include full error details for debugging
                var fullError = errorMsg
                if let output = output, !output.isEmpty {
                    fullError += "\n\nCommand output: \(output)"
                }
                completion(false, fullError)
            }
        }
    }
    
    /// Removes the existing profile if it's installed
    private static func removeExistingProfile(completion: @escaping (Bool) -> Void) {
        removeProfile { success, error in
            completion(success)
        }
    }
    
    /// Public method to remove the profile (for testing/undoing)
    static func removeProfile(completion: @escaping (Bool, String?) -> Void) {
        let command = "/usr/bin/profiles"
        let arguments = ["remove", "-identifier", profileIdentifier]
        
        executePrivilegedCommand(command: command, arguments: arguments) { success, output, error in
            if success {
                completion(true, nil)
            } else {
                // Profile might not exist, which is fine
                let errorMsg = error ?? "Profile may not be installed"
                completion(false, errorMsg)
            }
        }
    }
    
    /// Opens the profile file and System Settings for installation
    private static func installProfileViaGUI(at profilePath: String, completion: @escaping (Bool, String?) -> Void) {
        let fileURL = URL(fileURLWithPath: profilePath)
        
        guard FileManager.default.fileExists(atPath: profilePath) else {
            completion(false, "Profile file not found")
            return
        }
        
        // Open the profile file first (this triggers macOS to show the profile)
        NSWorkspace.shared.open(fileURL)
        
        // Wait a moment for the file to be processed, then open System Settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Try using shell command to open System Settings with URL scheme
            // This sometimes works better than NSWorkspace for URL schemes
            let process = Process()
            process.launchPath = "/usr/bin/open"
            process.arguments = ["x-apple.systempreferences:com.apple.preference.security?Privacy_Profiles"]
            
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus != 0 {
                    // Fallback: try opening System Settings app directly
                    self.logger.debug("URL scheme failed, opening System Settings app directly")
                    if let settingsAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.SystemSettings") {
                        NSWorkspace.shared.open(settingsAppURL)
                    }
                }
            } catch {
                // Fallback: just open System Settings app
                self.logger.debug("Failed to use shell command, opening System Settings app directly")
                if let settingsAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.SystemSettings") {
                    NSWorkspace.shared.open(settingsAppURL)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true, "System Settings should have opened. Click 'Install' in the Profiles section.")
        }
    }
    
    /// Executes a command with admin privileges using AppleScript
    /// Note: In a sandboxed app, Authorization Services won't work, so we use AppleScript
    /// which will prompt for admin credentials via the system dialog.
    private static func executePrivilegedCommand(
        command: String,
        arguments: [String],
        completion: @escaping (Bool, String?, String?) -> Void
    ) {
        // Use AppleScript's "quoted form of" for proper path handling
        // Escape backslashes and quotes for AppleScript string literals
        let escapeForAppleScript = { (str: String) -> String in
            return str.replacingOccurrences(of: "\\", with: "\\\\")
                     .replacingOccurrences(of: "\"", with: "\\\"")
        }
        
        let escapedCommand = escapeForAppleScript(command)
        let escapedArgs = arguments.map { escapeForAppleScript($0) }
        
        // Build AppleScript command using quoted form of for each part
        let commandPart = "quoted form of \"\(escapedCommand)\""
        let argsParts = escapedArgs.map { "quoted form of \"\($0)\"" }
        let allParts = [commandPart] + argsParts
        let commandString = allParts.joined(separator: " & \" \" & ")
        
        let script = """
        do shell script \(commandString) with administrator privileges
        """
        
        logger.info("Executing AppleScript command: \(command) \(arguments.joined(separator: " "))")
        logger.debug("Full script: \(script)")
        
        // Execute AppleScript - this will prompt for admin credentials
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            let result = appleScript.executeAndReturnError(&error)
            
            if error == nil {
                let output = result.stringValue ?? ""
                logger.info("AppleScript execution succeeded")
                completion(true, output.isEmpty ? nil : output, nil)
            } else {
                let errorCode = error?[NSAppleScript.errorNumber] as? Int ?? -1
                let errorMsg = error?[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                let errorBrief = error?[NSAppleScript.errorBriefMessage] as? String
                
                logger.error("AppleScript error \(errorCode): \(errorMsg)")
                logger.debug("Full error dictionary: \(String(describing: error))")
                
                // Error -128 means user cancelled the authentication dialog
                if errorCode == -128 {
                    completion(false, nil, "Authentication cancelled by user")
                } else {
                    // Include error code and brief message if available
                    var detailedError = "Failed to execute with admin privileges"
                    detailedError += "\nError code: \(errorCode)"
                    detailedError += "\nError: \(errorMsg)"
                    if let brief = errorBrief {
                        detailedError += "\nBrief: \(brief)"
                    }
                    completion(false, nil, detailedError)
                }
            }
        } else {
            logger.error("Failed to create AppleScript from source")
            completion(false, nil, "Failed to create AppleScript - invalid script syntax")
        }
    }
    
    /// Checks if the profile is currently installed
    static func isProfileInstalled() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/profiles")
        process.arguments = ["-P"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.contains(profileIdentifier)
            }
        } catch {
            print("Error checking profile status: \(error)")
        }
        
        return false
    }
}


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
    
    /// Installs a configuration profile using Authorization Services
    /// - Parameters:
    ///   - profilePath: Path to the .mobileconfig file
    ///   - completion: Callback with success status and optional error message
    static func installProfile(at profilePath: String, completion: @escaping (Bool, String?) -> Void) {
        // First, try to remove the old profile if it exists
        removeExistingProfile { removed in
            if removed {
                print("Removed existing profile")
            }
            
            // Attempt direct installation using profiles command
            self.installProfileDirectly(at: profilePath) { success, error in
                if success {
                    completion(true, nil)
                } else {
                    // Fallback: open the file and let macOS handle installation
                    self.installProfileViaGUI(at: profilePath) { guiSuccess, guiError in
                        completion(guiSuccess, guiError)
                    }
                }
            }
        }
    }
    
    /// Attempts direct installation using the profiles command with admin privileges
    private static func installProfileDirectly(at profilePath: String, completion: @escaping (Bool, String?) -> Void) {
        let command = "/usr/bin/profiles"
        let arguments = ["install", "-type", "configuration", "-path", profilePath]
        
        print("Attempting to install profile at: \(profilePath)")
        
        executePrivilegedCommand(command: command, arguments: arguments) { success, output, error in
            if success {
                print("Profile installed successfully via profiles command")
                completion(true, nil)
            } else {
                let errorMsg = error ?? "Failed to install profile"
                print("Direct installation failed: \(errorMsg)")
                print("Output: \(output ?? "none")")
                completion(false, errorMsg)
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
    
    /// Fallback method: Opens the profile file, triggering macOS GUI installation
    private static func installProfileViaGUI(at profilePath: String, completion: @escaping (Bool, String?) -> Void) {
        let fileURL = URL(fileURLWithPath: profilePath)
        
        guard FileManager.default.fileExists(atPath: profilePath) else {
            completion(false, "Profile file not found")
            return
        }
        
        // Use open command via AppleScript to trigger System Settings
        // This is more reliable than NSWorkspace for .mobileconfig files
        let script = """
        tell application "System Events"
            open POSIX file "\(profilePath)"
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            
            if error == nil {
                // Also try NSWorkspace as backup
                NSWorkspace.shared.open(fileURL)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(true, "Please complete installation in System Settings")
                }
            } else {
                // Fallback to NSWorkspace
                NSWorkspace.shared.open(fileURL)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(true, "Please complete installation in System Settings")
                }
            }
        } else {
            // Final fallback
            NSWorkspace.shared.open(fileURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(true, "Please complete installation in System Settings")
            }
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
        // Build command with proper quoting for AppleScript
        // Escape each argument properly - need to escape for AppleScript string
        let escapedArgs = arguments.map { arg -> String in
            // Escape backslashes first, then quotes
            let escaped = arg.replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "$", with: "\\$")
            return "\"\(escaped)\""
        }
        let fullCommand = command + " " + escapedArgs.joined(separator: " ")
        
        // Use AppleScript with admin privileges - this will prompt for admin password
        // The AppleEvents entitlement allows us to execute AppleScript
        let script = """
        do shell script "\(fullCommand)" with administrator privileges
        """
        
        // Execute AppleScript - this will prompt for admin credentials
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            let result = appleScript.executeAndReturnError(&error)
            
            if error == nil {
                let output = result.stringValue ?? ""
                print("AppleScript execution succeeded")
                completion(true, output.isEmpty ? nil : output, nil)
            } else {
                let errorCode = error?[NSAppleScript.errorNumber] as? Int ?? -1
                let errorMsg = error?[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                
                print("AppleScript error \(errorCode): \(errorMsg)")
                
                // Error -128 means user cancelled the authentication dialog
                if errorCode == -128 {
                    completion(false, nil, "Authentication cancelled by user")
                } else {
                    completion(false, nil, "Failed to execute with admin privileges: \(errorMsg)")
                }
            }
        } else {
            completion(false, nil, "Failed to create AppleScript")
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


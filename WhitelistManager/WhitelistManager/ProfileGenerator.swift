//
//  ProfileGenerator.swift
//  WhitelistManager
//
//  Generates .mobileconfig files for Safari web content filtering
//

import Foundation

/// Generates macOS configuration profiles (.mobileconfig) for Safari web content filtering
class ProfileGenerator {
    static let profileIdentifier = "com.arendsee.WhitelistManager.SafariWhitelist"
    static let profileDisplayName = "Safari School Whitelist"
    static let profileOrganization = "WhitelistManager"
    
    /// Generates a .mobileconfig file from a list of allowed URLs
    /// - Parameter allowedURLs: Array of domain names (e.g., ["google.com", "khanacademy.org"])
    /// - Returns: Data representation of the .mobileconfig file, or nil on error
    static func generateProfile(allowedURLs: [String]) -> Data? {
        // Validate we have at least one URL
        guard !allowedURLs.isEmpty else {
            return nil
        }
        
        // Create the payload dictionary
        // PermittedURLs should be domain names only (no protocol) on macOS Sequoia
        let permittedURLs = allowedURLs.compactMap { url -> String? in
            var cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanURL.isEmpty else { return nil }
            
            // Remove protocol if present
            if cleanURL.hasPrefix("https://") {
                cleanURL = String(cleanURL.dropFirst(8))
            } else if cleanURL.hasPrefix("http://") {
                cleanURL = String(cleanURL.dropFirst(7))
            }
            // Remove www. prefix if present
            if cleanURL.hasPrefix("www.") {
                cleanURL = String(cleanURL.dropFirst(4))
            }
            // Remove trailing slash
            if cleanURL.hasSuffix("/") {
                cleanURL = String(cleanURL.dropLast())
            }
            // Remove any path components (everything after first /)
            if let slashIndex = cleanURL.firstIndex(of: "/") {
                cleanURL = String(cleanURL[..<slashIndex])
            }
            // Return just the domain name
            return cleanURL.lowercased()
        }
        
        // Ensure we still have URLs after cleaning
        guard !permittedURLs.isEmpty else {
            return nil
        }
        
        // Build payload content
        // Note: Do not include WhitelistedBookmarks if empty - some macOS versions reject empty arrays
        let payloadContent: [String: Any] = [
            "PayloadType": "com.apple.webcontent-filter",
            "PayloadVersion": 1,
            "PayloadIdentifier": "\(profileIdentifier).payload",
            "PayloadUUID": UUID().uuidString,
            "PayloadDisplayName": "Web Content Filter",
            "PayloadDescription": "Restricts Safari to allowed websites only",
            "FilterType": "Whitelist",
            "FilterBrowsers": [1], // Safari only (1 = Safari)
            "PermittedURLs": permittedURLs
        ]
        
        // Create the main payload
        let payload: [String: Any] = [
            "PayloadType": "Configuration",
            "PayloadVersion": 1,
            "PayloadIdentifier": profileIdentifier,
            "PayloadUUID": UUID().uuidString,
            "PayloadDisplayName": profileDisplayName,
            "PayloadDescription": "Safari web content filter restricting access to school-approved websites",
            "PayloadOrganization": profileOrganization,
            "PayloadRemovalDisallowed": false, // Allow profile to be removed
            "PayloadContent": [payloadContent]
        ]
        
        // Convert to plist XML format
        guard let plistData = try? PropertyListSerialization.data(
            fromPropertyList: payload,
            format: .xml,
            options: 0
        ) else {
            return nil
        }
        
        return plistData
    }
    
    /// Saves the generated profile to a file
    /// - Parameters:
    ///   - profileData: The .mobileconfig data
    ///   - filename: Optional filename (defaults to "SchoolWhitelist.mobileconfig")
    /// - Returns: URL of the saved file, or nil on error
    static func saveProfile(profileData: Data, filename: String = "SchoolWhitelist.mobileconfig") -> URL? {
        // Try Desktop first, fall back to Downloads if Desktop access is denied
        var fileURL: URL?
        
        // Try Desktop
        if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let desktopFileURL = desktopURL.appendingPathComponent(filename)
            do {
                try profileData.write(to: desktopFileURL, options: .atomic)
                return desktopFileURL
            } catch {
                print("Failed to save to Desktop: \(error.localizedDescription)")
                // Fall through to Downloads
            }
        }
        
        // Fall back to Downloads folder (we have explicit permission for this)
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let downloadsFileURL = downloadsURL.appendingPathComponent(filename)
            do {
                try profileData.write(to: downloadsFileURL, options: .atomic)
                print("Saved profile to Downloads folder instead of Desktop")
                return downloadsFileURL
            } catch {
                print("Error saving profile to Downloads: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
}


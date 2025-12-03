#!/usr/bin/env swift

import Foundation

// Test different profile formats to find what works
let testDomains = ["google.com"]

// Test 1: Domain names only (current approach)
func generateProfileV1(domains: [String]) -> Data? {
    let payloadContent: [String: Any] = [
        "PayloadType": "com.apple.webcontent-filter",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist.payload",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Web Content Filter",
        "PayloadDescription": "Restricts Safari to allowed websites only",
        "FilterType": "BuiltIn",
        "FilterBrowsers": [1],
        "PermittedURLs": domains
    ]
    
    let payload: [String: Any] = [
        "PayloadType": "Configuration",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Safari School Whitelist",
        "PayloadDescription": "Safari web content filter",
        "PayloadRemovalDisallowed": false,
        "PayloadContent": [payloadContent]
    ]
    
    return try? PropertyListSerialization.data(fromPropertyList: payload, format: .xml, options: 0)
}

// Test 2: With PayloadOrganization
func generateProfileV2(domains: [String]) -> Data? {
    let payloadContent: [String: Any] = [
        "PayloadType": "com.apple.webcontent-filter",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist.payload",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Web Content Filter",
        "PayloadDescription": "Restricts Safari to allowed websites only",
        "FilterType": "BuiltIn",
        "FilterBrowsers": [1],
        "PermittedURLs": domains
    ]
    
    let payload: [String: Any] = [
        "PayloadType": "Configuration",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Safari School Whitelist",
        "PayloadDescription": "Safari web content filter",
        "PayloadOrganization": "WhitelistManager",
        "PayloadRemovalDisallowed": false,
        "PayloadContent": [payloadContent]
    ]
    
    return try? PropertyListSerialization.data(fromPropertyList: payload, format: .xml, options: 0)
}

// Test 3: With WhitelistedBookmarks as empty array
func generateProfileV3(domains: [String]) -> Data? {
    let payloadContent: [String: Any] = [
        "PayloadType": "com.apple.webcontent-filter",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist.payload",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Web Content Filter",
        "PayloadDescription": "Restricts Safari to allowed websites only",
        "FilterType": "BuiltIn",
        "FilterBrowsers": [1],
        "PermittedURLs": domains,
        "WhitelistedBookmarks": []
    ]
    
    let payload: [String: Any] = [
        "PayloadType": "Configuration",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Safari School Whitelist",
        "PayloadDescription": "Safari web content filter",
        "PayloadOrganization": "WhitelistManager",
        "PayloadRemovalDisallowed": false,
        "PayloadContent": [payloadContent]
    ]
    
    return try? PropertyListSerialization.data(fromPropertyList: payload, format: .xml, options: 0)
}

// Test 4: FilterBrowsers as string array instead of int array
func generateProfileV4(domains: [String]) -> Data? {
    let payloadContent: [String: Any] = [
        "PayloadType": "com.apple.webcontent-filter",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist.payload",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Web Content Filter",
        "PayloadDescription": "Restricts Safari to allowed websites only",
        "FilterType": "BuiltIn",
        "FilterBrowsers": ["1"],
        "PermittedURLs": domains
    ]
    
    let payload: [String: Any] = [
        "PayloadType": "Configuration",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Safari School Whitelist",
        "PayloadDescription": "Safari web content filter",
        "PayloadOrganization": "WhitelistManager",
        "PayloadRemovalDisallowed": false,
        "PayloadContent": [payloadContent]
    ]
    
    return try? PropertyListSerialization.data(fromPropertyList: payload, format: .xml, options: 0)
}

// Test 5: FilterType "Whitelist" (original) without FilterBrowsers
func generateProfileV5(domains: [String]) -> Data? {
    let payloadContent: [String: Any] = [
        "PayloadType": "com.apple.webcontent-filter",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist.payload",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Web Content Filter",
        "PayloadDescription": "Restricts Safari to allowed websites only",
        "FilterType": "Whitelist",
        "PermittedURLs": domains
    ]
    
    let payload: [String: Any] = [
        "PayloadType": "Configuration",
        "PayloadVersion": 1,
        "PayloadIdentifier": "com.arendsee.WhitelistManager.SafariWhitelist",
        "PayloadUUID": UUID().uuidString,
        "PayloadDisplayName": "Safari School Whitelist",
        "PayloadDescription": "Safari web content filter",
        "PayloadOrganization": "WhitelistManager",
        "PayloadRemovalDisallowed": false,
        "PayloadContent": [payloadContent]
    ]
    
    return try? PropertyListSerialization.data(fromPropertyList: payload, format: .xml, options: 0)
}

// Generate all test profiles
let profiles = [
    ("test-v1.mobileconfig", generateProfileV1(domains: testDomains)),
    ("test-v2.mobileconfig", generateProfileV2(domains: testDomains)),
    ("test-v3.mobileconfig", generateProfileV3(domains: testDomains)),
    ("test-v4.mobileconfig", generateProfileV4(domains: testDomains)),
    ("test-v5.mobileconfig", generateProfileV5(domains: testDomains))
]

let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

for (filename, profileData) in profiles {
    if let data = profileData {
        let fileURL = downloadsDir.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            print("✓ Generated \(filename)")
            
            // Validate with plutil
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/plutil")
            task.arguments = ["-lint", fileURL.path]
            task.standardOutput = Pipe()
            task.standardError = Pipe()
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                print("  ✓ Valid plist format")
            } else {
                let errorPipe = task.standardError as! Pipe
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                if let errorString = String(data: errorData, encoding: .utf8) {
                    print("  ✗ Invalid: \(errorString.trimmingCharacters(in: .whitespacesAndNewlines))")
                }
            }
        } catch {
            print("✗ Failed to write \(filename): \(error)")
        }
    } else {
        print("✗ Failed to generate \(filename)")
    }
}

print("\nTest profiles generated in Downloads folder.")
print("Try installing each one manually to see which format works.")


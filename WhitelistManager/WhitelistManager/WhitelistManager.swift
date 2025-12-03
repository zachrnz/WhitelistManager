//
//  WhitelistManager.swift
//  WhitelistManager
//
//  Manages the whitelist JSON file storage and retrieval
//

import Foundation

/// Manages the whitelist of allowed URLs stored in Application Support
class WhitelistManager: ObservableObject {
    @Published var allowedURLs: [String] = []
    
    private let whitelistFileName = "whitelist.json"
    private var whitelistURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "com.arendsee.WhitelistManager"
        let appSupportDir = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
        
        return appSupportDir.appendingPathComponent(whitelistFileName)
    }
    
    init() {
        loadWhitelist()
    }
    
    /// Loads the whitelist from the JSON file
    func loadWhitelist() {
        guard FileManager.default.fileExists(atPath: whitelistURL.path) else {
            // Create default whitelist if it doesn't exist
            allowedURLs = []
            saveWhitelist()
            return
        }
        
        guard let data = try? Data(contentsOf: whitelistURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let urls = json["allowed_urls"] as? [String] else {
            allowedURLs = []
            return
        }
        
        allowedURLs = urls
    }
    
    /// Saves the current whitelist to the JSON file
    func saveWhitelist() -> Bool {
        let json: [String: Any] = ["allowed_urls": allowedURLs]
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return false
        }
        
        do {
            try data.write(to: whitelistURL)
            return true
        } catch {
            print("Error saving whitelist: \(error)")
            return false
        }
    }
    
    /// Adds a URL to the whitelist
    func addURL(_ url: String) -> Bool {
        let normalizedURL = normalizeURL(url)
        guard !normalizedURL.isEmpty, !allowedURLs.contains(normalizedURL) else {
            return false
        }
        
        allowedURLs.append(normalizedURL)
        return saveWhitelist()
    }
    
    /// Adds multiple URLs from a pasted string (handles newlines, commas, whitespace)
    func addURLs(from text: String) -> (added: Int, skipped: Int) {
        var addedCount = 0
        var skippedCount = 0
        
        // Parse URLs from text - handle various separators
        let separators = CharacterSet(charactersIn: ",\n\r\t")
        let urlStrings = text.components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for urlString in urlStrings {
            let normalizedURL = normalizeURL(urlString)
            if !normalizedURL.isEmpty && !allowedURLs.contains(normalizedURL) {
                allowedURLs.append(normalizedURL)
                addedCount += 1
            } else {
                skippedCount += 1
            }
        }
        
        if addedCount > 0 {
            _ = saveWhitelist()
        }
        
        return (addedCount, skippedCount)
    }
    
    /// Removes a URL from the whitelist
    func removeURL(at index: Int) -> Bool {
        guard index >= 0 && index < allowedURLs.count else {
            return false
        }
        
        allowedURLs.remove(at: index)
        return saveWhitelist()
    }
    
    /// Removes multiple URLs by their indices (indices must be sorted in descending order)
    func removeURLs(at indices: Set<Int>) -> Bool {
        let sortedIndices = indices.sorted(by: >) // Sort descending to remove from end first
        
        for index in sortedIndices {
            guard index >= 0 && index < allowedURLs.count else {
                continue
            }
            allowedURLs.remove(at: index)
        }
        
        return saveWhitelist()
    }
    
    /// Normalizes a URL string (removes protocol, www, trailing slashes)
    private func normalizeURL(_ url: String) -> String {
        var normalized = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove protocol if present
        if let range = normalized.range(of: "://") {
            normalized = String(normalized[range.upperBound...])
        }
        
        // Remove www. prefix
        if normalized.hasPrefix("www.") {
            normalized = String(normalized.dropFirst(4))
        }
        
        // Remove trailing slash
        if normalized.hasSuffix("/") {
            normalized = String(normalized.dropLast())
        }
        
        // Remove path components (keep only domain)
        if let slashIndex = normalized.firstIndex(of: "/") {
            normalized = String(normalized[..<slashIndex])
        }
        
        return normalized.lowercased()
    }
}


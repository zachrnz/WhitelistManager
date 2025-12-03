//
//  ContentView.swift
//  WhitelistManager
//
//  Main UI for managing Safari URL whitelist
//

import SwiftUI

struct ContentView: View {
    @StateObject private var whitelistManager = WhitelistManager()
    @State private var newURL: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isUpdating = false
    @State private var selectedURLs: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Safari Whitelist Manager")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Manage allowed websites for Safari")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Divider()
            
            // URL Input Section
            VStack(spacing: 8) {
                HStack {
                    TextField("Enter domain or paste multiple URLs", text: $newURL, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...10)
                        .onSubmit {
                            addURLs()
                        }
                    
                    Button(action: addURLs) {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isUpdating)
                }
                
                Text("Tip: Paste multiple URLs separated by commas, newlines, or spaces")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // URL List Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Allowed URLs (\(whitelistManager.allowedURLs.count))")
                        .font(.headline)
                    Spacer()
                    
                    if !selectedURLs.isEmpty {
                        Button(action: selectAll) {
                            Text("Select All")
                        }
                        .buttonStyle(.borderless)
                        
                        Button(action: deselectAll) {
                            Text("Deselect")
                        }
                        .buttonStyle(.borderless)
                        
                        Button(action: deleteSelected) {
                            Label("Delete Selected (\(selectedURLs.count))", systemImage: "trash")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    } else if !whitelistManager.allowedURLs.isEmpty {
                        Button(action: selectAll) {
                            Text("Select All")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.horizontal)
                
                if whitelistManager.allowedURLs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No URLs in whitelist")
                            .foregroundColor(.secondary)
                        Text("Add a URL above to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    List(selection: $selectedURLs) {
                        ForEach(Array(whitelistManager.allowedURLs.enumerated()), id: \.offset) { index, url in
                            HStack {
                                Image(systemName: selectedURLs.contains(index) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedURLs.contains(index) ? .blue : .secondary)
                                    .onTapGesture {
                                        toggleSelection(index)
                                    }
                                Image(systemName: "globe")
                                    .foregroundColor(.blue)
                                Text(url)
                                    .font(.system(.body, design: .monospaced))
                                Spacer()
                                Button(action: {
                                    removeURL(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                                .disabled(isUpdating)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .tag(index)
                        }
                    }
                    .listStyle(.inset)
                    .frame(minHeight: 200)
                    .onChange(of: whitelistManager.allowedURLs.count) { oldCount, newCount in
                        // Adjust selected indices when URLs are added/removed
                        if newCount < oldCount {
                            selectedURLs = selectedURLs.filter { $0 < newCount }
                        }
                    }
                }
            }
            
            Divider()
            
            // Update Button
            Button(action: updateWhitelist) {
                HStack {
                    if isUpdating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, 4)
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                    Text(isUpdating ? "Updating..." : "Update Safari Whitelist")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(whitelistManager.allowedURLs.isEmpty || isUpdating)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(width: 600, height: 600)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addURLs() {
        let inputText = newURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !inputText.isEmpty else {
            return
        }
        
        // Check if it looks like multiple URLs (contains common separators)
        let hasMultipleURLs = inputText.contains(",") || 
                              inputText.contains("\n") || 
                              inputText.contains("\r") ||
                              inputText.components(separatedBy: .whitespaces).count > 1
        
        if hasMultipleURLs {
            // Parse and add multiple URLs
            let result = whitelistManager.addURLs(from: inputText)
            newURL = ""
            
            if result.added > 0 {
                if result.skipped > 0 {
                    showAlert(
                        title: "URLs Added",
                        message: "Added \(result.added) URL(s). \(result.skipped) URL(s) were skipped (duplicates or invalid)."
                    )
                } else {
                    // Don't show alert if all URLs were added successfully
                }
            } else {
                showAlert(
                    title: "No URLs Added",
                    message: "All URLs were skipped (they may already be in the list or invalid)."
                )
            }
        } else {
            // Single URL
            if whitelistManager.addURL(inputText) {
                newURL = ""
            } else {
                showAlert(title: "Error", message: "Failed to add URL. It may already be in the list.")
            }
        }
    }
    
    private func removeURL(at index: Int) {
        guard whitelistManager.removeURL(at: index) else {
            showAlert(title: "Error", message: "Failed to remove URL.")
            return
        }
        // Update selection if needed
        selectedURLs.remove(index)
        // Adjust indices for items after the removed one
        selectedURLs = Set(selectedURLs.compactMap { idx -> Int? in
            if idx > index {
                return idx - 1
            } else if idx == index {
                return nil
            }
            return idx
        })
    }
    
    private func selectAll() {
        selectedURLs = Set(0..<whitelistManager.allowedURLs.count)
    }
    
    private func deselectAll() {
        selectedURLs.removeAll()
    }
    
    private func toggleSelection(_ index: Int) {
        if selectedURLs.contains(index) {
            selectedURLs.remove(index)
        } else {
            selectedURLs.insert(index)
        }
    }
    
    private func deleteSelected() {
        guard !selectedURLs.isEmpty else {
            return
        }
        
        if whitelistManager.removeURLs(at: selectedURLs) {
            selectedURLs.removeAll()
        } else {
            showAlert(title: "Error", message: "Failed to remove some URLs.")
        }
    }
    
    private func updateWhitelist() {
        guard !whitelistManager.allowedURLs.isEmpty else {
            showAlert(title: "No URLs", message: "Please add at least one URL to the whitelist.")
            return
        }
        
        isUpdating = true
        
        // Generate the profile
        guard let profileData = ProfileGenerator.generateProfile(allowedURLs: whitelistManager.allowedURLs) else {
            isUpdating = false
            showAlert(title: "Error", message: "Failed to generate configuration profile.")
            return
        }
        
        // Save the profile to Desktop
        guard let profileURL = ProfileGenerator.saveProfile(profileData: profileData) else {
            isUpdating = false
            showAlert(title: "Error", message: "Failed to save configuration profile.")
            return
        }
        
        // Install the profile
        ProfileInstaller.installProfile(at: profileURL.path) { success, error in
            DispatchQueue.main.async {
                isUpdating = false
                
                if success {
                    if let error = error {
                        // GUI installation fallback
                        showAlert(
                            title: "Profile Ready",
                            message: "The profile has been saved to your Desktop. Please double-click 'SchoolWhitelist.mobileconfig' to install it. You'll be prompted for your admin password."
                        )
                    } else {
                        showAlert(
                            title: "Success",
                            message: "Safari whitelist has been updated successfully!"
                        )
                    }
                } else {
                    showAlert(
                        title: "Installation Failed",
                        message: error ?? "Failed to install profile. The profile has been saved to your Desktop. Please install it manually."
                    )
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    ContentView()
}

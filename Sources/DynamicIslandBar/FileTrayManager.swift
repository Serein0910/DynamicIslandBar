import AppKit
import Combine

/// Manages the file staging area within the Dynamic Island.
/// Handles drag-drop acceptance, file storage, and drag-out operations.
final class FileTrayManager: ObservableObject {

    // MARK: - Published

    /// Currently staged files, newest first
    @Published var stagedFiles: [StagedFile] = []

    /// Whether we are currently accepting drops
    @Published var isDropTarget: Bool = false

    // MARK: - Configuration

    var maximumStagedFiles: Int = 20

    // MARK: - Init

    init() {
        registerForDragDrop()
    }

    // MARK: - File Management

    /// Add files from a drag operation
    /// - Returns: accepted file URLs
    func acceptFiles(_ urls: [URL]) -> [URL] {
        var accepted: [URL] = []

        for url in urls {
            guard stagedFiles.count < maximumStagedFiles else { break }

            // Avoid duplicates
            guard !stagedFiles.contains(where: { $0.url == url }) else { continue }

            let staged = StagedFile(url: url)
            stagedFiles.insert(staged, at: 0)
            accepted.append(url)
        }

        return accepted
    }

    /// Remove a specific file from staging
    func removeFile(_ id: StagedFile.ID) {
        stagedFiles.removeAll { $0.id == id }
    }

    /// Clear all staged files
    func clearAll() {
        stagedFiles.removeAll()
    }

    /// Get the file URLs for drag-out operations
    func fileURLs(for ids: Set<StagedFile.ID>) -> [URL] {
        stagedFiles.filter { ids.contains($0.id) }.map(\.url)
    }

    // MARK: - Drag-Drop Registration

    private func registerForDragDrop() {
        // Registration happens via the SwiftUI .onDrop modifier in FileTrayView
    }
}
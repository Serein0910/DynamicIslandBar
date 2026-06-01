import SwiftUI
import UniformTypeIdentifiers

/// A drop zone that accepts files and displays staged items.
/// Supports drag-in to add, hover preview, and drag-out to use.
struct FileTrayView: View {

    @ObservedObject var fileTrayManager: FileTrayManager
    @State private var isDragOver = false

    private let columns = [
        GridItem(.adaptive(minimum: 56, maximum: 64), spacing: 6)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "File Tray", icon: "tray.full")

            if fileTrayManager.stagedFiles.isEmpty {
                emptyDropZone
            } else {
                fileGrid
            }
        }
    }

    // MARK: - Empty Drop Zone

    private var emptyDropZone: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isDragOver ? Color.accentColor.opacity(0.12) : .quaternary.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isDragOver ? Color.accentColor : .quaternary,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
            .frame(height: 64)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.title3)
                        .foregroundStyle(isDragOver ? .accentColor : .secondary)
                    Text(isDragOver ? "Drop to stage" : "Drag files here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            )
            .onDrop(
                of: [.fileURL],
                isTargeted: $isDragOver
            ) { providers in
                handleDrop(providers: providers)
            }
            .animation(.interactiveSpring(), value: isDragOver)
    }

    // MARK: - File Grid

    private var fileGrid: some View {
        VStack(spacing: 6) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(fileTrayManager.stagedFiles) { file in
                    FileIconView(file: file) {
                        withAnimation(.spring()) {
                            fileTrayManager.removeFile(file.id)
                        }
                    }
                }
            }

            // Bottom bar
            HStack {
                Text("\(fileTrayManager.stagedFiles.count) file(s)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Clear All") {
                    withAnimation(.spring()) {
                        fileTrayManager.clearAll()
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Drop Handling

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var accepted = false

        for provider in providers {
            provider.loadItem(
                forTypeIdentifier: UTType.fileURL.identifier,
                options: nil
            ) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil)
                else { return }

                DispatchQueue.main.async {
                    _ = fileTrayManager.acceptFiles([url])
                }
            }
            accepted = true
        }

        return accepted
    }
}

// MARK: - File Icon View

struct FileIconView: View {
    let file: StagedFile
    let onRemove: () -> Void

    @State private var isHovering = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                if let icon = file.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: "doc.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Text(file.name)
                    .font(.system(size: 8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 56)
            }
            .frame(width: 56, height: 56)
            .background(.quaternary.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
            .onHover { isHovering = $0 }

            // Remove button on hover
            if isHovering {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .background(Circle().fill(.background))
                }
                .buttonStyle(.plain)
                .offset(x: 4, y: -4)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isHovering)
    }
}
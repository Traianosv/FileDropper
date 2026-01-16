import SwiftUI
import UniformTypeIdentifiers
import Cocoa

struct ContentView: View {
    @State private var isExpanded = false
    @State private var droppedFiles: [URL] = []
    @State private var ballPosition: NSPoint = .zero

    var body: some View {
        ZStack {
            if isExpanded {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(width: 400, height: 300)
                        .shadow(color: Color.black.opacity(0.3), radius: 40, x: 0, y: 20)
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                                )
                            VStack(spacing: 8) {
                                Image(systemName: "tray.and.arrow.down.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                                Text("Drop files here")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        if !droppedFiles.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(droppedFiles.prefix(10), id: \.self) { url in
                                        VStack(spacing: 4) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(width: 64, height: 64)
                                                if isImage(url) {
                                                    AsyncImage(url: url) { image in
                                                        image.resizable().scaledToFill().frame(width: 64, height: 64).clipShape(RoundedRectangle(cornerRadius: 8))
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                } else {
                                                    Image(systemName: "doc.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .onDrag {
                                                NSItemProvider(object: url as NSURL)
                                            }
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 10))
                                                .lineLimit(1)
                                                .frame(width: 64)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .frame(height: 90)
                        }
                        HStack(spacing: 12) {
                            Button(action: openFiles) {
                                HStack {
                                    Image(systemName: "folder.badge.plus")
                                    Text("Open from Folder")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.system(size: 14, weight: .medium))
                            }
                            .buttonStyle(.plain)
                            Button(action: airDropFiles) {
                                HStack {
                                    Image(systemName: "airplayaudio")
                                    Text("AirDrop")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.system(size: 14, weight: .medium))
                            }
                            .buttonStyle(.plain)
                        }
                        if !droppedFiles.isEmpty {
                            Button(action: {
                                droppedFiles.removeAll()
                            }) {
                                Text("Clear All")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    .padding(.top, 32)
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isExpanded = false
                                DispatchQueue.main.async {
                                    if let window = NSApp.windows.first {
                                        window.isMovableByWindowBackground = true
                                    }
                                    positionForCollapse()
                                }
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                                .padding(.top, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                    return true
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if !isExpanded {
                    if let window = NSApp.windows.first {
                        ballPosition = window.frame.origin
                    }
                }
                isExpanded.toggle()
                DispatchQueue.main.async {
                    if let window = NSApp.windows.first {
                        window.isMovableByWindowBackground = !isExpanded
                    }
                    if isExpanded {
                        positionForExpansion()
                    } else {
                        positionForCollapse()
                    }
                }
                if isExpanded {
                    playSound()
                }
            }
        }
        .onAppear {
            positionWindow()
        }
    }

    private func positionWindow() {
        if let window = NSApp.windows.first {
            if let screen = NSScreen.main {
                let frame = screen.frame
                window.setFrameOrigin(NSPoint(x: frame.width - 60, y: frame.height / 2 - 25))
                window.setContentSize(NSSize(width: 50, height: 50))
            }
            window.styleMask = [.borderless]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.level = .floating
            window.isMovableByWindowBackground = true
        }
    }

    private func positionForExpansion() {
        if let window = NSApp.windows.first, let screen = NSScreen.main {
            let screenFrame = screen.frame
            let newSize = NSSize(width: 400, height: 300)
            var newOrigin = window.frame.origin

            // Adjust x to keep the window within screen bounds
            let rightEdge = newOrigin.x + 400
            if rightEdge > screenFrame.width {
                newOrigin.x = screenFrame.width - 400
            }
            if newOrigin.x < 0 {
                newOrigin.x = 0
            }

            // Adjust y to keep the window within screen bounds
            let bottomEdge = newOrigin.y + 300
            if bottomEdge > screenFrame.height {
                newOrigin.y = screenFrame.height - 300
            }
            if newOrigin.y < 0 {
                newOrigin.y = 0
            }

            window.setFrame(NSRect(origin: newOrigin, size: newSize), display: true, animate: true)
        }
    }

    private func positionForCollapse() {
        if let window = NSApp.windows.first {
            window.setFrame(NSRect(origin: ballPosition, size: NSSize(width: 50, height: 50)), display: true, animate: true)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier as String, options: nil) { item, error in
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        droppedFiles.append(url)
                    }
                }
            }
        }
        return true
    }

    private func openFiles() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = true
        openPanel.begin { response in
            if response == .OK {
                DispatchQueue.main.async {
                    droppedFiles.append(contentsOf: openPanel.urls)
                }
            }
        }
    }

    private func copyFiles() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                for file in droppedFiles {
                    let destination = url.appendingPathComponent(file.lastPathComponent)
                    do {
                        try FileManager.default.copyItem(at: file, to: destination)
                    } catch {
                        print("Error copying file: \(error)")
                    }
                }
                DispatchQueue.main.async {
                    droppedFiles.removeAll()
                }
            }
        }
    }

    private func airDropFiles() {
        let sharingService = NSSharingService(named: .sendViaAirDrop)
        sharingService?.perform(withItems: droppedFiles)
        DispatchQueue.main.async {
            droppedFiles.removeAll()
        }
    }

    private func playSound() {
        NSSound(named: "Blow")?.play()
    }

    private func isImage(_ url: URL) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "tiff", "bmp", "heic"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
}
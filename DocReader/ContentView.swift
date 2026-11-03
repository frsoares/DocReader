//
//  ContentView.swift
//  DocReader
//
//  Created by Francisco on 31/10/26.
//

import QuickLook
import SwiftUI

struct ContentView: View {
    let document: DocReaderDocument

    @State private var previewURL: URL?

    var body: some View {
        Group {
            if let importError = document.importError {
                DocumentErrorView(error: importError)
            } else if document.content.characters.isEmpty {
                ContentUnavailableView(
                    "Empty Document",
                    systemImage: "doc.text",
                    description: Text("This Word document contains no readable text.")
                )
            } else {
                DocumentReadingView(content: document.content)
            }
        }
        .navigationTitle(document.fileURL?.deletingPathExtension().lastPathComponent ?? "Document")
        .toolbar {
            ToolbarItem {
                Button("Preview Original", systemImage: "doc.richtext") {
                    previewURL = document.fileURL
                }
                .disabled(document.fileURL == nil)
                .accessibilityHint("Opens the original Word document with Quick Look")
            }
        }
        .quickLookPreview($previewURL)
    }
}

private struct DocumentReadingView: View {
    let content: AttributedString

    var body: some View {
        ScrollView {
            Text(content)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(.background)
    }
}

private struct DocumentErrorView: View {
    let error: WordDocumentImportError

    var body: some View {
        ContentUnavailableView(
            "Unable to Read Document",
            systemImage: "doc.badge.ellipsis",
            description: Text(error.message)
        )
    }
}

#Preview {
    ContentView(document: DocReaderDocument())
}

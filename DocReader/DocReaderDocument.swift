//
//  DocReaderDocument.swift
//  DocReader
//
//  Created by Francisco on 31/10/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class DocReaderDocument: ReadableDocument {
    static let readableContentTypes: [UTType] = [.legacyWordDocument]

    private(set) var content = AttributedString()
    private(set) var importError: WordDocumentImportError?

    let fileURL: URL?

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL
    }

    nonisolated func reader(
        configuration: sending ReadConfiguration
    ) -> sending FileWrapperDocumentReader<WordDocumentSnapshot> {
        FileWrapperDocumentReader(configuration) { fileWrapper in
            guard let data = fileWrapper.regularFileContents else {
                return .failure(.notARegularFile)
            }

            return WordDocumentDecoder.decode(data)
        }
    }

    @MainActor
    func apply(
        snapshot: sending WordDocumentSnapshot,
        previous: sending WordDocumentSnapshot?
    ) async throws {
        content = snapshot.content
        importError = snapshot.importError
    }
}

struct WordDocumentSnapshot: Sendable {
    let content: AttributedString
    let importError: WordDocumentImportError?

    nonisolated static func success(_ content: AttributedString) -> Self {
        Self(content: content, importError: nil)
    }

    nonisolated static func failure(_ error: WordDocumentImportError) -> Self {
        Self(content: AttributedString(), importError: error)
    }
}

enum WordDocumentImportError: Error, Equatable, Sendable {
    case emptyDocument
    case notARegularFile
    case nativeReadingUnavailable
    case unsupportedOrCorrupt

    var message: LocalizedStringResource {
        switch self {
        case .emptyDocument:
            "This Word document is empty."
        case .notARegularFile:
            "This item is not a readable Word document."
        case .nativeReadingUnavailable:
            "Simplified text extraction is unavailable on this device. Use Preview Original to read the document."
        case .unsupportedOrCorrupt:
            "This Word document is damaged, encrypted, or uses unsupported features."
        }
    }
}

enum WordDocumentDecoder {
    nonisolated static func decode(_ data: Data) -> WordDocumentSnapshot {
        guard !data.isEmpty else {
            return .failure(.emptyDocument)
        }

#if os(macOS)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.docFormat
        ]

        do {
            let imported = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )
            return .success(AttributedString(imported))
        } catch {
            return .failure(.unsupportedOrCorrupt)
        }
#else
        return .failure(.nativeReadingUnavailable)
#endif
    }
}

extension UTType {
    static let legacyWordDocument = UTType(importedAs: "com.microsoft.word.doc")
}

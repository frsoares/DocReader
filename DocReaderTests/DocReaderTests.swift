//
//  DocReaderTests.swift
//  DocReaderTests
//
//  Created by Francisco on 31/10/26.
//

import Foundation
import Testing
#if os(macOS)
import AppKit
#endif
@testable import DocReader

struct DocReaderTests {
#if os(macOS)
    @Test @MainActor
    func decodesLegacyWordDocument() throws {
        let source = NSAttributedString(
            string: "Legacy Word content",
            attributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)]
        )
        let data = try #require(
            source.docFormat(
                from: NSRange(location: 0, length: source.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.docFormat]
            )
        )

        let snapshot = WordDocumentDecoder.decode(data)

        #expect(snapshot.importError == nil)
        #expect(String(snapshot.content.characters).contains("Legacy Word content"))
    }
#endif

    @Test @MainActor
    func rejectsEmptyDocument() {
        let snapshot = WordDocumentDecoder.decode(Data())

        #expect(snapshot.importError == .emptyDocument)
        #expect(snapshot.content.characters.isEmpty)
    }

    @Test @MainActor
    func handlesInvalidDocument() {
        let snapshot = WordDocumentDecoder.decode(Data("not a Word file".utf8))

#if os(macOS)
        #expect(snapshot.importError == .unsupportedOrCorrupt)
#else
        #expect(snapshot.importError == .nativeReadingUnavailable)
#endif
        #expect(snapshot.content.characters.isEmpty)
    }

    @Test @MainActor
    func preservesOriginalFileURL() {
        let url = URL(fileURLWithPath: "/tmp/example.doc")
        let document = DocReaderDocument(fileURL: url)

        #expect(document.fileURL == url)
    }
}

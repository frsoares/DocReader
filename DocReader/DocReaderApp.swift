//
//  DocReaderApp.swift
//  DocReader
//
//  Created by Francisco on 31/10/26.
//

import SwiftUI

@main
struct DocReaderApp: App {
    var body: some Scene {
        DocumentGroup { document in
            ContentView(document: document)
        } makeReadableDocument: { configuration, _ in
            DocReaderDocument(fileURL: configuration.fileURL)
        }
    }
}

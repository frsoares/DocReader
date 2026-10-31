//
//  ContentView.swift
//  DocReader
//
//  Created by Francisco on 31/10/26.
//

import SwiftUI

struct ContentView: View {
    @Bindable var document: DocReaderDocument
    @Environment(\.undoManager) private var undoManager

    var body: some View {
        TextEditor(text: $document.text)
            .onChange(of: document.text) { oldValue, _ in
                undoManager?.registerUndo(withTarget: document) { document in
                    document.text = oldValue
                }
            }
            .font(.system(size: 16, weight: .regular, design: .monospaced))
    }
}

#Preview {
    ContentView(document: DocReaderDocument())
}

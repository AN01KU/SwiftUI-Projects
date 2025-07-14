//
//  NewMovieFormView.swift
//  Watchlist
//
//  Created by Ankush Ganesh on 05/07/25.
//

import SwiftUI

struct NewMovieFormView: View {
    // MARK: - PROPERTIES
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dimiss
    
    @State private var title: String = ""
    @State private var selectedGenre: Genre = .kids
    
    // MARK: - FUNCTIONS
    func addNewMovie() {
        let newMovie = Movie(title: title, genre: selectedGenre)
        modelContext.insert(newMovie)
        title = ""
        selectedGenre = .kids
    }
    
    var body: some View {
        Form {
            List {
                // MARK: - HEADER
                Text("What to Watch")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.blue.gradient)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                
                // MARK: - TITLE
                TextField("Move Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(.largeTitle.weight(.light))
                
                // MARK: - GENRE
                Picker("Genre", selection: $selectedGenre) {
                    ForEach(Genre.allCases) { genre in
                        Text(genre.name)
                            .tag(genre)
                    }
                }
                
                // MARK: - SAVE BUTTON
                Button {
                    if title.isEmpty || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        print("Title is empty")
                        return
                    } else {
                        print("Valid Title: \(title) - \(selectedGenre)")
                        addNewMovie()
                        dimiss()
                    }
                } label: {
                    Text("Save")
                        .font(.title2.weight(.medium))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
                .buttonBorderShape(.roundedRectangle)
                .disabled(title.isEmpty || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                // MARK: - CANCEL BUTTON
                Button {
                    dimiss()
                } label: {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                }
            } //: List
            
        } //: Form
    }
}

#Preview {
    NewMovieFormView()
}

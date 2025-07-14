//
//  ContentView.swift
//  Watchlist
//
//  Created by Ankush Ganesh on 03/07/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - PROPERTIES
    
    @Environment(\.modelContext) private var modelContext
    @Query private var movies: [Movie]

    @State private var isSheetPresented: Bool = false
    @State private var randomMovie: String = ""
    @State private var isShowingAlert: Bool = false
    
    // MARK: - FUNCTIONS
    func randomMovieGenerator() {
        randomMovie = movies.randomElement()!.title
    }
    
    var body: some View {
        List {
            if !movies.isEmpty {
                Section(
                    header:
                        VStack {
                            Text("WatchList")
                                .font(.title.weight(.black))
                                .foregroundStyle(.blue.gradient)
                                .padding()
                            
                            HStack {
                                Label("Title", systemImage: "movieclapper")
                                
                                Spacer()
                                
                                Label("Genre", systemImage: "tag")
                            }
                        }
                ) {
                    ForEach(movies) { movie in
                        HStack {
                            Text(movie.title)
                                .font(.title.weight(.light))
                                .padding(.vertical, 2)
                            
                            Spacer()
                            
                            Text(movie.genre.name)
                                .font(.footnote.weight(.medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .stroke(lineWidth: 1)
                                )
                                .foregroundStyle(.tertiary)
                        } //: List Row
                        .swipeActions {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(movie)
                                }
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        } //: List
        .overlay {
            if movies.isEmpty {
                EmptyListView()
            }
        }
        //MARK: - SAFE AREA
        .safeAreaInset(edge: .bottom, alignment: .center) {
            // NEW MOVIE BUTTON
            HStack {
                if movies.count >= 2 {
                    // RANDOMISE BUTTON
                    Button {
                        randomMovieGenerator()
                        isShowingAlert = true
                    } label: {
                        ButtonImageView(symbolName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                    }
                    .alert(randomMovie, isPresented: $isShowingAlert) {
                        Button("Ok", role: .cancel) {}
                    }
                    .accessibilityLabel("Random Movie")
                    .sensoryFeedback(.success, trigger: isShowingAlert)
                    
                    Spacer()
                }
                
                Button {
                    isSheetPresented.toggle()
                } label: {
                    ButtonImageView(symbolName: "plus.circle.fill")
                }
                .accessibilityLabel("New Movie")
                .sensoryFeedback(.success, trigger: isSheetPresented)
            }
            .padding(.horizontal)
        } //: Safe Area
        // MARK: - SHEET
        .sheet(isPresented: $isSheetPresented) {
            NewMovieFormView()
        }
    }
}

#Preview ("Dummy Data") {
    ContentView()
        .modelContainer(Movie.preview)
}

#Preview ("Empty List") {
    ContentView()
        .modelContainer(for: Movie.self, inMemory: true)
}

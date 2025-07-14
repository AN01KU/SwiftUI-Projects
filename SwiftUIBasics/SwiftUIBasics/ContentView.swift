//
//  ContentView.swift
//  HelloWorld
//
//  Created by Ankush Ganesh on 02/06/25.
//

import SwiftUI

extension Image {
    func imageModifier() -> some View {
        self
            .resizable()
            .scaledToFit()
    }
    
    func iconModifier() -> some View {
        self
            .imageModifier()
            .frame(maxWidth: 128)
            .foregroundColor(.purple)
            .opacity(0.5)
            
    }
}

struct ContentView: View {
    
    private let imageURL: String = "https://credo.academy/credo-academy@3x.png"
    
    var body: some View {
//        VStack {
//            Link("Apple", destination: URL(string: "https://apple.com")!)
//                .buttonStyle(.bordered)
//                .buttonBorderShape(.capsule)
//        }
//        VStack {
//            Text("Grad")
//                .font(.system(size: 150))
//                .fontWeight(.black)
//                .foregroundStyle(
//                    LinearGradient(
//                        colors: [.green, .white, .blue],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing)
//                )
//        }
//        .padding()
        
        //MARK: BASIC
//        AsyncImage(url: URL(string: imageURL))
        //MARK: SCALE
//        AsyncImage(url: URL(string: imageURL), scale: 3.0)
        //MARK: PLACEHOLDER
//        AsyncImage(url: URL(string: imageURL)) { image in
//            image.imageModifier()
//        } placeholder: {
//            Image(systemName: "photo.circle.fill").iconModifier(
//        } .padding(40)
        //MARK: PHASE
//        AsyncImage(url: URL(string: imageURL)) { phase in
//            if let image = phase.image {
//                image.imageModifier()
//            } else if phase.error != nil {
//                Image(systemName: "ant.circle.fill").iconModifier()
//            } else {
//                Image(systemName: "photo.circle.fill").iconModifier()
//            }
//        }
//        .padding(40)
        //MARK: ANIMATION
        AsyncImage(url: URL(string: imageURL), transaction: Transaction(animation: .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.25))) { phase in
            switch phase {
            case .empty:
                Image(systemName: "photo.circle.fill").iconModifier()
            case .success(let image):
                image
                    .imageModifier()
                    .transition(.move(edge: .bottom))
            case .failure(_):
                Image(systemName: "ant.circle.fill").iconModifier()
            @unknown default:
                ProgressView()
            }
        }
        .padding(40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}

//
//  CardView.swift
//  Hike
//
//  Created by Ankush Ganesh on 08/06/25.
//

import SwiftUI

struct CardView: View {
    //MARK: - PROPERTIES
    
    @State private var imageNumber: Int = 1
    @State private var randomNumber: Int = 1
    @State private var isShowingSheet: Bool = false
    
    //MARK: - FUNCTIONS
    
    func randomImage() {
//        print("--- BUTTON WAS PRESSED ---")
//        print("Status: Old Image Number = \(imageNumber)")
        repeat {
            randomNumber = Int.random(in: 1 ... 5)
//            print("Action: Random Image Generated = \(randomNumber)")
        } while randomNumber == imageNumber
        imageNumber = randomNumber
        
//        print("Result: New Image Number = \(imageNumber)")
//        print("--- THE END ---")
//        print("\n")
    }
    
    var body: some View {
        // MARK: - Card
        
        ZStack {
            
            CustomBackgroundView()
            
            VStack {
                //MARK: - HEADER
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Hiking")
                            .fontWeight(.black)
                            .font(.system(size: 52))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [  .customGrayLight, .customGrayMedium ],
                                    startPoint: .top,
                                    endPoint: .bottom)
                            )
                        
                        Spacer()
                        
                        Button {
                            // ACTION: Show a Sheet
//                            print("The button was pressed.")
                            isShowingSheet.toggle()
                        } label: {
                            CustomButtonView()
                        }
                        .sheet(isPresented: $isShowingSheet) {
                            SettingsView()
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.medium, .large])
                        }
                    }
                    
                    Text("Fun and enjoyable outdoor activity for friends and families.")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .foregroundStyle(.colorGrayMedium)
                } //: HEADER
                .padding(.horizontal, 30)
                
                //MARK: - MAIN CONTENT
                
                ZStack {
                    CustomCircleView()
                    
                    Image("image-\(imageNumber)")
                        .resizable()
                        .scaledToFit()
                        .animation(.default, value: imageNumber)
                }
                
                //MARK: - FOOTER
                
                Button {
                    // ACTION: Generate a random number
//                    print("The button was pressed")
                    randomImage()
                } label: {
                    Text("Explore More")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .customGreenLight,
                                    .customGreenMedium],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 0.25, x: 1, y: 2)
                }
                .buttonStyle(GradientButton())
            }
        }
        
        //: CARD
        .frame(width: 320, height: 570)
    }
}

#Preview {
    CardView()
}

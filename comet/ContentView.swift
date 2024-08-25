//
//  ContentView.swift
//  comet
//
//  Created by Maya Lekhi on 2024-08-21.
//
import SwiftUI

extension Color {
    static let customBackground = Color(red: 184 / 255.0, green: 185 / 255.0, blue: 236 / 255.0)
}

struct ContentView: View {
    @State private var isWagging = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Image("background-landing") // Replace "backgroundImageName" with the name of your image asset
                    .resizable() // Make the image resizable
                    .scaledToFill() // Scale the image to fill the view
                    .edgesIgnoringSafeArea(.all) // Makes sure the image covers the entire screen

                VStack {
                    // Title and Description
                    Image("header")
                        .resizable() // Allows resizing
                        .scaledToFit() // Scales the image to fit the container while preserving aspect ratio
                        .frame(width: 275, height: 200) // Adjust size as needed
                        .clipShape(Rectangle()) // Crop to a rectangle

                    // Start Button
                    NavigationLink(destination: GameplayView()) {
                        VStack {
                            Image(isWagging ? "dog-wag" : "dog")
                                .resizable() // Allows resizing
                                .scaledToFit() // Scales the image to fit the container while preserving aspect ratio
                                .frame(width: 200, height: 200) // Adjust size as needed
                                .padding()
                                .onAppear {
                                    // Timer to alternate between images
                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                                        isWagging.toggle()
                                    }
                                }

                            Image("tap")
                                .resizable() // Allows resizing
                                .scaledToFit() // Scales the image to fit the container while preserving aspect ratio
                                .frame(width: 200, height: 100
                                ) // Adjust size as needed
                                .clipShape(Rectangle()) // Crop to a rectangle
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

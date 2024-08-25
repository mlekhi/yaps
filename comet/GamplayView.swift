//
//  GamplayView.swift
//  comet
//
//  Created by Maya Lekhi on 2024-08-21.
//

import SwiftUI
import SpriteKit

struct GameplayView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        SpriteView(scene: makeGameplayScene())
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true) // Hide the back button
    }

    private func makeGameplayScene() -> SKScene {
        let scene = Gameplay(size: UIScreen.main.bounds.size)
        scene.homeButtonCallback = {
            // Pop the current view from the navigation stack to go back to ContentView
            self.presentationMode.wrappedValue.dismiss()
        }
        return scene
    }
}

//
//  Final_Project_MoLabApp.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 11/30/23.
//

import SwiftUI

struct DiceViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DiceViewController {
        return DiceViewController()
    }

    func updateUIViewController(_ uiViewController: DiceViewController, context: Context) {
        // You can add any necessary update logic here
    }
}

@main
struct Final_Project_MoLabApp: App {
    var body: some Scene {
        WindowGroup {
            DiceViewControllerWrapper()
        }
    }
}



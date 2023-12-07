//
//  Final_Project_MoLabApp.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 11/30/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TabView {
                NavigationView {
                    MineMapViewControllerWrapper()
                }
                .tabItem {
                    Label("Mine Map", systemImage: "map")
                }

                NavigationView {
                    DiceViewControllerWrapper()
                }
                .tabItem {
                    Label("Roll Dice", systemImage: "die.face.5")
                }
            }
            .navigationBarTitle("Game Selection")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MineMapViewControllerWrapper: View {
    var body: some View {
        MineMapViewControllerRepresentable()
    }
}

struct DiceViewControllerWrapper: View {
    var body: some View {
        DiceViewControllerRepresentable()
    }
}

struct ContentViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIHostingController<ContentView> {
        UIHostingController(rootView: ContentView())
    }

    func updateUIViewController(_ uiViewController: UIHostingController<ContentView>, context: Context) {
        // You can add any necessary update logic here
    }
}

@main
struct Final_Project_MoLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
        }
    }
}

struct MineMapViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MineMapViewController {
        return MineMapViewController()
    }

    func updateUIViewController(_ uiViewController: MineMapViewController, context: Context) {
        // You can add any necessary update logic here
    }
}

struct DiceViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DiceViewController {
        return DiceViewController()
    }

    func updateUIViewController(_ uiViewController: DiceViewController, context: Context) {
        // You can add any necessary update logic here
    }
}




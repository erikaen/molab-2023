//
//  Final_Project_MoLabApp.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 11/30/23.
//

import SwiftUI
import Combine

class DiceRollState: ObservableObject {
    @Published var diceRollResult: Int = 0
}

struct ContentView: View {
    @EnvironmentObject var diceRollState: DiceRollState
    @EnvironmentObject var diceViewController: DiceViewController // Use the shared instance
    @State private var selectedTab = 0
    @State private var showingGameTour = false
    
    var body: some View {
        NavigationView {
            TabView {
                NavigationView {
                    MineMapViewControllerWrapper()
                                            .environmentObject(diceViewController) // Pass the diceViewController
                                            .onAppear { selectedTab = 1 }
                }
                .tabItem {
                    Label("Mine Map", systemImage: "map")
                }
                .tag(1)
                
                NavigationView {
                    DiceViewControllerWrapper()
                                          .environmentObject(diceViewController) // Pass the diceViewController
                                          .onAppear { selectedTab = 0 }
                }
                .tabItem {
                    Label("Roll Dice", systemImage: "die.face.5")
                }
                .tag(0)
            }
            .navigationBarTitle("Game Selection")
            .accentColor(selectedTab == 0 ? .black : .white)
            .navigationBarItems(trailing: Button(action: {
                            showingGameTour = true
                        }) {
                            Image(systemName: "questionmark.circle")
                        })
                        .sheet(isPresented: $showingGameTour) {
                            GameTourView()
                        }
        }
        .environmentObject(diceRollState)
        .environmentObject(diceViewController)
    }
}

struct GameTourView: View {
    var body: some View {
        Text("Welcome to the Game!\n\n1. Roll the dice first to get the number of steps.\n2. Move on the blind mine map according to your steps.\n3. Avoid stepping on bombs.\n4. If you never step on a bomb and finish your steps, you win.\n5. If you step on a bomb before finishing your steps, you lose.\n6. Once the game is over, the mine map will reveal bomb locations.")
            .padding()
            .multilineTextAlignment(.leading)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MineMapViewControllerWrapper: View {
    @EnvironmentObject var diceRollState: DiceRollState 
    var body: some View {
        MineMapViewControllerRepresentable()
            .environmentObject(diceRollState) // Pass the environment object
    }
}

struct DiceViewControllerWrapper: View {
    @EnvironmentObject var diceViewController: DiceViewController

    var body: some View {
        DiceViewControllerRepresentable() // No need to create a new instance
    }
}


struct ContentViewWrapper: UIViewControllerRepresentable {
    let diceRollState: DiceRollState

    init(diceRollState: DiceRollState) {
        self.diceRollState = diceRollState
    }

    func makeUIViewController(context: Context) -> UIHostingController<AnyView> {
        let contentView = ContentView().environmentObject(diceRollState)
        return UIHostingController(rootView: AnyView(contentView))
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<AnyView>, context: Context) {
    }
}





@main
struct Final_Project_MoLabApp: App {
    @StateObject var diceRollState = DiceRollState()
    @StateObject var diceViewController = DiceViewController(diceRollState: DiceRollState())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diceRollState)
                .environmentObject(diceViewController) // Pass the shared diceViewController
        }
    }
}

struct MineMapViewControllerRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var diceRollState: DiceRollState
    @EnvironmentObject var diceViewController: DiceViewController
    
    func makeUIViewController(context: Context) -> MineMapViewController {
        let controller = MineMapViewController(diceRollState: diceRollState)
        controller.diceViewController = diceViewController
        diceViewController.delegate = controller
        return controller
    }

    func updateUIViewController(_ uiViewController: MineMapViewController, context: Context) {
        // Update logic here if needed
    }
}


struct DiceViewControllerRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var diceRollState: DiceRollState
    @EnvironmentObject var diceViewController: DiceViewController

    func makeUIViewController(context: Context) -> DiceViewController {
        return diceViewController // Use the shared instance
    }

    func updateUIViewController(_ uiViewController: DiceViewController, context: Context) {
        // You can add any necessary update logic here
    }
}



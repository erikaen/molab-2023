//
//  ContentView.swift
//  Week 05 Storage and App
//
//  Created by 项一诺 on 10/12/23.
//

import SwiftUI
import AVFoundation


struct Song: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let fileName: String
    let imageName: String
}

struct User {
    var favorites: Set<UUID> = []
}

let songs: [Song] = [
    Song(title: "Kitten Eating", fileName: "cat-eating-dry-food-133130", imageName: "kitten-and-pizza"),
    Song(title: "Kitten Purring", fileName: "cat-purr-6164", imageName: "kittencute"),
    Song(title: "Kitten Meowing", fileName: "cats-meow-81221", imageName: "cutekitten"),
    // Add more songs as needed
]

struct ContentView: View {
    @StateObject var audioPlayerManager = AudioPlayerManager()
    @State private var user = User()

    var body: some View {
        TabView {
            ForEach(songs) { song in
                NavigationView {
                    PlayerView(song: song, isFavorite: user.favorites.contains(song.id)) {
                        if user.favorites.contains(song.id) {
                            user.favorites.remove(song.id)
                        } else {
                            user.favorites.insert(song.id)
                        }
                    }
                    .environmentObject(audioPlayerManager)
                }
                .tabItem {
                    Text(song.title)
                    Image(systemName: "circle")
                }
            }
            
            // Favorites Tab
            NavigationView {
                FavoritesView(songs: songs, user: $user)
            }
            .tabItem {
                Text("Favorites")
                Image(systemName: "star.fill")
            }
        }
        .onAppear {
            // Count and print the number of favorites
            print("Number of Favorites: \(user.favorites.count)")
        }
        .environmentObject(audioPlayerManager) // Provide the AudioPlayerManager to the ContentView
    }
}


struct PlayerView: View {
    let song: Song
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    @State private var isPlaying = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    var isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        VStack {
            Text("\n")
            Text("Now Playing:")
                .font(.title2)
                .padding(4)
            Text(song.title)
                .font(.title)
                .fontWeight(.bold)

            Image(song.imageName)
                .resizable()
                .cornerRadius(10)
                .aspectRatio(contentMode: .fit)
                .padding(.all)

            Button(action: {
                if isPlaying {
                    audioPlayerManager.stopAudio()
                    stopTimer()
                } else {
                    audioPlayerManager.playAudio(fileName: song.fileName)
                    startTimer()
                }
                isPlaying.toggle()
            }) {
                Text(isPlaying ? "Stop Kitten" : "Play Kitten")
                    .font(.title)
            }
            
            Button(action: {
                toggleFavorite()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title)
                    .foregroundColor(isFavorite ? .red : .gray)
            }

            Spacer()

            Text(timeFormatted(elapsedTime))
                .fontWeight(.semibold)
                .onAppear {
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }
        }
        .navigationBarTitle("Kitten ASMR", displayMode: .inline)
        .onAppear {
            if audioPlayerManager.selectedSong != song {
                audioPlayerManager.stopAudio()
                stopTimer()
                isPlaying = false
                audioPlayerManager.selectedSong = nil
                elapsedTime = 0 // Reset the timer
            }
        }
        .onChange(of: audioPlayerManager.selectedSong) { _ in
            if audioPlayerManager.selectedSong != song {
                isPlaying = false
                elapsedTime = 0 // Reset the timer
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let player = audioPlayerManager.audioPlayer {
                elapsedTime = player.currentTime
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timeFormatted(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct FavoritesView: View {
    let songs: [Song]
    @Binding var user: User

    var body: some View {
        List {
            ForEach(songs.filter { user.favorites.contains($0.id) }) { song in
                NavigationLink(destination: PlayerView(song: song, isFavorite: true, toggleFavorite: { })) {
                    Text(song.title)
                }
            }
        }
        .navigationBarTitle("Favorites")
        .navigationBarItems(trailing: Text("Count: \(user.favorites.count)"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AudioPlayerManager: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?
    @Published var selectedSong: Song?

    func playAudio(fileName: String) {
        if let player = loadBundleAudio(fileName) {
            audioPlayer = player
            audioPlayer?.play()
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        selectedSong = nil
    }

    func loadBundleAudio(_ fileName: String) -> AVAudioPlayer? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                return try AVAudioPlayer(contentsOf: url)
            } catch {
                print("loadBundleAudio error", error)
            }
        }
        return nil
    }
}



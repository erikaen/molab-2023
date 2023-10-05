//
//  ContentView.swift
//  Week 04
//
//  Created by 项一诺 on 10/4/23.
//

import SwiftUI
import AVFoundation

struct Song: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let fileName: String
    let imageName: String
}

let songs: [Song] = [
    Song(title: "Kitten Eating", fileName: "cat-eating-dry-food-133130", imageName: "kitten-and-pizza"),
    Song(title: "Kitten Purring", fileName: "cat-purr-6164", imageName: "kittencute"),
    Song(title: "Kitten Meowing", fileName: "cats-meow-81221", imageName: "cutekitten"),
    // Add more songs as needed
]

struct ContentView: View {
    @StateObject var audioPlayerManager = AudioPlayerManager()
    
    var body: some View {
        TabView {
            ForEach(songs) { song in
                NavigationView {
                    PlayerView(song: song)
                        .environmentObject(audioPlayerManager)
                }
                .tabItem {
                    Text(song.title)
                    Image(systemName: "circle")
                }
            }
        }
    }
}

struct PlayerView: View {
    let song: Song
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    @State private var isPlaying = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
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


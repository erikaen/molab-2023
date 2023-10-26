//
//  ContentView.swift
//  Week 07 Files
//
//  Created by 项一诺 on 10/26/23.
//

import SwiftUI
import PhotosUI
import AVFoundation

//RESOURCE:
//ImagePicker Controller: https://www.hackingwithswift.com/read/10/4/importing-photos-with-uiimagepickercontroller
//onChange():https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-some-code-when-state-changes-using-onchange

struct Song: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let fileName: String?
    let imageName: String
    let image: UIImage?
}


struct User {
    var favorites: Set<UUID> = []
}


struct ContentView: View {
    @StateObject var audioPlayerManager = AudioPlayerManager()
    @State private var user = User()
    @State private var songs: [Song] = [
        Song(title: "Kitten Eating", fileName: nil, imageName: "", image: UIImage(named: "kitten-and-pizza")),
        Song(title: "Kitten Purring", fileName: nil, imageName: "", image: UIImage(named: "kittencute")),
        Song(title: "Kitten Meowing", fileName: nil, imageName: "", image: UIImage(named: "cutekitten"))
    ]



    @State private var isEditing = false
    

    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(songs) { song in
                        NavigationLink(destination: PlayerView(song: song, isFavorite: user.favorites.contains(song.id)) {
                            if user.favorites.contains(song.id) {
                                user.favorites.remove(song.id)
                            } else {
                                user.favorites.insert(song.id)
                            }
                        }) {
                            Text(song.title)
                        }
                    }
                    .onDelete(perform: deleteSongs)
                }
                .navigationBarTitle("Kittens")
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Text("Count: \(songs.count)")
                )
            }
            .tabItem {
                Text("Songs")
                Image(systemName: "cat")
                
            }
            
            // Favorites Tab
            NavigationView {
                FavoritesView(songs: songs, user: $user)
            }
            .tabItem {
                Text("Favorites")
                Image(systemName: "heart.circle.fill")
                
            }
            // Slideshow Tab
            NavigationView {
                SlideshowView(songs: $songs)
            }
            .tabItem {
                Text("Slideshow")
                Image(systemName: "play.circle.fill")
            }
        
        .onAppear {
            // Count and print the number of favorites
            print("Number of Favorites: \(user.favorites.count)")
        }

            // New Image Tab
            NavigationView {
                NewImageView(songs: $songs)
            }
            .tabItem {
                Text("Add Kitten")
                Image(systemName: "pawprint")
            }
        }
        .onAppear {
            // Count and print the number of favorites
            print("Number of Favorites: \(user.favorites.count)")
        }
        .environmentObject(audioPlayerManager) // Provide the AudioPlayerManager to the ContentView
    }

    func deleteSongs(at offsets: IndexSet) {
        songs.remove(atOffsets: offsets)
    }
}

struct NewImageView: View {
    @Binding var songs: [Song]

    @State private var newImageLabel: String = ""
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            Text("Add a New Kitten")
                .font(.title)
                .padding()

            Button(action: {
                isImagePickerPresented.toggle()
            }) {
                Text("Select Kitten Image from Library")
                    .font(.title2)
            }

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }

            TextField("Label", text: $newImageLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if let image = selectedImage, !newImageLabel.isEmpty {
                    let newSong = Song(title: newImageLabel, fileName: nil, imageName: "", image: image)
                    songs.append(newSong)
                    newImageLabel = ""
                    selectedImage = nil
                }
            }) {
                Text("Add Kitten")
                    .font(.title)
            }

        }
        .navigationBarTitle("New Kitten", displayMode: .inline)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

func saveImage(_ image: UIImage, imageName: String) -> String? {
    if let jpegData = image.jpegData(compressionQuality: 0.8) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let imagePath = paths.first?.appendingPathComponent(imageName + ".jpg") {
            do {
                try jpegData.write(to: imagePath)
                return imagePath.path
            } catch {
                print("Error saving image:", error)
            }
        }
    }
    return nil
}

struct SlideshowView: View {
    @Binding var songs: [Song]
    @State private var currentIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?
    @State private var isSlideshowPaused: Bool = true // Slideshow starts in paused state

    var body: some View {
        VStack {
            if songs.indices.contains(currentIndex) {
                let currentSong = songs[currentIndex]

                VStack {
                    if let image = currentSong.image {
                        // Display the UIImage object
                        Image(uiImage: image)
                            .resizable()
                            .cornerRadius(10)
                            .aspectRatio(contentMode: .fit)
                            .padding(.all)
                    }
                }

                Text(currentSong.title)
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Button(action: {
                        playPrevious()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }

                    Button(action: {
                        togglePlayPause()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                    }

                    Button(action: {
                        playNext()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle("Slideshow", displayMode: .inline)
        .onAppear {
            play()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func play() {
        if songs.isEmpty {
            return
        }

        if !isPlaying && !isSlideshowPaused {
            togglePlayPause()
        }
    }

    private func playNext() {
        if currentIndex < songs.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }

    private func playPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = songs.count - 1
        }
    }

    private func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
    }

    private func startTimer() {
        // Start a timer to automatically switch to the next image
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            playNext()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ImagePicker: UIViewControllerRepresentable {
@Binding var selectedImage: UIImage?
    

func makeCoordinator() -> Coordinator {
    Coordinator(self)
}

func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = context.coordinator
    return picker
}

func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    // Nothing to do here
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: ImagePicker

    init(_ parent: ImagePicker) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            print("Selected image is not nil")
            parent.selectedImage = editedImage
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
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

            VStack {
                if let fileName = song.fileName {
                    // Load and display the locally saved image using fileName
                    Image(fileName)
                        .resizable()
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fit)
                        .padding(.all)
                } else if let image = song.image {
                    // Display the UIImage object
                    Image(uiImage: image)
                        .resizable()
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fit)
                        .padding(.all)
                }
            }

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
                    if let fileName = song.fileName {
                        audioPlayerManager.playAudio(fileName: fileName)
                        startTimer()
                    }
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

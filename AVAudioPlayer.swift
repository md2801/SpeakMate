//  Latest done on 11/06/2025

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?

    func playRecording(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play recording: \(error)")
        }
    }
}

//  Latest done on 12/06/2025

import SwiftUI
import AVFoundation

struct AudioRecordingCard: View {
    var title: String
    var date: String
    var fileURL: URL
    @Binding var isPlaying: Bool
    var onTap: (() -> Void)? = nil // Added tap action

    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var duration: CGFloat = 60.0
    @State private var currentTime: CGFloat = 0.0
    @State private var audioPlayer: AVAudioPlayer?

    func play() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            duration = CGFloat(audioPlayer?.duration ?? 60)

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let current = audioPlayer?.currentTime, current < Double(duration) {
                    currentTime = CGFloat(current)
                    withAnimation(.linear(duration: 0.1)) {
                        progress = currentTime / duration
                    }
                } else {
                    pause()
                }
            }
        } catch {
            print("Playback failed: \(error)")
        }
    }

    func pause() {
        audioPlayer?.pause()
        timer?.invalidate()
    }

    func skipForward() {
        audioPlayer?.currentTime += 5
    }

    func skipBackward() {
        audioPlayer?.currentTime = max((audioPlayer?.currentTime ?? 0) - 5, 0)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Tappable content area (title, date, progress bar)
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Text(date)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: progress * 300, height: 6)
                }
            }
            .contentShape(Rectangle()) // Make entire area tappable
            .onTapGesture {
                onTap?()
            }

            // Non-tappable control area
            HStack(spacing: 32) {
                Button(action: skipBackward) {
                    Image(systemName: "gobackward.5")
                        .font(.system(size: 20))
                }

                Button(action: {
                    isPlaying.toggle()
                    isPlaying ? play() : pause()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                }

                Button(action: skipForward) {
                    Image(systemName: "goforward.5")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.primary)
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.blue.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
        )
    }
}

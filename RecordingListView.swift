//  Latest done on 11/06/2025

import SwiftUI

struct RecordingsListView: View {
    @StateObject private var recordingManager = RecordingManager()
    @StateObject private var audioPlayer = AudioPlayer()

    var body: some View {
        List(recordingManager.recordings, id: \.self) { url in
            Button(action: {
                audioPlayer.playRecording(from: url)
            }) {
                Text(url.lastPathComponent)
                    .lineLimit(1)
            }
        }
        .onAppear {
            recordingManager.fetchRecordings()
        }
        .navigationTitle("Recordings")
    }
}


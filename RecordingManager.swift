//  Latest done on 11/06/2025

import Foundation

class RecordingManager: ObservableObject {
    @Published var recordings: [URL] = []

    func fetchRecordings() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            recordings = files.filter { $0.pathExtension == "m4a" }
                .sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
        } catch {
            print("Failed to fetch recordings: \(error)")
        }
    }
}

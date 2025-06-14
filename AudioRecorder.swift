//  Latest done on 11/06/2025

import Foundation
import AVFoundation

class AudioRecorder: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var isRecording: Bool = false
    @Published var recordingLevel: Float = 0.0
    @Published var recordingDuration: TimeInterval = 0.0
    
    private var levelTimer: Timer?
    private var durationTimer: Timer?
    private var currentRecordingURL: URL?
    
    // MARK: - Enhanced Recording Settings for API Upload
    private let enhancedSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,  // Higher quality for better transcription
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        AVEncoderBitRateKey: 128000  // 128 kbps for good quality/size balance
    ]
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            
            // Generate timestamped filename
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let filename = "recording_\(formatter.string(from: Date())).m4a"
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: enhancedSettings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            currentRecordingURL = fileURL
            isRecording = true
            recordingDuration = 0.0
            
            audioRecorder?.record()
            
            // Start monitoring audio levels and duration
            startMonitoring()
            
            print("📱 Started recording: \(filename)")
            
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        
        stopMonitoring()
        
        // Perform cleanup of old recordings
        cleanupOldRecordings()
        
        print("📱 Recording stopped. Duration: \(recordingDuration)s")
        print("📁 Saved to: \(getDocumentsDirectory().path)")
    }
    
    // MARK: - Audio Level Monitoring
    private func startMonitoring() {
        // Monitor recording levels for visual feedback
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioRecorder?.updateMeters()
            let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -80
            
            // Convert decibel level to 0-1 range for UI
            let normalizedLevel = max(0, (level + 80) / 80)
            
            DispatchQueue.main.async {
                self.recordingLevel = normalizedLevel
            }
        }
        
        // Monitor recording duration
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.recordingDuration = self.audioRecorder?.currentTime ?? 0
            }
        }
    }
    
    private func stopMonitoring() {
        levelTimer?.invalidate()
        durationTimer?.invalidate()
        levelTimer = nil
        durationTimer = nil
        recordingLevel = 0.0
    }
    
    // MARK: - File Management
    func getLatestRecording() -> URL? {
        return currentRecordingURL
    }
    
    func getAllRecordings() -> [URL] {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])
            return fileURLs
                .filter { $0.pathExtension == "m4a" }
                .sorted { url1, url2 in
                    let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
                }
        } catch {
            print("Error getting recordings: \(error)")
            return []
        }
    }
    
    // MARK: - Audio Compression for API Upload (iOS 18 Compatible)
    func compressAudioForUpload(sourceURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                let compressedURL = try await compressAudio(sourceURL: sourceURL)
                DispatchQueue.main.async {
                    completion(.success(compressedURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    @available(iOS 18.0, *)
    private func compressAudio(sourceURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: sourceURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw AudioCompressionError.exportSessionCreationFailed
        }
        
        let compressedURL = getDocumentsDirectory().appendingPathComponent("compressed_\(sourceURL.lastPathComponent)")
        
        // Remove existing compressed file if it exists
        try? FileManager.default.removeItem(at: compressedURL)
        
        do {
            try await exportSession.export(to: compressedURL, as: .m4a)
            return compressedURL
        } catch {
            throw AudioCompressionError.compressionFailed
        }
    }
    
    // Simplified compression - avoids deprecation warnings
    private func compressAudioLegacy(sourceURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // For now, just return original URL to avoid deprecation warnings
        // Compression can be re-enabled when targeting iOS 18+ only
        completion(.success(sourceURL))
    }
    
    // MARK: - Automatic Cleanup
    private func cleanupOldRecordings() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])
            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
            
            // Keep only the 10 most recent recordings
            let maxRecordings = 10
            if audioFiles.count > maxRecordings {
                let sortedFiles = audioFiles.sorted { url1, url2 in
                    let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
                }
                
                // Delete older files
                let filesToDelete = sortedFiles.dropFirst(maxRecordings)
                for fileURL in filesToDelete {
                    try? fileManager.removeItem(at: fileURL)
                    print("🗑️ Cleaned up old recording: \(fileURL.lastPathComponent)")
                }
            }
            
            // Also cleanup compressed files older than 1 day
            let compressedFiles = audioFiles.filter { $0.lastPathComponent.contains("compressed_") }
            let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
            
            for fileURL in compressedFiles {
                if let creationDate = try? fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   creationDate < oneDayAgo {
                    try? fileManager.removeItem(at: fileURL)
                    print("🗑️ Cleaned up old compressed file: \(fileURL.lastPathComponent)")
                }
            }
            
        } catch {
            print("Error during cleanup: \(error)")
        }
    }
    
    func listFilesInDocumentsFolder() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
            print("📁 Files in Documents folder (\(fileURLs.count) total):")
            
            for fileURL in fileURLs.prefix(10) {
                let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                let fileSize = resourceValues?.fileSize ?? 0
                let creationDate = resourceValues?.creationDate ?? Date()
                
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                
                print("  📄 \(fileURL.lastPathComponent)")
                print("     Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))")
                print("     Created: \(formatter.string(from: creationDate))")
            }
        } catch {
            print("Error listing files: \(error)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// MARK: - Audio Compression Errors
enum AudioCompressionError: Error, LocalizedError {
    case exportSessionCreationFailed
    case compressionFailed
    
    var errorDescription: String? {
        switch self {
        case .exportSessionCreationFailed:
            return "Failed to create audio export session"
        case .compressionFailed:
            return "Audio compression failed"
        }
    }
}

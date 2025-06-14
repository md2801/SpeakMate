//  Latest done on 12/06/2025

import SwiftUI

struct RecordingsView: View {
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var endDate: Date = Date()
    @State private var currentlyPlayingID: UUID?
    @State private var allRecordings: [Recording] = []
    @State private var selectedRecording: Recording?
    @State private var showClearAllConfirmation = false
    @State private var recordingToDelete: Recording?
    @State private var showDeleteConfirmation = false
    @State private var filteredRecordings: [Recording] = []
    @StateObject private var resultsStorage = ResultsStorageManager()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                filterSection
                recordingsList
            }
            .navigationTitle("Recordings")
            .padding(.top, 16)
            .onAppear {
                print("🎯 RecordingsView appeared, loading recordings...")
                updateFilteredRecordings()
            }
            .task(id: startDate) { @Sendable in
                updateFilteredRecordings()
            }
            .task(id: endDate) { @Sendable in
                updateFilteredRecordings()
            }
            .navigationDestination(item: $selectedRecording) { recording in
                if let storedResult = recording.storedResult {
                    let metrics = createMetrics(from: storedResult)
                    let feedback = createFeedback(from: storedResult)
                    DailyScoreView(metrics: metrics, feedback: feedback)
                }
            }
            .alert("Clear All Recordings", isPresented: $showClearAllConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    clearAllRecordings()
                }
            } message: {
                Text("Are you sure you want to delete all recordings and their results? This action cannot be undone.")
            }
            .alert("Delete Recording", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    recordingToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let recording = recordingToDelete {
                        deleteSingleRecording(recording)
                    }
                    recordingToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this recording and its results? This action cannot be undone.")
            }
        }
    }
    
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter recordings")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            DatePicker("Start date", selection: $startDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            DatePicker("End date", selection: $endDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
        }
        .padding(.horizontal)
    }
    
    private var recordingsList: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(filteredRecordings) { recording in
                    AudioRecordingCard(
                        title: recording.title,
                        date: formatted(recording.date),
                        fileURL: recording.fileURL,
                        isPlaying: Binding(
                            get: { currentlyPlayingID == recording.id },
                            set: { newValue in
                                currentlyPlayingID = newValue ? recording.id : nil
                            }),
                        onTap: {
                            if recording.storedResult != nil {
                                selectedRecording = recording
                            }
                        }
                    )
                    .onLongPressGesture {
                        recordingToDelete = recording
                        showDeleteConfirmation = true
                    }
                }
                
                // Clear All button - only shows when there are recordings
                if !filteredRecordings.isEmpty {
                    Button(action: {
                        showClearAllConfirmation = true
                    }) {
                        Text("Clear All")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func loadRecordings() -> [Recording] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Get stored results to match with audio files
        let storedResults = resultsStorage.getRecentResults(limit: 100)
        print("🎯 Found \(storedResults.count) stored results for matching")
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            print("🎯 Found \(fileURLs.count) files in documents directory")
            
            let recordings = fileURLs
                .filter { $0.pathExtension == "m4a" }
                .compactMap { url -> Recording? in
                    let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                    let creationDate = attributes?[.creationDate] as? Date ?? Date()
                    
                    // Find matching stored result by audio filename
                    let filename = url.lastPathComponent
                    print("🎯 Looking for match for filename: \(filename)")
                    
                    let matchingResult = storedResults.first { result in
                        let match = result.audioFileName == filename
                        if match {
                            print("🎯 Found match: \(result.prompt)")
                        }
                        return match
                    }
                    
                    // Use prompt from stored result, or create descriptive fallback
                    let title: String
                    if let matchingResult = matchingResult {
                        title = matchingResult.prompt
                        print("🎯 Using prompt: \(title)")
                    } else {
                        // Create more descriptive fallback based on date
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        title = "Recording \(formatter.string(from: creationDate))"
                        print("🎯 Using fallback title: \(title)")
                    }
                    
                    return Recording(
                        title: title,
                        date: creationDate,
                        fileURL: url,
                        storedResult: matchingResult
                    )
                }
            
            let sortedRecordings = recordings.sorted(by: { $0.date > $1.date })
            print("🎯 Created \(sortedRecordings.count) recording entries")
            
            return sortedRecordings
        } catch {
            print("❌ Error reading contents of documents directory: \(error)")
            return []
        }
    }
    
    private func updateFilteredRecordings() {
        let recordings = loadRecordings()
        let filtered = recordings.filter { recording in
            recording.date > startDate && recording.date < endDate
        }
        filteredRecordings = filtered
        print("🎯 Filtered to \(filtered.count) recordings between dates")
    }
    
    private func deleteSingleRecording(_ recording: Recording) {
        // Delete stored result if exists
        if let storedResult = recording.storedResult {
            resultsStorage.deleteResult(withId: storedResult.id)
        }
        
        // Delete audio file
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: recording.fileURL)
            print("🗑️ Deleted recording: \(recording.title)")
        } catch {
            print("❌ Error deleting audio file: \(error)")
        }
        
        // Refresh the recordings list
        updateFilteredRecordings()
    }
    
    private func clearAllRecordings() {
        // Clear stored results
        resultsStorage.clearAllResults()
        
        // Delete audio files
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
            
            for fileURL in audioFiles {
                try fileManager.removeItem(at: fileURL)
                print("🗑️ Deleted audio file: \(fileURL.lastPathComponent)")
            }
            
            // Refresh the recordings list
            updateFilteredRecordings()
            
        } catch {
            print("❌ Error clearing audio files: \(error)")
        }
    }
    
    // Helper function to create metrics from stored result
    private func createMetrics(from storedResult: StoredPerformanceResult) -> PerformanceMetrics {
        return PerformanceMetrics(
            fluency: storedResult.metrics.fluency,
            pronunciation: storedResult.metrics.pronunciation,
            vocabularyRange: storedResult.metrics.vocabularyRange,
            confidence: storedResult.metrics.confidence,
            overall: storedResult.metrics.overall,
            transcript: storedResult.metrics.transcript,
            sentiment: nil
        )
    }
    
    // Helper function to create feedback from stored result
    private func createFeedback(from storedResult: StoredPerformanceResult) -> FeedbackResult {
        return FeedbackResult(
            aiFeedback: storedResult.feedback.aiFeedback,
            suggestions: storedResult.feedback.suggestions,
            aussieSlangSuggestions: storedResult.feedback.aussieSlangSuggestions.map {
                FeedbackResult.SlangSuggestion(formal: $0.formal, aussie: $0.aussie)
            }
        )
    }
}

#Preview {
    RecordingsView()
}

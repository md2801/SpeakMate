//  Latest done on 11/06/2025

import Foundation

// MARK: - Deepgram Service (Pure API Layer)
@MainActor
class DeepgramService: ObservableObject {
    private let apiKey = "d60deab88c77ce370a60b030baddcecebbbcbe6d"
    private let baseURL = "https://api.deepgram.com/v1/listen"
    
    @Published var isProcessing = false
    @Published var lastError: String?
    
    // MARK: - Upload and Transcribe
    func transcribeAudio(from fileURL: URL) async throws -> DeepgramResponse {
        isProcessing = true
        lastError = nil
        
        defer {
            isProcessing = false
        }
        
        guard let url = URL(string: "\(baseURL)?model=nova-2&language=en&smart_format=true&sentiment=true") else {
            throw DeepgramError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("audio/m4a", forHTTPHeaderField: "Content-Type")
        
        do {
            let audioData = try Data(contentsOf: fileURL)
            request.httpBody = audioData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DeepgramError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = httpResponse.statusCode == 401 ? "Invalid API key" :
                                 httpResponse.statusCode == 400 ? "Invalid audio format" :
                                 "Server error (\(httpResponse.statusCode))"
                throw DeepgramError.httpError(status: httpResponse.statusCode, message: errorMessage)
            }
            
            let deepgramResponse = try JSONDecoder().decode(DeepgramResponse.self, from: data)
            
            // Log successful transcription
            print("✅ Deepgram transcription successful")
            print("📝 Request ID: \(deepgramResponse.metadata.request_id)")
            print("⏱️ Duration: \(deepgramResponse.metadata.duration)s")
            if let transcript = deepgramResponse.results.channels.first?.alternatives.first?.transcript {
                print("📄 Transcript preview: \(String(transcript.prefix(50)))...")
            }
            
            return deepgramResponse
            
        } catch let error as DeepgramError {
            lastError = error.errorDescription
            throw error
        } catch {
            lastError = "Network error: \(error.localizedDescription)"
            throw DeepgramError.networkError(error)
        }
    }
    
    // MARK: - Convenience Methods
    func getTranscript(from response: DeepgramResponse) -> String {
        return response.results.channels.first?.alternatives.first?.transcript ?? ""
    }
    
    func getConfidence(from response: DeepgramResponse) -> Double {
        return response.results.channels.first?.alternatives.first?.confidence ?? 0.0
    }
    
    func getWords(from response: DeepgramResponse) -> [DeepgramResponse.Results.Channel.Alternative.Word] {
        return response.results.channels.first?.alternatives.first?.words ?? []
    }
    
    func getSentimentSegments(from response: DeepgramResponse) -> [DeepgramResponse.Results.Channel.Alternative.SentimentSegment] {
        return response.results.channels.first?.alternatives.first?.sentiment_segments ?? []
    }
}

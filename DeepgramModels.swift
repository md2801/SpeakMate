//  Latest done on 12/06/2025

import Foundation

// MARK: - Deepgram Response Models
struct DeepgramResponse: Codable {
    let metadata: Metadata
    let results: Results
    
    struct Metadata: Codable {
        let request_id: String
        let transaction_key: String
        let sha256: String
        let created: String
        let duration: Double
        let channels: Int
    }
    
    struct Results: Codable {
        let channels: [Channel]
        
        struct Channel: Codable {
            let alternatives: [Alternative]
            
            struct Alternative: Codable {
                let transcript: String
                let confidence: Double
                let words: [Word]
                let sentiment_segments: [SentimentSegment]?
                
                struct Word: Codable {
                    let word: String
                    let start: Double
                    let end: Double
                    let confidence: Double
                    let punctuated_word: String
                }
                
                struct SentimentSegment: Codable {
                    let text: String
                    let start_word: Int
                    let end_word: Int
                    let sentiment: String
                    let sentiment_score: Double
                }
            }
        }
    }
}

// MARK: - Performance Metrics Data Model
struct PerformanceMetrics {
    let fluency: Int
    let pronunciation: Int
    let vocabularyRange: Int
    let confidence: Int  // Changed from "clarity" to "confidence"
    let overall: Int
    let transcript: String
    let sentiment: SentimentAnalysis?
    
    struct SentimentAnalysis {
        let overallSentiment: String
        let averageScore: Double
        let segments: [DeepgramResponse.Results.Channel.Alternative.SentimentSegment]
    }
}

// MARK: - Feedback Data Model
struct FeedbackResult {
    let aiFeedback: String
    let suggestions: String
    let aussieSlangSuggestions: [SlangSuggestion]
    
    struct SlangSuggestion {
        let formal: String
        let aussie: String
    }
}

// MARK: - Error Types
enum DeepgramError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(status: Int, message: String)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Deepgram API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let status, let message):
            return "HTTP \(status): \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

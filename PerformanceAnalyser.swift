//  Latest done on 12/06/2025

import Foundation

// MARK: - Performance Analysis Service
class PerformanceAnalyser {
    
    // MARK: - Main Analysis Method
    func analyse(deepgramResponse: DeepgramResponse) -> PerformanceMetrics {
        guard let alternative = deepgramResponse.results.channels.first?.alternatives.first else {
            return PerformanceMetrics(
                fluency: 0,
                pronunciation: 0,
                vocabularyRange: 0,
                confidence: 0,
                overall: 0,
                transcript: "",
                sentiment: nil
            )
        }
        
        // Calculate individual metrics
        let pronunciation = calculatePronunciation(from: alternative.words, confidence: alternative.confidence)
        let fluency = calculateFluency(from: alternative.words, totalDuration: deepgramResponse.metadata.duration, sentimentSegments: alternative.sentiment_segments)
        let vocabularyRange = calculateVocabularyRange(from: alternative.words)
        let confidence = calculateConfidence(sentimentSegments: alternative.sentiment_segments, transcript: alternative.transcript)
        
        // Calculate overall score
        let overall = (fluency + pronunciation + vocabularyRange + confidence) / 4
        
        // Process sentiment analysis
        let sentiment = processSentiment(segments: alternative.sentiment_segments)
        
        return PerformanceMetrics(
            fluency: fluency,
            pronunciation: pronunciation,
            vocabularyRange: vocabularyRange,
            confidence: confidence,
            overall: overall,
            transcript: alternative.transcript,
            sentiment: sentiment
        )
    }
    
    // MARK: - Individual Metric Calculations
    
    // Updated: Stricter pronunciation scoring with no boosting
    private func calculatePronunciation(from words: [DeepgramResponse.Results.Channel.Alternative.Word], confidence: Double) -> Int {
        guard !words.isEmpty else { return 0 }
        
        // Calculate average word-level confidence
        let wordConfidences = words.map { $0.confidence }
        let avgWordConfidence = wordConfidences.reduce(0, +) / Double(wordConfidences.count)
        
        // Weight overall vs word-level confidence (70/30 split)
        let weightedConfidence = (confidence * 0.7) + (avgWordConfidence * 0.3)
        
        // Apply strictness factor (0.85x) and convert to 0-100 scale
        let strictnessMultiplier = 0.85
        return min(100, Int(weightedConfidence * strictnessMultiplier * 100))
    }
    
    // Updated: Fluency with marginal sentiment integration
    private func calculateFluency(from words: [DeepgramResponse.Results.Channel.Alternative.Word], totalDuration: Double, sentimentSegments: [DeepgramResponse.Results.Channel.Alternative.SentimentSegment]?) -> Int {
        guard !words.isEmpty, totalDuration > 0 else { return 0 }
        
        // Calculate speech timing metrics
        let speechStartTime = words.first?.start ?? 0
        let speechEndTime = words.last?.end ?? 0
        let actualSpeechDuration = speechEndTime - speechStartTime
        
        // Calculate speech density (words per minute)
        let wordsPerMinute = Double(words.count) / (actualSpeechDuration / 60.0)
        
        // Optimal range: 120-180 words per minute for clear speech
        let optimalWPM = 150.0
        let wpmScore = max(0, 1.0 - abs(wordsPerMinute - optimalWPM) / optimalWPM)
        
        // Calculate pause analysis
        var pauseCount = 0
        var totalPauseTime = 0.0
        
        for i in 1..<words.count {
            let pauseDuration = words[i].start - words[i-1].end
            if pauseDuration > 0.5 { // Pauses longer than 0.5 seconds
                pauseCount += 1
                totalPauseTime += pauseDuration
            }
        }
        
        // Penalise excessive pauses
        let pausePenalty = min(1.0, (totalPauseTime / actualSpeechDuration) * 2)
        let pauseScore = max(0, 1.0 - pausePenalty)
        
        // Sentiment boost/penalty (small weighting)
        var sentimentModifier = 1.0
        if let segments = sentimentSegments, !segments.isEmpty {
            let avgSentiment = segments.map { $0.sentiment_score }.reduce(0, +) / Double(segments.count)
            // Small sentiment impact: -0.3 to +0.3 becomes 0.95 to 1.05
            sentimentModifier = 1.0 + (avgSentiment * 0.1)
        }
        
        // Combine metrics (55% WPM, 35% pause analysis, 10% sentiment)
        let baseScore = (wpmScore * 0.55) + (pauseScore * 0.35)
        let fluencyScore = baseScore * sentimentModifier * 0.1 + baseScore * 0.9
        
        // Apply strictness factor
        let strictnessMultiplier = 0.85
        return min(100, Int(fluencyScore * strictnessMultiplier * 100))
    }
    
    // Updated: Stricter vocabulary scoring
    private func calculateVocabularyRange(from words: [DeepgramResponse.Results.Channel.Alternative.Word]) -> Int {
        guard !words.isEmpty else { return 0 }
        
        // Get unique words (case-insensitive)
        let uniqueWords = Set(words.map { $0.word.lowercased() })
        let totalWords = words.count
        
        // Calculate vocabulary diversity ratio
        let diversityRatio = Double(uniqueWords.count) / Double(totalWords)
        
        // Analyse word complexity
        var complexWords = 0
        var totalWordLength = 0
        
        for word in uniqueWords {
            let cleanWord = word.filter { $0.isLetter }
            totalWordLength += cleanWord.count
            
            // Consider words with 7+ characters as complex
            if cleanWord.count >= 7 {
                complexWords += 1
            }
        }
        
        let avgWordLength = Double(totalWordLength) / Double(uniqueWords.count)
        let complexityRatio = Double(complexWords) / Double(uniqueWords.count)
        
        // Score based on diversity (40%), average word length (30%), complexity (30%)
        let diversityScore = min(1.0, diversityRatio * 2) // Cap at reasonable diversity
        let lengthScore = min(1.0, (avgWordLength - 3) / 4) // 3-7 character range
        let complexityScore = complexityRatio
        
        let vocabularyScore = (diversityScore * 0.4) + (lengthScore * 0.3) + (complexityScore * 0.3)
        
        // Apply strictness factor
        let strictnessMultiplier = 0.85
        return min(100, Int(vocabularyScore * strictnessMultiplier * 100))
    }
    
    // NEW: Confidence metric based predominantly on sentiment with word usage indicators
    private func calculateConfidence(sentimentSegments: [DeepgramResponse.Results.Channel.Alternative.SentimentSegment]?, transcript: String) -> Int {
        var confidenceScore = 0.5 // Base score
        
        // Sentiment analysis (70% weight)
        if let segments = sentimentSegments, !segments.isEmpty {
            let avgSentiment = segments.map { $0.sentiment_score }.reduce(0, +) / Double(segments.count)
            
            // Map sentiment (-1 to 1) to confidence (0 to 1)
            // Positive sentiment = higher confidence
            let sentimentConfidence = (avgSentiment + 1.0) / 2.0
            confidenceScore = confidenceScore * 0.3 + sentimentConfidence * 0.7
        }
        
        // Word usage confidence indicators (30% weight)
        let lowercaseTranscript = transcript.lowercased()
        var wordConfidenceBoost = 0.0
        
        // Confident words/phrases
        let confidenceIndicators = [
            ("definitely", 0.1), ("absolutely", 0.1), ("certainly", 0.1),
            ("i believe", 0.05), ("i think", 0.03), ("clearly", 0.08),
            ("obviously", 0.08), ("without doubt", 0.1), ("no worries", 0.05)
        ]
        
        // Hesitation indicators (penalties)
        let hesitationIndicators = [
            ("um", -0.05), ("uh", -0.05), ("er", -0.05),
            ("maybe", -0.03), ("i guess", -0.05), ("perhaps", -0.03),
            ("i'm not sure", -0.08), ("i don't know", -0.08)
        ]
        
        for (phrase, boost) in confidenceIndicators {
            if lowercaseTranscript.contains(phrase) {
                wordConfidenceBoost += boost
            }
        }
        
        for (phrase, penalty) in hesitationIndicators {
            if lowercaseTranscript.contains(phrase) {
                wordConfidenceBoost += penalty
            }
        }
        
        // Apply word usage confidence (30% weight)
        confidenceScore = confidenceScore * 0.7 + (0.5 + wordConfidenceBoost) * 0.3
        
        // Apply strictness factor
        let strictnessMultiplier = 0.85
        return min(100, max(0, Int(confidenceScore * strictnessMultiplier * 100)))
    }
    
    // MARK: - Sentiment Processing
    
    // Map sentiment scores (-1 to 1) to performance metrics (0-100)
    private func processSentiment(segments: [DeepgramResponse.Results.Channel.Alternative.SentimentSegment]?) -> PerformanceMetrics.SentimentAnalysis? {
        guard let segments = segments, !segments.isEmpty else { return nil }
        
        let averageScore = segments.map { $0.sentiment_score }.reduce(0, +) / Double(segments.count)
        
        let overallSentiment: String
        if averageScore > 0.1 {
            overallSentiment = "positive"
        } else if averageScore < -0.1 {
            overallSentiment = "negative"
        } else {
            overallSentiment = "neutral"
        }
        
        return PerformanceMetrics.SentimentAnalysis(
            overallSentiment: overallSentiment,
            averageScore: averageScore,
            segments: segments
        )
    }
    
    // MARK: - Feedback Generation
    func generateFeedback(from metrics: PerformanceMetrics) -> FeedbackResult {
        let aiFeedback = generateAIFeedback(metrics: metrics)
        let suggestions = generateSuggestions(metrics: metrics)
        let slangSuggestions = generateAussieSlangSuggestions(transcript: metrics.transcript)
        
        return FeedbackResult(
            aiFeedback: aiFeedback,
            suggestions: suggestions,
            aussieSlangSuggestions: slangSuggestions
        )
    }
    
    private func generateAIFeedback(metrics: PerformanceMetrics) -> String {
        var feedback = "Your speech was "
        
        // Base feedback on multiple metrics
        if metrics.overall >= 80 {
            feedback += "excellent - confident, clear, and well-paced"
        } else if metrics.overall >= 70 {
            feedback += "good overall with room for improvement"
        } else if metrics.confidence > 60 {
            feedback += "mostly confident but could benefit from more practice"
        } else {
            feedback += "lacking confidence and needs more work on clarity"
        }
        
        // Add specific feedback based on lowest scoring metric
        let lowestMetric = min(metrics.fluency, metrics.pronunciation, metrics.vocabularyRange, metrics.confidence)
        
        if lowestMetric == metrics.fluency && metrics.fluency < 70 {
            feedback += ". Work on speaking more smoothly with fewer pauses"
        } else if lowestMetric == metrics.pronunciation && metrics.pronunciation < 70 {
            feedback += ". Focus on clearer pronunciation of individual words"
        } else if lowestMetric == metrics.vocabularyRange && metrics.vocabularyRange < 70 {
            feedback += ". Try to use a wider range of vocabulary"
        } else if lowestMetric == metrics.confidence && metrics.confidence < 70 {
            feedback += ". Work on speaking with more confidence and positivity"
        }
        
        // Add Aussie context
        feedback += ". To sound more like a native Aussie, consider using local slang and expressions that make your speech more natural and relatable."
        
        return feedback
    }
    
    private func generateSuggestions(metrics: PerformanceMetrics) -> String {
        var suggestions: [String] = []
        
        // Fluency-based suggestions
        if metrics.fluency < 70 {
            suggestions.append("Practice speaking without long pauses - try recording yourself and listening back")
            suggestions.append("Work on connecting your thoughts more smoothly")
        }
        
        // Pronunciation-based suggestions
        if metrics.pronunciation < 70 {
            suggestions.append("Focus on clearer enunciation of each word")
            suggestions.append("Practice with tongue twisters to improve articulation")
        }
        
        // Vocabulary-based suggestions
        if metrics.vocabularyRange < 70 {
            suggestions.append("Try using more varied vocabulary to express your ideas")
            suggestions.append("Read more Australian content to learn local expressions")
        }
        
        // Confidence-based suggestions
        if metrics.confidence < 70 {
            suggestions.append("Practice speaking with more assertive language")
            suggestions.append("Avoid filler words like 'um' and 'uh' - pause instead")
        }
        
        // Sentiment-based suggestions
        if let sentiment = metrics.sentiment, sentiment.averageScore < -0.2 {
            suggestions.append("Try to maintain a more positive tone when discussing topics")
            suggestions.append("Consider framing your points in a more optimistic way")
        }
        
        // Default suggestions if all metrics are good
        if suggestions.isEmpty {
            suggestions.append("Getting straight to the point shows confidence and makes it easier for others to follow")
            suggestions.append("Be mindful of your tone - aim for a relaxed, friendly vibe like you're having a yarn with a mate")
        }
        
        return suggestions.joined(separator: ". ") + "."
    }
    
    private func generateAussieSlangSuggestions(transcript: String) -> [FeedbackResult.SlangSuggestion] {
        let slangMappings: [(formal: String, aussie: String)] = [
            ("I'm very tired", "I'm knackered"),
            ("afternoon", "arvo"),
            ("avocado", "avo"),
            ("service station", "servo"),
            ("how are you", "how ya going"),
            ("definitely", "definitely"),
            ("breakfast", "brekky"),
            ("barbecue", "barbie"),
            ("chocolate", "choccy"),
            ("sunglasses", "sunnies"),
            ("umbrella", "brolly"),
            ("football", "footy"),
            ("sandwich", "sanga"),
            ("absolutely", "bloody oath"),
            ("no problem", "no worries")
        ]
        
        var suggestions: [FeedbackResult.SlangSuggestion] = []
        let lowercaseTranscript = transcript.lowercased()
        
        for mapping in slangMappings {
            if lowercaseTranscript.contains(mapping.formal.lowercased()) {
                suggestions.append(FeedbackResult.SlangSuggestion(
                    formal: mapping.formal,
                    aussie: mapping.aussie
                ))
            }
        }
        
        // Add some general suggestions if no specific matches
        if suggestions.isEmpty {
            suggestions = [
                FeedbackResult.SlangSuggestion(formal: "I'm feeling tired", aussie: "I'm knackered"),
                FeedbackResult.SlangSuggestion(formal: "This afternoon", aussie: "This arvo"),
                FeedbackResult.SlangSuggestion(formal: "How are you?", aussie: "How ya going?"),
                FeedbackResult.SlangSuggestion(formal: "No problem", aussie: "No worries")
            ]
        }
        
        return Array(suggestions.prefix(4)) // Return max 4 suggestions
    }
}

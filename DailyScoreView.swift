// Latest done on 12/06/2025

import SwiftUI

struct DailyScoreView: View {
    let metrics: PerformanceMetrics?
    let feedback: FeedbackResult?
    
    @StateObject private var resultsStorage = ResultsStorageManager()
    @State private var latestResult: StoredPerformanceResult?
    
    private var displayMetrics: PerformanceMetrics {
        // First try passed metrics, then latest stored result, finally fallback
        if let metrics = metrics {
            print("🎯 DailyScoreView using passed metrics: \(metrics.overall)%")
            return metrics
        } else if let stored = latestResult {
            print("🎯 DailyScoreView using stored metrics: \(stored.metrics.overall)%")
            return PerformanceMetrics(
                fluency: stored.metrics.fluency,
                pronunciation: stored.metrics.pronunciation,
                vocabularyRange: stored.metrics.vocabularyRange,
                confidence: stored.metrics.confidence,
                overall: stored.metrics.overall,
                transcript: stored.metrics.transcript,
                sentiment: nil
            )
        } else {
            print("🎯 DailyScoreView using fallback dummy metrics")
            return PerformanceMetrics(
                fluency: 38,
                pronunciation: 78,
                vocabularyRange: 88,
                confidence: 48,
                overall: 78,
                transcript: "Sample transcript",
                sentiment: nil
            )
        }
    }
    
    private var displayFeedback: FeedbackResult {
        // First try passed feedback, then latest stored result, finally fallback
        if let feedback = feedback {
            print("🎯 DailyScoreView using passed feedback")
            return feedback
        } else if let stored = latestResult {
            print("🎯 DailyScoreView using stored feedback")
            return FeedbackResult(
                aiFeedback: stored.feedback.aiFeedback,
                suggestions: stored.feedback.suggestions,
                aussieSlangSuggestions: stored.feedback.aussieSlangSuggestions.map {
                    FeedbackResult.SlangSuggestion(formal: $0.formal, aussie: $0.aussie)
                }
            )
        } else {
            print("🎯 DailyScoreView using fallback dummy feedback")
            return FeedbackResult(
                aiFeedback: "Your speech was confident and clear, but you could make it more natural by using common Aussie slang. For example, instead of saying \"I'm very tired,\" you could say \"I'm knackered.\" Swapping in local expressions like \"no worries\" or \"arvo\" can help you sound more like a native speaker and connect better with your audience.",
                suggestions: "Getting straight to the point shows confidence and makes it easier for others to follow. Be mindful of your tone. Aim for a relaxed, friendly vibe like you're having a yarn with a mate.",
                aussieSlangSuggestions: []
            )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                headerSection
                subscoresSection
                confidenceSection
                aiFeedbackSection
                suggestionsSection
                transcriptSection
            }
            .padding(.bottom)
        }
        .onAppear {
            print("🎯 DailyScoreView appeared. Passed metrics: \(metrics?.overall ?? -1)")
            // Load the most recent result as backup
            let recentResults = resultsStorage.getRecentResults(limit: 1)
            latestResult = recentResults.first
            print("🎯 Latest stored result: \(latestResult?.metrics.overall ?? -1)")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Overall Result")
                    .padding(.leading, 0)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Text("\(displayMetrics.overall)")
                    .font(.system(size: 66))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.blue)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    private var subscoresSection: some View {
        VStack {
            HStack {
                ScoreCard(title: "Fluency", score: displayMetrics.fluency, colour: Color.red.opacity(0.3))
                    .padding(.trailing)
                ScoreCard(title: "Pronunciation", score: displayMetrics.pronunciation, colour: Color.mint.opacity(0.3))
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
            HStack {
                ScoreCard(title: "Vocab Range", score: displayMetrics.vocabularyRange, colour: Color.yellow.opacity(0.3))
                    .padding(.trailing)
                ScoreCard(title: "Confidence", score: displayMetrics.confidence, colour: Color.purple.opacity(0.3))
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var confidenceSection: some View {
        if let sentiment = displayMetrics.sentiment {
            VStack(alignment: .leading, spacing: 20) {
                Text("Speech Analysis")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.leading, 20)

                VStack(spacing: 16) {
                    HStack {
                        Text("Overall Tone:")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        let sentimentText = sentiment.overallSentiment.capitalized
                        let sentimentColourValue = sentimentColour(sentiment.overallSentiment)
                        
                        Text(sentimentText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(sentimentColourValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(sentimentColourValue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Confidence Level:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(confidenceLevel)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(confidenceColour)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .fill(confidenceColour)
                                    .frame(width: geometry.size.width * CGFloat(confidencePercentage), height: 6)
                                    .cornerRadius(3)
                                    .animation(.easeInOut(duration: 1.0), value: confidencePercentage)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .padding(20)
                .background(Color.blue.opacity(0.03))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 1))
                .padding(.horizontal)
            }
        }
    }
    
    private var aiFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI Feedback")
                .font(.title)
                .bold()
                .foregroundColor(.black)
                .padding(.leading, 20)

            Text(displayFeedback.aiFeedback)
                .foregroundColor(.black)
                .padding(20)
                .background(Color.blue.opacity(0.03))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 1))
                .padding(.horizontal)
        }
    }
    
    private func suggestionCard(suggestion: FeedbackResult.SlangSuggestion, index: Int) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Instead of:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\"\(suggestion.formal)\"")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                    .scaleEffect(1.2)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Try:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\"\(suggestion.aussie)\"")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if index < displayFeedback.aussieSlangSuggestions.count - 1 {
                Divider()
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI Suggestions")
                .font(.title)
                .bold()
                .foregroundColor(.black)
                .padding(.leading, 20)

            Text(displayFeedback.suggestions)
                .foregroundColor(.black)
                .padding(20)
                .background(Color.blue.opacity(0.03))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 1))
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var transcriptSection: some View {
        if !displayMetrics.transcript.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Response")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.leading, 20)

                Text(displayMetrics.transcript)
                    .foregroundColor(.black)
                    .padding(20)
                    .background(Color.blue.opacity(0.03))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.9), lineWidth: 1))
                    .padding(.horizontal)
            }
        }
    }
    
    private func sentimentColour(_ sentiment: String) -> Color {
        switch sentiment.lowercased() {
        case "positive": return .green
        case "negative": return .red
        default: return .orange
        }
    }
    
    private var confidenceLevel: String {
        switch confidencePercentage {
        case 0.8...: return "High"
        case 0.6..<0.8: return "Medium"
        default: return "Low"
        }
    }
    
    private var confidenceColour: Color {
        switch confidencePercentage {
        case 0.8...: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
    
    private var confidencePercentage: Double {
        Double(displayMetrics.confidence) / 100.0
    }
}


struct ScoreCard: View {
    var title: String
    var score: Int
    var colour: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom)
            Text("\(score)")
                .font(.system(size: 30, weight: .bold))
                .bold()
                .foregroundColor(.black)
        }
        .padding()
        .frame(width: 165, height: 120, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colour.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colour.opacity(3), lineWidth: 2))
    }
}

#Preview {
    DailyScoreView(metrics: nil, feedback: nil)
}

//  Latest done on 12/06/2025

import Foundation

// MARK: - Stored Performance Result
struct StoredPerformanceResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let prompt: String
    let metrics: StoredMetrics
    let feedback: StoredFeedback
    let audioFileName: String
    
    init(date: Date, prompt: String, metrics: PerformanceMetrics, feedback: FeedbackResult, audioFileName: String) {
        self.id = UUID()
        self.date = date
        self.prompt = prompt
        self.metrics = StoredMetrics(from: metrics)
        self.feedback = StoredFeedback(from: feedback)
        self.audioFileName = audioFileName
    }
}

// MARK: - Codable Versions
struct StoredMetrics: Codable {
    let fluency: Int
    let pronunciation: Int
    let vocabularyRange: Int
    let confidence: Int  // Changed from "clarity" to "confidence"
    let overall: Int
    let transcript: String
    
    init(from metrics: PerformanceMetrics) {
        self.fluency = metrics.fluency
        self.pronunciation = metrics.pronunciation
        self.vocabularyRange = metrics.vocabularyRange
        self.confidence = metrics.confidence
        self.overall = metrics.overall
        self.transcript = metrics.transcript
    }
}

struct StoredFeedback: Codable {
    let aiFeedback: String
    let suggestions: String
    let aussieSlangSuggestions: [StoredSlangSuggestion]
    
    init(from feedback: FeedbackResult) {
        self.aiFeedback = feedback.aiFeedback
        self.suggestions = feedback.suggestions
        self.aussieSlangSuggestions = feedback.aussieSlangSuggestions.map { StoredSlangSuggestion(from: $0) }
    }
}

struct StoredSlangSuggestion: Codable {
    let formal: String
    let aussie: String
    
    init(from suggestion: FeedbackResult.SlangSuggestion) {
        self.formal = suggestion.formal
        self.aussie = suggestion.aussie
    }
}

// MARK: - Results Storage Manager
class ResultsStorageManager: ObservableObject {
    @Published var storedResults: [StoredPerformanceResult] = []
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "SpeakMatePerformanceResults"
    
    init() {
        loadResults()
    }
    
    // MARK: - Save New Result
    func saveResult(prompt: String, metrics: PerformanceMetrics, feedback: FeedbackResult, audioFileName: String) {
        let newResult = StoredPerformanceResult(
            date: Date(),
            prompt: prompt,
            metrics: metrics,
            feedback: feedback,
            audioFileName: audioFileName
        )
        
        storedResults.insert(newResult, at: 0) // Add to beginning for newest first
        
        // Keep only last 50 results to prevent storage bloat
        if storedResults.count > 50 {
            storedResults = Array(storedResults.prefix(50))
        }
        
        persistResults()
        
        print("💾 Saved performance result: Overall \(metrics.overall)%")
    }
    
    // MARK: - Data Access Methods
    func getRecentResults(limit: Int = 10) -> [StoredPerformanceResult] {
        return Array(storedResults.prefix(limit))
    }
    
    func getResultsForDateRange(from startDate: Date, to endDate: Date) -> [StoredPerformanceResult] {
        return storedResults.filter { result in
            result.date >= startDate && result.date <= endDate
        }
    }
    
    func getAverageScore(for period: TimePeriod) -> Double {
        let results = getResultsForPeriod(period)
        guard !results.isEmpty else { return 0.0 }
        
        let totalScore = results.reduce(0) { $0 + $1.metrics.overall }
        return Double(totalScore) / Double(results.count)
    }
    
    func getScoresForChart(period: TimePeriod) -> [ChartDataPoint] {
        let results = getResultsForPeriod(period)
        
        switch period {
        case .week:
            return getWeeklyChartData(from: results)
        case .month:
            return getMonthlyChartData(from: results)
        case .year:
            return getYearlyChartData(from: results)
        }
    }
    
    // MARK: - Delete Methods
    func deleteResult(withId id: UUID) {
        storedResults.removeAll { $0.id == id }
        persistResults()
        print("🗑️ Deleted result with ID: \(id)")
    }
    
    func clearAllResults() {
        storedResults.removeAll()
        persistResults()
        print("🗑️ Cleared all stored results")
    }
    
    // MARK: - Private Methods
    private func getResultsForPeriod(_ period: TimePeriod) -> [StoredPerformanceResult] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return getResultsForDateRange(from: startDate, to: now)
    }
    
    private func getWeeklyChartData(from results: [StoredPerformanceResult]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        
        var chartData: [ChartDataPoint] = []
        
        // Create data for last 7 days
        for i in stride(from: 6, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayResults = results.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            let averageScore: CGFloat
            if dayResults.isEmpty {
                averageScore = 0
            } else {
                let total = dayResults.reduce(0) { $0 + $1.metrics.overall }
                averageScore = CGFloat(total) / CGFloat(dayResults.count)
            }
            
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            chartData.append(ChartDataPoint(label: String(dayName.prefix(1)), value: averageScore))
        }
        
        return chartData
    }
    
    private func getMonthlyChartData(from results: [StoredPerformanceResult]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        
        var chartData: [ChartDataPoint] = []
        
        // Create data for last 4 weeks
        for i in stride(from: 3, through: 0, by: -1) {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: today) else { continue }
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            
            let weekResults = results.filter { result in
                result.date >= weekStart && result.date <= weekEnd
            }
            
            let averageScore: CGFloat
            if weekResults.isEmpty {
                averageScore = 0
            } else {
                let total = weekResults.reduce(0) { $0 + $1.metrics.overall }
                averageScore = CGFloat(total) / CGFloat(weekResults.count)
            }
            
            chartData.append(ChartDataPoint(label: "W\(4-i)", value: averageScore))
        }
        
        return chartData
    }
    
    private func getYearlyChartData(from results: [StoredPerformanceResult]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        
        var chartData: [ChartDataPoint] = []
        
        // Create data for last 12 months
        for i in stride(from: 11, through: 0, by: -1) {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: today) else { continue }
            let monthResults = results.filter { result in
                calendar.isDate(result.date, equalTo: monthDate, toGranularity: .month)
            }
            
            let averageScore: CGFloat
            if monthResults.isEmpty {
                averageScore = 0
            } else {
                let total = monthResults.reduce(0) { $0 + $1.metrics.overall }
                averageScore = CGFloat(total) / CGFloat(monthResults.count)
            }
            
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: monthDate) - 1]
            chartData.append(ChartDataPoint(label: String(monthName.prefix(1)), value: averageScore))
        }
        
        return chartData
    }
    
    // MARK: - Persistence
    private func loadResults() {
        guard let data = userDefaults.data(forKey: storageKey),
              let results = try? JSONDecoder().decode([StoredPerformanceResult].self, from: data) else {
            storedResults = []
            return
        }
        
        storedResults = results
        print("📱 Loaded \(results.count) stored performance results")
    }
    
    private func persistResults() {
        do {
            let data = try JSONEncoder().encode(storedResults)
            userDefaults.set(data, forKey: storageKey)
            print("💾 Persisted \(storedResults.count) performance results")
        } catch {
            print("❌ Failed to persist results: \(error)")
        }
    }
    
    // MARK: - Cleanup
    func clearOldResults() {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        
        let originalCount = storedResults.count
        storedResults.removeAll { $0.date < cutoffDate }
        
        if storedResults.count != originalCount {
            persistResults()
            print("🗑️ Cleaned up \(originalCount - storedResults.count) old results")
        }
    }
}

// MARK: - Supporting Types
enum TimePeriod: String, CaseIterable {
    case week = "Daily"
    case month = "Weekly"
    case year = "Monthly"
}

struct ChartDataPoint {
    let label: String
    let value: CGFloat
}

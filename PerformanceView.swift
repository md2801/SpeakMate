//  Latest done on 11/06/2025

import SwiftUI

struct PerformanceView: View {
    let chartData: [CGFloat] = [65, 55, 65, 75, 80]
    let days = ["W", "T", "F", "S", "S"]
    @State private var selectedPeriod = "Daily"
    @State private var showDropdown = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
           // headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    dropdownSection
                    chartSection
                    aussieWordsSection
                    feedbackSection
                    suggestionsSection
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
    }

    
    private var dropdownSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDropdown.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedPeriod)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if showDropdown {
                dropdownMenu
            }
        }
    }
    
    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(["Daily", "Weekly", "Monthly"], id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDropdown = false
                    }
                }) {
                    HStack {
                        Text(period)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedPeriod == period ? .blue : .primary)
                        Spacer()
                        if selectedPeriod == period {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                .background(
                    selectedPeriod == period ?
                    Color.blue.opacity(0.1) : Color.clear
                )
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            PerformanceChartView(data: chartData, days: days)
            
            HStack {
                Text("Your average score of the week is ")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                + Text("78%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding(20)
        .background(Color.blue.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private var aussieWordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aussie word suggestions")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            PerformanceAussieWordsCard()
                .padding(.horizontal, 20)
        }
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feedback")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            PerformanceFeedbackCard(
                text: "Your speech was confident and clear, but you could make it more natural by using common Aussie slang. For example, instead of saying \"I'm very tired,\" you could say \"I'm knackered.\" Swapping in local expressions like \"no worries\" or \"arvo\" can help you sound more like a native speaker and connect better with your audience."
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggestions")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            PerformanceSuggestionCard(
                suggestions: [
                    "Getting straight to the point shows confidence and makes it easier for others to follow.",
                    "Be mindful of your tone. Aim for a relaxed, friendly vibe like you're having a yarn with a mate."
                ]
            )
            .padding(.horizontal, 20)
        }
    }
}

struct PerformanceChartView: View {
    let data: [CGFloat]
    let days: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                let chartPadding: CGFloat = 20
                let yAxisSpace: CGFloat = 50
                let chartWidth = geometry.size.width - yAxisSpace - (chartPadding * 2)
                let chartHeight = geometry.size.height
                let stepX = chartWidth / CGFloat(data.count - 1)
                let chartStartX: CGFloat = yAxisSpace + chartPadding
                
                ZStack {
                    gridLines(geometry: geometry, chartHeight: chartHeight, yAxisSpace: yAxisSpace)
                    yAxisLabels(chartHeight: chartHeight)
                    chartLine(chartHeight: chartHeight, chartStartX: chartStartX, stepX: stepX)
                    dataPoints(chartHeight: chartHeight, chartStartX: chartStartX, stepX: stepX)
                }
            }
            .frame(height: 180)
            
            xAxisLabels
        }
    }
    
    private func gridLines(geometry: GeometryProxy, chartHeight: CGFloat, yAxisSpace: CGFloat) -> some View {
        ForEach([0, 20, 40, 60, 80, 100], id: \.self) { value in
            Path { path in
                let y = chartHeight - (CGFloat(value) / 100 * chartHeight)
                path.move(to: CGPoint(x: yAxisSpace, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
            .stroke(Color.blue.opacity(0.35), style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
        }
    }
    
    private func yAxisLabels(chartHeight: CGFloat) -> some View {
        VStack {
            ForEach([100, 80, 60, 40, 20, 0], id: \.self) { value in
                HStack {
                    Text("\(value)%")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.blue.opacity(0.7))
                    Spacer()
                }
                if value != 0 {
                    Spacer()
                }
            }
        }
    }
    
    private func chartLine(chartHeight: CGFloat, chartStartX: CGFloat, stepX: CGFloat) -> some View {
        Path { path in
            for (index, value) in data.enumerated() {
                let x = chartStartX + CGFloat(index) * stepX
                let y = chartHeight - (value / 100 * chartHeight)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(Color.blue, lineWidth: 2)
    }
    
    private func dataPoints(chartHeight: CGFloat, chartStartX: CGFloat, stepX: CGFloat) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, value in
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .position(
                    x: chartStartX + CGFloat(index) * stepX,
                    y: chartHeight - (value / 100 * chartHeight)
                )
        }
    }
    
    private var xAxisLabels: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 70)
            HStack(alignment: .center) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.blue.opacity(0.7))
                    if index < days.count - 1 {
                        Spacer()
                    }
                }
            }
            Spacer().frame(width: 20)
        }
        .frame(height: 20)
    }
}

struct PerformanceAussieWordsCard: View {
    let suggestions = [
        ("I'm feeling tired", "I'm knackered"),
        ("Avocado", "Avo"),
        ("Service / Petrol station", "Servo"),
        ("How are you?", "Scarnon")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            headerRow
            suggestionsList
        }
        .background(Color.blue.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
        )
    }
    
    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Instead of")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .trailing) {
                Text("You can use")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var suggestionsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                HStack {
                    Text(suggestion.0)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(suggestion.1)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                
                if index < suggestions.count - 1 {
                    Divider()
                        .background(Color.blue.opacity(0.2))
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct PerformanceFeedbackCard: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(Color.blue.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
        )
    }
}

struct PerformanceSuggestionCard: View {
    let suggestions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                Text(suggestion)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                
                if index < suggestions.count - 1 {
                    Divider()
                        .background(Color.blue.opacity(0.2))
                }
            }
        }
        .padding(20)
        .background(Color.blue.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
        )
    }
}

#Preview {
    PerformanceView()
}


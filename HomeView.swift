// Latest done on 11/06/2025

import SwiftUI

struct AussieWord {
    let word: String
    let pronunciation: String
    let meaning: String
}

struct WordManager {
    static let allWords: [AussieWord] = [
        AussieWord(word: "Arvo", pronunciation: "ah-vough", meaning: "Afternoon"),
        AussieWord(word: "Servo", pronunciation: "ser-vo", meaning: "Petrol station"),
        AussieWord(word: "Maccas", pronunciation: "mack-uhs", meaning: "McDonald's"),
        AussieWord(word: "Brekky", pronunciation: "brek-ee", meaning: "Breakfast"),
        AussieWord(word: "Thongs", pronunciation: "th-awngs", meaning: "Flip flops"),
        AussieWord(word: "Heaps", pronunciation: "heeps", meaning: "A lot"),
        AussieWord(word: "No worries", pronunciation: "noh wuh-reez", meaning: "It's all good"),
        AussieWord(word: "Sickie", pronunciation: "sick-ee", meaning: "A day off work (faked or not)"),
        AussieWord(word: "Snag", pronunciation: "snag", meaning: "Sausage"),
        AussieWord(word: "Ripper", pronunciation: "rip-uh", meaning: "Really great"),
        AussieWord(word: "Avo", pronunciation: "av-oh", meaning: "Avocado"),
        AussieWord(word: "Esky", pronunciation: "ess-kee", meaning: "Cooler box"),
        AussieWord(word: "Bogan", pronunciation: "boh-gan", meaning: "An uncultured person"),
        AussieWord(word: "Trackies", pronunciation: "trak-ees", meaning: "Tracksuit pants"),
        AussieWord(word: "Bottle-o", pronunciation: "bot-ul-oh", meaning: "Liquor store"),
        AussieWord(word: "Mozzie", pronunciation: "moz-ee", meaning: "Mosquito"),
        AussieWord(word: "Chook", pronunciation: "chook", meaning: "Chicken"),
        AussieWord(word: "Lollies", pronunciation: "lol-eez", meaning: "Sweets or candy"),
        AussieWord(word: "Dunny", pronunciation: "dun-ee", meaning: "Toilet"),
        AussieWord(word: "Fair dinkum", pronunciation: "fair din-kum", meaning: "Genuine or real"),
        AussieWord(word: "Stubby", pronunciation: "stub-ee", meaning: "A bottle of beer"),
        AussieWord(word: "Sunnies", pronunciation: "sun-ees", meaning: "Sunglasses"),
        AussieWord(word: "Togs", pronunciation: "togs", meaning: "Swimsuit"),
        AussieWord(word: "Ute", pronunciation: "yoot", meaning: "Utility vehicle"),
        AussieWord(word: "Relo", pronunciation: "rel-oh", meaning: "Relative"),
        AussieWord(word: "Crook", pronunciation: "crook", meaning: "Sick or unwell"),
        AussieWord(word: "Bail", pronunciation: "bayl", meaning: "To leave suddenly"),
        AussieWord(word: "Chunder", pronunciation: "chun-der", meaning: "To vomit"),
        AussieWord(word: "G'day", pronunciation: "guh-day", meaning: "Hello"),
        AussieWord(word: "Sheila", pronunciation: "shee-lah", meaning: "Woman"),
        AussieWord(word: "Bloke", pronunciation: "blohk", meaning: "Man"),
        AussieWord(word: "Footy", pronunciation: "foot-ee", meaning: "Football"),
        AussieWord(word: "Pash", pronunciation: "pash", meaning: "Kiss"),
        AussieWord(word: "Bikkie", pronunciation: "bik-ee", meaning: "Biscuit or cookie"),
        AussieWord(word: "Yarn", pronunciation: "yarn", meaning: "Chat or story"),
        AussieWord(word: "Rapt", pronunciation: "rapt", meaning: "Very pleased"),
        AussieWord(word: "Sook", pronunciation: "sook", meaning: "Someone who whines or complains"),
        AussieWord(word: "Drongo", pronunciation: "dron-go", meaning: "Fool"),
        AussieWord(word: "Spit the dummy", pronunciation: "spit thuh dum-ee", meaning: "Throw a tantrum"),
        AussieWord(word: "Cuppa", pronunciation: "cup-ah", meaning: "Cup of tea"),
        AussieWord(word: "Larrikin", pronunciation: "lar-ih-kin", meaning: "Mischievous person"),
        AussieWord(word: "Hard yakka", pronunciation: "hard yak-ah", meaning: "Hard work"),
        AussieWord(word: "Chuck a sickie", pronunciation: "chuk uh sick-ee", meaning: "Pretend to be sick to get off work"),
        AussieWord(word: "Flat out", pronunciation: "flat owt", meaning: "Very busy"),
        AussieWord(word: "Have a go", pronunciation: "hav uh goh", meaning: "Try something"),
        AussieWord(word: "Bloody oath", pronunciation: "bluh-dee ohth", meaning: "Absolutely!"),
        AussieWord(word: "Good on ya", pronunciation: "good on yah", meaning: "Well done"),
        AussieWord(word: "Ta", pronunciation: "tah", meaning: "Thank you"),
        AussieWord(word: "Straya", pronunciation: "stray-ah", meaning: "Australia"),
        AussieWord(word: "Mate", pronunciation: "mayt", meaning: "Friend")
    ]

    static func randomWords(count: Int = 1) -> [AussieWord] {
        return Array(allWords.shuffled().prefix(count))
    }
}

struct HomeView: View {
    @StateObject private var resultsStorage = ResultsStorageManager()
    @State private var selectedPeriod: TimePeriod = .week
    @State private var navigate = false
    @State private var isButtonDisabled = UserDefaults.standard.bool(forKey: "hasVisitedSecondPage")
    @Binding var showGradient: Bool
    
    private var chartData: [ChartDataPoint] {
        resultsStorage.getScoresForChart(period: selectedPeriod)
    }
    
    private var averageScore: Int {
        Int(resultsStorage.getAverageScore(for: selectedPeriod))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.horizontal, 20)
            }
            
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Button {
                            showGradient = true
                        } label: {
                            Text("Try Today's Prompt")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 40) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Daily Performance Report")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ChartView(
                                    data: chartData.map { $0.value },
                                    days: chartData.map { $0.label },
                                    period: selectedPeriod,
                                    onPeriodChange: { period in
                                        selectedPeriod = period
                                    }
                                )
                                
                                HStack {
                                    Text("Your average score of the \(selectedPeriod.rawValue.lowercased()) is ")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.primary)
                                    + Text("\(averageScore)%")
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
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Aussie Word of the Day")
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            AussieWordsCard()
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            resultsStorage.clearOldResults()
        }
    }
}

struct ChartView: View {
    let data: [CGFloat]
    let days: [String]
    let period: TimePeriod
    let onPeriodChange: (TimePeriod) -> Void
    
    @State private var showDropdown = false
    
    var body: some View {
        NavigationLink(destination: PerformanceView()) {
            VStack(spacing: 16) {
                dropdownSection
                chartSection
                xAxisLabels
            }
        }
    }
    
    private var dropdownSection: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDropdown.toggle()
                }
            }) {
                HStack {
                    Text(period.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            if showDropdown {
                dropdownMenu
            }
        }
    }
    
    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { timePeriod in
                Button(action: {
                    onPeriodChange(timePeriod)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDropdown = false
                    }
                }) {
                    HStack {
                        Text(timePeriod.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(period == timePeriod ? .blue : .primary)
                        Spacer()
                        if period == timePeriod {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var chartSection: some View {
        GeometryReader { geometry in
            let chartPadding: CGFloat = 20
            let yAxisSpace: CGFloat = 50
            let chartWidth = geometry.size.width - yAxisSpace - (chartPadding * 2)
            let chartHeight = geometry.size.height
            let stepX = data.count > 1 ? chartWidth / CGFloat(data.count - 1) : 0
            let chartStartX: CGFloat = yAxisSpace + chartPadding
            
            ZStack {
                gridLines(geometry: geometry, chartHeight: chartHeight, yAxisSpace: yAxisSpace)
                yAxisLabels
                chartLine(chartHeight: chartHeight, chartStartX: chartStartX, stepX: stepX)
                dataPoints(chartHeight: chartHeight, chartStartX: chartStartX, stepX: stepX)
            }
        }
        .frame(height: 180)
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
    
    private var yAxisLabels: some View {
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
    
    @ViewBuilder
    private func chartLine(chartHeight: CGFloat, chartStartX: CGFloat, stepX: CGFloat) -> some View {
        if !data.isEmpty && data.count > 1 {
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
            Spacer().frame(width: 50 + 20)
            if !days.isEmpty {
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
            }
            Spacer().frame(width: 20)
        }
        .frame(height: 20)
    }
}

struct AussieWordsCard: View {
    let randomWords: [AussieWord] = WordManager.randomWords()
    
    var body: some View {
        VStack {
            ForEach(randomWords, id: \.word) { word in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(word.word)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text(word.pronunciation)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.blue)
                            .opacity(0.6)
                    }
                    .padding(.bottom, 10)
                    
                    Text("Meaning")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(word.meaning)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 20)
            }
            .background(Color.blue.opacity(0.03))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.9), lineWidth: 1)
            )
        }
    }
}

#Preview {
    HomeView(showGradient: .constant(true))
}

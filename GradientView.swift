// Latest done on 11/06/2025

import SwiftUI
import AVFAudio

struct GradientView: View {
    @State private var t: Float = 0.0
    @State private var meshTimer: Timer?
    @Binding var navigateToDailyScore: Bool
    @Binding var showGradient: Bool
    @State private var isGeneratingResults = false
    @State private var countdown = 5 // 10 sec
    @State private var recordingTime = 60 // 60sec
    @State private var isRecording = false
    @State private var recordingTimer: Timer?
    @State private var showGenerating = false
    @State private var circleScale: CGFloat = 1.0
    @State private var currentPrompt: String = PromptManager.randomPrompt()
    
    // audio recorder
    @State private var recordingTimeLeft = 60 // 60
    @State private var showFinalCountdown = false
    @State private var navigateToAnalysis = false
    @State private var permissionChecked = false
    @State private var permissionGranted: Bool = false

    // API Integration + Results Storage
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var deepgramService = DeepgramService()
    @StateObject private var resultsStorage = ResultsStorageManager()
    @State private var performanceAnalyser = PerformanceAnalyser()
    @State private var currentMetrics: PerformanceMetrics?
    @State private var currentFeedback: FeedbackResult?
    @State private var processingError: String?
    @State private var showRetryButton = false

    struct PromptManager {
        static let prompts: [String] = [
            "What's your favourite Aussie snack?",
            "Beach days or bush walks — which one's your vibe?",
            "What Aussie slang have you learnt?",
            "What surprised you most about Australia?",
            "What's your weekend routine like here?",
            "What do you love about Aussie life?",
            "What's a funny or awkward moment you've had here?",
            "What's one habit you picked up in Australia?",
            "What if a kangaroo knocked on your door?",
            "BBQ with koalas or surfing with dolphins?",
            "If Vegemite vanished forever, how would Aussies react?",
            "Would you rather ride a giant wombat or fly with cockatoos?",
            "What would your Aussie life movie be called?",
            "What's one Aussie word you still don't get?",
            "What would you cook on your first Aussie BBQ?",
            "What Aussie phrase do you hear all the time?",
            "How would you explain 'Straya' to your family?",
            "If you opened a cafe in Australia, what would you serve?",
            "Would you rather live in the Outback or by the beach?",
            "If you made a new Aussie slang word, what would it be?",
            "What has been your biggest learning experience since coming to Australia?",
            "How has your daily routine changed since moving here?",
            "Describe your first impression of Australia and how it compares to your view now.",
            "What are some cultural differences that surprised you the most?",
            "How has living in Australia influenced your personality or habits?",
            "Share a story about a time you felt truly welcomed in Australia.",
            "What challenges did you face when trying to make local friends, and how did you overcome them?",
            "How do you handle homesickness while living in Australia?",
            "What does a perfect weekend in Australia look like for you?",
            "Describe your experience using public transport in Australia compared to your home country.",
            "If you could create your own Aussie-themed festival, what would it be like?",
            "What are some unwritten social rules in Australia you've noticed?",
            "Describe your favourite place in Australia and what makes it special.",
            "How do you think Australia has shaped your view of the world?",
            "What's the most unusual or unexpected thing you've seen or done here?",
            "What's something you've done in Australia that you never thought you'd try?",
            "If your life in Australia was turned into a documentary, what would it be called and why?",
            "Talk about a time you had to adapt quickly in a new or unfamiliar Australian setting.",
            "How do you think Australia supports newcomers or international residents?",
            "What role does nature or the outdoors play in your Aussie life?",
            "How would you describe your journey of understanding Aussie humour?",
            "Share a memory that made you feel like you really belonged in Australia.",
            "How has your taste in food changed since you moved here?",
            "If you were to recommend three things every newcomer should do in Australia, what would they be?",
            "How do people celebrate different seasons or holidays differently here compared to your country?",
            "What's the most Aussie thing you've ever done, and how did it go?",
            "How would you explain your experience of Aussie work or study culture to someone back home?",
            "What have you learnt from Australians about work-life balance or lifestyle?",
            "How would you describe the Australian way of life to someone who has never been here?",
            "If you could go back in time and give your past self advice before arriving in Australia, what would you say?"
        ]
        
        static func randomPrompt() -> String {
            return prompts.randomElement() ?? "What's your Aussie experience like?"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                MeshGradient(width: 3, height: 3, points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    [sinInRange(-0.8...(-0.2), offset: 0.439, timeScale: 0.342, t: t), sinInRange(0.3...0.7, offset: 3.42, timeScale: 0.984, t: t)],
                    [sinInRange(0.1...0.8, offset: 0.239, timeScale: 0.084, t: t), sinInRange(0.2...0.8, offset: 5.21, timeScale: 0.242, t: t)],
                    [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.084, t: t), sinInRange(0.4...0.8, offset: 0.25, timeScale: 0.642, t: t)],
                    [sinInRange(-0.8...0.0, offset: 1.439, timeScale: 0.442, t: t), sinInRange(1.4...1.9, offset: 3.42, timeScale: 0.984, t: t)],
                    [sinInRange(0.3...0.6, offset: 0.339, timeScale: 0.784, t: t), sinInRange(1.0...1.2, offset: 1.22, timeScale: 0.772, t: t)],
                    [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.056, t: t), sinInRange(1.3...1.7, offset: 0.47, timeScale: 0.342, t: t)]
                ],  colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),   // navy blue
                    Color(red: 0.0, green: 0.2, blue: 0.5),   // deep ocean blue
                    .blue,
                    .blue.opacity(0.7),
                    Color(red: 0.0, green: 0.4, blue: 0.7),   // steel blue
                    Color(red: 0.2, green: 0.6, blue: 0.9),   // sky blue
                    .teal.opacity(0.7),                      // optional depth
                    Color.blue.opacity(0.6)                  // muted blue for flow
                ])
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    if !showGenerating {
                        Text(currentPrompt)
                            .foregroundColor(.white)
                            .font(.custom("SF Pro", size: 24))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                        
                        if !isRecording {
                            VStack(spacing: 10) {
                                Text("Recording starts in...")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                
                                ZStack {
                                    let maxSize: CGFloat = 50
                                    let minSize: CGFloat = 25      // starting size
                                    let progress = CGFloat(10 - countdown) / 10
                                    let whiteSize = minSize + (maxSize - minSize) * progress
                                    
                                    // Grey background
                                    Circle()
                                        .fill(Color.white.opacity(0.17))
                                        .frame(width: maxSize, height: maxSize)
                                    
                                    // Growing white circle
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: whiteSize, height: whiteSize)
                                        .animation(.easeInOut(duration: 0.5), value: countdown)
                                    
                                    // Countdown text — only show when white circle is smaller than 90% of full size
                                    if countdown >= 0 {
                                        Text("\(countdown)")
                                            .foregroundColor(.black)
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                }
                            }
                            
                        } else {
                            
                            Text("Recording in progress...")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            ZStack {
                                let circleSize: CGFloat = 50
                                
                                // ⚪️ Solid white background circle (like donut base)
                                Circle()
                                    .fill(Color.white.opacity(0.17))
                                    .frame(width: circleSize, height: circleSize)
                                
                                // ⭕️ Progress ring
                                Circle()
                                    .trim(from: 0, to: CGFloat(60 - recordingTime) / 60)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: circleSize+5, height: circleSize+5)
                                    .animation(.easeInOut(duration: 1), value: recordingTime)
                                
                                // ⏱ Countdown text
                                Text("\(recordingTime)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                    }
                    
                    if showGenerating {
                        VStack(spacing: 16) {
                            if deepgramService.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(2.0)
                                
                                Text("Analysing your speech...")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                            } else if let error = processingError {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                    
                                    Text("Analysis Failed")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Text(error)
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 14))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    if showRetryButton {
                                        Button(action: retryAnalysis) {
                                            Text("Try Again")
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                        }
                                        .padding(.horizontal, 40)
                                        .padding(.top, 8)
                                    }
                                }
                            } else {
                                // Success state - brief moment before navigation
                                VStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.green)
                                    
                                    Text("Analysis Complete!")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                }
                            }
                        }
                    }
                }
            }
            
            .navigationDestination(isPresented: $navigateToDailyScore) {
                DailyScoreView(
                    metrics: currentMetrics,
                    feedback: currentFeedback
                )
            }
        }
        .onAppear {
            meshTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                t += 0.02
            }

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if countdown > 0 {
                    countdown -= 1
                    withAnimation {
                        circleScale = 1.0 + CGFloat((10 - countdown)) * 0.02
                    }
                } else {
                    timer.invalidate()
                    startRecording()
                }
            }
       }
    }
    
    func requestMicrophoneAccess() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.permissionChecked = granted
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.permissionChecked = granted
                }
            }
        }
    }
    
    func startRecording() {
        isRecording = true
        audioRecorder.startRecording()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if recordingTime > 0 {
                recordingTime -= 1
                recordingTimeLeft -= 1
            }
            
            if recordingTimeLeft == 0 {
                timer.invalidate()
                stopRecording()
            }
        }
    }
        
    func stopRecording() {
        isRecording = false
        audioRecorder.stopRecording()
        showGenerating = true
        
        // Process the recording with Deepgram API
        Task {
            await processRecording()
        }
    }
        
    @MainActor
    func processRecording() async {
        guard let recordingURL = audioRecorder.getLatestRecording() else {
            processingError = "No recording found"
            showRetryButton = true
            return
        }
        
        do {
            // Step 1: Transcribe audio with Deepgram
            print("🎯 Starting Deepgram API call...")
            let deepgramResponse = try await deepgramService.transcribeAudio(from: recordingURL)
            
            // Step 2: Calculate performance metrics
            print("🎯 Calculating performance metrics...")
            let metrics = performanceAnalyser.analyse(deepgramResponse: deepgramResponse)
            print("🎯 Metrics calculated - Overall: \(metrics.overall)%")
            
            // Step 3: Generate feedback
            print("🎯 Generating feedback...")
            let feedback = performanceAnalyser.generateFeedback(from: metrics)
            
            // Step 4: Set state variables
            print("🎯 Setting currentMetrics and currentFeedback...")
            currentMetrics = metrics
            currentFeedback = feedback
            
            // Step 5: Save results locally
            resultsStorage.saveResult(
                prompt: currentPrompt,
                metrics: metrics,
                feedback: feedback,
                audioFileName: recordingURL.lastPathComponent
            )
            
            // Step 6: Verify metrics are set before navigation
            print("🎯 About to navigate with metrics: \(currentMetrics?.overall ?? -1)")
            
            // Navigate immediately after confirming metrics are set
            navigateToDailyScore = true
            showGradient = false
            
        } catch {
            print("🎯 Error in processRecording: \(error)")
            processingError = error.localizedDescription
            showRetryButton = true
            
            // Auto-retry network errors after 3 seconds
            if let deepgramError = error as? DeepgramError,
               case .networkError = deepgramError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    showRetryButton = true
                }
            }
        }
    }
    
    func retryAnalysis() {
        processingError = nil
        showRetryButton = false
        
        Task {
            await processRecording()
        }
    }
}

func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
    let amplitude = (range.upperBound - range.lowerBound) / 2
    let midPoint = (range.upperBound + range.lowerBound) / 2
    return midPoint + amplitude * sin(timeScale * t + offset)
}

#Preview {
    GradientView(navigateToDailyScore: .constant(true), showGradient: .constant(true))
}


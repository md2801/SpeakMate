//  Latest done on 11/06/2025

import SwiftUI
import AVFoundation

struct AudioRecordingView: View {
    @State private var countdown = 10
    @State private var isRecording = false
    @State private var recordingTimeLeft = 60
    @State private var showFinalCountdown = false
    @State private var navigateToAnalysis = false
    @State private var permissionChecked = false
    @State private var permissionGranted: Bool = false
    @StateObject private var audioRecorder = AudioRecorder()
    
    func requestRecordPermission() {
        //        AVAudioApplication.requestRecordPermission { granted in
        //            permissionChecked = true
        //            if granted {
        //                permissionGranted = true
        //            } else {
        //                permissionGranted = true
        //            }
        //        }
    }
    
    
    
    var body: some View {
        VStack {
            Text(audioRecorder.isRecording ? "Recording" : "Not Recording")
            
            HStack {
                Button {
                    startRecording()
                } label: {
                    Text("Start")
                }
                
                Button {
                    stopRecording()
                } label: {
                    Text("Stop")
                }
            }
            Button {
                audioRecorder.listFilesInDocumentsFolder()
            } label: {
                Text("Show me the files!")
            }
        }
        
        NavigationStack {
            VStack(spacing: 20) {
                if !permissionChecked {
                    Text("Checking microphone permission...")
                } else if !isRecording && countdown > 0 {
                    Text("Recording starts in \(countdown) seconds")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                } else if isRecording {
                    if showFinalCountdown {
                        Text("Recording ends in \(recordingTimeLeft) seconds")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    } else {
                        Text("Recording...")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                } else if recordingTimeLeft == 0 {
                    Text("Recording complete!")
                        .font(.title)
                }
            }
            .onAppear {
                requestMicrophoneAccess()
            }
            .task(id: permissionChecked) {
                if permissionGranted {
                    startCountdownToRecord()
                }
            }
            .navigationDestination(isPresented: $navigateToAnalysis) {
                RecordingsListView()
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
    
    func startCountdownToRecord() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown == 0 {
                timer.invalidate()
                startRecording()
            }
        }
    }
    
    func startRecording() {
        isRecording = true
        audioRecorder.startRecording()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            recordingTimeLeft -= 1
            if recordingTimeLeft <= 10 {
                showFinalCountdown = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigateToAnalysis = true
        }
    }
}

#Preview {
    AudioRecordingView()
}

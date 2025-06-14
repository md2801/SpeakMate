// Latest done on 11/06/2025

import SwiftUI

struct ContentView: View {
    
    @State var showGradient: Bool = false
    @State var navigateToDailyScore: Bool = false
    
    var body: some View {
        if showGradient {
            GradientView(navigateToDailyScore: $navigateToDailyScore, showGradient: $showGradient)
        } else {
            TabView {
                NavigationStack {
                    HomeView(showGradient: $showGradient)
                        .navigationDestination(isPresented: $navigateToDailyScore) {
                            DailyScoreView(metrics: nil, feedback: nil)
                        }
                }
                    .tabItem {
                        Label("Home",
                              systemImage: "house")
                    }
                
                RecordingsView()
                    .tabItem {
                        Label("Recordings",
                              systemImage: "waveform")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings",
                              systemImage: "gear")
                    }
                
            }
        }
    }
}

#Preview {
    ContentView()
}

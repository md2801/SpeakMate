//  Latest done on 11/06/2025

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Box 2: Emily Profile Box
                HStack (spacing:16){
                    Image("ProfileImage") // Replace with actual image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    
                    Text("Emily")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background((Color.blue.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                        )
                )
     
                
                // Box 3: Recording Timer and Notifications
                VStack(spacing: 16) {
                    SettingsRow(icon: "timer", title: "Recording Timer")
                    Divider().background(Color.blue.opacity(0.2))
                    NavigationLink(destination: NotificationsView()) {
                            SettingsRow(icon: "bell", title: "Notifications")
                        }
                    }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)  // Apply padding to the entire VStack
                .frame(maxWidth: .infinity)  // Ensure it stretches
                .background((Color.blue.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                        )
                )
     


                    
                    // Box 4: Privacy Policy and Help
                    VStack(spacing: 16) {
                        SettingsRow(icon: "lock", title: "Privacy Policy")
                        Divider().background(Color.blue.opacity(0.3))
                        SettingsRow(icon: "info.circle", title: "Help")
                    }
                    .padding(.vertical,16)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background((Color.blue.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                            )
                    )
   
                    
                    Spacer()
                }
            .padding(24)
            .navigationTitle("Settings")
            }
        
        }
    }
        
        // Reusable Settings Row
        struct SettingsRow: View {
            let icon: String
            let title: String
            var action: (() -> Void )?=nil
            
            var body: some View {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    if let action = action {
                        Button(action: action) {
                            Text(title)
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 16/255, green: 134/255, blue: 212/255))
                        }
                        .padding(16)
                    } else {
                        Text(title)
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.blue)
               
//
                    }
                    Spacer()
                }
            }
        }

        #Preview {
            SettingsView()
        }

//  Latest done on 11/06/2025

import SwiftUI

struct NotificationsView: View {
    @AppStorage("allowNotifications") private var allowNotifications = true
    @AppStorage("reminders") private var reminders = true
    @AppStorage("selectedTime") private var selectedTime = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            
            // Box with toggles and time
            VStack(spacing: 0) {
                
                // Allow notifications row
                HStack {
                    Text("Allow all notifications")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    Toggle("", isOn: $allowNotifications)
                        .labelsHidden()
                        .tint(Color.blue) // Custom toggle tint
                }
                .padding()
                
                Divider().background(Color.blue.opacity(0.2))
                
                // Reminders row
                HStack {
                    Text("Reminders Notifications")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    Toggle("", isOn: $reminders)
                        .labelsHidden()
                        .tint(Color.blue) // Custom toggle tint
                }
                .padding()
                
                Divider()
                
                // Time row
                if reminders {
                    HStack {
                        Text("Time")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.blue)
                
                        Spacer()
                        Text(selectedTime, style: .time)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    // DatePicker (Inline mode)
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background((Color.blue.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                    )
            )
            
            .padding(.vertical, 43)
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

#Preview {
    NotificationsView()
}

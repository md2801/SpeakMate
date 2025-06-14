//  Latest done on 11/06/2025

import Foundation

func dateFrom(_ str: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone.current
    return formatter.date(from: str) ?? Date()
}

func formatted(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: date)
}

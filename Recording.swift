//  Latest done on 12/06/2025

import Foundation

struct Recording: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let fileURL: URL
    let storedResult: StoredPerformanceResult?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Recording, rhs: Recording) -> Bool {
        lhs.id == rhs.id
    }
}

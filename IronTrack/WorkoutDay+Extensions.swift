import Foundation

extension WorkoutDay {
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self.date ?? Date())
    }
}

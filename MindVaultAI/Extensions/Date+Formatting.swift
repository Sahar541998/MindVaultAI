import Foundation

extension Date {
    var relativeFormatted: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Today, " + formatted(date: .omitted, time: .shortened)
        }

        if calendar.isDateInYesterday(self) {
            return "Yesterday, " + formatted(date: .omitted, time: .shortened)
        }

        let daysAgo = calendar.dateComponents([.day], from: self, to: now).day ?? 0

        if daysAgo < 7 {
            let weekday = formatted(.dateTime.weekday(.abbreviated))
            return weekday + ", " + formatted(date: .omitted, time: .shortened)
        }

        if daysAgo < 14 {
            return "Last week"
        }

        return formatted(date: .abbreviated, time: .omitted)
    }
}

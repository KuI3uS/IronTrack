//
//  WeekCalendarView.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 15/04/2025.
//

import SwiftUI
import CoreData

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        let calendar = Calendar.current
        let today = Date()
        let week = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }

        HStack(spacing: 10) {
            ForEach(week, id: \.self) { day in
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)

                Button(action: {
                    selectedDate = day
                    openOrCreateWorkoutDay(for: day)
                }) {
                    VStack {
                        Text(day.formatted(.dateTime.weekday().locale(Locale(identifier: "pl_PL"))).prefix(3))
                            .font(.caption2)
                            .foregroundColor(.gray)

                        Text(day.formatted(.dateTime.day()))
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(8)
                            .background(isSelected ? Color.accentColor : Color.clear)
                            .clipShape(Circle())
                    }
                    .frame(minWidth: 40)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private func openOrCreateWorkoutDay(for date: Date) {
        let fetchRequest: NSFetchRequest<WorkoutDay> = WorkoutDay.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
            Calendar.current.startOfDay(for: date) as NSDate,
            Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))! as NSDate
        )

        if let existingDay = try? viewContext.fetch(fetchRequest).first {
            // Istnieje — nic nie rób, tylko przypisz datę
            print("WorkoutDay already exists: \(existingDay.name ?? "brak")")
        } else {
            let newDay = WorkoutDay(context: viewContext)
            newDay.date = date
            newDay.name = dayOfWeek(from: date)
            try? viewContext.save()
        }
    }

    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }
}

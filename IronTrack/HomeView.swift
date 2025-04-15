import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutDay.date, ascending: true)],
        animation: .default
    )
    private var allWorkoutDays: FetchedResults<WorkoutDay>

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Twój tydzień")
                    .font(.title2)
                    .padding(.leading)

                WeekCalendarView(selectedDate: $selectedDate)

                List {
                    ForEach(filteredWorkoutDays()) { day in
                        NavigationLink(destination: WorkoutDayDetailView(workoutDay: day)) {
                            VStack(alignment: .leading) {
                                Text(day.name ?? "Bez nazwy")
                                    .font(.headline)
                                if let date = day.date {
                                    Text(date.formatted(.dateTime.day().month().year()))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkoutDay)
                }
            }
            .navigationTitle("IronTrack")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: addWorkoutDay) {
                        Label("Dodaj dzień", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func filteredWorkoutDays() -> [WorkoutDay] {
        allWorkoutDays.filter { day in
            if let date = day.date {
                return Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
            return false
        }
    }

    private func addWorkoutDay() {
        let today = selectedDate

        let alreadyExists = allWorkoutDays.contains { day in
            guard let date = day.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }

        guard !alreadyExists else {
            print("WorkoutDay już istnieje dla wybranego dnia")
            return
        }

        let newDay = WorkoutDay(context: viewContext)
        newDay.date = today
        newDay.name = dayOfWeek(from: today)

        do {
            try viewContext.save()
            print("WorkoutDay zapisany: \(newDay.objectID)")
        } catch {
            print("Błąd zapisu WorkoutDay: \(error.localizedDescription)")
        }
    }

    private func deleteWorkoutDay(at offsets: IndexSet) {
        let days = filteredWorkoutDays()
        for index in offsets {
            viewContext.delete(days[index])
        }
        try? viewContext.save()
    }

    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }
}
